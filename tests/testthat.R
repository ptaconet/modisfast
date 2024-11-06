library(testthat)
library(modisfast)

### Instructions to run the tests in order to verify the functionality of modisfast :

# - open the file : test/testthat/helper-modisfast.R
# - uncomment the lines : earthdata_un = "my_username" and earthdata_pw = "my_password"
# - replace "my_username" and "my_password" with your own Earthdata username and password
# - run devtools::test()

message("tests are not executed automatically")

if (exists("earthdata_un") & exists("earthdata_pw")){
   test_check("modisfast")
}

