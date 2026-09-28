test_that("DDS metadata identifies nested 2D variables", {
  dds <- paste0("Dataset {\n",
    " UInt16 /MODIS_Grid_Daily_1km_LST/Data_Fields/LST_Day_1km",
    "[YDim_MODIS_Grid_Daily_1km_LST = 1200]",
    "[XDim_MODIS_Grid_Daily_1km_LST = 1200];\n} granule;")
  spec <- modisfast:::.mf_cloud_variable("LST_Day_1km", dds)
  expect_equal(spec$path, "/MODIS_Grid_Daily_1km_LST/Data_Fields/LST_Day_1km")
  expect_equal(spec$size, c(1200L, 1200L))
  expect_error(modisfast:::.mf_cloud_variable("unknown", dds))
})

test_that("Cloud DDS bands get the public validation message before subsetting", {
  dds <- paste0("Dataset {\n",
    " UInt16 /Grid/Data_Fields/LST_Day_1km",
    "[YDim = 1200][XDim = 1200];\n} granule;")
  available <- modisfast:::.mf_cloud_dds_variables(dds)
  extractable <- available$name[available$extractable_with_modisfast ==
                                  "extractable"]
  expect_silent(modisfast:::.testIfVarExists("LST_Day_1km", extractable))
  expect_error(modisfast:::.testIfVarExists("LST_Day_1KM", extractable),
               "Use the function mf_list_variables")
})

test_that("MODIS sinusoidal tile indices are clipped and zero based", {
  crs <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
  roi <- sf::st_as_sf(data.frame(id = "x", geom =
    "POLYGON ((0 0, 1000 0, 1000 -1000, 0 -1000, 0 0))"),
    wkt = "geom", crs = crs)
  expect_equal(modisfast:::.mf_cloud_indices(roi, "h18v09", 1200, 1200),
               c(0L, 1L, 0L, 1L))
})

test_that("cloud granule URLs strip complete response suffixes", {
  base <- paste0("https://opendap.earthdata.nasa.gov/collections/",
                 "C1748058432-LPCLOUD/granules/MOD11A1.A2025258.h17v08.061.2025259093527")
  for (suffix in c("", ".dmr", ".dmr.html", ".dap.nc4")) {
    expect_equal(modisfast:::.mf_cloud_base_url(paste0(base, suffix)), base)
  }
})

test_that("CMR HDF links resolve to OPeNDAP granule IDs", {
  id <- "MOD13A3.A2023001.h21v11.061.2023034180349"
  entry <- list(links = list(list(href = paste0(
    "https://example.com/MOD13A3.061/", id, "/", id, ".hdf"))))
  expect_equal(modisfast:::.mf_cloud_granule_base(entry,
    "C2327962326-LPCLOUD"), paste0(
      "https://opendap.earthdata.nasa.gov/collections/",
      "C2327962326-LPCLOUD/granules/", id))
})

test_that("VIIRS version 002 collection names are accepted for CMR lookup", {
  expect_equal(modisfast:::.mf_cloud_collection_source("VNP43MA4.002"),
               "VIIRS")
  expect_equal(modisfast:::.mf_cloud_collection_source("VJ109H1.002"),
               "VIIRS")
  expect_null(modisfast:::.mf_cloud_collection_source("VNP43MA4.003"))
  expect_null(modisfast:::.mf_cloud_collection_source("VNP_NOT_CATALOG.002"))
})

test_that("VIIRS HDF5 granule links omit the source file extension", {
  id <- "VNP43MA4.A2023265.h18v04.002.2023274000000"
  entry <- list(links = list(list(href = paste0(
    "https://example.com/VNP43MA4.002/", id, "/", id, ".h5"))))
  expect_equal(modisfast:::.mf_cloud_granule_base(entry,
    "C2545314608-LPCLOUD"), paste0(
      "https://opendap.earthdata.nasa.gov/collections/",
      "C2545314608-LPCLOUD/granules/", id))
  expect_equal(modisfast:::.mf_cloud_base_url(paste0(
    "https://opendap.earthdata.nasa.gov/collections/",
    "C2545314608-LPCLOUD/granules/", id, ".h5.dmr.html")),
    paste0("https://opendap.earthdata.nasa.gov/collections/",
           "C2545314608-LPCLOUD/granules/", id))
})

test_that("Cloud collection IDs come from the bundled CSV without a CMR lookup", {
  catalogue <- system.file("extdata", "data_collections_cloud.csv",
                           package = "modisfast")
  expect_true(file.exists(catalogue))
  expect_equal(modisfast:::.mf_cloud_collection_id("MOD11A1.061"),
               "C1748058432-LPCLOUD")
  expect_equal(modisfast:::.mf_cloud_collection_id("VNP43MA4.002"),
               "C2545314608-LPCLOUD")
  expect_error(modisfast:::.mf_cloud_collection_id("MISSING.002"),
               "Provide collection_id explicitly")
  expect_equal(modisfast:::.mf_cloud_collection_id("MISSING.002",
    "C2545314608-LPCLOUD"), "C2545314608-LPCLOUD")
  expect_error(modisfast:::.mf_cloud_collection_id("MISSING.002", "invalid"),
               "LPCLOUD CMR collection concept ID")
})

test_that("Cloud routing uses collection IDs instead of legacy provider labels", {
  fixture <- tempfile(fileext = ".csv")
  on.exit(unlink(fixture), add = TRUE)
  utils::write.csv(data.frame(
    collection = c("MOD_CLOUD_ONLY.061", "GPM_3IMERGDF.07"),
    collection_id = c("C1234567890-LPCLOUD", ""),
    source = c("MODIS", "GPM")), fixture, row.names = FALSE)
  expect_equal(modisfast:::.mf_cloud_collection_source(
    "MOD_CLOUD_ONLY.061", catalog_path = fixture), "MODIS")
  expect_null(modisfast:::.mf_cloud_collection_source(
    "GPM_3IMERGDF.07", catalog_path = fixture))
  expect_equal(modisfast:::.mf_cloud_collection_source("MOD11A1.061"),
               "MODIS")
})
