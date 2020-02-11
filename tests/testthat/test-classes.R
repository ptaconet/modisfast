context("classes")

test_that("Input object is ok", {
  roi = sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
    expect_is(get_url(roi), "sf")
  })
