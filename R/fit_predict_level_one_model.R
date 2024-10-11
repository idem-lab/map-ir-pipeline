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
  # insecticides, and stack them together

  # get the number of groups (insecticide types modelled simultaneously) and the
  # names of the covariates/models used in stacking
  n_groups <- length(level_one_model_setup$temporal_effects)
  group_vec <- seq_len(n_groups)
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

  # Need to work out what format each of Penny and Nick T are using for the
  # training and prediction data to amke sure they match

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
      mort = percent_mortality,
      w = 1,
      year = "?"
    ) %>%
    # keep the stuff we need from here
    select(mort,
           w,
           year,
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
      year = "?"
    ) %>%
    # keep the stuff we need from here
    select(mort,
           w,
           year,
           x, y, z) %>%
    # and add on the level 0 predictions from in-sample models
    bind_cols(prediction_covariates)


  # for each of these, split them up by insecticide type, and make data stack
  # objects



  # build up the INLA stack object for a single group (insecticide type)
  # IRT_dat_c <- ir_data %>%
  #   mutate(mort = ?,
  #          w = 1,
  #          year = ?) %>%
  #   # add on training covariates (level 0 stacker out-of-sample predictions)
  #   left_join(training_covariates,
  #             by = ?) %>%
  #   # add on x,y,z coordinates from latlongs

  # prediction data (flagged with NAs in the response column)
  # use prediction_covariates, and make sure the coordinates match
  # IRT_dat_v <- prediction_covariates %>%
  #   mutate(y = NA,
  #          w = 1,
  #          year = ?) %>%
  # add on x,y,z coordinates from latlongs

  # IRT_dat1_c <- IRT_dat_c %>%
  #   filter(insecticide_id == 1)

  # IRT_dat1_v <- IRT_dat_c %>%
  #   filter(insecticide_id == 1)

  # replaces this:
  # IRT_dat1 <- data.frame(y = as.vector(data1[,7]),
  #                        w = rep(1, length(data1[,7])),
  #                        year = year1,
  #                        xcoo = coords_est1[,1],
  #                        ycoo = coords_est1[,2],
  #                        zcoo = coords_est1[,3],
  #                        cov = training_covariates)
  # IRT_dat1_c <- IRT_dat1[-isel1a, ]
  # IRT_dat1_v <- data.frame(
  #   y = rep(NA, nrow(IRT_dat1)),
  #   w = rep(1, length(data1[,7])),
  #   year = year1,
  #   xcoo = coords_est1[,1],
  #   ycoo = coords_est1[,2],
  #   zcoo = coords_est1[,3],
  #   cov = prediction_covariates)

  # # indices for making the projection 'A' matrices from the mesh to each of the
  # # training and prediction datasets
  # IRT_iset1 <- inla.spde.make.index('field1',
  #                                   n.spde = meshes$spatial_mesh$n,
  #                                   n.group = meshes$temporal_mesh$m)
  #
  # # training data stack:
  #
  # # projection matrix for mapping from the mesh nodes to prediction data
  # IRT_A1_c <- inla.spde.make.A(meshes$spatial_mesh,
  #                              loc = cbind(IRT_dat1_c$xcoo,
  #                                          IRT_dat1_c$ycoo,
  #                                          IRT_dat1_c$zcoo),
  #                              group = IRT_dat1_c$year,
  #                              group.mesh = meshes$temporal_mesh)
  # # in an INLA stack object
  # IRT_stk1_c <- inla.stack(
  #   tag = "data1",
  #   data = list(y = cbind(IRT_dat1_c$y, NA, NA, NA)),
  #   A = list(IRT_A1_c, 1),
  #   effects = list(IRT_iset1,
  #                  list(b0.1 = IRT_dat1_c$w,
  #                       IRT_dat1_c[, covariate_names])))
  #
  # # prediction data stack:
  #
  # # projection matrix for mapping from the mesh nodes to prediction data
  # IRT_A1_v <- inla.spde.make.A(meshes$spatial_mesh,
  #                              loc = cbind(IRT_dat1_v$xcoo,
  #                                          IRT_dat1_v$ycoo,
  #                                          IRT_dat1_v$zcoo),
  #                              group = IRT_dat1_v$year,
  #                              group.mesh = meshes$temporal_mesh)
  #
  # # in an INLA stack object
  # IRT_stk1_v <- inla.stack(
  #   tag = "val1",
  #   data = list(y = cbind(IRT_dat1_v$y, NA, NA, NA)),
  #   A = list(IRT_A1_v, 1),
  #   effects = list(IRT_iset1,
  #                  list(b0.1 = IRT_dat1_v$w,
  #                       IRT_dat1_v[, covariate_names])))




  # make the overall INLA stack object, combining the fitting (c) and prediction
  # data (v) for each group
  # j.stk <- inla.stack(IRT_stk1_c,
  #                     IRT_stk1_v,
  #                     IRT_stk2_c,
  #                     IRT_stk2_v,
  #                     IRT_stk3_c,
  #                     IRT_stk3_v,
  #                     IRT_stk4_c,
  #                     IRT_stk4_v)

  # make this by combining the two lists of stack objects

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
  group_intercept_terms <- paste0("b0.", group_vec, collapse = " + ")

  # each group has a space-time random effect (Matern x AR1), represented as an
  # SPDE, with pcrho giving the penalised complexity prior for the rho parameter
  # (temporal correlation) of the AR1 process
  field_fixed <- "model = spatial_spde,
  control.group = list(model = 'ar1', hyper = pcrho)"
  field_terms_vec <- sprintf("f(field%i, group = field_group%i, %s)",
                             group_vec, group_vec, field_fixed)
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
        group_field_terms,  # "f(field1, group = field_group1, ...) + ...",
        sep = " + "))

  stop("not yet implemented")

  # Run the INLA model
  result <- INLA::inla(

    # specify the formula
    formula = inla_formula,

    # Gaussian observation model over logit-transformed data
    family = rep("Gaussian",
                 n_groups),

    # provide the full dataset, for all the fields, etc.
    data = inla.stack.data(j.stk),

    # specify the measurement noise priors
    control.family = replicate(n_groups,
                               eprec,
                               simplify = FALSE),

    # make predictions
    control.predictor = list(compute = TRUE,
                             A = inla.stack.A(j.stk)),
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

  # for now, return the full list of things that Penny did
  output <- list(
    gauss_j.res = result,
    isel1 = isel1,
    isel2 = isel2,
    isel3 = isel3,
    isel4 = isel4,
    isel1a = isel1a,
    isel2a = isel2a,
    isel3a = isel3a,
    isel4a = isel4a
  )

  output

}
