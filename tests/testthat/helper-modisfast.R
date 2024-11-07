# here are "global" variable which can be used for all tests, as explained in https://github.com/r-lib/testthat/issues/422

library(sf)
library(terra)

roi <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt = "geom", crs = 4326)
time_range <- as.Date(c("2023-01-01", "2023-03-31"))

skip_if_creds_not_provided <- function() {
  if (!exists("earthdata_un") | !exists("earthdata_pw" )) {
    skip("Please set your EarthData username and password before testing the package. See instructions in ReadMe file.")
  } else {
    invisible()
  }
}

skip_if_wrong_creds <- function() {
  out <- tryCatch(mf_login(credentials = c(earthdata_un,earthdata_pw), verbose = "quiet"), error = function(e) e)
  if (any(class(out) == "error")) {
    skip("EarthData username and/or passwords are wrong. Please provide correct credentials before testing the package.")
  } else {
    invisible()
  }
}
