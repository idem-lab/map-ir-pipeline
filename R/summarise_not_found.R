#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes_raw
#' @return
#' @author njtierney
#' @export
summarise_not_found <- function(ir_data_moyes_raw) {

  miss_scan_count(ir_data_moyes_raw,
                  "NF") %>%
    arrange(-n) %>%
    mutate(
      pct = n / nrow(ir_data_moyes_raw)
    )

}
