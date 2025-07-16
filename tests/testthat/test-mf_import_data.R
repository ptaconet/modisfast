test_that("function mf_import_data() works to import a MODIS datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  modis_directory <- dirname(list.files(path = tempdir(), pattern = "MOD13A3.061.2023001_2023060.h21v10.nc4", recursive = TRUE, full.names = TRUE))

  r_to_test_modis <- mf_import_data(
    path = modis_directory,
    collection = "MOD13A3.061"
  )

  # the resulting raster should be equal to :
  # > r_to_test_modis
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

  expect_is(r_to_test_modis,'SpatRaster')  # output is a SpatRaster
  expect_equal(dim(r_to_test_modis),c(1785, 1522, 3))  # dimension
  expect_equal(round(res(r_to_test_modis)),c(927, 927))  # resolution
  expect_equal(ext(r_to_test_modis),ext(4186957.01926165, 5597280.9283724, -2918406.80140823, -1264380.40340488))  # extent
  expect_equal(time(r_to_test_modis),as.Date(c("2023-01-01", "2023-02-01", "2023-03-01")))  # dates
  expect_equal(names(r_to_test_modis), c("_1_km_monthly_NDVI_1", "_1_km_monthly_NDVI_2", "_1_km_monthly_NDVI_3"))
  expect_equal(varnames(r_to_test_modis), "_1_km_monthly_NDVI")


})


test_that("function mf_import_data() works to import a GPM datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  gpm_directory <- dirname(list.files(path = tempdir(), pattern = "3B-DAY.MS.MRG.3IMERG.20230101-S000000-E235959.V07B.nc4", recursive = TRUE, full.names = TRUE))

  r_to_test_gpm <- mf_import_data(
    path = gpm_directory,
    collection = "GPM_3IMERGDF.07"
  )

  # the resulting raster should be equal to :
  # > r_to_test_gpm
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

  expect_is(r_to_test_gpm,'SpatRaster')  # output is a SpatRaster
  expect_equal(dim(r_to_test_gpm),c(149, 94, 90))  # dimension
  expect_equal(round(res(r_to_test_gpm),1),c(0.1,0.1))  # resolution
  expect_equal(ext(r_to_test_gpm),ext(41.9999992411624, 51.3999984700193, -26.1, -11.2))  # extent
  expect_equal(time(r_to_test_gpm),seq(as.Date("2023-01-01"),as.Date("2023-03-31"), 1))  # dates
  expect_equal(varnames(r_to_test_gpm), "precipitation") # variable names


})
