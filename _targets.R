## Load your packages, e.g. library(targets).
source("./packages.R")
source("./conflicts.R")

## Load your R files
tar_source()

# facilitate this working in parallel
controller <- crew_controller_local(
  name = "my_controller",
  workers = 4,
  seconds_idle = 3
)

tar_option_set(
  # Save a workspace file for a target that errors out
  workspace_on_error = TRUE
  # debug = "outer_loop_results_spatial", # Set the target you want to debug.
  # cue = tar_cue(mode = "never") # Force skip non-debugging outdated targets.
  # controller = controller
)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  # read in example infection resistance data
  tar_file(
    hancock_path,
    "data/ir-data-raw.csv.gz"
  ),
  hancock_raw = read_csv(hancock_path),

  # data is from https://datadryad.org/stash/dataset/doi:10.5061/dryad.dn4676s
  tar_file(
    moyes_pheno_path,
    "data/2_standard-WHO-susc-test_species.csv"
  ),
  moyes_pheno_raw = read_csv_clean(moyes_pheno_path),

  gambiae_complex_list = create_valid_gambiae(),
  moyes_pheno_prepared = prepare_pheno_data(
    moyes_pheno_raw,
    gambiae_complex_list
  ),

  tar_file(
    moyes_geno_path,
    "data/6_Vgsc-allele-freq_complex-subgroup.csv"
  ),
  moyes_geno_raw = read_csv_clean(moyes_geno_path),
  moyes_geno_no_na_long_lat = drop_na_long_lat_moyes(moyes_geno_raw),

  tar_target(
    africa_countries,
    create_africa_country_list()
  ),

  tar_terra_vect(
    africa_shapefile,
    cgaz_country(africa_countries$iso3c)
  ),

  moyes_geno_countries = extract_country(
    africa_df = moyes_geno_no_na_long_lat,
    shapefile = africa_shapefile
  ),
  moyes_geno_prepared = prepare_geno_data(
    moyes_geno_no_na_long_lat,
    moyes_geno_countries
  ),

  moyes_geno_pheno = combine_pheno_geno(
    moyes_pheno_prepared,
    moyes_geno_prepared
  ),

  theta_ihs_value = unique(moyes_geno_pheno$theta_ihs),

  # explicitly drop NA values
  ir_data = create_ir_data(moyes_geno_pheno),

  tar_quarto(q_explore, "doc/explore.qmd"),
  tar_quarto(q_checks, "doc/checks.qmd"),

  # Create a spatial dataset with linked ID so we can join this on later
  ir_data_sf_key = create_sf_id(ir_data),

  # specify how many years you want to predict out to (can be just one year)
  predict_year_range = 2014:2015,
  # setup analysis to work on a few countries
  subset_countries = c("Benin", "Nigeria"),
  ir_data_subset = filter(ir_data, country %in% subset_countries),
  ir_data_sf_key_subset = semi_join(
    ir_data_sf_key,
    ir_data_subset,
    by = "uid"
  ),

  subset_country_codes = countrycode(
    sourcevar = subset_countries,
    origin = "country.name",
    destination = "iso3c"
  ),
  # read everything but the mask path
  tar_target(
    map_covariate_paths,
    get_map_paths("data/map-covariates/")
  ),
  tar_terra_rast(
    raster_map_covariates,
    rast(map_covariate_paths)
  ),
  tar_terra_rast(
    raster_coffee,
    agcrop_area(crop = "acof")
  ),
  tar_terra_rast(
    raster_veg,
    agcrop_area(crop = "vege")
  ),
  # tar_terra_rast(
  #   raster_trees,
  #   get_landcover("trees")
  # ),
  ## Currently removing these as they don't subset to the right countries
  # tar_terra_rast(
  #   raster_countries_elevation,
  # get_elevation(subset_country_codes)
  # ),
  # tar_terra_rast(
  #   raster_countries_worldclimate,
  #   get_worldclim(subset_country_codes, var = "tmin")
  # ),
  # this step should make the rasters match extent etc
  tar_terra_rast(
    raster_spam,
    c(
      # raster_countries_trees,
      raster_veg,
      raster_coffee
    )
  ),
  tar_file(
    path_ir_mask,
    "data/map-covariates/ir_mask.tif"
  ),
  tar_terra_rast(
    reference_rast_africa,
    rast(path_ir_mask)
  ),
  tar_terra_vect(
    country_shapefile,
    cgaz_country(subset_country_codes)
  ),
  tar_terra_rast(
    reference_rast_countries,
    crop_raster_to_shapefile(
      raster = reference_rast_africa,
      shapefile = country_shapefile
    )
  ),
  tar_terra_rast(
    raster_countries_map,
    crop_raster_to_reference(
      raster = raster_map_covariates,
      reference = reference_rast_countries,
      data_type = "continuous",
      impute_value = 0
    )
  ),
  tar_terra_rast(
    raster_countries_spam,
    crop_raster_to_reference(
      raster = raster_spam,
      reference = reference_rast_countries,
      data_type = "continuous",
      impute_value = 0
    )
  ),
  tar_terra_rast(
    raster_covariates_countries,
    c(
      raster_countries_spam,
      raster_countries_map
    )
  ),

  spatial_covariate_lags = 0:3,

  all_spatial_covariates = join_rasters_to_mosquito_data(
    rasters = raster_covariates_countries,
    mosquito_data = ir_data_subset,
    lags = spatial_covariate_lags
  ),

  complete_spatial_covariates = identify_complete_vars(
    all_spatial_covariates
  ),

  # drop uid name and keep rest for use later
  spatial_covariate_names = get_covariate_names(complete_spatial_covariates),

  # dropping generation as it is missing too many values
  other_covariates = c("start_year",
                       "insecticide_id"),
  model_covariates = unique(c(other_covariates, spatial_covariate_names)),

  # specify the details for the different models ahead of time
  # hyperparameters are hard coded internally inside these functions
  ## NOTE RMSE is the default performance metric in tidymodels:
  ## https://tune.tidymodels.org/articles/getting_started.html
  model_xgb = build_ir_xgboost(tree_depth = 2, trees = 5),
  model_rf = build_ir_rf(mtry = 2, trees = 5),
  model_list = build_workflow_list(
    models = list(
      model_xgb,
      model_rf
    ),
    outcomes = "transformed_mortality",
    predictors = model_covariates
  ),
  inla_meshes = create_meshes(ir_data_subset),
  gp_inla_setup = setup_gp_inla_model(
    ir_data_subset,
    covariate_names = names(model_list),
    outcome = "transformed_mortality",
    meshes = inla_meshes
  ),
  ir_data_mn_oos_predictions = model_validation(
    covariate_rasters = raster_covariates_countries,
    training_data = ir_data_subset,
    level_zero_models = model_list,
    inla_setup = gp_inla_setup,
    lags = spatial_covariate_lags
  ),
  oos_diagnostics = diagnostics(ir_data_mn_oos_predictions),
  plot_diagnostics = gg_diagnostics(oos_diagnostics),

  # --- model deployment to rasters -----
  # Predictions are made to every pixel of map + year (spatiotemporal)
  # Year is currently fixed
  outer_loop_results_spatial = spatial_prediction(
    covariate_rasters = raster_covariates_countries,
    training_data = ir_data_subset,
    level_zero_models = model_list,
    inla_mesh_setup = gp_inla_setup,
    lags = spatial_covariate_lags,
    prediction_year_range = predict_year_range
  ),

  # ensure transformed_mortality gets transformed back to values we
  # can understsand, and not logit space
  # These are currently the same name, "transformed_mortality".
  # as this is the dependent variable used
  ir_data_subset_converted_mort = invert_pct_mortality(
    # ir_data = ir_data_subset,
    ir_data = outer_loop_results_spatial,
    theta = theta_ihs_value,
    outcome = .pred,
    use_infinite_sample = TRUE
  ),
  insecticide_id_lookup = create_insecticide_id_lookup(ir_data_subset),

  # We get out a set of out of sample predictions of length N
  # Which we can compare to the true data (y-hat vs y)

  # TODO
  # potentially loop across the insecticide ID
  # and then
  insecticide_names = str_subset(insecticide_id_lookup, "none", negate = TRUE),

  tar_terra_rast(
    pixel_maps_data,
    create_pixel_map_data(
      predictions = ir_data_subset_converted_mort,
      rasters = raster_covariates_countries,
      insecticide_lookup = insecticide_id_lookup,
      insecticide = insecticide_names
    ),
    pattern = map(insecticide_names)
  ),

  # Save the raster of the data
  tar_target(
    pixel_map_tif,
    write_insecticide_raster(
      pixel_maps_data,
      insecticide_names
    ),
    pattern = map(pixel_maps_data,insecticide_names)
  ),

  # Save the plots
  tar_target(
    plot_pixel_map,
    gg_pixel_map(pixel_maps_data),
    pattern = map(pixel_maps_data),
    iteration = "list"
  ),

  tar_target(
    pixel_maps_paths,
    glue("plots/pixel-maps-{insecticide_names}.png",
         insecticide_names = insecticide_names)
  ),

  tar_target(
    pixel_map_plots,
    save_plot(
      raster = pixel_maps_data,
      path = pixel_maps_paths
    ),
    pattern = map(pixel_maps_data, pixel_maps_paths)
  )

) |>
  tar_hook_before(
    hook = source("conflicts.R"),
    names = everything()
  )
