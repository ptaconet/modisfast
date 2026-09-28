test_that("function mf_download_data() works to download a GPM datacube", {

  skip_on_cran()
  skip_on_ci()
  skip_if_token_not_provided()

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
  expect_gt(sum(res_dl_gpm$fileSize),4500000)  # file size for this very specific example should be 5500000 bites
  expect_lt(sum(res_dl_gpm$fileSize),6500000)



})
