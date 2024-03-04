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
    by = "uid"
  )

  extracted_raster <- extract(
    raster,
    sf_subset,
    ID = FALSE,
    method = "bilinear"
  ) %>%
    as_tibble(.name_repair = make_clean_names) %>%
    mutate(
      uid = ir_data_subset$uid,
      .before = everything()
    )

  ## add country information back onto the data

  sf_subset %>%
    # drop sf info?
    as.data.frame() %>%
    select(
      uid,
      country
    ) %>%
    left_join(
      extracted_raster,
      by = "uid"
    ) %>%
    as_tibble()
}
