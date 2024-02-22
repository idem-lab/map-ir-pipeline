#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_raw
#' @return
#' @author njtierney
#' @export
geocode_geno_data <- function(moyes_geno_raw) {
  geno_lat_lon <- moyes_geno_raw %>%
    select(
      latitude,
      longitude
    )

  geocoded <- reverse_geocode(
    geno_lat_lon,
    lat = latitude,
    long = longitude,
    method = "osm",
    full_results = TRUE
  )

}
