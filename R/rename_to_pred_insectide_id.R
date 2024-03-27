#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
rename_to_pred_insectide_id <- function(.data) {

  rename_with(
    .data = .data,
    .fn = function(x){
      digits <- str_extract(
        names(.data),
        "[:digit:]"
      )
      paste0(".pred_insectide_id_",digits)
    }
  )

}
