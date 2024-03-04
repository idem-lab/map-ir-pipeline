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
  # make this id after the data have been combined
  rowid_to_column("uid") %>%
  select(
    # no country column - this can be inferred however
    start_month,
    start_year,
    end_month,
    end_year,
    latitude,
    longitude,
    # species - write "gambaie complex"
    no_mosquitoes_tested,
    # no mosquitoes dead? - can be calculated
    # no percent mortality? - instead we are using: l1014l_percent
    l1014l_percent,
    # need to add type
    # no identification method1?
    # no identification method2?
    generation,
    # no information on insecticide
  )

d7 %>%
  rowid_to_column("uid") %>%
  select(
    kdr_test_id,
    start_month,
    start_year,
    end_month,
    end_year,
    publication_year,
    site_name,
    latitude,
    longitude,
    no_mosquitoes_tested,
    identification_method_1,
    identification_method_2,
    generation,
    # no insecticide information
  )

# looks like d8 has most of the data that we want?
d8 %>%
  rowid_to_column("uid") %>%
  select(
    kdr_test_id,
    start_month,
    start_year,
    end_month,
    end_year,
    publication_year,
    site_name,
    latitude,
    longitude,
    no_mosquitoes_tested,
    # anophelines_tested, ## interesting?
    # no mosquitoes dead?
    # no percent mortality?
    # create type later
    identification_method_1,
    identification_method_2,
    generation,
    insecticide_tested
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
