#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
rename_insecticide_ids <- function(gp_inla_data_n_star_is_pred) {

  gp_inla_data_n_star_is_pred %>%
    rename_with(
      .fn = function(x){
        digits <- str_extract(
          names(gp_inla_data_n_star_is_pred),
          "[:digit:]"
        )
        paste0(".pred_insectide_id_",digits)
      }
    )

}
