
test_that("function mf_list_variables() sends back the expected output", {

  skip_on_cran()
  skip_on_ci()
  skip_if_creds_not_provided()
  skip_if_wrong_creds()

  # here we test with the collections "MOD13A3.061" and "GPM_3IMERGDF.07"
  vars_mod13a3 <- mf_list_variables(collection = "MOD13A3.061")

  expect_is(vars_mod13a3,'data.frame')  # output is a data.frame
  expect_named(vars_mod13a3, c("name","long_name","units","indices","all_info","extractable_with_modisfast")) # column names are ok
  expect_equal(nrow(vars_mod13a3), 17) # there are 17 rows (corresponding to 17 variables/bands for this collection)

  vars_gpm <- mf_list_variables(collection = "GPM_3IMERGDF.07")

  expect_is(vars_gpm,'data.frame')  # output is a data.frame
  expect_named(vars_gpm, c("name","long_name","units","indices","all_info","extractable_with_modisfast")) # column names are ok
  expect_equal(nrow(vars_gpm), 14) # there are 14 rows (corresponding to 14 variables/bands for this collection)

})

