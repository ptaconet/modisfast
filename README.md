
<!-- README.md is generated from README.Rmd. Please edit that file -->

# modisfast <a href="https://github.com/ptaconet/modisfast"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- <img src="man/figures/logo.png" align="right" /> -->

<!-- badges: start -->

[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/modisfast)](https://cran.r-project.org/package=modisfast)
[![Github_Status_Badge](https://img.shields.io/badge/Github-1.0.0-blue.svg)](https://github.com/ptaconet/modisfast)
[![R-CMD-check](https://github.com/ptaconet/modisfast/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ptaconet/modisfast/actions/workflows/R-CMD-check.yaml)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.07343/status.svg)](https://doi.org/10.21105/joss.07343)
![CRAN_downloads](https://cranlogs.r-pkg.org/badges/last-month/modisfast)
<!-- [![SWH](https://archive.softwareheritage.org/badge/origin/https://github.com/ptaconet/modisfast/)](https://archive.softwareheritage.org/browse/origin/?origin_url=https://github.com/ptaconet/modisfast) -->
<!-- [![DOI-zenodo](https://zenodo.org/badge/doi/10.5281/zenodo.8475.svg)](https://doi.org/10.5281/zenodo.12772739) -->
<!-- badges: end -->

## Table of contents

<p align="left">

• <a href="#overview">Overview</a><br> •
<a href="#installation">Installation</a><br> •
<a href="#get-started">Get started</a><br> •
<a href="#collections-available-in-modisfast">Data collections
available</a><br> •
<a href="#manual-testing-of-the-functionality">Manual testing of the
functionality</a><br> • <a href="#foundational-framework">Foundational
framework</a><br> •
<a href="#comparison-with-similar-r-packages">Comparison with similar R
packages</a><br> • <a href="#citation">Citation</a><br> •
<a href="#future-developments">Future developments</a><br> •
<a href="#contributing">Contributing</a><br> •
<a href="#acknowledgments">Acknowledgments</a><br>
</p>

## News

2026-09-29 :

**`modisfast` is back!**

- After a year-long interruption caused by the migration of NASA’s data
  servers, `modisfast` is back
- `modisfast` now uses the new [NASA Earthdata Cloud OPeNDAP
  endpoint](https://opendap.earthdata.nasa.gov) for MODIS and VIIRS
  collections !
- Authentication to access data is now dealt with an Earthdata token
  instead of username and password.

## Overview

**`modisfast`** is an R package designed for **easy** and **fast**
downloads of
[**MODIS**](https://www.earthdata.nasa.gov/data/instruments/modis) Land
products,
[**VIIRS**](https://www.earthdata.nasa.gov/data/instruments/viirs) Land
products, and
[**GPM**](https://earth.gsfc.nasa.gov/hydro/missions/global-precipitation-measurement-gpm)
(Global Precipitation Measurement Mission) Earth Observation data.

`modisfast` uses the abilities offered by the
[OPeNDAP](https://www.opendap.org/about/) framework (*Open-source
Project for a Network Data Access Protocol*) to download a subset of
Earth Observation data cube, along spatial, temporal or any other data
dimension (depth, …). This way, it reduces downloading time and disk
usage to their minimum : no more 1° x 1° MODIS tiles with 10 bands when
your region of interest is only 30 km x 30 km wide and you need 2 bands
! Moreover, `modisfast` enables parallel downloads of data.

This package is hence particularly suited for retrieving MODIS or VIIRS
data **over long time series** and **over areas**, rather than short
time series and points.

Importantly, the robust, sustainable, and cost-free [foundational
framework](#foundational-framework) of `modisfast`, both for the data
provider (NASA) and the software (R, OPeNDAP, the `tidyverse` and `GDAL`
suite of packages and software), guarantees the long-term reliability
and open-source nature of the package.

By enabling to download subsets of data cubes, `modisfast` facilites the
access to Earth science data for R users in places where internet
connection is slow or expensive and promotes digital sobriety for our
research work.

## Installation

You can install the released version of `modisfast` from
[CRAN](https://CRAN.R-project.org) with :

``` r
install.packages("modisfast")
```

or the development version (to get a bug fix or to use a feature from
the development version) with :

``` r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("ptaconet/modisfast")
```

## Get Started

This example shows how to download and import a 3-month weekly time
series of VIIRS Land Surface Temperature (LST) at 1 km spatial
resolution over the whole country of Madagascar.

**Fist, you need to retrieve your Earthdata token**. This token is
mandatory to access the data. You can get it here :
<https://urs.earthdata.nasa.gov/> .

![Earthdata token generation](.token_earthdata_readme.png) **Next, run
the following code**

``` r
# set your EarthData token as an environment system :
Sys.setenv(EARTHDATA_TOKEN = "your Earthdata bearer token")

# Load the packages
library(modisfast)
library(sf)
library(terra)

# Set ROI and time range of interest
roi <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt = "geom", crs = 4326) # a ROI of interest, format sf polygon
time_range <- as.Date(c("2026-01-01", "2026-04-01")) # a time range of interest (or single date)

# Set MODIS collections and variables (bands) of interest
collection <- "VJ221A2.002" # run mf_list_collections() for an exhaustive list of collections available
variables <- c("LST_Day_1KM") # run mf_list_variables("VJ221A2.002") for an exhaustive list of variables available for the collection "VJ221A2.002"


## Get the URLs of the data with mf_get_url() 
urls <- mf_get_url(
  collection = collection,
  variables = variables,
  roi = roi,
  time_range = time_range
)

## Download the data with mf_download_data(). By default the data is downloaded in a temporary directory, but you can specify a folder
res_dl <- mf_download_data(urls, 
                           parallel = TRUE, 
                           num_workers = 3)


# And finally, import the data in R as a terra::SpatRaster object using the function mf_import_data()
r <- mf_import_data(
  path = dirname(res_dl$destfile[1]),
  collection = collection,
  proj_epsg = 4326,
  roi_mask = roi
)

terra::plot(r, col = rev(terrain.colors(20)))
```

<figure>
<img src=".Rplot_readme.png"
alt="Time series of weekly 1-km VIIRS Land surface temperature over Madagascar for the first 3 months of the year 2023, retrieved with modisfast" />
<figcaption aria-hidden="true">Time series of weekly 1-km VIIRS Land
surface temperature over Madagascar for the first 3 months of the year
2023, retrieved with <code>modisfast</code></figcaption>
</figure>

  
et voilà !

Want more examples ? `modisfast` provides a [long-form documentations
and examples to learn more about the
package](https://ptaconet.github.io/modisfast/articles/get_started.html)(<https://ptaconet.github.io/modisfast/articles/get_started.html>)

<!--
## Objectives
modisfast provides an entry point to some specific OPeNDAP servers (e.g. MODIS, VNP, GPM or SMAP) via HTTPS. The development of the package was motivated by the following reasons : 
* **Providing a simple and single way in R to download data stored on heterogeneous servers** : People that use Earth science data often struggle with data access. In modisfast we propose a harmonized way to download data from various providers that have implemented access to their data through OPeNDAP.
* **Fastening the data import phase**, especially for large time series analysis.
Apart from these performance aspects, ethical considerations have driven the development of this package :
* **Facilitating the access to Earth science data for R users in places where internet connection is slow or expensive** : Earth science products are generally huge files that can be quite difficult to download in places with slow internet connection, even more if large time series are needed. By enabling to download strictly the data that is needed, the products become more accessible in those places;
* **Caring about the environmental digital impact of our research work** : Downloading data has an impact on environment and to some extent contributes to climate change. By downloading only the data that is need (rather than e.g a whole MODIS tile, or a global SMAP or GPM dataset) we somehow promote digital sobriety. 
* **Supporting the open-source-software movement** : The OPeNDAP is developed and advanced openly and collaboratively, by the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) This open, powerfull and standard data access protocol is more and more used, by major Earth science data providers (e.g. NASA or NOAA). Using OPeNDAP means supporting methods for data access protocols that are open, build collaboratively and shared.
-->

<!--
## Citation
We thank in advance people that use `modisfast` for citing it in their work / publication(s). For this, please use the citation provided at this link [zenodo link to add] or through `citation("modisfast")`.
-->

## Collections available in `modisfast`

Currently `modisfast` supports download of 95 data collections,
extracted from the following meta-collections :

- [MODIS land
  products](https://www.earthdata.nasa.gov/data/instruments/modis) made
  available by the [NASA / USGS LP
  DAAC](https://www.earthdata.nasa.gov/centers/lp-daac) ;
- [VIIRS land
  products](https://www.earthdata.nasa.gov/data/instruments/viirs) made
  available by the [NASA / USGS LP
  DAAC](https://www.earthdata.nasa.gov/centers/lp-daac)
- [Global Precipitation
  Measurement](https://earth.gsfc.nasa.gov/hydro/missions/global-precipitation-measurement-gpm)
  (GPM) made available by the [NASA / JAXA GES
  DISC](https://www.earthdata.nasa.gov/centers/gesdisc-daac).

Details of each product available for download are provided in the
tables below or through the function `mf_list_collections()`.

<details>

<summary>

<b> Albedo </b> data collections <b>(click to expand)</b>
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MCD43A1.061">MCD43A1.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

MODIS/Terra and Aqua BRDF/Albedo Model Parameters Daily L3 Global 500 m
SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-02-24 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143DNBA3.002">VJ143DNBA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/JPSS1 DNB Albedo Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143MA3.002">VJ143MA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Albedo Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243DNBA3.002">VJ243DNBA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/JPSS2 DNB Albedo Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243MA3.002">VJ243MA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Albedo Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43DNBA3.002">VNP43DNBA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/NPP DNB Albedo Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-19 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43MA3.002">VNP43MA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/NPP Albedo Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143IA3.002">VJ143IA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Albedo Daily L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243IA3.002">VJ243IA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Albedo Daily L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43IA3.002">VNP43IA3.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo
</td>

<td style="text-align:left;">

VIIRS/NPP Albedo Daily L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Albedo / BRDF </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143DNBA1.002">VJ143DNBA1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS1 DNB BRDF/Albedo Model Parameters Daily L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143DNBA2.002">VJ143DNBA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS1 DNB BRDF/Albedo Quality Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143MA2.002">VJ143MA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS1 BRDF/Albedo Quality Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243DNBA1.002">VJ243DNBA1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS2 DNB BRDF/Albedo Model Parameters Daily L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243DNBA2.002">VJ243DNBA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS2 DNB BRDF/Albedo Quality Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243MA2.002">VJ243MA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS2 BRDF/Albedo Quality Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43DNBA1.002">VNP43DNBA1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/NPP DNB BRDF/Albedo Model Parameters Daily L3 Global 1km SIN Grid
V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-19 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43DNBA2.002">VNP43DNBA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/NPP DNB BRDF/Albedo Quality Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-19 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43MA2.002">VNP43MA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/NPP BRDF/Albedo Quality Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143IA1.002">VJ143IA1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS1 BRDF/Albedo Model Parameters Daily L3 Global 500m SIN Grid
V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143IA2.002">VJ143IA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS1 BRDF/Albedo Quality Daily L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243IA1.002">VJ243IA1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS2 BRDF/Albedo Model Parameters Daily L3 Global 500m SIN Grid
V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243IA2.002">VJ243IA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/JPSS2 BRDF/Albedo Quality Daily L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43IA1.002">VNP43IA1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/NPP BRDF/Albedo Model Parameters Daily L3 Global 500m SIN Grid
V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43IA2.002">VNP43IA2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Albedo / BRDF
</td>

<td style="text-align:left;">

VIIRS/NPP BRDF/Albedo Quality Daily L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Evapotranspiration </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD16A2.061">MOD16A2.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Evapotranspiration
</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration 8-Day L4 Global 500m SIN Grid v061
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2021-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD16A2.061">MYD16A2.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Evapotranspiration
</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration 8-Day L4 Global 500m SIN Grid v061
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2021-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD16A2GF.061">MOD16A2GF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Evapotranspiration
</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration Gap-Filled 8-Day L4 Global 500 m SIN
Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2000-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD16A3GF.061">MOD16A3GF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Evapotranspiration
</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration Gap-Filled Yearly L4 Global 500 m SIN
Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

365 day
</td>

<td style="text-align:left;">

2000-02-18 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD16A2GF.061">MYD16A2GF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Evapotranspiration
</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration Gap-Filled 8-Day L4 Global 500 m SIN
Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2002-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD16A3GF.061">MYD16A3GF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Evapotranspiration
</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration Gap-Filled Yearly L4 Global 500 m SIN
Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

365 day
</td>

<td style="text-align:left;">

2002-07-04 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Land cover </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MCD12Q1.061">MCD12Q1.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land cover
</td>

<td style="text-align:left;">

MODIS/Terra+Aqua Land Cover Type Yearly L3 Global 500 m SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

365 day
</td>

<td style="text-align:left;">

2001-01-01 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Land surface phenology </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP22Q2.002">VNP22Q2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface phenology
</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Phenology Yearly L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

1 year
</td>

<td style="text-align:left;">

2013-01-01 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Land surface temperature </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD11A1.061">MOD11A1.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid v061
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-02-24 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD11A1.061">MYD11A1.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid v061
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2002-07-05 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD11A2.061">MOD11A2.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid v061
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2000-02-18 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD11A2.061">MYD11A2.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid v061
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2002-07-04 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD11B3.061">MOD11B3.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity Monthly L3 Global 6 km
SIN Grid
</td>

<td style="text-align:left;">

6000 m
</td>

<td style="text-align:left;">

30 day
</td>

<td style="text-align:left;">

2000-02-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP21A1D.002">VNP21A1D.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid Day V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ121A1N.002">VJ121A1N.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid Night V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ221A1N.002">VJ221A1N.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid Night V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP21A1N.002">VNP21A1N.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid Night V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ121A1D.002">VJ121A1D.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid Day V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ121A2.002">VJ121A2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Land Surface Temperature/Emissivity 8-Day L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ221A1D.002">VJ221A1D.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid Day V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ221A2.002">VJ221A2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Land Surface Temperature/Emissivity 8-Day L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP21A2.002">VNP21A2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Land surface temperature
</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Temperature/Emissivity 8-Day L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Land Water mask </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD44W.061">MOD44W.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Land Water mask
</td>

<td style="text-align:left;">

MODIS/Terra Land Water Mask Derived from MODIS and SRTM L3 Global 250m
SIN Grid V061
</td>

<td style="text-align:left;">

250 m
</td>

<td style="text-align:left;">

365 day
</td>

<td style="text-align:left;">

2000-01-01 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Leaf area index / FPAR </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ115A2H.002">VJ115A2H.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Leaf area index / FPAR
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Leaf Area Index/FPAR 8-Day L4 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ215A2H.002">VJ215A2H.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Leaf area index / FPAR
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Leaf Area Index/FPAR 8-Day L4 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP15A2H.002">VNP15A2H.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Leaf area index / FPAR
</td>

<td style="text-align:left;">

VIIRS/NPP Leaf Area Index/FPAR 8-Day L4 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Primary Productivity </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD17A2H.061">MOD17A2H.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Primary Productivity
</td>

<td style="text-align:left;">

MODIS/Aqua Gross Primary Productivity 8-Day L4 Global 500 m SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2021-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD17A2H.061">MYD17A2H.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Primary Productivity
</td>

<td style="text-align:left;">

MODIS/Terra Gross Primary Productivity 8-Day L4 Global 500 m SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2021-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD17A2HGF.061">MOD17A2HGF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Primary Productivity
</td>

<td style="text-align:left;">

MODIS/Terra Gross Primary Productivity Gap-Filled 8-Day L4 Global 500 m
SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2000-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MOD17A3HGF.061">MOD17A3HGF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Primary Productivity
</td>

<td style="text-align:left;">

MODIS/Terra Net Primary Production Gap-Filled Yearly L4 Global 500 m SIN
Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

365 day
</td>

<td style="text-align:left;">

2000-02-18 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD17A2HGF.061">MYD17A2HGF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Primary Productivity
</td>

<td style="text-align:left;">

MODIS/Aqua Gross Primary Productivity Gap-Filled 8-Day L4 Global 500 m
SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2002-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MYD17A3HGF.061">MYD17A3HGF.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Primary Productivity
</td>

<td style="text-align:left;">

MODIS/Aqua Net Primary Production Gap-Filled Yearly L4 Global 500 m SIN
Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

365 day
</td>

<td style="text-align:left;">

2002-07-04 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Rainfall </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERGDE/DAY/06">GPM_3IMERGDE.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Early Precipitation L3 1 day 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERGDF/DAY/06">GPM_3IMERGDF.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERGDF/DAY/07">GPM_3IMERGDF.07</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree V07
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERGDL/DAY/06">GPM_3IMERGDL.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Late Precipitation L3 1 day 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH/06">GPM_3IMERGHH.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

30 minute
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH/07">GPM_3IMERGHH.07</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V07
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

30 minute
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH-E/06">GPM_3IMERGHHE.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Early Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

30 minute
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH-L/06">GPM_3IMERGHHL.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Late Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

30 minute
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERG/3B-MONTH/06">GPM_3IMERGM.06</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 month 0.1 degree x 0.1 degree V06
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

1 month
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/GPM/IMERG/3B-MONTH/07">GPM_3IMERGM.07</a>
</td>

<td style="text-align:left;">

GPM
</td>

<td style="text-align:left;">

Rainfall
</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 month 0.1 degree x 0.1 degree V07
</td>

<td style="text-align:left;">

10000 m
</td>

<td style="text-align:left;">

1 month
</td>

<td style="text-align:left;">

2000-06-01 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Surface reflectance </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://dx.doi.org/10.5067/MODIS/MCD43A4.061">MCD43A4.061</a>
</td>

<td style="text-align:left;">

MODIS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

MODIS/Terra and Aqua Nadir BRDF-Adjusted Reflectance Daily L3 Global 500
m SIN Grid
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2000-02-24 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143DNBA4.002">VJ143DNBA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS1 DNB Nadir BRDF-Adjusted Reflectance Daily L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243DNBA4.002">VJ243DNBA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS2 DNB Nadir BRDF-Adjusted Reflectance Daily L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43DNBA4.002">VNP43DNBA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/NPP DNB Nadir BRDF-Adjusted Reflectance Daily L3 Global 1km SIN
Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-19 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ109A1.002">VJ109A1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Surface Reflectance 8-Day L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143MA4.002">VJ143MA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Nadir BRDF-Adjusted Reflectance Daily L3 Global 1km SIN Grid
V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ209A1.002">VJ209A1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Surface Reflectance 8-Day L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243MA4.002">VJ243MA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Nadir BRDF-Adjusted Reflectance Daily L3 Global 1km SIN Grid
V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP09A1.002">VNP09A1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/NPP Surface Reflectance 8-Day L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43MA4.002">VNP43MA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/NPP Nadir BRDF-Adjusted Reflectance Daily L3 Global 1km SIN Grid
V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ143IA4.002">VJ143IA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Nadir BRDF-Adjusted Reflectance Daily L3 Global 500m SIN
Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ243IA4.002">VJ243IA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Nadir BRDF-Adjusted Reflectance Daily L3 Global 500m SIN
Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP43IA4.002">VNP43IA4.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/NPP Nadir BRDF-Adjusted Reflectance Daily L3 Global 500m SIN Grid
V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ109H1.002">VJ109H1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Surface Reflectance 8-Day L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ209H1.002">VJ209H1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Surface Reflectance 8-Day L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP09H1.002">VNP09H1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Surface reflectance
</td>

<td style="text-align:left;">

VIIRS/NPP Surface Reflectance 8-Day L3 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Thermal anomalies and fire </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ114A1.002">VJ114A1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Thermal anomalies and fire
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Thermal Anomalies and Fire Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2018-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ214A1.002">VJ214A1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Thermal anomalies and fire
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Thermal Anomalies and Fire Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP14A1.002">VNP14A1.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Thermal anomalies and fire
</td>

<td style="text-align:left;">

VIIRS/NPP Thermal Anomalies and Fire Daily L3 Global 1km SIN Grid V002
</td>

<td style="text-align:left;">

1000 m
</td>

<td style="text-align:left;">

Daily
</td>

<td style="text-align:left;">

2012-01-17 to present
</td>

</tr>

</tbody>

</table>

</details>

<details>

<summary>

<b> Vegetation productivity </b> data collections
</summary>

<table class="table table-hover table-condensed" style="color: black; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection
</th>

<th style="text-align:left;">

Source
</th>

<th style="text-align:left;">

Type
</th>

<th style="text-align:left;">

Name
</th>

<th style="text-align:left;">

Spatial resolution
</th>

<th style="text-align:left;">

Temporal resolution
</th>

<th style="text-align:left;">

Temporal extent
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ117A2.002">VJ117A2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Gross Primary Productivity and Net Photosynthesis 8-Day L4
Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2025-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ217A2.002">VJ217A2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Gross Primary Productivity and Net Photosynthesis 8-Day L4
Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP17A2.002">VNP17A2.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/NPP Gross Primary Productivity and Net Photosynthesis 8-Day L4
Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2025-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ117A2GF.002">VJ117A2GF.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Gross Primary Productivity and Net Photosynthesis Gap-Filled
8-Day L4 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2025-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ117A3GF.002">VJ117A3GF.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/JPSS1 Gross and Net Primary Production Gap-Filled Yearly L4 Global
500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

1 year
</td>

<td style="text-align:left;">

2025-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ217A2GF.002">VJ217A2GF.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Gross Primary Productivity and Net Photosynthesis Gap-Filled
8-Day L4 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VJ217A3GF.002">VJ217A3GF.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/JPSS2 Gross and Net Primary Production Gap-Filled Yearly L4 Global
500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

1 year
</td>

<td style="text-align:left;">

2023-02-10 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP17A2GF.002">VNP17A2GF.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/NPP Gross Primary Productivity and Net Photosynthesis Gap-Filled
8-Day L4 Global 500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

8 day
</td>

<td style="text-align:left;">

2025-01-01 to present
</td>

</tr>

<tr>

<td style="text-align:left;">

<a href="https://doi.org/10.5067/VIIRS/VNP17A3GF.002">VNP17A3GF.002</a>
</td>

<td style="text-align:left;">

VIIRS
</td>

<td style="text-align:left;">

Vegetation productivity
</td>

<td style="text-align:left;">

VIIRS/NPP Gross and Net Primary Production Gap-Filled Yearly L4 Global
500m SIN Grid V002
</td>

<td style="text-align:left;">

500 m
</td>

<td style="text-align:left;">

1 year
</td>

<td style="text-align:left;">

2025-01-01 to present
</td>

</tr>

</tbody>

</table>

</details>

## Manual testing of the functionality

Since most `modisfast` functions depend on EarthData credentials/token,
automated tests are disabled. However, after installation, users can
manually test the package’s functionality by running these lines of code
:

``` r
Sys.setenv(EARTHDATA_TOKEN = "your Earthdata bearer token")
devtools::test("~path/to/modisfast")
```

## Foundational framework

Technically, `modisfast` is a programmatic interface (R wrapper) to
several NASA [OPeNDAP](https://www.opendap.org/) servers. OPeNDAP is the
acronym for *Open-source Project for a Network Data Access Protocol* and
designates both the software, the access protocol, and the corporation
that develops them. The OPeNDAP is designed to simplify access to
structured and high-volume data, such as satellite products, over the
Web. It is a collaborative effort involving multiple institutions and
companies, with open-source code, free software, and adherence to the
[Open Geospatial Consortium](https://www.ogc.org/) (OGC) standards. It
is widely used by NASA, which partly finances it.

A key feature of OPeNDAP is its capability to apply filters at the data
download process, ensuring that only the necessary data is retrieved.
These filters, specified within a URL, can be spatial, temporal, or
dimensional. Although powerful, OPeNDAP URLs are not trivial to build.
`modisfast` facilitates this process by constructing the URL based on
the spatial, temporal, and dimensional filters provided by the user in
the function `mf_get_url()`.

These OPeNDAP URLs are not trivial to build. `modisfast` converts the
spatial, temporal and dimensional filters (R objects) provided by the
user through the function `mf_get_url()` into the appropriate OPeNDAP
URL(s). Subsequently, the function `mf_download_data()` allows for
downloading the data using the
[`httr`](https://cran.r-project.org/package=httr) and `parallel`
packages.

## Comparison with similar R packages

There are other R packages available for accessing MODIS data. Below is
a comparison of modisfast with other packages available for downloading
chunks of MODIS or VIIRS data :

| Package | Data | Available on CRAN | Utilizes open standards for data access protocols | Spatial subsetting\* | Dimensional subsetting\* | Maximum area size allowed for download | Speed\*\* |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| [`modisfast`](https://github.com/ptaconet/modisfast) | MODIS, VIIRS, GPM | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | unlimited | :white_check_mark: |
| [`appeears`](https://github.com/bluegreen-labs/appeears) | MODIS, VIIRS, and many others | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | unlimited | variable |
| [`MODISTools`](https://github.com/bluegreen-labs/MODISTools/) | MODIS, VIIRS | :white_check_mark: | :x: | :white_check_mark: | :white_check_mark: | 200 km x 200 km | :white_check_mark: |
| [`rgee`](https://github.com/r-spatial/rgee) | MODIS, VIIRS, GPM, and many others | :white_check_mark: | :x: | :white_check_mark: | :white_check_mark: | unlimited | not tested |
| [`MODIStsp`](https://github.com/ropensci/MODIStsp) | MODIS | :x: |  | :x: | :white_check_mark: | unlimited | NA |
| [`MODIS`](https://github.com/fdetsch/MODIS) | MODIS | :x: | :x: | :x: | :x: | NA | NA |

\* at the downloading phase

## Citation

This package is licensed under a [GNU General Public License v3.0 or
later](https://www.gnu.org/licenses/gpl-3.0-standalone.html) license.

We thank in advance people that use `modisfast` for citing it in their
work / publication(s). For this, please use the following citation :

> Taconet et al., (2024). modisfast: An R package for fast and efficient
> access to MODIS, VIIRS and GPM Earth Observation data. Journal of Open
> Source Software, 9(103), 7343, <https://doi.org/10.21105/joss.07343>

## Future developments

Future developments of the package may include access to additional data
collections from other OPeNDAP servers, and support for a variety of
data formats as they become available from data providers through their
OPeNDAP servers. Furthermore, the creation of an RShiny application on
top of the package is being considered, as a means of further
simplifying data access for users with limited coding skills.

## Contributing

All types of contributions are encouraged and valued. For more
information, check out our [Contributor
Guidelines](https://github.com/ptaconet/modisfast/blob/master/CONTRIBUTING.md).

Please note that the `modisfast` project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Acknowledgments

We thank NASA and its partners for making all their Earth science data
freely available, and implementing open data access protocols such as
OPeNDAP. `modisfast` heavily builds on top of the OPeNDAP, so we thank
the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) for
developing the eponym tool in an open and collaborative way.

We also thank the contributors that have tested the package, reviewed
the documentation and brought valuable feedbacks to improve the package
: [Florian de Boissieu](https://github.com/floriandeboissieu), Julien
Taconet.

This work has been developed over the course of several research
projects (REACT 1, REACT 2, ANORHYTHM and DIV-YOO) funded by Expertise
France, the French National Research Agency (ANR), and the French
National Research Institute for Sustainable Development (IRD).
