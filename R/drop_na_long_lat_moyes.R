#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_raw
#' @return
#' @author njtierney
#' @export
drop_na_long_lat_moyes <- function(moyes_geno_raw) {

  moyes_geno_raw |>
    mutate(
      across(
        c(longitude, latitude),
        \(x) na_if(x, "NR")
      )
    ) %>%
    mutate(
      across(
        c(longitude, latitude),
        \(x) na_if(x, "NF")
      )
    ) |>
    mutate(
      across(
        c(longitude, latitude),
        as.numeric
      )
    ) |>
    drop_na(c(longitude,
              latitude))

}
