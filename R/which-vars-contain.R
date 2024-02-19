which_vars_contain <- function(data, containing){
  data %>%
    map_lgl(
      \(x) any(x == containing)
    ) %>%
    keep(isTRUE) %>%
    names()
}
