library(testthat)
library(modisfast)

### Instructions to run the tests in order to verify the functionality of modisfast :

# - open the file test/testthat/test-modisfast.R
# - uncomment the 2 first two lines of the script (earthdata_un = "my_username" and earthdata_pw = "my_password")
# - replace "my_username" and "my_password" with your own Earthdata username and password
# - run devtools::test()  (or run the script test/testthat/test-modisfast.R manually)

message("tests are not executed automatically")

if (exists("earthdata_un") & exists("earthdata_pw")){
   test_check("modisfast")
}

