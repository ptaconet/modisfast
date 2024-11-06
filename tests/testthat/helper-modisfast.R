# here are "global" variable which can be used for all tests, as explained in https://github.com/r-lib/testthat/issues/422

earthdata_un = "my_username"
earthdata_pw = "my_password"


library(sf)
library(terra)

roi <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt = "geom", crs = 4326)
time_range <- as.Date(c("2023-01-01", "2023-03-31"))
