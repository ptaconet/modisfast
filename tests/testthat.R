library(testthat)
library(modisfast)


if (exists("earthdata_un") & exists("earthdata_pw")){
   test_check("modisfast")
}

