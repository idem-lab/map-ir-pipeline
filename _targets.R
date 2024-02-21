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
  tar_target(ir_data_path,
    "data/ir-data-raw.csv.gz",
    format = "file"
  ),
  ir_data_raw = read_csv(ir_data_path),

  # data is from https://datadryad.org/stash/dataset/doi:10.5061/dryad.dn4676s
  tar_target(moyes_data_path,
    "data/2_standard-WHO-susc-test_species.csv",
    format = "file"
  ),
  ir_data_moyes_raw = read_moyes_data(moyes_data_path),
  ir_count_nr = summarise_not_recorded(ir_data_moyes_raw),
  ir_count_nf = summarise_not_found(ir_data_moyes_raw),
  ir_data_moyes_prepared = prepare_moyes_data(ir_data_moyes_raw),
  checked_no_dead = check_back_calculate_no_dead(ir_data_moyes_prepared),
  checked_pct_mortality = check_mortality(ir_data_moyes_prepared),

  # there are times where PCT mortality is recorded, but neither
  explore_pct_mortality = why_pct_mortality(ir_data_moyes_prepared),
  ir_data_moyes_replace = replace_no_dead_pct_mortality(ir_data_moyes_prepared),
  ir_data_moyes = drop_na(
    ir_data_moyes_replace,
    no_mosquitoes_tested,
    no_mosquitoes_dead,
  ),

  # this drops missing values in long/lat (about 7% missing values)

  vis_miss_moyes = vis_miss(
    ir_data_moyes,
    sort_miss = TRUE,
    cluster = TRUE
  ),

  # Create a spatial dataset with linked ID so we can join this on later
  ir_data_sf_key = create_sf_id(ir_data_moyes),

  # Check the map
  ir_data_map = mapview(ir_data_sf_key),

  # perform the emplogit on response, and do IHS transform
  ir_data = add_pct_mortality(
    ir_data_raw = ir_data_moyes,
    no_dead = no_mosquitoes_dead,
    no_tested = no_mosquitoes_tested
  ),
  subset_country = "Ethiopia",
  ir_data_subset = filter(ir_data, country == subset_country),

  # get cropland data from geodata package
  subset_country_codes = country_codes(subset_country),

  # crops = c("vege", "plnt", "bana", "toba", "teas", "coco", "acof", "cnut"),

  tar_target(
    crop_coffee_data,
    agcrop_area(crop = "acof", subset_country_codes),
    format = format_geotiff
  ),

  tar_target(
    crop_vege,
    agcrop_area(crop = "vege", subset_country_codes),
    format = format_geotiff
  ),
  tar_target(
    landcover_trees,
    get_landcover("trees", subset_country_codes),
    format = format_geotiff
  ),
  tar_target(
    elevation,
    get_elevation(subset_country_codes),
    format = format_geotiff
  ),
  climate_variables = tibble(
    vars = c("tmin", "tmax", "tavg", "prec", "wind", "vapr", "bio")
  ),

  tar_target(
    worldclimate,
    get_worldclim(subset_country_codes, var = "tmin"),
    format = format_geotiff
  ),

  extracted_climate = extract_from_raster(
    worldclimate,
    ir_data_subset,
    ir_data_sf_key
  ),

  extracted_elevation = extract_from_raster(
    elevation,
    ir_data_subset,
    ir_data_sf_key
  ),

  extracted_trees = extract_from_raster(
    landcover_trees,
    ir_data_subset,
    ir_data_sf_key
  ),

  extracted_vege = extract_from_raster(
    crop_vege,
    ir_data_subset,
    ir_data_sf_key
  ),

  extracted_coffee = extract_from_raster(
    crop_coffee_data,
    ir_data_subset,
    ir_data_sf_key
  ),

  all_spatial_covariates = join_extracted(
    extracted_coffee,
    extracted_vege,
    extracted_trees,
    extracted_elevation,
    extracted_climate
  ),

  ir_data_subset_spatial_covariates = left_join(
    ir_data_subset,
    all_spatial_covariates,
    by = "uid"
  ),

  # drop uid name and keep rest for use later
  spatial_covariate_names = get_covariate_names(all_spatial_covariates),

  spatial_covariate_sample = spatial_covariate_names[1:5],

  # other_covariates = c("start_year", "generation", "insecticide_class"),
  # dropping generation as it is missing too many values
  other_covariates = c("start_year", "insecticide_class"),

  model_covariates = c(other_covariates, spatial_covariate_sample),

  # m = Number of rows of full **genotypic** data
  # n = Number of rows of full **phenotypic** data
  # m + n = Number of rows of full dataset

  # specify the details for the different models ahead of time
  # hyperparameters are hard coded internally inside these functions
  ## NOTE that RMSE is used to measure performance, and is the default for
  ## regression problems in tidymodels:
  ## https://tune.tidymodels.org/articles/getting_started.html
  model_xgb = build_ir_xgboost(tree_depth = 2, trees = 5),
  model_rf = build_ir_rf(mtry = 2, trees = 5),
  workflow_xgb = build_workflow(
    model_spec = model_xgb,
    outcomes = "pct_mortality_emp",
    predictors = model_covariates
  ),
  workflow_rf = build_workflow(
    model_spec = model_rf,
    outcomes = "pct_mortality_emp",
    predictors = model_covariates
  ),

  # currently going to remove the BGAM model at this stage, see issue #3
  # model_bgam = build_ir_bgam(),

  model_list = list(
    xgb = workflow_xgb,
    rf = workflow_rf
  ),
  inla_mesh = create_mesh(ir_data),
  gp_inla_setup = setup_gp_inla_model(
    covariate_names = names(model_list),
    outcome = "pct_mortality_emp",
    mesh = inla_mesh
  ),

  # ---- outer loop ---- #

  # Outer Loop ----
  # Take a full dataset (M+N)
  ir_data_mn = ir_data_subset_spatial_covariates,
  ir_data_mn_folds = vfold_cv(ir_data_mn, v = 10, strata = type),

  # then on the full dataset run 10 fold CV of the entire inner loop
  # Every time we run inner loop, pass in N* = N x 0.9, and M* = M x 0.9
  # Every time we run inner loop, we give it a prediction set
  # N x 0.1 and M x 0.1

  # ---- inner loop ---- #
  # We need to fit each of the L0 models, 11 times
  # TODO: we need to do something special to appropriately handle
  # how the V-fold CV data, `ir_data_mn` works here, but for demo purposes
  # we will just assume that it runs on every fold separately.
  # we can probably do something with map, or have `inner_loop_cv` or
  # `inner_loop.vfold_cv` or something.

  training_data = map(ir_data_mn_folds$splits, training),
  testing_data = map(ir_data_mn_folds$splits, testing),
  out_of_sample_predictions = map2(
    .x = training_data,
    .y = testing_data,
    .f = function(.x, .y) {
      inner_loop(
        data = .x,
        new_data = .y,
        l_zero_model_list = model_list,
        l_one_model_setup = gp_inla_setup
      )
    }
  ),

  # OUTER LOOP parts from here now ----
  # We get out a set of out of sample predictions of length N
  # Which we can compare to the true data (y-hat vs y)
  ## TODO: remember to manage the length of the predictions so we only get
  ## out length N out of sample predictions (the phenotypic predictions).
  ## might be easiest to pad out the genotypic (M) predictions with NA values
  ir_data_mn_oos_predictions = bind_cols(
    .preds = bind_rows(out_of_sample_predictions),
    ir_data_mn
  ),
  oos_diagnostics = diagnostics(ir_data_mn_oos_predictions),
  plot_diagnostics = gg_diagnostics(oos_diagnostics),

  # Run the inner loop one more time, to the full dataset, N+M
  outer_loop_results = inner_loop(
    data = ir_data_mn,
    # full set of mapping data as an sf object (environmental
    # covariates and coordinates)
    # in this final step we need to take a setof rasters, pull out the
    # coordinates and environmental covariates for each pixel, and use the
    # stacked generalisation model to predict to all of them, then put
    # the predicted IR values back in a raster of predictions.
    new_data = ,
    l_zero_model_list = model_list,
    l_one_model_setup = gp_inla_setup
  ),

  ## TODO: future considerations, might be worthwhile thinking about a way to
  ## batch up the predictions that are done on the inner_loop model, so that
  ## the computation time/cost is low and achievable and easier to handle.

  # Predictions are made back to every pixel of map + year (spatiotemporal)
  # this puts them out into a raster
  pixel_map = create_pixel_map(outer_loop_results)

  # other target outcomes for plotting, country level resistance
  ## TODO: computation considerations - considering ways to make all of this
  ## run in a reasonable time, and thinking about ways to run this as software
  ## e.g., do people need a pipeline, or do people just want a couple of
  ## functions that wrap all of this up. The key point with this is choosing a
  ## level of abstraction that makes the computation accessible and reasonable
  ## with a thought of what someone might do if they have a new dataset
)
