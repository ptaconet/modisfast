test_that("function mf_import_data() works to import a VIIRS datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_token_not_provided()

  viirs_directory <- dirname(list.files(path = tempdir(), pattern = "VNP21A2.A2023001.h21v10.002.2023146014559_LST_Day_1KM.nc4", recursive = TRUE, full.names = TRUE))

  r_to_test_viirs <- mf_import_data(
    path = viirs_directory,
    collection = "VJ121A2.002"
  )

  # the resulting raster should be equal to :
  # > r_to_test_viirs
  #class       : SpatRaster
  #size        : 1777, 1514, 12  (nrow, ncol, nlyr)
  #resolution  : 926.6254, 926.6254  (x, y)
  #extent      : 4185567, 5588478, -2910530, -1263917  (xmin, xmax, ymin, ymax)
  #coord. ref. : +proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs
  #source(s)   : memory
  #varnames    : _HDFEOS_GRIDS_VIIRS_Grid_8Day_1km_LST21_Data_Fields_LST_Day_1KM (8-day daytime 1km grid Land-surface Temperature)
  #_HDFEOS_GRIDS_VIIRS_Grid_8Day_1km_LST21_Data_Fields_LST_Day_1KM (8-day daytime 1km grid Land-surface Temperature)
  #_HDFEOS_GRIDS_VIIRS_Grid_8Day_1km_LST21_Data_Fields_LST_Day_1KM (8-day daytime 1km grid Land-surface Temperature)
  #_HDFEOS_GRIDS_VIIRS_Grid_8Day_1km_LST21_Data_Fields_LST_Day_1KM (8-day daytime 1km grid Land-surface Temperature)
  #_HDFEOS_GRIDS_VIIRS_Grid_8Day_1km_LST21_Data_Fields_LST_Day_1KM (8-day daytime 1km grid Land-surface Temperature)
  #...
  #names       : 2023-~y_1KM, 2023-~y_1KM, 2023-~y_1KM, 2023-~y_1KM, 2023-~y_1KM, 2023-~y_1KM, ...
  #min values  :           0,           0,           0,           0,           0,           0, ...
  #max values  :      395.16,      635.66,      1222.7,      674.08,      654.96,      816.58, ...
  #time (days) : 2023-01-01 to 2023-03-30 (12 steps)

  expect_is(r_to_test_viirs,'SpatRaster')  # output is a SpatRaster
  expect_equal(dim(r_to_test_viirs),c(1777, 1514, 12))  # dimension
  expect_equal(round(res(r_to_test_viirs)),c(927, 927))  # resolution
  expect_equal(ext(r_to_test_viirs),ext(4185567.0811119443, 5588477.9867580552, -2910530.4852275001, -1263917.0906877781))  # extent
  expect_equal(time(r_to_test_viirs),as.Date(c("2023-01-01", "2023-01-09" ,"2023-01-17" ,"2023-01-25" ,"2023-02-02", "2023-02-10" ,"2023-02-18" ,"2023-02-26", "2023-03-06", "2023-03-14" ,"2023-03-22" ,"2023-03-30")))  # dates
  expect_equal(names(r_to_test_viirs), c("2023-01-01_LST_Day_1KM", "2023-01-09_LST_Day_1KM", "2023-01-17_LST_Day_1KM", "2023-01-25_LST_Day_1KM", "2023-02-02_LST_Day_1KM", "2023-02-10_LST_Day_1KM", "2023-02-18_LST_Day_1KM", "2023-02-26_LST_Day_1KM", "2023-03-06_LST_Day_1KM" ,"2023-03-14_LST_Day_1KM", "2023-03-22_LST_Day_1KM" ,"2023-03-30_LST_Day_1KM"))
  expect_equal(unique(varnames(r_to_test_viirs)), "_HDFEOS_GRIDS_VIIRS_Grid_8Day_1km_LST21_Data_Fields_LST_Day_1KM")


})


test_that("function mf_import_data() works to import a GPM datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_token_not_provided()

  gpm_directory <- dirname(list.files(path = tempdir(), pattern = "3B-DAY.MS.MRG.3IMERG.20230101-S000000-E235959.V07B.nc4", recursive = TRUE, full.names = TRUE))

  r_to_test_gpm <- mf_import_data(
    path = gpm_directory,
    collection = "GPM_3IMERGDF.07"
  )

  # the resulting raster was equal to (v1):
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

  # in the v2 of the package, equal to :
  #class       : SpatRaster
  #size        : 149, 94, 90  (nrow, ncol, nlyr)
  #resolution  : 0.09999999, 0.1  (x, y)
  #extent      : 42, 51.4, -26.1, -11.2  (xmin, xmax, ymin, ymax)
  #coord. ref. : lon/lat WGS 84 (EPSG:4326)
  #sources     : 3B-DAY.MS.MRG.3IMERG.20230101-S000000-E235959.V07B.nc4
  #3B-DAY.MS.MRG.3IMERG.20230102-S000000-E235959.V07B.nc4
  #3B-DAY.MS.MRG.3IMERG.20230103-S000000-E235959.V07B.nc4
  #... and 87 more sources
  #varnames    : precipitation (Daily mean precipitation rate (combined microwave-IR) estimate. Formerly precipitationCal.)
  #precipitation (Daily mean precipitation rate (combined microwave-IR) estimate. Formerly precipitationCal.)
  #precipitation (Daily mean precipitation rate (combined microwave-IR) estimate. Formerly precipitationCal.)
  #precipitation (Daily mean precipitation rate (combined microwave-IR) estimate. Formerly precipitationCal.)
  #precipitation (Daily mean precipitation rate (combined microwave-IR) estimate. Formerly precipitationCal.)
  #...
  #names       : preci~ation, preci~ation, preci~ation, preci~ation, preci~ation, preci~ation, ...
  #unit        : mm/day
  #time (days) : 2023-01-01 to 2023-03-31 (90 steps)


  expect_is(r_to_test_gpm,'SpatRaster')  # output is a SpatRaster
  expect_equal(dim(r_to_test_gpm),c(149, 94, 90))  # dimension
  expect_equal(round(res(r_to_test_gpm),1),c(0.1,0.1))  # resolution
  expect_equal(ext(r_to_test_gpm),ext(41.9999992411624, 51.3999984700193, -26.1, -11.2))  # extent
  expect_equal(time(r_to_test_gpm),seq(as.Date("2023-01-01"),as.Date("2023-03-31"), 1))  # dates
  expect_equal(unique(varnames(r_to_test_gpm)), "precipitation") # variable names


})
