# simulating data to assist with understanding the general modelling process.
library(tidyverse)

generate_ir_data <- function(n_rows) {
  tibble(
    year = rep(seq(2005, 2017), length.out = n_rows),
    no_dead = rpois(n_rows, 57),
    no_tested = rpois(n_rows, 99),
    x1 = rnorm(n_rows),
    x2 = runif(n_rows),
    x3 = rnorm(n_rows, 10, 5),
    x4 = rnorm(n_rows, 100, 1),
    x5 = rnorm(n_rows, 50, 5),
  ) %>%
    arrange(year)
}

ir_data_phenotypic <- generate_ir_data(1000)
ir_data_genotypic <- generate_ir_data(1000)

ir_data <- bind_rows(
  genotypic = ir_data_phenotypic,
  phenotypic = ir_data_genotypic,
  .id = "type"
)

ir_data

write_csv(ir_data, here::here("data/simulated-ir-data.csv"))
