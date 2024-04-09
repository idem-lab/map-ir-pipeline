#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param rasters
#' @param mosquito_data
#' @return
#' @author njtierney
#' @export
join_rasters_to_mosquito_data <- function(rasters = raster_covariates,
                                          mosquito_data = ir_data_subset,
                                          extract_method = "bilinear") {
  cli_inform(
    message = c(
      "Using extraction method: {.var {extract_method}}",
      "In {.fn extract_from_raster}"
    )
  )

  extracted_raster_covariates <- extract_from_raster(
    raster = rasters,
    ir_data_subset = mosquito_data,
    extract_method = extract_method
  ) %>%
    # impute 0 into missing values for all rasters
    mutate(
      across(
        .cols = everything(),
        .fns = impute_zero
      )
    )

  ir_data_subset_spatial_covariates <- left_join(
    mosquito_data,
    extracted_raster_covariates,
    by = c("uid", "country")
  )

  ir_data_subset_spatial_covariates

}
