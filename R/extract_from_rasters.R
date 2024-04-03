#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param raster_covariates
#' @param ir_data_subset
#' @param ir_data_sf_key
#' @return
#' @author njtierney
#' @export
extract_from_rasters <- function(raster_covariates,
                                 ir_data_subset,
                                 ir_data_sf_key) {
  extracted_countries_covariates <- map(
    as.list(raster_covariates),
    function(x) {
      extract_from_raster(
        raster = x,
        ir_data_subset = ir_data_subset,
        ir_data_sf_key = ir_data_sf_key
      )
    }
  )

  extracted_countries_covariates
}
