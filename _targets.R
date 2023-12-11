## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
tar_source()

## tar_plan supports drake-style targets and also tar_target()
tar_plan(

  # read in example infection resistance data
  tar_target(ir_data_path,
             "data/simulated-ir-data.csv",
             format = "file"),
  ir_data_raw = read_csv(ir_data_path),

  # perform the emplogit on response, and do IHs transform
  ir_data = add_pct_mortality(ir_data_raw, no_dead, no_tested),

  # not sure if we needed to identify these ahead of time?
  # n_star = 1.0 # or n_phenotypic
  # m_star = 1.0 # or n_genotypic

  test_train = create_test_train(data = ir_data,
                                 # so we get equal test/training within type
                                 strata = type,
                                 n_folds = 10),

  # this should be N* + M*
  train_data = extract_training(test_train),
  # this should just be M*
  test_data = extract_test(test_train) %>% filter(type == "phenotypic"),

  model_formula = construct_model_formula(ir_data, response = "pct_mortality"),

  # hyperparameters are hard coded initially
  train_xgb = fit_xgb(data = train_data,
                      formula = model_formula,
                      # max depth of a tree
                      max_depth = 8,
                      # number of trees
                      nrounds = 12000,
                      # learning rate
                      eta = 0.001,
                      # min los reduction required to make a further partition
                      gamma = 0.5,
                      # minimum sum of instance weight needed in a child
                      min_child_weight = 7,
                      # subsample ratio of columns when constructing a tree
                      colsample_by_tree = 0.7,
                      # subsample ratio of the training instance
                      subsample = 0.7,
                      # proportion of trees dropped each iteration
                      rate_drop = 0.001,
                      # regularisation parameter
                      lambda = 1),
  train_rf = fit_rf(data = train_data,
                    formula = model_formula,
                    # num variables randomly sampled at each split
                    mtry = 150,
                    # number of trees
                    ntree = 1001,
                    # rate of randomly sampling featured used for each tree
                    col_sample_rate_per_tree = 0.8,
                    # min number of observations per leaf
                    node_size = 20),
  train_bgam = fit_bgam(data = train_data,
                        formula = model_formula,
                        # final number of iterations
                        mstop = 80000,
                        # degrees of freedom of the base learners
                        degree = 1,
                        # shrinkage parameter
                        nu = 0.4),

  # these prediction vectors should happen on each list of `test_data`
  # these will be of length N*
  predict_xgb = map2_dfr(train_xgb, test_data, predict),
  predict_rf = map2_dfr(train_rf, test_data, predict),
  predict_bgam = map2_dfr(train_bgam, test_data, predict),

  # Take the out of sample predictions for each of the models,
  # combine them together of length N*, into the fixed effects,
  # one per model (XBG, RF, BGAM)
  # A 3xN* matrix / AKA out of sample covariates?
  oos_covariates = bind_cols(xgb = predict_xgb,
                                  rf = predict_rf,
                                  bgam = predict_bgam),

  # this formula will have spatial terms and other features?
  gp_inla_formula = build_gp_inla_formula(data = oos_covariates,
                                          outcome = "pct_mortality"),
  gp_inla_data = bind_cols(filter(ir_data, type == "phenotype"),
                           # including the out of sample covariates
                           oos_covariates),

  # Fit the whole L1 model to N* original data, using out of sample covariates
  # oos = out of sample
  # super learner = L1 model
  super_learner_oos = gp_inla(data = gp_inla_data, gp_inla_formula),

  # Finally, we make a prediction
  # But we switch the out of sample L0 fixed effects,
  # for the L0 in sample fixed effects,
  # that gives a prediction of length N*
  ## QUESTION: How do we incorporate the in sample fixed effects, since that
    ## is effectively 10 lots of 90% of the data, rather than 10 lots of 10% of
    ## the data?

  # is = in sample
  super_learner_is

  # Fit L0 model once to the full dataset, fitting to N*+M* data,
  # and predict to the N* phenotypic data points,
  # to get the in sample predictions
  # (once we’ve determined the parameters of the L1 model)

  # Outer Loop ----
    # Take a full dataset (N+M), then run 10 fold CV of the entire inner loop
      # Every time we run inner loop, pass in N* = N x 0.9, and M* = M x 0.9
      # Every time we run this we give it a prediction set
        # N x 0.1 and M x 0.1
    # We get out a set of out of sample predictions of length N
    # Which we can compare to the true data (y-hat vs y)
    # Run the inner loop one more time, to the full dataset, N+M,
    # Predictions are made back to every pixel of map + year (spatiotemporal)



)
