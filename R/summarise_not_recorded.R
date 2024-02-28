#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data_raw
#' @return
#' @author njtierney
#' @export
summarise_not_recorded <- function(data_raw) {

  miss_scan_count(
    data_raw,
    search = "NR"
    ) %>%
    arrange(-n) %>%
    mutate(
      pct = n / nrow(data_raw)
    )

}
