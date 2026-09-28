
test_that("function mf_list_variables() sends back the expected output", {

  skip_on_cran()
  skip_on_ci()
  skip_if_token_not_provided()

  # Cloud VIIRS and GPM metadata use the same token.
  vars_viirs <- mf_list_variables(collection = "VJ121A2.002",
                                  time_range = as.Date(c("2026-01-01", "2026-01-30")))

  expect_is(vars_viirs,'data.frame')
  expect_named(vars_viirs, c("name","long_name","units","indices","all_info","extractable_with_modisfast"))
  expect_true(all(c("LST_Day_1KM", "LST_Night_1KM") %in% vars_viirs$name))

  vars_gpm <- mf_list_variables(collection = "GPM_3IMERGDF.07")

  expect_is(vars_gpm,'data.frame')  # output is a data.frame
  expect_named(vars_gpm, c("name","long_name","units","indices","all_info","extractable_with_modisfast")) # column names are ok
  expect_equal(nrow(vars_gpm), 14) # there are 14 rows (corresponding to 14 variables/bands for this collection)

})

test_that("Cloud DDS exposes unique 2D science bands with the old table schema", {
  dds <- paste(
    "Dataset {",
    " Byte /Grid/eos_cf_projection;",
    " Float64 /Grid/Latitude[YDim = 1200][XDim = 1200];",
    " UInt16 /Grid/Data_Fields/LST_Day_1km[YDim = 1200][XDim = 1200];",
    " UInt16 /Grid/Data_Fields/LST_Night_1km[YDim = 1200][XDim = 1200];",
    " UInt16 /Other/Data_Fields/LST_Night_1km[YDim = 1200][XDim = 1200];",
    " Byte /Grid/QA[Band = 2][YDim = 1200][XDim = 1200];",
    "} sample;", sep = "\n")
  vars <- modisfast:::.mf_cloud_dds_variables(dds)
  expect_named(vars, c("name", "long_name", "units", "indices", "all_info",
                       "extractable_with_modisfast"))
  expect_equal(vars$name[vars$extractable_with_modisfast == "extractable"],
               "LST_Day_1km")
  expect_equal(vars$extractable_with_modisfast[vars$name == "Latitude"],
               "automatically extracted")
  expect_true(all(vars$extractable_with_modisfast[vars$name ==
                 "LST_Night_1km"] == "not extractable"))
  expect_equal(vars$extractable_with_modisfast[vars$name == "QA"],
               "not extractable")
})

test_that("bundled GPM metadata resolves the example granule and server", {
  metadata <- modisfast:::.mf_collection_metadata("GPM_3IMERGDF.07")
  expect_equal(nrow(metadata), 1L)
  expect_equal(metadata$source, "GPM")
  expect_match(metadata$url_opendapexample,
               "/opendap/GPM_L3/GPM_3IMERGDF\\.07/.+\\.nc4$")
  expect_true(startsWith(metadata$url_opendapexample,
                         metadata$url_opendapserver))
  expect_false(is.na(metadata$dim_lon))
  expect_false(is.na(metadata$dim_lat))
})

test_that("GPM DDS and DAS produce one record per band", {
  dds <- paste("Dataset {", "Float64 time[time = 1];",
               "Float32 lon[lon = 3600];", "Float64 lat[lat = 1800];",
               "Float32 precipitation[time = 1][lon = 3600][lat = 1800];",
               "Float32 randomError[time = 1][lon = 3600][lat = 1800];",
               "} granule;", sep = "\n")
  das <- paste("Attributes {", "time {", "String units \"days since 1980-01-06 00:00:00Z\";",
               "}", "lon {", "String long_name \"Longitude\";", "}",
               "precipitation {", "String long_name \"Daily precipitation\";",
               "String units \"mm/day\";", "}", "}", sep = "\n")
  metadata <- modisfast:::.mf_collection_metadata("GPM_3IMERGDF.07")
  bands <- modisfast:::.mf_gpm_parse_variables(dds, das, metadata)
  expect_equal(bands$name, c("time", "lon", "lat", "precipitation", "randomError"))
  expect_equal(bands$long_name[bands$name == "precipitation"], "Daily precipitation")
  expect_equal(bands$units[bands$name == "precipitation"], "mm/day")
  expect_equal(bands$extractable_with_modisfast,
               c(rep("automatically extracted", 3), rep("extractable", 2)))
})

test_that("GPM Grid MAPS do not repeat coordinates or hide data fields", {
  dds <- paste("Dataset {", "Grid {", "ARRAY:",
    "Float32 precipitation[time = 1][lon = 3600][lat = 1800];",
    "MAPS:", "Float64 time[time = 1];", "Float32 lon[lon = 3600];",
    "Float64 lat[lat = 1800];", "} precipitation;",
    "Grid {", "ARRAY:",
    "Float32 randomError[time = 1][lon = 3600][lat = 1800];",
    "MAPS:", "Float64 time[time = 1];", "Float32 lon[lon = 3600];",
    "Float64 lat[lat = 1800];", "} randomError;", "} granule;",
    sep = "\n")
  metadata <- modisfast:::.mf_collection_metadata("GPM_3IMERGDF.07")
  bands <- modisfast:::.mf_gpm_parse_variables(dds, "Attributes { }", metadata)
  expect_equal(bands$name, c("precipitation", "time", "lon", "lat", "randomError"))
  expect_equal(bands$extractable_with_modisfast,
    c("extractable", rep("automatically extracted", 3), "extractable"))
})
