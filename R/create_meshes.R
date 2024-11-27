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
                          # a scaling factor to contrl the mesh resolution.
                          # default value of 1 returns what looks like a
                          # reasonable trade-off of computational complexity
                          # versus quality, for Benin.
                          mesh_resolution_scaling = 1,
                          min.angle = c(25, 25),
                          tmesh.yr.by = 2) {


  # convert latlongs to xyz coordinates of unique points
  unique_xyz <- ir_data %>%
    select(longitude, latitude) %>%
    distinct() %>%
    ll_to_xyz()

  # scale the mesh according to the maximum dimension of the coordinates
  dimension <- apply(coords_xyz, 2, function(x) diff(range(x)))

  # minimum edge length inside the boundary
  min_edge <- max(dimension) / (mesh_resolution_scaling * 20)

  # outside the boundary it's 5x coarser
  max.edge <- min_edge * c(1, 5)

  # set the cutoff (minimum distance between observations points) to half the
  # inner edge minimum
  cutoff <- min_edge / 2

  # make the spatial mesh; mesh creation code from
  # indep_model_gen_gauss_4way_val.r, object called 'mesh' there
  spatial_mesh <- INLA::inla.mesh.2d(
    loc = unique_xyz,
    cutoff = cutoff,
    min.angle = min.angle,
    max.edge = max.edge)

  tmesh.yr.st <- min(ir_data$start_year)
  tmesh.yr.end <- max(ir_data$end_year)
  # Penny has this one higher, so copying
  tmesh.yr.end2 <- tmesh.yr.end + 1

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
