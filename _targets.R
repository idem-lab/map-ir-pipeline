## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
tar_source()

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  # read in example infection resistance data
  tar_target(ir_data_path,
             "data/ir-data-raw.csv.gz",
             format = "file"
  ),

  ir_data_raw = read_csv(ir_data_path),

  # TODO ensure SF objects play properly with tidymodels/subsequent objects
  ir_data_sf = st_as_sf(ir_data_raw,
                        coords = c("longitude", "latitude"),
                        # equivalent to "EPSG:4326" which technically is
                        # strictly lat,lon for contexts where that matters
                        crs = "OGC:CRS84"
                        ),

  # check the map
  ir_data_map = mapview(ir_data_sf),

  # perform the emplogit on response, and do IHS transform
  ir_data = add_pct_mortality(ir_data_raw = ir_data_sf,
                              no_dead = no_dead,
                              no_tested = no_tested),

  # m = Number of rows of full **genotypic** data
  # n = Number of rows of full **phenotypic** data
  # m + n = Number of rows of full dataset

  # specify the details for the different models ahead of time
  # hyperparameters are hard coded internally inside these functions
  ## NOTE that RMSE is used to measure performance, and is the default for
  ## regression problems in tidymodels:
  ## https://tune.tidymodels.org/articles/getting_started.html
  model_xgb = build_ir_xgboost(),
  model_rf = build_ir_rf(),

  # currently going to remove the BGAM model at this stage, see issue #3
  # model_bgam = build_ir_bgam(),

  model_list = list(
    xgb = model_xgb,
    rf = model_rf
  ),

  l_zero_model_formula = construct_model_formula(ir_data,
                                                  response = "pct_mortality"),

  inla_mesh = create_mesh(ir_data),

  gp_inla_setup <- setup_gp_inla_model(
    covariate_names = names(model_list),
    outcome = "pct_mortality",
    mesh = inla_mesh
  ),

  # ---- outer loop ---- #

  # Outer Loop ----
  # Take a full dataset (M+N)
  ir_data_mn = ir_data,

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
  out_of_sample_predictions = inner_loop(
    data = training(ir_data_mn_folds$splits[[1]]),
    new_data = testing(ir_data_mn_folds$splits[[1]]),
    l_zero_model_formula = l_zero_model_formula,
    l_zero_model_list = model_list,
    l_one_model_setup = gp_inla_setup
    ),

  # OUTER LOOP parts from here now ----
  # We get out a set of out of sample predictions of length N
  # Which we can compare to the true data (y-hat vs y)
  ## TODO: remember to manage the length of the predictions so we only get
  ## out length N out of sample predictions (the phenotypic predictions).
  ## might be easiest to pad out the genotypic (M) predictions with NA values
  ir_data_mn_oos_predictions = add_oos_predictions(ir_data_mn,
                                                   out_of_sample_predictions),

  oos_diagnostics = diagnostics(ir_data_mn_oos_predictions),

  plot_diagnostics = gg_diagnostics(oos_diagnostics),

  # Run the inner loop one more time, to the full dataset, N+M
  outer_loop_results = inner_loop(
    data = ir_data_mn,
    l_zero_model_formula = l_zero_model_formula,
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
