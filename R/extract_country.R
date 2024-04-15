#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param africa_df
#' @param shapefile
#' @return
#' @author njtierney
#' @export
extract_country <- function(africa_df = moyes_geno_raw,
                            shapefile = africa_shapefile) {
  pts <- africa_df |>
    select(
      longitude,
      latitude
    ) |>
    as.matrix()

  # this only returns something of length 1005
  # pts_index <- cellFromXY(object = rast(africa_shapefile), pts)
  # country_index <- africa_shapefile[pts_index]

  # but this returns the same length as africa_df
  extract_index <- terra::extract(shapefile, pts)

  afri_iso3c <- extract_index$shapeGroup

  africa_df |>
    mutate(
      country_iso3 = afri_iso3c,
      country_name = countrycode(
        sourcevar = country_iso3,
        origin = "iso3c",
        destination = "country.name",
      ),
      .before = everything()
    )
}
