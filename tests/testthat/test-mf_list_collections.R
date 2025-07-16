
test_that("function mf_list_collections() sends back the expected output", {

  skip_on_cran()
  skip_on_ci()

  coll <- mf_list_collections()

  expect_is(coll,'data.frame')  # output is a data.frame
  expect_equal(ncol(coll), 26) # there are 26 columns
  expect_named(coll, c("collection" ,"source","long_name" ,"nature","provider" ,
                       "url_metadata",  "doi", "version", "spatial_resolution_m" ,  "temporal_resolution",
                       "temporal_resolution_unit", "spatial_coverage", "start_date", "end_date","indicative_latency_days" ,
                       "url_manual_access" ,"status","login", "url_opendapserver" , "url_programmatic_access" ,
                       "url_opendapexample","dim_lon","dim_lat","dim_time" ,"dim_proj",  "crs" )) # column names are ok

  # number of rows is not tested since it can evolve with integration of additional opendap data sources

})
