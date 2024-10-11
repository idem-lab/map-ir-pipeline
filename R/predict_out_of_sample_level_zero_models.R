#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param in_sample_data
#' @param level_zero_model_list
#' @return
#' @author njtierney
#' @export
predict_out_of_sample_level_zero_models <- function(in_sample_data,
                                                    level_zero_model_list,
                                                    new_data,
                                                    n_insecticides) {

  # fit models to full training dataset
  in_sample_fitted <- map(
    .x = level_zero_model_list,
    .f = \(x) fit(object = x, data = in_sample_data)
  )

  # and predict to full prediction dataset (messing around with names)
  old_names <- names(in_sample_fitted)
  names(in_sample_fitted) <- paste0(".pred_", old_names)
  in_sample_covariates <- map_dfc(
    in_sample_fitted,
    \(x) predict(x, new_data)
  ) %>%
    set_names(old_names)

  in_sample_covariates

}
