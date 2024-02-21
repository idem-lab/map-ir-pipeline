#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param worldclimate
#' @param ir_data_moyes
#' @return
#' @author njtierney
#' @export
extract_from_raster <- function(raster, ir_data_subset, ir_data_sf_key) {

  # filter down to the right SF data
  sf_subset <- semi_join(ir_data_sf_key,
                         ir_data_subset,
                         by = "uid")

  extracted_raster <- terra::extract(raster,
                                     sf_subset,
                                     ID = FALSE) %>%
    as_tibble(.name_repair = make_clean_names) %>%
    mutate(
      uid = ir_data_subset$uid,
      .before = everything()
      )

  extracted_raster

}
