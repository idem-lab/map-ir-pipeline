#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @return
#' @author njtierney
#' @export
create_meshes <- function(ir_data,
                        # Penny's mesh setup options from line 32-38
                        # inputs_list_wa_gauss_DPLA.r, to edit later
                        m1.cutoff = 0.005,
                        m1.min.angle = c(25, 25),
                        m1.max.edge = c(0.05, 1000),
                        tmesh.yr.st = 2005,
                        tmesh.yr.end = 2017,
                        tmesh.yr.end2 = 2018,
                        tmesh.yr.by = 2) {


  # convert latlongs to xyz coordinates of unique points
  unique_xyz <- ir_data %>%
    select(longitude, latitude) %>%
    distinct() %>%
    ll_to_xyz()

  # make the spatial mesh; mesh creation code from
  # indep_model_gen_gauss_4way_val.r, object called 'mesh' there
  spatial_mesh <- INLA::inla.mesh.2d(
    loc = unique_xyz,
    cutoff = m1.cutoff,
    min.angle = m1.min.angle,
    max.edge = m1.max.edge)

  # make the temporal mesh, object called 'mesh1d' there
  temporal_mesh <- INLA::inla.mesh.1d(
    seq(tmesh.yr.st, tmesh.yr.end, by = tmesh.yr.by),
    interval = c(tmesh.yr.st, tmesh.yr.end2),
    degree = 2,
    boundary = "free")

  # return the meshes in a list
  list(
    spatial_mesh = spatial_mesh,
    temporal_mesh = temporal_mesh
  )

}
