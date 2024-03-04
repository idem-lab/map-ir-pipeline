library(tidyverse)
library(readr)

covariate_names <- read_rds("../demo-map-ir/data/covariate_names_all_wa.rds")

write_rds(covariate_names,
  here::here("data/ir-data-covariates.rds"),
  compress = "xz"
)
