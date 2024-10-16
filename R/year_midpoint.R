#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param start_year
#' @param start_month
#' @param end_year
#' @param end_month
#' @return
#' @author Nick Golding
#' @export
# given integer start/end years/months, return the midpoint of the period as a
# decimal year
year_midpoint <- function(start_year, start_month, end_year, end_month) {
  start_month <- replace_na(start_month, 1)
  end_month <- replace_na(end_month, 12)
  end_year <- case_when(
    is.na(end_year) ~ start_year,
    .default = end_year
  )
  start_date <- zoo::as.yearmon(paste0(start_year, "-", start_month))
  end_date <- zoo::as.yearmon(paste0(end_year, "-", end_month))
  midpoint <- as.numeric((start_date + end_date) / 2)
  midpoint
}
