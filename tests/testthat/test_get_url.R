context("Collections implemented are working")
skip_on_cran() # because it uses login
skip_on_travis()

require(opendapr)
require(sf)
require(magrittr)

roi = sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
log <- login(c(Sys.getenv("earthdata_un"),Sys.getenv("earthdata_pw")),"earthdata")


## test that errors are working
test_that("test if errors are sent back", {
  # wrong type for roi
  expect_error(get_url(collection = "MOD11A1.006", roi = "not_a_sf_object", time_range = as.Date(c("2017-01-01","2017-02-01"))),"Argument roi must be a object of class sf or sfc with only POLYGON-type geometries")
 # wrong type for time range
  expect_error(get_url(collection = "MOD11A1.006", roi = roi, time_range = c("2017-01-01","2017-02-01")),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n")
  # wrong dates
  expect_error(get_url(collection = "MOD11A1.006", roi = roi, time_range = as.Date(c("2000-01-01","2017-02-01"))),"First time frame in time_range argument is before the beginning of the mission\n")
  expect_error(get_url(collection = "MOD11A1.006", roi = roi, time_range = as.Date(c("2000-01-01","1999-02-01"))),"Time end is superior to time start in time_range argument \n")
  # wrong length for time range
  expect_error(get_url(collection = "MOD11A1.006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01","2017-02-03"))),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n")
  # wrong type for singleNetcdf
  expect_error(get_url(collection = "MOD11A1.006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), single_netcdf = "TRUE"),"single_netcdf argument must be boolean\n")
  # Collection does not exist
  #expect_error(get_url(collection = "MOD11A1v006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01"))),"The collection that you specified does not exist. Check get_collections_available() to see which collections are implemented\n")
  # output format is not specified
  expect_error(get_url(collection = "MOD11A1.006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), output_format = NA),"Specified output format is not valid. Please specify a valid output format \n")

})




## test that the function get_url is working (above in comments, to test all the collections)
#for (i in 1:nrow(opendapr:::opendapMetadata_internal)){
# collection_tested <- opendapr:::opendapMetadata_internal$collection[i]

collection_tested <- c("GPM_L3/GPM_3IMERGDE.06","MCD12Q1.006","SMAP/SPL3SMP_E.003")
for (i in 1:length(collection_tested)){

  if(collection_tested[i] %in% c("GPM_L3/GPM_3IMERGHHE.06","GPM_L3/GPM_3IMERGHHL.06","GPM_L3/GPM_3IMERGHH.06")){
    time_range = as.POSIXlt(c("2017-01-01 12:00:00","2017-01-02 02:00:00"))
  } else {
    time_range = as.Date(c("2017-01-01","2017-02-01"))
  }

  test_that(paste0(collection_tested[i]," is working"), {

    opendap_urls <- get_url(collection = collection_tested[i],
                                    roi = roi,
                                    time_range = time_range
                                    )

    expect_is(opendap_urls, "data.frame") # output is a data.frame
    expect_named(opendap_urls, c("time_start","name","url","destfile")) # column names are ok
    expect_gt(nrow(opendap_urls),0) # there is at least 1 row

    opendap_urls$destfile <- file.path("data",opendap_urls$destfile)
    res <- download_data(opendap_urls,source = "earthdata", parallel = TRUE)

    expect_equal(unique(res$fileDl),TRUE) # all files have been downloaded

    for (j in 1:nrow(opendap_urls)){  # size is greater than 5 ko (meaning that a file with effective data has been downloaded, not an empty file)
      expect_gt(res$fileSize[j],5000)
    }

    })
}

#unlink("data", recursive = T) # remove directory with data downloaded
