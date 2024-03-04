#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data
#' @param models
#' @return
#' @author njtierney
#' @export
predict_model <- function(data,
                          model) {
  predictions <- map2(
    .x = model,
    .y = data,
    .f = function(.x, .y) {
      predict(.x, as.data.frame(.y))
    }
  )

  engine_name <- extract_engine_name(model[[1]])

  new_name <- glue(".pred_{engine_name}")

  bind_rows(
    predictions,
    .id = "fold"
  ) %>%
    rename(
      !!new_name := .pred
    )
}
