require(usethis)
require(devtools)
require(attachment)
require(pkgdown)
require(dplyr)
## See tutorials here : https://rtask.thinkr.fr/blog/rmd-first-when-development-starts-with-documentation/ and here : https://stateofther.github.io/finistR2019/d-mypkg.html and here https://jef.works/blog/2019/02/17/automate-testing-of-your-R-package/
## and https://usethis.r-lib.org/articles/articles/usethis-setup.html
## and video here : http://www.user2019.fr/static/pres/t257651.zip

## create the package
usethis::create_package("/home/ptaconet/opendapr")
## Manual step : Create a dev_history.R file that archives all the package history steps. Then copy it to the package folder.
## Then proceed :
usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore(".data_collections.csv")
usethis::use_build_ignore(".notes_articles.txt")
usethis::use_git()
usethis::use_git_ignore("dev_history.R")
usethis::use_git_ignore(".data_collections.csv")
usethis::use_git_ignore(".notes_articles.txt")
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
usethis::use_package("magrittr","dplyr","httr","sf","purrr","lubridate","xml2","stringr","rvest","utils","parallel","curl")
# pour que les vignettes s'installent : ajouter VignetteBuilder: knitr dans le DESCRIPTION file
# Intégration continue avec Travis-CI
usethis::use_travis()

## Manual step : Commit and push

## Document functions and dependencies
attachment::att_to_description()
## Check the package
devtools::check()

usethis::use_testthat()

## Manual step : Add example dataset in inst/example-data

#usethis::use_vignette("aa-exploration")
# Document functions and dependencies
attachment::att_to_description()
# Check the package
devtools::check()

devtools::document()

# For CRAN-like check
devtools::check(args = c('--as-cran'))

#then :
devtools::install(build_vignettes = TRUE)

## Ajouter manuellement dans le description file, la liste des packages dont dépend le package

## ci dessous, pour ajouter des données internes au package (ie non visibles par les utilisateurs)
opendapMetadata_internal <- read.csv("/home/ptaconet/opendapr/.data_collections.csv",stringsAsFactors =F ) %>% arrange(collection)
modis_tiles<-sf::read_sf("/home/ptaconet/Téléchargements/modis_sin.kmz")  %>% #https://modis.ornl.gov/files/modis_sin.kmz
  sf::st_zm(modis_tiles) %>%
  dplyr::select(Name,geometry)
usethis::use_data(opendapMetadata_internal,modis_tiles, internal = TRUE,overwrite = TRUE)



roi_example<-"/home/ptaconet/getRemoteData/inst/extdata/roi_example.gpkg"
dir.create("inst/extdata")
file.copy(roi_example,gsub("getRemoteData","opendapr",roi_example))

roi_modis2tiles<-"/home/ptaconet/Documents/modis2tiles.gpkg"
file.copy(roi_modis2tiles,gsub("Documents","opendapr/inst/extdata",roi_modis2tiles))

### To add a config file with username and password to usgs. More info : https://db.rstudio.com/best-practices/managing-credentials/
file.create("config.yml")
usethis::use_build_ignore("config.yml")
usethis::use_git_ignore("config.yml")

## To build vignettes
devtools::build_vignettes() # ne pas oublier d'avoir ajouté au préalable VignetteBuilder: knitr dans le DESCRIPTION file
devtools::install(build_vignettes = TRUE)

## To build a website with home and vignettes
usethis::use_package_doc()
usethis::use_tibble()
devtools::document()
pkgdown::build_site()
usethis::use_build_ignore("docs")
## Manual step : go to the settings of the package on the github page, then under "github page" put "master branch /docs folder"
