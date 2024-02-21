library(tidyverse)
d6 <- read_csv(
  file = "~/Downloads/doi_10_5061_dryad_dn4676s__v20190308/6_Vgsc-allele-freq_complex-subgroup.csv",
  name_repair = make_clean_names
  )

# problems?
d7 <- read_csv(
  file = "~/Downloads/doi_10_5061_dryad_dn4676s__v20190308/7_Vgsc-allele-freq_species.csv",
  name_repair = make_clean_names
  )
problems(d7)

d8 <- read_csv(
  file = "~/Downloads/doi_10_5061_dryad_dn4676s__v20190308/8_Vgsc-allele-freq_survivors-dead.csv",
  name_repair = make_clean_names
  )

head(names(d6), 30)
head(names(d8), 30)
