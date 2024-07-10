context("Collections implemented are working")


chk <- Sys.getenv("_R_CHECK_LIMIT_CORES_", "")

if (nzchar(chk) && chk == "TRUE") {
  # use 2 cores in CRAN/Travis/AppVeyor
  num_workers <- 2L
} else {
  # use all cores in devtools::test()
  num_workers <- parallel::detectCores()
}


require(modisfast)
require(sf)
require(magrittr)

roi <- st_as_sf(data.frame(id = "Korhogo",geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),wkt="geom",crs = 4326)


## test that errors are working
test_that("test if errors are sent back", {
  skip_on_cran()
  skip_on_ci()
  log <- mf_login(c(Sys.getenv("earthdata_un"),Sys.getenv("earthdata_pw")))
  # wrong type for roi
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = "not_a_sf_object", time_range = as.Date(c("2017-01-01","2017-02-01"))),"Argument roi must be an object of class sf or sfc with POLYGON-type feature geometry and at least two columns : 'id' and a geometry column that must not be NULL or NA")
 # wrong type for time range
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = c("2017-01-01","2017-02-01")),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n")
  # wrong dates
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2000-01-01","2017-02-01"))),"First time frame in time_range argument is before the beginning of the mission\n")
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2000-01-01","1999-02-01"))),"Time end is superior to time start in time_range argument \n")
  # wrong length for time range
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01","2017-02-03"))),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n")
  # wrong type for singleNetcdf
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), single_netcdf = "TRUE"),"single_netcdf argument must be boolean\n")
  # Collection does not exist
  #expect_error(mf_get_url(collection = "MOD11A1v006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01"))),"The collection that you specified does not exist. Check get_collections_available() to see which collections are implemented\n")
  # output format is not specified
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), output_format = NA),"Specified output format is not valid. Please specify a valid output format \n")
  # wrong variables specified
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), variables = c("LST_Day_1km","not_a_good_var")),"Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n")
  expect_error(mf_get_url(collection = "MOD11A1.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), variables = c("LST_Day_1km","time")),"Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n")

})




## test that the function mf_get_url is working (above in comments, to test all the collections)
#for (i in 1:nrow(modisfast:::opendapMetadata_internal)){
# collection_tested <- modisfast:::opendapMetadata_internal$collection[i]

#collection_tested <- c("GPM_3IMERGDE.06","MCD12Q1.006","SPL3SMP_E.003")
collection_tested <- c("GPM_3IMERGDF.07","MCD12Q1.061")

for (i in 1:length(collection_tested)){

  if(collection_tested[i] %in% c("GPM_3IMERGHH.07")){
    time_range = as.POSIXlt(c("2017-01-01 12:00:00","2017-01-02 02:00:00"))
  } else {
    time_range = as.Date(c("2017-01-01","2017-02-01"))
  }

  test_that(paste0(collection_tested[i]," is working"), {
    skip_on_cran()
    skip_on_ci()
    log <- mf_login(c(Sys.getenv("earthdata_un"),Sys.getenv("earthdata_pw")))

    opendap_urls <- mf_get_url(collection = collection_tested[i],
                                    roi = roi,
                                    time_range = time_range
                                    )

    expect_is(opendap_urls, "data.frame") # output is a data.frame
    expect_named(opendap_urls, c("id_roi","time_start","collection","name","url")) # column names are ok
    expect_gt(nrow(opendap_urls),0) # there is at least 1 row

    res <- mf_download_data(opendap_urls)

    expect_equal(unique(res$fileDl),TRUE) # all files have been downloaded

    for (j in 1:nrow(opendap_urls)){  # size is greater than 5 ko (meaning that a file with effective data has been downloaded, not an empty file)
      expect_gt(res$fileSize[j],5000)
    }

    })
}

#unlink("data", recursive = T) # remove directory with data downloaded
