test_that("function mf_get_url() sends back the expected output for a MODIS query", {

  skip_on_cran()
  skip_on_ci()
  skip_if_token_not_provided()

  urls_modis <- mf_get_url(collection = "VNP21A2.002",
                           variables = c("LST_Day_1KM"),
                           roi = roi,
                           time_range = time_range
  )

  expect_is(urls_modis, "data.frame") # output is a data.frame
  expect_named(urls_modis, c("id_roi","time_start","collection","name","url","grid_nrow","grid_ncol","maxFileSizeEstimated")) # column names are ok
  expect_equal(ncol(urls_modis), 8) # there are 8 columns
  expect_equal(nrow(urls_modis), 60)# there are 60 rows (corresponding to 5 tiles * 12 dates)
  expect_match(urls_modis$url[1], "https://opendap.earthdata.nasa.gov/")  # urls starts with the right OPENDAP url

  observed <- urls_modis[1:5, 1:5]
  rownames(observed) <- NULL
  expect_equal(observed, data.frame(id_roi = rep("madagascar",5),
                                            time_start = rep(as.Date("2023-01-01"), 5),
                                            collection = rep("VNP21A2.002", 5),
                                            name = c("VNP21A2.A2023001.h21v10.002.2023146014559_LST_Day_1KM.nc4", "VNP21A2.A2023001.h21v11.002.2023146014601_LST_Day_1KM.nc4", "VNP21A2.A2023001.h22v10.002.2023146015101_LST_Day_1KM.nc4", "VNP21A2.A2023001.h22v11.002.2023146015101_LST_Day_1KM.nc4", "VNP21A2.A2023001.h23v10.002.2023146015102_LST_Day_1KM.nc4"),
                                            url = c( "https://opendap.earthdata.nasa.gov/collections/C2545314562-LPCLOUD/granules/VNP21A2.A2023001.h21v10.002.2023146014559.nc4?/HDFEOS/GRIDS/VIIRS_Grid_8Day_1km_LST21/Data_Fields/LST_Day_1KM%5B164:1199%5D%5B917:1199%5D",
                                                     "https://opendap.earthdata.nasa.gov/collections/C2545314562-LPCLOUD/granules/VNP21A2.A2023001.h21v11.002.2023146014601.nc4?/HDFEOS/GRIDS/VIIRS_Grid_8Day_1km_LST21/Data_Fields/LST_Day_1KM%5B0:740%5D%5B917:1199%5D",
                                                     "https://opendap.earthdata.nasa.gov/collections/C2545314562-LPCLOUD/granules/VNP21A2.A2023001.h22v10.002.2023146015101.nc4?/HDFEOS/GRIDS/VIIRS_Grid_8Day_1km_LST21/Data_Fields/LST_Day_1KM%5B164:1199%5D%5B0:1199%5D",
                                                     "https://opendap.earthdata.nasa.gov/collections/C2545314562-LPCLOUD/granules/VNP21A2.A2023001.h22v11.002.2023146015101.nc4?/HDFEOS/GRIDS/VIIRS_Grid_8Day_1km_LST21/Data_Fields/LST_Day_1KM%5B0:740%5D%5B0:1199%5D",
                                                     "https://opendap.earthdata.nasa.gov/collections/C2545314562-LPCLOUD/granules/VNP21A2.A2023001.h23v10.002.2023146015102.nc4?/HDFEOS/GRIDS/VIIRS_Grid_8Day_1km_LST21/Data_Fields/LST_Day_1KM%5B164:1199%5D%5B0:30%5D")
  )
  )

})



test_that("function mf_get_url() sends back the expected output for a GPM query", {

  skip_on_cran()
  skip_on_ci()
  skip_if_token_not_provided()

  urls_gpm <- mf_get_url(collection = "GPM_3IMERGDF.07",
                     variables = c("precipitation"),
                     roi = roi,
                     time_range = time_range
  )

  expect_is(urls_gpm, "data.frame") # output is a data.frame
  expect_named(urls_gpm, c("id_roi","time_start","collection","name","url","grid_nrow","grid_ncol","maxFileSizeEstimated")) # column names are ok
  expect_equal(ncol(urls_gpm), 8) # there are 8 columns
  expect_equal(nrow(urls_gpm), 90) # there are 90 rows (corresponding to 90 dates)
  expect_match(urls_gpm$url[1], "https://gpm1.gesdisc.eosdis.nasa.gov")  # urls starts with the right OPENDAP url

  expect_equal(urls_gpm[1,1:5], data.frame(id_roi = "madagascar",
                                      time_start = as.Date("2023-01-01"),
                                      collection = "GPM_3IMERGDF.07",
                                      name = "3B-DAY.MS.MRG.3IMERG.20230101-S000000-E235959.V07B.nc4",
                                      url ="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.07/2023/01/3B-DAY.MS.MRG.3IMERG.20230101-S000000-E235959.V07B.nc4.nc4?precipitation%5B0:0%5D%5B2220:2313%5D%5B639:787%5D,time%5B0:0%5D,lon%5B2220:2313%5D,lat%5B639:787%5D"
                                      )
  )


})


test_that("mf_get_url is the Cloud entry point and rejects unsupported products", {
  previous <- Sys.getenv("EARTHDATA_TOKEN", unset = NA_character_)
  on.exit(if (is.na(previous)) Sys.unsetenv("EARTHDATA_TOKEN") else
    Sys.setenv(EARTHDATA_TOKEN = previous), add = TRUE)
  Sys.setenv(EARTHDATA_TOKEN = "test-token-not-sent-to-network")
  expect_error(mf_get_url("NOT_A_COLLECTION", "band", roi,
                          as.Date("2025-01-01")),
               "mf_list_collections_cloud")
  expect_false("mf_get_url_cloud" %in% getNamespaceExports("modisfast"))
  expect_error(mf_get_url("GPM_3IMERGDF.07", "precipitation", roi,
                          as.Date("2023-01-01"),
                          collection_id = "C1748058432-LPCLOUD"),
               "collection_id applies only")
})

test_that("Earthdata token supplies the authentication header", {
  previous <- Sys.getenv("EARTHDATA_TOKEN", unset = NA_character_)
  on.exit(if (is.na(previous)) Sys.unsetenv("EARTHDATA_TOKEN") else
    Sys.setenv(EARTHDATA_TOKEN = previous), add = TRUE)
  Sys.setenv(EARTHDATA_TOKEN = "test-token-not-sent-to-network")
  expect_false(is.null(modisfast:::.mf_earthdata_auth()))
})

test_that("public URL and download functions use token-only arguments", {
  previous <- Sys.getenv("EARTHDATA_TOKEN", unset = NA_character_)
  on.exit(if (is.na(previous)) Sys.unsetenv("EARTHDATA_TOKEN") else
    Sys.setenv(EARTHDATA_TOKEN = previous), add = TRUE)
  Sys.setenv(EARTHDATA_TOKEN = "test-token-not-sent-to-network")
  expect_false(any(c("credentials", "output_format", "single_netcdf",
                     "opt_param") %in% names(formals(mf_get_url))))
  expect_false("credentials" %in% names(formals(mf_download_data)))
  expect_false(any(c("earthdata_username", "earthdata_password") %in%
                   names(formals(mf_modisfast))))
  expect_error(mf_get_url("NOT_A_COLLECTION", "band", roi,
                          as.Date("2025-01-01"), verbose = TRUE),
               "verbose must be one of")
  progress <- capture.output(expect_error(mf_get_url(
    "NOT_A_COLLECTION", "band", roi, as.Date("2025-01-01")),
    "mf_list_collections_cloud"))
  expect_true("Building the URLs..." %in% progress)
})

test_that("URL and variable queries require a token before network access", {
  previous <- Sys.getenv("EARTHDATA_TOKEN", unset = NA_character_)
  on.exit(if (is.na(previous)) Sys.unsetenv("EARTHDATA_TOKEN") else
    Sys.setenv(EARTHDATA_TOKEN = previous), add = TRUE)
  Sys.unsetenv("EARTHDATA_TOKEN")
  expect_error(mf_get_url("VJ121A2.002", "LST_Day_1KM", roi,
                          as.Date("2026-01-01")),
               "Set EARTHDATA_TOKEN.*mf_get_url")
  expect_error(mf_list_variables("VJ121A2.002"),
               "Set EARTHDATA_TOKEN.*mf_list_variables")
})

test_that("URL inputs fail with actionable messages before network access", {
  previous <- Sys.getenv("EARTHDATA_TOKEN", unset = NA_character_)
  on.exit(if (is.na(previous)) Sys.unsetenv("EARTHDATA_TOKEN") else
    Sys.setenv(EARTHDATA_TOKEN = previous), add = TRUE)
  Sys.setenv(EARTHDATA_TOKEN = "test-token-not-sent-to-network")
  date <- as.Date("2026-01-01")
  expect_error(mf_get_url("VJ121A2.002", NULL, roi, date),
               'mf_list_variables\\("VJ121A2.002"\\)')
  expect_error(mf_get_url("GPM_3IMERGDF.07", NULL, roi, date),
               'mf_list_variables\\("GPM_3IMERGDF.07"\\)')
  expect_error(mf_get_url("VJ121A2.002", "LST_Day_1KM", "not a polygon", date),
               "roi must be a non-empty sf object")
  expect_error(mf_get_url("VJ121A2.002", "LST_Day_1KM", roi, "2026-01-01"),
               "time_range must be one Date")
  expect_error(mf_get_url("VJ121A2.002", "LST_Day_1KM", roi,
                          as.Date(c("2026-01-30", "2026-01-01"))),
               "start date before its end date")
  expect_error(mf_get_url("VJ121A2.002", "LST_Day_1KM", roi,
                          as.Date(character())),
               "time_range must be one Date")
  expect_silent(modisfast:::.testTimeRange(date))
  expect_error(mf_get_url("VJ121A2.002", "LST_Day_1KM",
                          sf::st_set_crs(roi, NA), date),
               "roi must have a coordinate reference system")
  expect_error(mf_list_variables("NOT_A_COLLECTION"),
               "mf_list_collections_cloud")
  expect_error(mf_list_variables("VJ121A2.002", time_range = "2026-01-01"),
               "time_range must be one Date")
})
