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

View(d6)
View(d7)
View(d8)

dim(d6)
names(d6)
names(ir_data)

d6 %>%
  rowid_to_column("uid") %>%
  select(kdr_test_id,
         # no country column - this can be inferred however
         start_month,
         start_year,
         end_month,
         end_year,
         publication_year,
         site_name,
         latitude,
         longitude,
         # no species name!
         no_mosquitoes_tested,
         # no mosquitoes dead?
         # no percent mortality?
         # need to add type
         # no identification method1?
         # no identification method2?
         generation,
         # no information on insecticide
         )



coded_places <- tibble(
  latitude = c(38.895865, 43.6534817),
  longitude = c(-77.0307713, -79.3839347)
) %>%
  reverse_geocode(
    lat = latitude,
    long = longitude,
    method = "osm",
    full_results = TRUE
  )

coded_places$country_code
coded_places$country


dim(d8)

names(d6)
names(d8)
