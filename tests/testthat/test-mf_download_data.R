
test_that("function mf_download_data() works to download a MODIS datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  urls_modis <- mf_get_url(collection = "MOD13A3.061",
                           variables = c("_1_km_monthly_NDVI"),
                           roi = roi,
                           time_range = time_range
  )

  res_dl_modis <- mf_download_data(df_to_dl = urls_modis)

  expect_is(res_dl_modis,'data.frame')  # output is a data.frame
  expect_named(res_dl_modis, c("id_roi","time_start","collection","name","url","maxFileSizeEstimated","destfile", "fileDl", "fileSize", "dlStatus")) # column names are ok
  expect_equal(ncol(res_dl_modis), 10) # there are 10 columns
  expect_equal(nrow(res_dl_modis), 5)# there are 5 rows (corresponding to 5 tiles)
  expect_equal(unique(res_dl_modis$fileDl), TRUE)  # all files were properly downloaded (fileDl == TRUE for all files)
  expect_gt(sum(res_dl_modis$fileSize),5500000)  # file size for this very specific example should be around 6000000 bites
  expect_lt(sum(res_dl_modis$fileSize),6500000)



})



test_that("function mf_download_data() works to download a GPM datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  urls_gpm <- mf_get_url(collection = "GPM_3IMERGDF.07",
                         variables = c("precipitation"),
                         roi = roi,
                         time_range = time_range
  )

  res_dl_gpm <- mf_download_data(df_to_dl = urls_gpm, parallel = TRUE) # download data, with parallelization

  expect_is(res_dl_gpm,'data.frame')  # output is a data.frame
  expect_named(res_dl_gpm, c("id_roi","time_start","collection","name","url","maxFileSizeEstimated","destfile", "fileDl", "fileSize", "dlStatus")) # column names are ok
  expect_equal(ncol(res_dl_gpm), 10) # there are 10 columns
  expect_equal(nrow(res_dl_gpm), 90 ) # there are 90 rows (corresponding to 90 dates)
  expect_equal(unique(res_dl_gpm$fileDl), TRUE)  # all files were properly downloaded (fileDl == TRUE for all files)
  expect_gt(sum(res_dl_gpm$fileSize),5000000)  # file size for this very specific example should be 5500000 bites
  expect_lt(sum(res_dl_gpm$fileSize),6000000)



})
