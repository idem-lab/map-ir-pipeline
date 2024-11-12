#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param covariate_names
#' @param outcome
#' @param mesh
#' @param alpha INLA SPDE matern parameter
#' @param prior.range INLA SPDE matern parameter
#' @param prior.sigma INLA SPDE matern parameter
#' @return
#' @author njtierney
#' @export
setup_gp_inla_model <- function(
    ir_data,
    covariate_names,
    outcome,
    meshes,
    alpha = 2,
    prior.range = c(0.0003, 0.01),
    prior.sigma = c(5, 0.01)) {

  # create the SPDE objects for INLA model specification, from the meshes

  # one SPDE object for the spatial effect
  spatial_spde <- INLA::inla.spde2.pcmatern(
    mesh = meshes$spatial_mesh,
    alpha = alpha,
    prior.range = prior.range,
    prior.sigma = prior.sigma
  )

  # a different named temporal SPDE object for each insecticide ID
  n_groups <- dplyr::n_distinct(ir_data$insecticide_id)
  temporal_effects <- list()
  for (i in seq_len(n_groups)) {
    temporal_effects[[i]] <- INLA::inla.spde.make.index(
      name = paste0("temporal.field", i),
      n.spde = meshes$temporal_mesh$n,
      n.group = meshes$temporal_mesh$m)
  }

  # for now, just pass through the objects as a named list
  list(
    covariate_names = covariate_names,
    outcome = outcome,
    spatial_spde = spatial_spde,
    temporal_effects = temporal_effects,
    meshes = meshes
  )

}
