
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opendapr <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![Travis build
status](https://travis-ci.org/ptaconet/opendapr.svg?branch=master)](https://travis-ci.org/ptaconet/opendapr)
<!-- badges: end -->

**\[ Caution : Package still in development … \]**

The goal of opendapr is to …

## Installation

You can install the released version of opendapr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("opendapr")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/opendapr")
```

`opendapr` is not a generic wrapper around the OPeNDAP framework. Its
objective is more to provide an entry point to some specific OPeNDAP
servers (e.g. MODIS, VNP, GPM, SMAP)

## Example

We want to download over the 50 km x 50 km (3500 km<sup>2</sup>) wide
region of interest :

  - a 40 days time series of [MODIS Terra Land Surface Temperature
    (LST)](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (spatial
    resolution : 1 km ; temporal resolution : 1 day),
  - the same 40 days times series of [Global Precipitation Measurement
    (GPM)](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (spatial
    resolution : 1° ; temporal resolution : 1 day)

First prepare the script : set-up ROI, time frame and connect to USGS

``` r
### Prepare script
# Packages
require(opendapr)
require(sf)

# Set ROI and time range of interest
roi <- st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
time_range <- as.Date(c("2017-01-01","2017-01-30"))

# Login to USGS servers with username and password. To create an account : https://ers.cr.usgs.gov/register/
usgs_credentials <- readLines(".usgs_credentials.txt")
username <- strsplit(usgs_credentials,"=")[[1]][2]
password <- strsplit(usgs_credentials,"=")[[2]][2]
log <- login_usgs(c(username,password))
```

Retrieve MODIS and GPM data : get the OPeNDAP URLs and download the data

``` r
## Get the URLs of MODIS Terra LST daily
urls_mod11a1 <- get_url(
  collection = "MOD11A1.006",
  roi = roi,
  time_range = time_range
 )

## Get the URLs of GPM daily
urls_gpm <- get_url(
  collection = "GPM_L3/GPM_3IMERGDF.06",
  roi = roi,
  time_range = time_range
 )

## Download the data. Destination file for each dataset is specified in the column "destfile" of the dataframe urls_mod11a1 and urls_gpm
df_to_dl <- rbind(urls_mod11a1,urls_gpm)
res_dl <- download_data(df_to_dl,data_source="usgs",parallel = TRUE)

## Check that data have been properly downloaded :
list.files(res_dl_modis$destile)
list.files(res_dl_gpm$destile)
```

Other examples, including data download + import workflows, are provided
in the
[vignettes](https://ptaconet.github.io/opendapr/articles/get_started.html)
\!
