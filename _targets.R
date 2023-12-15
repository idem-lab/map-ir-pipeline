## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
tar_source()

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  # read in example infection resistance data
  tar_target(ir_data_path,
             "data/ir-data-sample.csv",
             format = "file"
  ),
  ir_data_raw = read_csv(ir_data_path),

  # perform the emplogit on response, and do IHs transform
  ir_data = add_pct_mortality(ir_data_raw = ir_data_raw,
                              no_dead = no_dead,
                              no_tested = no_tested),

  # m = Number of rows of full **genotypic** data
  # n = Number of rows of full **phenotypic** data
  # m + n = Number of rows of full dataset

  # specify the details for the different models ahead of time
  # hyperparameters are hard coded internally inside these functions
  model_xgb = build_ir_xgboost(),
  model_rf = build_ir_rf(),
  model_bgam = build_ir_bgam(),

  model_list = list(
    xgb = model_xgb,
    rf = model_rf,
    bgam = model_bgam
  ),

  model_formula = construct_model_formula(ir_data, response = "pct_mortality"),

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
  # NOTE: we need to do something special to appropriately handle
  # how the V-fold CV data, `ir_data_mn` works here, but for demo purposes
  # we will just assume that it runs on every fold separately.
  # we can probably do something with map, or have `inner_loop_cv` or
  # `inner_loop.vfold_cv` or something.
  out_of_sample_predictions = inner_loop(data = ir_data_mn,
                                         model_formula = model_formula,
                                         model_list = model_list),

  # We get out a set of out of sample predictions of length N
  # Which we can compare to the true data (y-hat vs y)
  ir_data_mn_oos_predictions = add_oos_predictions(ir_data_mn,
                                                   out_of_sample_predictions),

  # Run the inner loop one more time, to the full dataset, N+M
  full_predictions = inner_loop(data = ir_data_mn,
                                model_formula = model_formula,
                                model_list = model_list
                                # extra args to include spatiotemporal parts
                                )

  # Predictions are made back to every pixel of map + year (spatiotemporal)

)
