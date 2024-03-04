#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes_raw
#' @return
#' @author njtierney
#' @export
summarise_not_found <- function(data_raw) {
  miss_scan_count(
    data_raw,
    "NF"
  ) %>%
    arrange(-n) %>%
    mutate(
      pct = n / nrow(data_raw)
    )
}
