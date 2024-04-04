## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
tar_source()

tar_option_set(
  # Save a workspace file for a target that errors out
  workspace_on_error = TRUE
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

  ## Checking functions
  moyes_pheno_count_nr = summarise_not_recorded(moyes_pheno_raw),
  moyes_pheno_count_nf = summarise_not_found(moyes_pheno_raw),

  gambiae_complex_list = create_valid_gambiae(),
  moyes_pheno_prepared = prepare_pheno_data(
    moyes_pheno_raw,
    gambiae_complex_list
  ),

  ## Checking functions
  moyes_pheno_check_dead = check_back_calculate_no_dead(moyes_pheno_prepared),
  moyes_pheno_check_pct_mort = check_mortality(moyes_pheno_prepared),
  moyes_geno_raw = read_csv_clean(moyes_geno_path),

  ## Checking functions
  moyes_geno_count_nr = summarise_not_recorded(moyes_geno_raw),
  moyes_geno_count_nf = summarise_not_found(moyes_geno_raw),
  moyes_geno_geocode = geocode_geno_data(moyes_geno_raw),
  moyes_geno_countries = extract_country(moyes_geno_geocode),
  moyes_geno_prepared = prepare_geno_data(
    moyes_geno_raw,
    moyes_geno_countries
  ),
  moyes_geno_check_dead = check_back_calculate_no_dead(moyes_geno_prepared),
  moyes_geno_check_pct_mort = check_mortality(moyes_geno_prepared),
  geno_pheno_match = check_pheno_geno_match(
    moyes_pheno_prepared,
    moyes_geno_prepared
  ),
  moyes_geno_pheno = combine_pheno_geno(
    geno_pheno_match,
    moyes_pheno_prepared,
    moyes_geno_prepared
  ),


  # there are times where PCT mortality is recorded, but neither tested or dead?
  explore_pct_mortality = why_pct_mortality(moyes_geno_pheno),
  vis_miss_moyes = vis_miss(
    moyes_geno_pheno,
    sort_miss = TRUE,
    cluster = TRUE
  ),

  # explicitly drop NA values
  ir_data = create_ir_data(moyes_geno_pheno),
  vis_miss_ir_data = vis_miss(
    ir_data,
    sort_miss = TRUE,
    cluster = TRUE
  ),

  # Create a spatial dataset with linked ID so we can join this on later
  ir_data_sf_key = create_sf_id(ir_data),

  # Check the map
  ir_data_map = mapview(ir_data_sf_key),
  ir_country_count = count(ir_data, country, type, sort = TRUE),
  # setup analysis to work on a few countries
  subset_countries = c("Kenya", "Tanzania", "Benin"),
  ir_data_subset = filter(ir_data, country %in% subset_countries),
  ir_data_sf_key_subset = semi_join(
    ir_data_sf_key,
    ir_data_subset,
    by = "uid"
  ),
  ir_data_map_subset = mapview(ir_data_sf_key_subset),

  # get cropland data from geodata package
  subset_country_codes = map_dfr(subset_countries, country_codes),

  tar_target(
    raster_coffee,
    agcrop_area(crop = "acof"),
    format = format_geotiff
  ),
  tar_target(
    raster_countries_coffee,
    crop_raster_to_country(raster_coffee, subset_country_codes),
    format = format_geotiff
  ),
  tar_target(
    raster_veg,
    agcrop_area(crop = "vege"),
    format = format_geotiff
  ),
  tar_target(
    raster_countries_veg,
    crop_raster_to_country(raster_veg, subset_country_codes),
    format = format_geotiff
  ),
  tar_target(
    raster_trees,
    get_landcover("trees"),
    format = format_geotiff
  ),
  tar_target(
    raster_countries_trees,
    crop_raster_to_country(
      raster_trees,
      subset_country_codes
    ),
    format = format_geotiff
  ),
  tar_target(
    raster_countries_elevation,
    get_elevation(subset_country_codes),
    format = format_geotiff
  ),
  tar_target(
    raster_countries_worldclimate,
    get_worldclim(subset_country_codes, var = "tmin"),
    format = format_geotiff
  ),
  tar_target(
    raster_covariates,
    sprc(
      list(
        raster_countries_worldclimate,
        raster_countries_elevation,
        raster_countries_trees,
        raster_countries_veg,
        raster_countries_coffee
      )
    ),
    format = format_sprc_geotiff
  ),

  all_spatial_covariates = join_rasters_to_mosquito_data(
    rasters = raster_covariates,
    mosquito_data = ir_data_subset
  ),

  vis_miss_covariates = vis_miss(
    all_spatial_covariates,
    sort_miss = TRUE,
    cluster = TRUE
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

  # other_covariates = c("start_year", "generation", "insecticide_class"),
  # dropping generation as it is missing too many values
  other_covariates = c("start_year", "insecticide_id"),
  model_covariates = c(other_covariates, spatial_covariate_names),
  # TODO fold this check into model_validate
  ## Checking function
  # predictors_missing = check_if_model_inputs_missing(
  #   model_covariates,
  #   ir_data_mn
  # ),

  # specify the details for the different models ahead of time
  # hyperparameters are hard coded internally inside these functions
  ## NOTE that RMSE is used to measure performance, and is the default for
  ## regression problems in tidymodels:
  ## https://tune.tidymodels.org/articles/getting_started.html
  model_xgb = build_ir_xgboost(tree_depth = 2, trees = 5),
  model_rf = build_ir_rf(mtry = 2, trees = 5),
  workflow_xgb = build_workflow(
    model_spec = model_xgb,
    outcomes = "percent_mortality",
    predictors = model_covariates
  ),
  workflow_rf = build_workflow(
    model_spec = model_rf,
    outcomes = "percent_mortality",
    predictors = model_covariates
  ),

  ## TODO?
  # These models must be named after the model name in the workflow
  # e.g., if using set_engine("randomForest"), then name this `randomForest`
  model_list = list(
    xgboost = workflow_xgb,
    randomForest = workflow_rf
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
    list_of_l0_models = model_list,
    inla_mesh_setup = gp_inla_setup
  ),
  ir_data_mn_oos_predictions = bind_cols(
    .preds = bind_rows(out_of_sample_predictions),
    ir_data_mn
  ),
  oos_diagnostics = diagnostics(ir_data_mn_oos_predictions),
  plot_diagnostics = gg_diagnostics(oos_diagnostics),

  # --- model deployment to rasters -----
  # We get out a set of out of sample predictions of length N
  # Which we can compare to the true data (y-hat vs y)
  ## TODO: remember to manage the length of the predictions so we only get
  ## out length N out of sample predictions (the phenotypic predictions).
  ## might be easiest to pad out the genotypic (M) predictions with NA values

  # Run the inner loop one more time, to the full dataset, N+M
  outer_loop_results = inner_loop(
    data = ir_data_mn,
    # full set of mapping data as an sf object
    # (environmental covariates and coords)
    # in this final step we take a set of rasters, pull out the coords and
    # environmental covariates for each pixel, and use the
    # stacked generalisation model to predict to all of them, then put
    # the predicted IR values back in a raster of predictions.
    new_data = raster_example,
    l_zero_model_list = model_list,
    l_one_model_setup = gp_inla_setup
  ),

  ## TODO
  ## Write this out as a mapped pipeline
  tar_target(
    predicted_raster_id_1,
    prediction_to_raster(
      raster = raster_countries_coffee,
      predictions = outer_loop_results,
      insecticide_id = 1
    ),
    format = format_geotiff
  ),
  tar_target(
    predicted_raster_id_2,
    prediction_to_raster(
      raster = raster_countries_coffee,
      predictions = outer_loop_results,
      insecticide_id = 2
    ),
    format = format_geotiff
  ),
  tar_file(
    plot_predicted_raster_id_1,
    save_plot(path = "plots/predicted_raster_id_1.png", predicted_raster_id_1),
  ),
  tar_file(
    plot_predicted_raster_id_2,
    save_plot(path = "plots/predicted_raster_id_2.png", predicted_raster_id_2),
  ),

  ## TODO
  ## What do we pass this inner loop one more time?
  ## Because we just did the whole out_of_sample_predictions thing
  ## and we don't use it again?
  outer_loop_results_spatial = spatial_prediction(
    covariate_rasters = raster_covariates,
    training_data = ir_data_subset,
    list_of_l0_models = model_list,
    inla_mesh_setup = gp_inla_setup
  ),

  # Predictions are made back to every pixel of map + year (spatiotemporal)
  # this puts them out into a raster
  pixel_map = create_pixel_map(outer_loop_results)
)

# other target outcomes for plotting, country level resistance
