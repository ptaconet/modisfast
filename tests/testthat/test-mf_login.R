

test_that("function mf_login() sends back the expected outputs and errors when necessary", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  expect_error(mf_login(credentials = c(earthdata_un,earthdata_pw,"hello")),"credentials must be a vector character string of length 2 (username and password)\n", fixed = TRUE)
  expect_error(mf_login(credentials = c(earthdata_un)),"credentials must be a vector character string of length 2 (username and password)\n", fixed = TRUE)
  expect_error(mf_login(credentials = c(earthdata_un,"wrong password")))  # error if wrong password is provided
  expect_error(mf_login(credentials = c("wrong username",earthdata_pw)))  # error if wrong username is provided
  expect_no_error(mf_login(credentials = c(earthdata_un,earthdata_pw)))   # no error if right password or username are provided

})
