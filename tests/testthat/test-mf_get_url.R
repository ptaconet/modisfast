

test_that("function mf_get_url() sends back the expected output for a MODIS query", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  urls_modis <- mf_get_url(collection = "MOD13A3.061",
                     variables = c("_1_km_monthly_NDVI"),
                     roi = roi,
                     time_range = time_range
  )

  expect_is(urls_modis, "data.frame") # output is a data.frame
  expect_named(urls_modis, c("id_roi","time_start","collection","name","url","maxFileSizeEstimated")) # column names are ok
  expect_equal(ncol(urls_modis), 6) # there are 6 columns
  expect_equal(nrow(urls_modis), 5)# there are 5 rows (corresponding to 5 tiles)
  expect_match(urls_modis$url[1], "https://opendap.cr.usgs.gov")  # urls starts with the right OPENDAP url

  expect_equal(urls_modis[,1:5], data.frame(id_roi = rep("madagascar",5),
                                time_start = rep(as.Date("2023-01-01"), 5),
                                collection = rep("MOD13A3.061", 5),
                                name = c("MOD13A3.061.2023001_2023060.h21v10.nc4", "MOD13A3.061.2023001_2023060.h21v11.nc4", "MOD13A3.061.2023001_2023060.h22v10.nc4", "MOD13A3.061.2023001_2023060.h22v11.nc4", "MOD13A3.061.2023001_2023060.h23v10.nc4"),
                                url = c( "https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.061/h21v10.ncml.nc4?MOD_Grid_monthly_1km_VI_eos_cf_projection,_1_km_monthly_NDVI%5B275:277%5D%5B922:1199%5D%5B1132:1199%5D,time%5B275:277%5D,YDim%5B922:1199%5D,XDim%5B1132:1199%5D",
                                         "https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.061/h21v11.ncml.nc4?MOD_Grid_monthly_1km_VI_eos_cf_projection,_1_km_monthly_NDVI%5B275:277%5D%5B0:749%5D%5B919:1199%5D,time%5B275:277%5D,YDim%5B0:749%5D,XDim%5B919:1199%5D",
                                         "https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.061/h22v10.ncml.nc4?MOD_Grid_monthly_1km_VI_eos_cf_projection,_1_km_monthly_NDVI%5B275:277%5D%5B165:1199%5D%5B0:1199%5D,time%5B275:277%5D,YDim%5B165:1199%5D,XDim%5B0:1199%5D",
                                         "https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.061/h22v11.ncml.nc4?MOD_Grid_monthly_1km_VI_eos_cf_projection,_1_km_monthly_NDVI%5B275:277%5D%5B0:749%5D%5B0:982%5D,time%5B275:277%5D,YDim%5B0:749%5D,XDim%5B0:982%5D",
                                         "https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.061/h23v10.ncml.nc4?MOD_Grid_monthly_1km_VI_eos_cf_projection,_1_km_monthly_NDVI%5B275:277%5D%5B165:351%5D%5B0:40%5D,time%5B275:277%5D,YDim%5B165:351%5D,XDim%5B0:40%5D")
  )
  )

})



test_that("function mf_get_url() sends back the expected output for a GPM query", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  urls_gpm <- mf_get_url(collection = "GPM_3IMERGDF.07",
                     variables = c("precipitation"),
                     roi = roi,
                     time_range = time_range
  )

  expect_is(urls_gpm, "data.frame") # output is a data.frame
  expect_named(urls_gpm, c("id_roi","time_start","collection","name","url","maxFileSizeEstimated")) # column names are ok
  expect_equal(ncol(urls_gpm), 6) # there are 5 columns
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


test_that("function mf_get_url() sends back the expected errors when necessary", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  # wrong type for roi
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = "not_a_sf_object",
                          time_range = as.Date(c("2017-01-01","2017-02-01"))),
               "Argument roi must be an object of class sf or sfc with POLYGON-type feature geometry and at least two columns : 'id' and a geometry column that must not be NULL or NA",
               fixed = TRUE)

  # wrong type for time range
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = c("2017-01-01","2017-02-01")),
               "Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n",
               fixed = TRUE)

  # wrong dates
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2000-01-01","2017-02-01"))),
               "First time frame in time_range argument is before the beginning of the mission\n",
               fixed = TRUE)

  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2000-01-01","1999-02-01"))),
               "Time end is superior to time start in time_range argument \n",
               fixed = TRUE)

  # wrong length for time range
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2017-01-01","2017-02-01","2017-02-03"))),
               "Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n",
               fixed = TRUE)

  # wrong type for singleNetcdf
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2017-01-01","2017-02-01")),
                          single_netcdf = "TRUE"),
               "single_netcdf argument must be boolean\n",
               fixed = TRUE)

  # Collection does not exist
  expect_error(mf_get_url(collection = "MOD13A3v006",
                          roi = roi,
                          time_range = as.Date(c("2017-01-01","2017-02-01"))),
               "The collection that you specified does not exist. Check mf_list_collections() to see which collections are implemented\n",
               fixed = TRUE)

  # output format is not specified
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2017-01-01","2017-02-01")),
                          output_format = NA),
               "Specified output format is not valid. Please specify a valid output format \n",
               fixed = TRUE)

  # wrong variables specified
  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2017-01-01","2017-02-01")),
                          variables = c("LST_Day_1km","not_a_good_var")),
               "Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n",
               fixed = TRUE)

  expect_error(mf_get_url(collection = "MOD13A3.061",
                          roi = roi,
                          time_range = as.Date(c("2017-01-01","2017-02-01")),
                          variables = c("LST_Day_1km","time")),
               "Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n",
               fixed = TRUE)

})
