#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param raster
#' @param training_data
#' @return
#' @author njtierney
#' @export
prepare_rasters_for_inner_loop <- function(rasters,
                                           training_data,
                                           models) {

  insecticide_ids <- sort(unique(training_data$insecticide_id))
  chosen_year <- max(as.integer(training_data$start_year))

  rasters_as_data <- raster_to_df(rasters)

  cli_warn(
    message = c(
      "Dear Golding: Interpret with caution",
      "The {.var no_mosquitoes_tested} and {.var no_mosquitoes_dead} values \\
      are totally made up because I haven't worked out how to populate the \\
      raster with corresponding values from the training data...hopefully \\
      that makes sense!"
    )
  )
  rasters_w_basic_info <- rasters_as_data %>%
    mutate(
      start_year = chosen_year,
      start_month = 1,
      end_month = 12,
      end_year = chosen_year,
      ## TODO
      # We need to add the following variables -
      # no_mosquitoes_tested...
      # no_mosquitoes_dead...
      # by interpolating them to be nearest to their corresponding
      # values in the data frame.
      # which can actually be done for all of the above values
      # for the time being thi will be random values...
      no_mosquitoes_tested = rpois(n = n(), lambda = 63),
      no_mosquitoes_dead = rpois(n = n(), lambda = 48),
      int = 1,
      .before = everything()
    )


  # names(rasters_w_basic_info) <- glue("raster_{seq_len(length(rasters))}")

  prepared_rasters <- map(
    .x = insecticide_ids,
    .f = function(ids) {
      mutate(
        .data = rasters_w_basic_info,
        insecticide_id = ids,
        .before = everything()
        )
    }
  )

  names(prepared_rasters) <- glue("insect_id_{insecticide_ids}")

  prepared_rasters

}
