require(usethis)
require(devtools)
require(attachment)
require(pkgdown)
## See tutorials here : https://rtask.thinkr.fr/blog/rmd-first-when-development-starts-with-documentation/
## and https://usethis.r-lib.org/articles/articles/usethis-setup.html
## and video here : http://www.user2019.fr/static/pres/t257651.zip

## create the package
usethis::create_package("/home/ptaconet/getRemoteData")
## Manual step : Create a dev_history.R file that archives all the package history steps. Then copy it to the package folder.
## Then proceed :
usethis::use_build_ignore("dev_history.R")
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
