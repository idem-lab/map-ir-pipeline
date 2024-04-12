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
  workspace_on_error = TRUE,
  # debug = "outer_loop_results_spatial", # Set the target you want to debug.
  # cue = tar_cue(mode = "never") # Force skip non-debugging outdated targets.
  controller = controller
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
  tar_file(
    moyes_geno_path,
    "data/6_Vgsc-allele-freq_complex-subgroup.csv"
  ),
  moyes_pheno_raw = read_csv_clean(moyes_pheno_path),

  gambiae_complex_list = create_valid_gambiae(),
  moyes_pheno_prepared = prepare_pheno_data(
    moyes_pheno_raw,
    gambiae_complex_list
  ),

  moyes_geno_raw = read_csv_clean(moyes_geno_path),

  moyes_geno_geocode = geocode_geno_data(moyes_geno_raw),
  moyes_geno_countries = extract_country(moyes_geno_geocode),
  moyes_geno_prepared = prepare_geno_data(
    moyes_geno_raw,
    moyes_geno_countries
  ),

  moyes_geno_pheno = combine_pheno_geno(
    moyes_pheno_prepared,
    moyes_geno_prepared
  ),

  # explicitly drop NA values
  ir_data = create_ir_data(moyes_geno_pheno),

  tar_quarto(q_explore, "doc/explore.qmd"),
  tar_quarto(q_checks, "doc/checks.qmd"),

  # Create a spatial dataset with linked ID so we can join this on later
  ir_data_sf_key = create_sf_id(ir_data),

  # setup analysis to work on a few countries
  subset_countries = c("Kenya", "Tanzania", "Benin"),
  ir_data_subset = filter(ir_data, country %in% subset_countries),
  ir_data_sf_key_subset = semi_join(
    ir_data_sf_key,
    ir_data_subset,
    by = "uid"
  ),

  # get cropland data from geodata package
  subset_country_codes = map_dfr(subset_countries, country_codes),
  tar_terra_vect(
    country_shapefile,
    cgaz_country(subset_country_codes$NAME)
  ),
  tar_terra_rast(
    raster_coffee,
    agcrop_area(crop = "acof")
  ),
  tar_terra_rast(
    raster_countries_coffee,
    crop_raster_to_country(raster_coffee, country_shapefile)
  ),
  tar_terra_rast(
    raster_veg,
    agcrop_area(crop = "vege")
  ),
  tar_terra_rast(
    reference_rast,
    raster_countries_coffee[[1]]
  ),
  tar_terra_rast(
    raster_countries_veg,
    crop_raster_to_country(raster_veg, reference_rast)
  ),
  tar_terra_rast(
    raster_trees,
    get_landcover("trees")
  ),
  tar_terra_rast(
    raster_countries_trees,
    resample(raster_trees, reference_rast) %>%
      crop_raster_to_country(reference_rast)
  ),
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
    raster_covariates,
    c(
      raster_countries_trees,
      raster_countries_veg,
      raster_countries_coffee
    )
  ),
  all_spatial_covariates = join_rasters_to_mosquito_data(
    rasters = raster_covariates,
    mosquito_data = ir_data_subset
  ),

  ir_data_mn = left_join(
    ir_data_subset,
    all_spatial_covariates,
    by = c("uid", "country")
  ),
  complete_spatial_covariates = identify_complete_vars(
    all_spatial_covariates
  ),

  # drop uid name and keep rest for use later
  spatial_covariate_names = get_covariate_names(complete_spatial_covariates),

  # dropping generation as it is missing too many values
  other_covariates = c("start_year", "insecticide_id"),
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
    outcomes = "percent_mortality",
    predictors = model_covariates
  ),
  inla_mesh = create_mesh(ir_data),
  gp_inla_setup = setup_gp_inla_model(
    covariate_names = names(model_list),
    outcome = "percent_mortality",
    mesh = inla_mesh
  ),
  out_of_sample_predictions = model_validation(
    covariate_rasters = raster_covariates,
    training_data = ir_data_subset,
    level_zero_models = model_list,
    inla_mesh_setup = gp_inla_setup
  ),
  ir_data_mn_oos_predictions = bind_cols(
    .preds = bind_rows(out_of_sample_predictions),
    ir_data_subset
  ),
  oos_diagnostics = diagnostics(ir_data_mn_oos_predictions),
  plot_diagnostics = gg_diagnostics(oos_diagnostics),

  # --- model deployment to rasters -----
  # We get out a set of out of sample predictions of length N
  # Which we can compare to the true data (y-hat vs y)
  outer_loop_results_spatial = spatial_prediction(
    covariate_rasters = raster_covariates,
    training_data = ir_data_subset,
    level_zero_models = model_list,
    inla_mesh_setup = gp_inla_setup
  ),

  # Predictions are made back to every pixel of map + year (spatiotemporal)
  # this puts them out into a raster, for each of raster_covariates
  tar_terra_rast(
    pixel_maps,
    create_pixel_map_data(
      predictions = outer_loop_results_spatial,
      rasters = raster_covariates
    )
  ),

  tar_target(
    pixel_map_paths,
    here("plots/pixel-maps-insecticide-1-5.png")
  ),

  tar_file(
    pixel_map_plots,
    save_plot(
      path = pixel_map_paths,
      raster = pixel_maps
    )
  )

) |>
  tar_hook_before(
    hook = source("conflicts.R"),
    names = everything()
  )

# other target outcomes for plotting, country level resistance
