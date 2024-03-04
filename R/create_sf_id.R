#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes
#' @return
#' @author njtierney
#' @export
create_sf_id <- function(ir_data_moyes) {
  sf_moyes <- st_as_sf(
    ir_data_moyes,
    coords = c("longitude", "latitude"),
    # equivalent to "EPSG:4326" which technically is
    # strictly lat,lon for contexts where that matters
    crs = "OGC:CRS84"
  )

  # separating down to a unique ID and a geometry column so we can keep
  # this as a primary key of the data
  sf_moyes %>%
    select(
      uid,
      geometry,
      country
    )
}
