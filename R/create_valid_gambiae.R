#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
create_valid_gambiae <- function() {

  # from:
  # moyes_pheno_raw %>%
  # pull(species) %>%
    # unique()

  valid_gambiae <- c(
    "Anopheles coluzzii/gambiae",
    "Anopheles arabiensis",
    "Anopheles gambiae",
    "Anopheles coluzzii",
    # "Anopheles funestus",
    # "Anopheles rivulorum",
    # "Anopheles pharoensis",
    # "Anopheles mascarensis",
    "Anopheles melas",
    # "Anopheles parensis",
    "Anopheles quadriannulatus"
  )

  valid_gambiae


}
