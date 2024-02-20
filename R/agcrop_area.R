#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param crop
#' @return
#' @author njtierney
#' @export
agcrop_area <- function(crop = "acof") {

  crop_spam(
    crop = crop,
    var = "area",
    path = "data",
    africa = TRUE
  )

}
