cgaz_country <- function(country_name){
  cgaz_source <- CGAZ()
  cgaz_query <- CGAZ_sql(country_name)

  v <- vect(
    x = cgaz_source,
    query = cgaz_query
  )

  v
}
