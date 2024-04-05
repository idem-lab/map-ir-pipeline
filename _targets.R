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
  moyes_pheno_count_nr = summarise_not_recorded(moyes_pheno_raw),
  moyes_pheno_count_nf = summarise_not_found(moyes_pheno_raw),
  gambiae_complex_list = create_valid_gambiae(),
  moyes_pheno_prepared = prepare_pheno_data(
    moyes_pheno_raw,
    gambiae_complex_list
  ),
  moyes_pheno_check_dead = check_back_calculate_no_dead(moyes_pheno_prepared),
  moyes_pheno_check_pct_mort = check_mortality(moyes_pheno_prepared),
  moyes_geno_raw = read_csv_clean(moyes_geno_path),
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

  # crops = c("vege", "plnt", "bana", "toba", "teas", "coco", "acof", "cnut"),

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
  climate_variables = tibble(
    vars = c("tmin", "tmax", "tavg", "prec", "wind", "vapr", "bio")
  ),
  tar_target(
    raster_countries_worldclimate,
    get_worldclim(subset_country_codes, var = "tmin"),
    format = format_geotiff
  ),
  extracted_countries_climate = extract_from_raster(
    raster_countries_worldclimate,
    ir_data_subset,
    ir_data_sf_key
  ),
  extracted_countries_elevation = extract_from_raster(
    raster_countries_elevation,
    ir_data_subset,
    ir_data_sf_key
  ),
  extracted_countries_trees = extract_from_raster(
    raster_countries_trees,
    ir_data_subset,
    ir_data_sf_key
  ),
  extracted_countries_veg = extract_from_raster(
    raster_countries_veg,
    ir_data_subset,
    ir_data_sf_key
  ),
  extracted_countries_coffee = extract_from_raster(
    raster_countries_coffee,
    ir_data_subset,
    ir_data_sf_key
  ),
  all_spatial_covariates = join_extracted(
    extracted_countries_coffee,
    extracted_countries_veg,
    extracted_countries_trees,
    extracted_countries_elevation,
    extracted_countries_climate
  ) %>%
    # impute 0 into missing values for all rasters
    mutate(
      across(
        .cols = everything(),
        .fns = impute_zero
      )
    ),
  vis_miss_covariates = vis_miss(
    all_spatial_covariates,
    sort_miss = TRUE,
    cluster = TRUE
  ),
  ir_data_subset_spatial_covariates = left_join(
    ir_data_subset,
    all_spatial_covariates,
    by = c("uid", "country")
  ),
  complete_spatial_covariates = identify_complete_vars(
    all_spatial_covariates
  ),

  # drop uid name and keep rest for use later
  spatial_covariate_names = get_covariate_names(complete_spatial_covariates),
  spatial_covariate_sample = spatial_covariate_names[1:6],

  # other_covariates = c("start_year", "generation", "insecticide_class"),
  # dropping generation as it is missing too many values
  other_covariates = c("start_year", "insecticide_id"),
  model_covariates = c(other_covariates, spatial_covariate_sample),
  predictors_missing = check_if_model_inputs_missing(
    model_covariates,
    ir_data_subset_spatial_covariates
  ),

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
    outcomes = "percent_mortality",
    predictors = model_covariates
  ),
  workflow_rf = build_workflow(
    model_spec = model_rf,
    outcomes = "percent_mortality",
    predictors = model_covariates
  ),

  # currently going to remove the BGAM model at this stage, see issue #3
  # model_bgam = build_ir_bgam(),

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

  # ---- outer loop ---- #

  # Outer Loop ----
  # Take a full dataset (M+N)
  ir_data_mn = ir_data_subset_spatial_covariates,
  ir_data_mn_folds = vfold_cv(
    ir_data_mn,
    v = 10,
    strata = type
  ),

  # then on the full dataset run 10 fold CV of the entire inner loop
  # Every time we run inner loop, pass in N* = N x 0.9, and M* = M x 0.9
  # Every time we run inner loop, we give it a prediction set
  # N x 0.1 and M x 0.1

  # ---- model validation ---- #
  # We need to fit each of the L0 models, 11 times
  # TODO: we need to do something special to appropriately handle
  # how the V-fold CV data, `ir_data_mn` works here, but for demo purposes
  # we will just assume that it runs on every fold separately.
  # we can probably do something with map, or have `inner_loop_cv` or
  # `inner_loop.vfold_cv` or something.

  training_data = map(ir_data_mn_folds$splits, training),
  testing_data = map(ir_data_mn_folds$splits, testing),

  ## TODO
  ## Does insecticide_id need to be a factor? It's currently an integer
  ## Converting it to factor breaks the analysis ()
  ## Returns one set of predictions because we fit the L1 model
  ## out from the L0 models in here
  ## NOTE - this is to evaluate how good our model/process is
  ## API Note - this part is separate to the raster prediction step,
  ## ## so we might want to consider keeping this as a logical/flagging
  ## ## step so we
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

  ## API - so the user should be able to provide their own raster here
  coffee_raster_as_data = raster_to_df(raster_countries_coffee),
  ## TODO
  ## Convert this into something that makes a list of many insectidies
  raster_example = raster_df_add_year_insecticide(coffee_raster_as_data,
                                                  start_year = 2019,
                                                  insecticide_id = 1),

  ## TODO
  ## maybe we wrap inner_loop to specify other prediction information that we
  ## care about, namely:
  ## start_year, and
  ## insecticide_id

  # Run the inner loop one more time, to the full dataset, N+M
  ## TODO
  ## What do we pass this inner loop one more time?
  ## Because we just did the whole out_of_sample_predictions thing
  ## and we don't use it again?
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

  # Predictions are made back to every pixel of map + year (spatiotemporal)
  # this puts them out into a raster
  pixel_map = create_pixel_map(outer_loop_results)
)

# other target outcomes for plotting, country level resistance
