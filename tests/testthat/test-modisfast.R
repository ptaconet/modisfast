
# earthdata_un = "my_username"
# earthdata_pw = "my_password"

################
# test mf_login()
################

test_that("function mf_login() sends back the expected and outputs and errors when necessary", {
  skip_on_cran()
  skip_on_ci()
  expect_error(mf_login(c(earthdata_un,earthdata_pw,"fd")),"credentials must be a vector character string of length 2 (username and password)\n", fixed = TRUE)
  expect_error(mf_login(c(earthdata_un)),"credentials must be a vector character string of length 2 (username and password)\n", fixed = TRUE)
  expect_error(mf_login(c(earthdata_un,"wrong password")))  # error if wrong password is provided
  expect_error(mf_login(c("wrong username",earthdata_pw)))  # error if wrong username is provided
  expect_null(mf_login(c(earthdata_un,earthdata_pw)))   # no error if right password or username are provided

})


################
# test mf_list_collections()
################

test_that("function mf_list_collections() sends back the expected output", {
  skip_on_cran()
  skip_on_ci()
  coll <- mf_list_collections()
  expect_is(coll,'data.frame')  # output is a data.frame
})

################
# test mf_list_variables()
################

log <- mf_login(c(earthdata_un,earthdata_pw))

test_that("function mf_list_variables() sends back the expected output", {

  skip_on_cran()
  skip_on_ci()

  # here we test with the collections "MOD13A3.061" and "GPM_3IMERGDF.07"
  vars_mod13a3 <- mf_list_variables("MOD13A3.061")
  expect_is(vars_mod13a3,'data.frame')  # output is a data.frame
  expect_named(vars_mod13a3, c("name","long_name","units","indices","all_info","extractable_with_modisfast")) # column names are ok
  expect_equal(nrow(vars_mod13a3), 17) # there are 17 rows (corresponding to 17 variables/bands for this collection)

  vars_gpm <- mf_list_variables("GPM_3IMERGDF.07")
  expect_is(vars_gpm,'data.frame')  # output is a data.frame
  expect_named(vars_gpm, c("name","long_name","units","indices","all_info","extractable_with_modisfast")) # column names are ok
  expect_equal(nrow(vars_gpm), 14) # there are 14 rows (corresponding to 14 variables/bands for this collection)

})



################  ################  ################  ################
## test downloading and importing of a MODIS datacube
################  ################  ################  ################

library(sf)
library(terra)

roi <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt = "geom", crs = 4326)
time_range <- as.Date(c("2023-01-01", "2023-03-31"))


test_that("function mf_get_url() sends back the expected output and errors when necessary", {
  skip_on_cran()
  skip_on_ci()
  urls <- mf_get_url(collection = "MOD13A3.061",
                     variables = c("_1_km_monthly_NDVI"),
                     roi = roi,
                     time_range = time_range
  )

  expect_is(urls, "data.frame") # output is a data.frame
  expect_named(urls, c("id_roi","time_start","collection","name","url")) # column names are ok
  expect_equal(ncol(urls), 5) # there are 5 columns
  expect_equal(nrow(urls), 5)# there are 5 rows (corresponding to 5 tiles)
  expect_match(urls$url[1], "https://opendap.cr.usgs.gov")  # urls starts with the right OPENDAP url

  # wrong type for roi
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = "not_a_sf_object", time_range = as.Date(c("2017-01-01","2017-02-01"))),"Argument roi must be an object of class sf or sfc with POLYGON-type feature geometry and at least two columns : 'id' and a geometry column that must not be NULL or NA", fixed = TRUE)
  # wrong type for time range
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = c("2017-01-01","2017-02-01")),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n", fixed = TRUE)
  # wrong dates
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2000-01-01","2017-02-01"))),"First time frame in time_range argument is before the beginning of the mission\n", fixed = TRUE)
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2000-01-01","1999-02-01"))),"Time end is superior to time start in time_range argument \n", fixed = TRUE)
  # wrong length for time range
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01","2017-02-03"))),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n", fixed = TRUE)
  # wrong type for singleNetcdf
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), single_netcdf = "TRUE"),"single_netcdf argument must be boolean\n", fixed = TRUE)
  # Collection does not exist
  expect_error(mf_get_url(collection = "MOD13A3v006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01"))),"The collection that you specified does not exist. Check mf_list_collections() to see which collections are implemented\n", fixed = TRUE)
  # output format is not specified
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), output_format = NA),"Specified output format is not valid. Please specify a valid output format \n", fixed = TRUE)
  # wrong variables specified
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), variables = c("LST_Day_1km","not_a_good_var")),"Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n", fixed = TRUE)
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), variables = c("LST_Day_1km","time")),"Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n", fixed = TRUE)

})

test_that("modisfast works to download a MODIS datacube", {
  skip_on_cran()
  skip_on_ci()

  urls <- mf_get_url(collection = "MOD13A3.061",
                     variables = c("_1_km_monthly_NDVI"),
                     roi = roi,
                     time_range = time_range
  )

  expect_is(urls, "data.frame") # output is a data.frame
  expect_named(urls, c("id_roi","time_start","collection","name","url")) # column names are ok
  expect_equal(ncol(urls), 5) # there are 5 columns
  expect_equal(nrow(urls), 5)# there are 5 rows (corresponding to 5 tiles)
  expect_match(urls$url[1], "https://opendap.cr.usgs.gov")  # urls starts with the right OPENDAP url

  # wrong type for roi
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = "not_a_sf_object", time_range = as.Date(c("2017-01-01","2017-02-01"))),"Argument roi must be an object of class sf or sfc with POLYGON-type feature geometry and at least two columns : 'id' and a geometry column that must not be NULL or NA", fixed = TRUE)
  # wrong type for time range
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = c("2017-01-01","2017-02-01")),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n", fixed = TRUE)
  # wrong dates
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2000-01-01","2017-02-01"))),"First time frame in time_range argument is before the beginning of the mission\n", fixed = TRUE)
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2000-01-01","1999-02-01"))),"Time end is superior to time start in time_range argument \n", fixed = TRUE)
  # wrong length for time range
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01","2017-02-03"))),"Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n", fixed = TRUE)
  # wrong type for singleNetcdf
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), single_netcdf = "TRUE"),"single_netcdf argument must be boolean\n", fixed = TRUE)
  # Collection does not exist
  expect_error(mf_get_url(collection = "MOD13A3v006", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01"))),"The collection that you specified does not exist. Check mf_list_collections() to see which collections are implemented\n", fixed = TRUE)
  # output format is not specified
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), output_format = NA),"Specified output format is not valid. Please specify a valid output format \n", fixed = TRUE)
  # wrong variables specified
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), variables = c("LST_Day_1km","not_a_good_var")),"Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n", fixed = TRUE)
  expect_error(mf_get_url(collection = "MOD13A3.061", roi = roi, time_range = as.Date(c("2017-01-01","2017-02-01")), variables = c("LST_Day_1km","time")),"Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n", fixed = TRUE)

  res_dl <- mf_download_data(urls)

  expect_is(res_dl,'data.frame')  # output is a data.frame
  expect_named(res_dl, c("id_roi","time_start","collection","name","url","destfile", "fileDl", "fileSize", "dlStatus")) # column names are ok
  expect_equal(ncol(res_dl), 9) # there are 9 columns
  expect_equal(nrow(res_dl), 5)# there are 5 rows (corresponding to 5 tiles)
  expect_equal(unique(res_dl$fileDl), TRUE)  # all files were properly downloaded (fileDl == TRUE for all files)
  expect_equal(sum(res_dl$fileSize),6129096)  # file size for this very specific example should be 6129096 bites (or very close)

  r_to_test <- mf_import_data(
    path = dirname(res_dl$destfile[1]),
    collection = "MOD13A3.061"
  )

  # the resulting raster should be equal to :
  # > r_to_test
  # class       : SpatRaster
  # dimensions  : 1785, 1522, 3  (nrow, ncol, nlyr)
  # resolution  : 926.6254, 926.6254  (x, y)
  # extent      : 4186957, 5597281, -2918407, -1264380  (xmin, xmax, ymin, ymax)
  # coord. ref. : +proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs
  # source(s)   : memory
  # varname     : _1_km_monthly_NDVI (1 km monthly NDVI)
  # names       : _1_km_monthly_NDVI_1, _1_km_monthly_NDVI_2, _1_km_monthly_NDVI_3
  # min values  :              -0.2000,                 -0.2,              -0.1993
  # max values  :               0.9868,                  1.0,               1.0000
  # time (days) : 2023-01-01 to 2023-03-01

  expect_is(r_to_test,'SpatRaster')  # output is a SpatRaster
  expect_equal(round(res(r_to_test)),c(927, 927))  # resolution
  expect_equal(dim(r_to_test),c(1785, 1522, 3))  # dimension
  expect_equal(ext(r_to_test),ext(4186957.01926165, 5597280.9283724, -2918406.80140823, -1264380.40340488))  # extent
  expect_equal(time(r_to_test),as.Date(c("2023-01-01", "2023-02-01", "2023-03-01")))  # dates
  expect_equal(names(r_to_test), c("_1_km_monthly_NDVI_1", "_1_km_monthly_NDVI_2", "_1_km_monthly_NDVI_3"))
  expect_equal(varnames(r_to_test), "_1_km_monthly_NDVI")

})


################  ################  ################  ################
## test downloading and importing of a GPM datacube
################  ################  ################  ################

test_that("modisfast works to download a GPM datacube", {

  skip_on_cran()
  skip_on_ci()

    urls <- mf_get_url(collection = "GPM_3IMERGDF.07",
                     variables = c("precipitation"),
                     roi = roi,
                     time_range = time_range
  )

  expect_is(urls, "data.frame") # output is a data.frame
  expect_named(urls, c("id_roi","time_start","collection","name","url")) # column names are ok
  expect_equal(ncol(urls), 5) # there are 5 columns
  expect_equal(nrow(urls), 90) # there are 90 rows (corresponding to 90 dates)
  expect_match(urls$url[1], "https://gpm1.gesdisc.eosdis.nasa.gov")  # urls starts with the right OPENDAP url

  res_dl <- mf_download_data(urls, parallel = TRUE) # download data, with parallelization

  expect_is(res_dl,'data.frame')  # output is a data.frame
  expect_named(res_dl, c("id_roi","time_start","collection","name","url","destfile", "fileDl", "fileSize", "dlStatus")) # column names are ok
  expect_equal(ncol(res_dl), 9) # there are 9 columns
  expect_equal(nrow(res_dl), 90 ) # there are 90 rows (corresponding to 90 dates)
  expect_equal(unique(res_dl$fileDl), TRUE)  # all files were properly downloaded (fileDl == TRUE for all files)
  expect_equal(sum(res_dl$fileSize),5689873)  # file size for this very specific example should be 5689873 bites (or very close)

  r_to_test <- mf_import_data(
    path = dirname(res_dl$destfile[1]),
    collection = "GPM_3IMERGDF.07"
  )

  # the resulting raster should be equal to :
  # > r_to_test
  # class       : SpatRaster
  # dimensions  : 149, 94, 90  (nrow, ncol, nlyr)
  # resolution  : 0.09999999, 0.1  (x, y)
  # extent      : 42, 51.4, -26.1, -11.2  (xmin, xmax, ymin, ymax)
  # coord. ref. : lon/lat WGS 84 (EPSG:4326)
  # source(s)   : memory
  # varname     : precipitation (Daily mean precipitation rate (combined microwave-IR) estimate. Formerly precipitationCal.)
  # names       : preci~ation, preci~ation, preci~ation, preci~ation, preci~ation, preci~ation, ...
  # min values  :       0.000,       0.000,        0.00,        0.00,        0.00,        0.00, ...
  # max values  :     169.725,     175.575,      106.55,      138.54,      172.57,      167.06, ...
  # time (days) : 2023-01-01 to 2023-03-31

  expect_is(r_to_test,'SpatRaster')  # output is a SpatRaster
  expect_equal(round(res(r_to_test),1),c(0.1,0.1))  # resolution
  expect_equal(dim(r_to_test),c(149, 94, 90))  # dimension
  expect_equal(ext(r_to_test),ext(41.9999992411624, 51.3999984700193, -26.1, -11.2))  # extent
  expect_equal(time(r_to_test),seq(as.Date("2023-01-01"),as.Date("2023-03-31"), 1))  # dates
  expect_equal(varnames(r_to_test), "precipitation")

})

