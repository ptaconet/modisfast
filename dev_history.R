require(usethis)
require(devtools)
require(attachment)
require(pkgdown)
require(dplyr)
## See tutorials here : https://rtask.thinkr.fr/blog/rmd-first-when-development-starts-with-documentation/
## and https://usethis.r-lib.org/articles/articles/usethis-setup.html
## and video here : http://www.user2019.fr/static/pres/t257651.zip

## create the package
usethis::create_package("/home/ptaconet/getRemoteData")
## Manual step : Create a dev_history.R file that archives all the package history steps. Then copy it to the package folder.
## Then proceed :
usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("data_collections.csv")
usethis::use_build_ignore("opendapr_functions.R")
usethis::use_git()
usethis::use_gpl3_license()
devtools::check()
usethis::proj_get()

## Manual steps : If not installed, install these packages
# system("brew install libssh2")
# system("brew install libgit2")
# install.packages("git2r")

## Manual step : Fill-in DESCRIPTION file with title and description of the package
## Manual step : If not already done, add a local SSH key following the instructions here : https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
## Then proceed :
usethis::use_github()
devtools::install()
usethis::use_readme_rmd()


# insert description of data as package data
path_to_description_dataset<-"/home/ptaconet/opendapr/data_collections.csv"
opendapMetadata <- read.csv(path_to_description_dataset,stringsAsFactors = F)
usethis::use_data(opendapMetadata)












## Manual step : Commit and push

## Document functions and dependencies
attachment::att_to_description()
## Check the package
devtools::check()

## Manual step : Add example dataset in inst/example-data

#usethis::use_vignette("aa-exploration")
# Document functions and dependencies
attachment::att_to_description()
# Check the package
devtools::check()

devtools::install()



## To build a website with home and vignettes
usethis::use_package_doc()
usethis::use_tibble()
devtools::document()
pkgdown::build_site()
## Manual step : go to the settings of the package on the github page, then under "github page" put "master branch /docs folder"

#sf::read_sf("https://modis.ornl.gov/files/modis_sin.kmz")
#modis_tile<-sf::read_sf("/home/ptaconet/Téléchargements/extdata/modis_sin.kmz")
#sf::write_sf(modis_tile,"/inst/extdata/modis_sin.gpkg")

opendapMetadata <- read.csv("/home/ptaconet/opendapr/data_collections.csv",stringsAsFactors =F )
usethis::use_data(opendapMetadata, internal = FALSE, overwrite = TRUE)
opendapMetadata_internal=opendapMetadata
usethis::use_data(opendapMetadata_internal, internal = TRUE,overwrite = TRUE)
