#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param coffee_raster_as_data
#' @return
#' @author njtierney
#' @export
raster_df_add_year_insecticide <- function(coffee_raster_as_data,
                                           start_year = start_year,
                                           insecticide_id) {

  coffee_raster_as_data %>%
    mutate(
      start_year = start_year,
      insecticide_id = insecticide_id
    )

}
