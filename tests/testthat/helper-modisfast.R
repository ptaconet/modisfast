# here are "global" variable which can be used for all tests, as explained in https://github.com/r-lib/testthat/issues/422

library(sf)
library(terra)

roi <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt = "geom", crs = 4326)
time_range <- as.Date(c("2023-01-01", "2023-03-31"))

skip_if_token_not_provided <- function() {
  if (!nzchar(Sys.getenv("EARTHDATA_TOKEN", unset = ""))) {
    testthat::skip("Set EARTHDATA_TOKEN to run the live Earthdata tests.")
  }
}
