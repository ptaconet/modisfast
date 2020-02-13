context("Collections implemented are working")
skip_on_cran() # because it uses login to usgs
skip_on_travis()

require(opendapr)
require(sf)

roi = sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
credentials_usgs <- config::get("usgs")
log <- login_usgs(c(credentials_usgs$usr,credentials_usgs$pwd))

for (i in 1:nrow(opendapr:::opendapMetadata_internal)){

  collection_tested <- opendapr:::opendapMetadata_internal$collection[i]

  if(collection_tested %in% c("GPM_L3/GPM_3IMERGHHE.06","GPM_L3/GPM_3IMERGHHL.06","GPM_L3/GPM_3IMERGHH.06")){
    time_range = as.POSIXlt(c("2017-01-01 12:00:00","2017-01-02 02:00:00"))
  } else {
    time_range = as.Date(c("2017-01-01","2017-01-20"))
  }

  test_that(paste0(collection_tested," is working"), {

    opendap_urls <- get_url(collection = collection_tested,
                                    roi = roi,
                                    time_range = time_range
                                    )

    expect_is(opendap_urls, "data.frame") # output is a data.frame
    expect_named(opendap_urls, c("time_start","name","url","destfile")) # column names are ok
    expect_gt(nrow(opendap_urls),0) # there is at least 1 row

    opendap_urls$destfile <- file.path("data",opendap_urls$destfile)
    res <- download_data(opendap_urls,data_source = "usgs", parallel = TRUE)

    expect_equal(unique(res$fileDl),TRUE) # all files have been downloaded

    for (j in 1:nrow(opendap_urls)){  # size is greater than 5 ko (meaning that a file with effective data has been downloaded, not an empty file)
      expect_gt(opendap_urls$destfile[j],5000)
    }

    })
}

#unlink("data", recursive = T) # remove directory with data downloaded
