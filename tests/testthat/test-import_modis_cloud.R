test_that("cloud import recovers subset position from its download URL", {
  url <- paste0(
    "https://opendap.earthdata.nasa.gov/collections/C1748058432-LPCLOUD/",
    "granules/MOD11A1.A2025258.h21v10.061.2025259093658.nc4?",
    "/MODIS_Grid_Daily_1km_LST/Data_Fields/LST_Day_1km",
    "%5B164:1199%5D%5B917:1199%5D")
  slice <- modisfast:::.mf_cloud_slice(url)
  expect_equal(slice, c(164L, 1199L, 917L, 1199L))
  extent <- modisfast:::.mf_cloud_extent("h21v10", slice, 1200L, 1200L)
  expect_equal(terra::xmax(extent), 4 * 1111950.5196666666)
  expect_equal(terra::ymax(extent), -1 * 1111950.5196666666 -
                 164 * 1111950.5196666666 / 1200)
})

test_that("cloud import checks NetCDF variable names against the request", {
  url <- paste0("https://opendap.earthdata.nasa.gov/granule.nc4?",
    "/MODIS_Grid_Daily_1km_LST/Data_Fields/LST_Day_1km%5B1:2%5D%5B3:4%5D,",
    "/MODIS_Grid_Daily_1km_LST/Data_Fields/LST_Night_1km%5B1:2%5D%5B3:4%5D")
  expect_equal(modisfast:::.mf_cloud_requested_bands(url),
               c("LST_Day_1km", "LST_Night_1km"))
  expect_equal(modisfast:::.mf_cloud_clean_varnames(c(
    "_MODIS_Grid_8Day_1km_LST_Data_Fields_LST_Day_1km",
    "_MODIS_Grid_8Day_1km_LST_Data_Fields_LST_Night_1km")),
    c("LST_Day_1km", "LST_Night_1km"))
})

test_that("cloud import retains one acquisition date per band", {
  r <- terra::rast(nrows = 2, ncols = 2, nlyrs = 4)
  labels <- c("2023-01-01_LST_Day_1km", "2023-01-01_LST_Night_1km",
              "2023-01-09_LST_Day_1km", "2023-01-09_LST_Night_1km")
  r <- modisfast:::.mf_cloud_set_layer_metadata(r, labels)
  expect_equal(names(r), labels)
  expect_equal(as.Date(terra::time(r)),
               as.Date(c("2023-01-01", "2023-01-01",
                         "2023-01-09", "2023-01-09")))
})
