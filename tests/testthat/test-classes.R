context("classes")

require(opendapr)
require(sf)

test_that("Input collection is ok and data is downloaded", {
  roi = sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
  time_range = as.Date(c("2017-01-01","2017-01-30"))
  usgs_credentials <- readLines(".usgs_credentials.txt")
  username <- strsplit(usgs_credentials,"=")[[1]][2]
  password <- strsplit(usgs_credentials,"=")[[2]][2]
  log <- login_usgs(c(username,password))



    })
