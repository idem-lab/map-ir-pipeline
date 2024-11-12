#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param training_covariates
#' @param prediction_covariates
#' @param level_one_model_setup
#' @return
#' @author njtierney
#' @export
fit_predict_level_one_model <- function(training_data,
                                        training_covariates,
                                        prediction_data,
                                        prediction_covariates,
                                        level_one_model_setup) {

  # set up the data objects for fitting and prediction, based on Penny's code

  # need to create separate objects and terms for each of the different
  # insecticides, and for training and prediction for each, and stack them
  # together

  # the insecticides we are modelling
  insecticide_ids <- sort(unique(training_data$insecticide_id))

  # get the number of groups (insecticide types modelled simultaneously) and the
  # names of the covariates/models used in stacking
  n_groups <- length(insecticide_ids)
  covariate_names <- names(training_covariates)

  # get the mesh and SPDE objects
  meshes <- level_one_model_setup$meshes
  spatial_spde <- level_one_model_setup$spatial_spde
  # level_one_model_setup$temporal_spdes

  # In Penny's code, some indices (isel1a, isel2a, etc.) were used to index the
  # records of each insecticide in the larger dataset, and then to split them up
  # and do things with them. Here, the whole dataset is already subsetted and we
  # just need to split on insecticide type, e.g. with a grouping/filtering
  # statement.

  # compute the year from various temporal information

  # combine required training data and covariates
  training_all <- training_data %>%
    # compute x,y,z coordinates
    bind_cols(
      ll_to_xyz(
        select(., "longitude", "latitude")
      )
    ) %>%
    # rename stuff and add dummy weights column
    mutate(
      mort = transformed_mortality,
      w = 1,
      year = year_midpoint(start_year = start_year,
                           start_month = start_month,
                           end_year = end_year,
                           end_month = end_month)
    ) %>%
    # keep the stuff we need from here
    select(mort,
           w,
           year,
           insecticide_id,
           x, y, z) %>%
    # and add on the level 0 OOS covariates
    bind_cols(training_covariates)

  # the same for prediction
  prediction_all <- prediction_data %>%
    # compute x,y,z coordinates
    bind_cols(
      ll_to_xyz(
        select(., "longitude", "latitude")
      )
    ) %>%
    # rename stuff and add dummy response and weights columns
    mutate(
      mort = NA,
      w = 1,
      year = year_midpoint(start_year = start_year,
                           start_month = start_month,
                           end_year = end_year,
                           end_month = end_month)
    ) %>%
    # keep the stuff we need from here
    select(mort,
           w,
           year,
           insecticide_id,
           x, y, z) %>%
    # and add on the level 0 predictions from in-sample models
    bind_cols(prediction_covariates)


  # for each of these, split them up by insecticide type, and make data stack
  # objects

  # loop through insecticide types, making the relevant object and putting them
  # in this environment

  stack_list <- list()
  for (this_insecticide_id in insecticide_ids) {

    # what to call the INLA effects for this insecticide
    this_intercept_name <- paste0("b0.", this_insecticide_id)
    this_field_name <- paste0("field", this_insecticide_id)

    # indices to the combined space-time SPDE mesh
    spde_indices <- INLA::inla.spde.make.index(this_field_name,
                                           n.spde = meshes$spatial_mesh$n,
                                           n.group = meshes$temporal_mesh$m)

    # loop through the training and prediction stacks
    for (type in c("training", "prediction")) {

      # replace data1, val1, with training1, prediction1
      this_stack_name <- paste0(type, this_insecticide_id)

      dataset_all <- switch(type,
                        training = training_all,
                        prediction = prediction_all)

      dataset <- dataset_all %>%
        filter(insecticide_id == this_insecticide_id) %>%
        select(-insecticide_id)

      coords <- dataset %>%
        select(x, y, z) %>%
        as.matrix()

      # projection matrix for mapping from the mesh nodes to these data
      this_A <- INLA::inla.spde.make.A(meshes$spatial_mesh,
                                      loc = coords,
                                      group = dataset$year,
                                      group.mesh = meshes$temporal_mesh)

      # name the intercept effects
      effects_sub <- list(dataset$w, dataset[, covariate_names])
      names(effects_sub) <- c(this_intercept_name, names(effects_sub)[-1])

      # put it in an INLA stack object
      this_stack <- INLA::inla.stack(
        tag = this_stack_name,
        data = list(mort = cbind(dataset$mort, NA, NA, NA)),
        A = list(this_A, 1),
        effects = list(spde_indices, effects_sub))

      # and add this stack to the list of stacks for more stacking
      stack_list <- c(
        stack_list,
        list(this_stack)
      )

    } # training/prediction loop

  } # insecticide_id loop

  # combine all these stack elements in the main stack
  j.stk <- do.call(INLA::inla.stack, stack_list)

  # Specify priors on the measurement noise and the temporal autocorrelation
  eprec <- list(
    hyper = list(
      theta = list(
        prior = "pc.prec",
        param = c(5, 0.01)
      )
    )
  )

  pcrho <- list(
    theta = list(
      prior = "pccor0",
      param = c(0.5, 0.5)
    )
  )

  # set up the INLA formula object, with some horrible text manipulation

  # each group (insecticide type) has its own intercept (mean logit-prevalence)
  group_intercept_terms <- paste0("b0.", insecticide_ids, collapse = " + ")

  # each group has a space-time random effect (Matern x AR1), represented as an
  # SPDE, with pcrho giving the penalised complexity prior for the rho parameter
  # (temporal correlation) of the AR1 process
  field_fixed <- "model = spatial_spde,
  control.group = list(model = 'ar1', hyper = pcrho)"
  field_terms_vec <- sprintf("f(field%i, group = field%i.group, %s)",
                             insecticide_ids, insecticide_ids, field_fixed)
  group_field_terms <- paste(field_terms_vec, collapse = " + ")

  # add the stacking weights for the level 0 models (making predictions to all
  # the groups, simultaneously, so not split by group); these are constrained to
  # be in 0-1 (non-negative, with initial value at 0.2), but not constrained to be a
  # simplex across weights
  covariate_terms_vec <- sprintf("f(%s,
                                 model = 'clinear',
                                 range = c(0, 1),
                                 initial = 0.2)",
                                 covariate_names)
  covariate_terms <- paste(covariate_terms_vec, collapse = " + ")

  # combine all these into a formula object
  inla_formula <- as.formula(
      paste(
        "mort ~ -1",
        covariate_terms, # "f(x, model = 'clinear') + ..."
        group_intercept_terms, # "b0.1 + ...",
        group_field_terms,  # "f(field1, group = field1.group, ...) + ...",
        sep = " + "))

  # Run the INLA model
  result <- INLA::inla(

    # specify the formula
    formula = inla_formula,

    # Gaussian observation model over logit-transformed data
    family = rep("Gaussian",
                 n_groups),

    # provide the full dataset, for all the fields, etc.
    data = INLA::inla.stack.data(j.stk),

    # specify the measurement noise priors
    control.family = replicate(n_groups,
                               eprec,
                               simplify = FALSE),

    # make predictions
    control.predictor = list(compute = TRUE,
                             A = INLA::inla.stack.A(j.stk)),
    # compute validation stats and hypers
    control.compute = list(config = TRUE,
                           cpo = TRUE,
                           dic = TRUE,
                           waic = TRUE),
    # just do 'Empirical Bayes' strategy for hyperparameter integration (Ie.
    # don't integrate the hyperparameters, just have the maximum a posteriori
    # estimate :/ )
    control.inla = list(int.strategy = "eb")
  )

  # now pull out predictions for the insecticides and observation data in the
  # format Nick T's code expects

  # the model has identity link, so we can use either
  # result$summary.linear.predictor or result$summary.fitted.values

  # Pull out the training and prediction data represented in the stacks
  # (APredictor elements)
  all_preds <- result$summary.linear.predictor[, 1, drop = FALSE]
  keep_idx <- str_starts(rownames(all_preds), "APredictor")
  preds <- all_preds[keep_idx, "mean"]
  preds

  # reconstitute the predictions for the different insecticide_id levels, by
  # making a look up table based on the order of observations within each of the
  # groups
  pred_list <- list()
  for (this_insecticide_id in insecticide_ids) {
    this_element <- paste0("prediction", this_insecticide_id)
    index <- j.stk$data$index[[this_element]]
    this_pred_set <- tibble(
      insecticide_id = this_insecticide_id,
      .pred = preds[index]
    ) %>%
      mutate(
        idx = row_number()
      )
    pred_list <- c(pred_list, list(this_pred_set))

  }

  pred_tibble <- do.call(bind_rows, pred_list)

  # join this back onto prediction_all to get the predictions in the right
  # order, then return those as a vector
  output <- prediction_data %>%
    group_by(
      insecticide_id
    ) %>%
    mutate(idx = row_number()) %>%
    ungroup() %>%
    left_join(
      pred_tibble,
      by = c("insecticide_id", "idx")
    ) %>%
    # now pull out the predictions, in the right order, as a tibble
    select(.pred)

  # return them
  output

}
