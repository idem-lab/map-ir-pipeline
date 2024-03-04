# just read in a fraction of columns the original data, as a toy example
# data is from https://github.com/pahanc/Mapping-insecticide-resistance
library(tidyverse)
library(readr)
data_all <- as_tibble(read_rds("../demo-map-ir/data/data_all_wa.rds"))

ir_sample <- data_all %>%
  select(
    start_month,
    end_month,
    start_year,
    end_year,
    no_dead,
    no_tested,
    banana,
    bean,
    cereal,
    coconut,
    ins_ind,
    coffee
  ) %>%
  # create random genotypic/phenotypic variable, since I'm not sure where it is
  mutate(
    type = sample(
      x = c("genotypic", "phenotypic"),
      replace = TRUE,
      size = n()
    ),
    .before = everything()
  )

write_csv(ir_sample, "data/ir-data-sample.csv")

# explore which variables might potentially be the genotypic/phenotypic indicator
# could not find this - might need to ask Penny
# map_dfr(data_all, n_distinct) %>%
# pivot_longer(cols = everything(),
#              names_to = "vars",
#              values_to = "distinct") %>%
#   filter(distinct <= 3) %>%
#   arrange(distinct)
