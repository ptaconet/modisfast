
<!-- README.md is generated from README.Rmd. Please edit that file -->

# modisfast

<!-- <img src="man/figures/logo.png" align="right" /> -->
<!-- badges: start -->

[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/modisfast)](https://cran.r-project.org/package=modisfast)
[![Github_Status_Badge](https://img.shields.io/badge/Github-0.9.2-blue.svg)](https://github.com/ptaconet/modisfast)
[![R-CMD-check](https://github.com/ptaconet/modisfast/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ptaconet/modisfast/actions/workflows/R-CMD-check.yaml)
[![DOI](https://joss.theoj.org/papers/abd5750a442de6a9d95b60bf49c440cb/status.svg)](https://joss.theoj.org/papers/abd5750a442de6a9d95b60bf49c440cb)
![CRAN_downloads](https://cranlogs.r-pkg.org/badges/grand-total/modisfast)
<!-- [![SWH](https://archive.softwareheritage.org/badge/origin/https://github.com/ptaconet/modisfast/)](https://archive.softwareheritage.org/browse/origin/?origin_url=https://github.com/ptaconet/modisfast) -->
<!-- [![DOI-zenodo](https://zenodo.org/badge/doi/10.5281/zenodo.8475.svg)](https://doi.org/10.5281/zenodo.12772739) -->
<!-- badges: end -->

<!-- ATTENTION A CHANGER : FUSEAUX HORAIRES POUR DONNEES GPM HALF HOURLY !!!!!!
AUSSI : min filesize (le fichier peut etre plus petit que 50 k.. e.g. titi)
renvoyer erreur ou warning si le fichier n'existe pas
-->

<!-- ⚠️ Package still under development ! -->

<!--
R package to access various spatiotemporal Earth science data collections in R using the [OPeNDAP framework](https://www.opendap.org/about/). Currently implemented data collections are [MODIS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/), [VIIRS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/), [GPM](https://pmm.nasa.gov/GPM) and [SMAP](https://smap.jpl.nasa.gov/)). 
Opendap (*Open-source Project for a Network Data Access Protocol*) is a data access protocol that enables to subset the data  - spatially, temporally, etc. - directly at the downloading phase. Filters are provided directly within a http url. For example the following URL : 
https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.006/h17v08.ncml.nc4?MODIS_Grid_Daily_1km_LST_eos_cf_projection,LST_Day_1km[6093:6122][55:140][512:560],LST_Night_1km[6093:6122][55:140][512:560],QC_Day[6093:6122][55:140][512:560],QC_Night[6093:6122][55:140][512:560],time[6093:6122],YDim[55:140],XDim[512:560]
provides the MOD11A1.006 (MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN Grid V006) data in netCDF, subsetted for bands LST_Day_1km, LST_Night_1km, QC_Day, QC_Night, for each day between the 2017-01-01 and the 2017-01-30, and within the following bounding box (lon/lat): -5.41 8.84, -5.82 9.54.
This package enables to build OPeNDAP (https) URLs given input parameters such as a data collection, region and time range of interst . These URLs can then be used to either download the data to your workspace or computer, or access the datacube directly as an R object (of class `ndcf4`, `raster`, `stars`, etc.)
-->

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

## Overview

**`modisfast`** is an R package designed for **easy** and **fast**
downloads of
[**MODIS**](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/)
Land products,
[**VIIRS**](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/)
Land products, and [**GPM**](https://gpm.nasa.gov/data) (Global
Precipitation Measurement Mission) Earth Observation data.

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

Accessing and opening MODIS data with `modisfast` is a simple 3-steps
workflow. This example shows how to download and import a one-year-long
monthly time series of MODIS Normalized Difference Vegetation Index
(NDVI) at 1 km spatial resolution over the whole country of Madagascar.

**1/ First, define the variables of interest (ROI, time frame,
collection, and bands) :**

``` r
# Load the packages
library(modisfast)
library(sf)
library(terra)

# ROI and time range of interest
roi <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt = "geom", crs = 4326) # a ROI of interest, format sf polygon
time_range <- as.Date(c("2023-01-01", "2023-12-31")) # a time range of interest

# MODIS collections and variables (bands) of interest
collection <- "MOD13A3.061" # run mf_list_collections() for an exhaustive list of collections available
variables <- c("_1_km_monthly_NDVI") # run mf_list_variables("MOD13A3.061") for an exhaustive list of variables available for the collection "MOD13A3.061"
```

**2/ Then, get the URL of the data and download them :**

``` r
## Login to Earthdata servers with your EOSDIS credentials.
# To create an account (free) go to : https://urs.earthdata.nasa.gov/.
log <- mf_login(credentials = c("username", "password")) # set your own EOSDIS username and password

## Get the URLs of the data
urls <- mf_get_url(
  collection = collection,
  variables = variables,
  roi = roi,
  time_range = time_range
)

## Download the data. By default the data is downloaded in a temporary directory, but you can specify a folder
res_dl <- mf_download_data(urls, parallel = TRUE)
```

**3/ And finally, import the data in R as a `terra::SpatRaster` object
using the function `mf_import_data()`** ( :warning: see
[here](https://ptaconet.github.io/modisfast/articles/get_started.html#warning-import)
why you should use this function, instead of the original
`terra::rast()`, in the context of `modisfast`) :

``` r
r <- mf_import_data(
  path = dirname(res_dl$destfile[1]),
  collection = collection,
  proj_epsg = 4326
)

terra::plot(r, col = rev(terrain.colors(20)))
```

<figure>
<img src=".Rplot_readme.png"
alt="Time series of monthly 1-km MODIS NDVI over Madagascar for the year 2023, retrieved with modisfast" />
<figcaption aria-hidden="true">Time series of monthly 1-km MODIS NDVI
over Madagascar for the year 2023, retrieved with
<code>modisfast</code></figcaption>
</figure>

  
et voilà !

Want more examples ? `modisfast` provides three long-form documentations
and examples to learn more about the package :

- a [“Get started”
  article](https://ptaconet.github.io/modisfast/articles/get_started.html)
  describing the core features of the package;
- a [“Get data on several regions or periods of interest simultaneously”
  article](https://ptaconet.github.io/modisfast/articles/modisfast2.html)
  detailing advanced functionalities of `modisfast` (for multi-time
  frame or multi-regions data access);
- a [“Full use case”
  article](https://ptaconet.github.io/modisfast/articles/use_case.html)
  showcasing an example of use of the package in a scientific context
  (here: landscape epidemiology).

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

Currently `modisfast` supports download of 77 data collections,
extracted from the following meta-collections :

- [MODIS land
  products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/)
  made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/)
  ( :arrow_right: [source OPeNDAP
  server](https://opendap.cr.usgs.gov/opendap/hyrax/)) ;
- [VIIRS land
  products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/)
  made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/)
  ( :arrow_right: [source OPeNDAP
  server](https://opendap.cr.usgs.gov/opendap/hyrax/))
- [Global Precipitation Measurement](https://gpm.nasa.gov/missions/GPM)
  (GPM) made available by the [NASA / JAXA GES
  DISC](https://disc.gsfc.nasa.gov/) ( :arrow_right: [source OPeNDAP
  server](https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/)).

Details of each product available for download are provided in the
tables below or through the function `mf_list_collections()`.

<details>
<summary>
<b>MODIS and VIIRS data collections accessible with modisfast (click to
expand)</b>
</summary>
<p>
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD43A1.061" style="     ">MCD43A1.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD43A2.061" style="     ">MCD43A2.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
MODIS/Terra and Aqua BRDF/Albedo Quality Daily L3 Global 500 m SIN Grid
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD43A3.061" style="     ">MCD43A3.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
MODIS/Terra and Aqua Albedo Daily L3 Global 500 m SIN Grid
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
<a href="https://doi.org/10.5067/VIIRS/VNP43MA2.001" style="     ">VNP43MA2.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
VIIRS/NPP BRDF/Albedo Quality Daily L3 Global 1 km SIN Grid
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
<a href="https://doi.org/10.5067/VIIRS/VNP43MA3.001" style="     ">VNP43MA3.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
VIIRS/NPP Albedo Daily L3 Global 1 km SIN Grid
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
<a href="https://doi.org/10.5067/VIIRS/VNP43MA1.001" style="     ">VNP43MA1.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
VIIRS/NPP BRDF/Albedo Model Parameters Daily L3 Global 1 km SIN
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
<a href="https://doi.org/10.5067/VIIRS/VNP43IA2.001" style="     ">VNP43IA2.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
VIIRS/NPP BRDF/Albedo Quality Daily L3 Global 500 m SIN Grid
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
<a href="https://doi.org/10.5067/VIIRS/VNP43IA3.001" style="     ">VNP43IA3.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Albedo
</td>
<td style="text-align:left;">
VIIRS/NPP Albedo Daily L3 Global 500 m SIN Grid
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD64A1.061" style="     ">MCD64A1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Burned areas
</td>
<td style="text-align:left;">
MODIS/Terra+Aqua Burned Area Monthly L3 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
</td>
<td style="text-align:left;">
30 day
</td>
<td style="text-align:left;">
2000-11-01 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD16A2GF.061" style="     ">MOD16A2GF.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD16A2GF.061" style="     ">MYD16A2GF.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD16A2.061" style="     ">MOD16A2.061</a>
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
2001-01-01 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD16A3GF.061" style="     ">MOD16A3GF.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD16A2.061" style="     ">MYD16A2.061</a>
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
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MYD16A3GF.061" style="     ">MYD16A3GF.061</a>
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
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MCD12Q1.061" style="     ">MCD12Q1.061</a>
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
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD11A2.061" style="     ">MOD11A2.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD11A1.061" style="     ">MOD11A1.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD11A2.061" style="     ">MYD11A2.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD11A1.061" style="     ">MYD11A1.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD11B2.061" style="     ">MOD11B2.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 6 km SIN
Grid
</td>
<td style="text-align:left;">
6000 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD11B3.061" style="     ">MOD11B3.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD11B2.061" style="     ">MYD11B2.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
MODIS/Aqua Land Surface Temperature/Emissivity 8-Day L3 Global 6 km SIN
Grid
</td>
<td style="text-align:left;">
6000 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD11B3.061" style="     ">MYD11B3.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
MODIS/Aqua Land Surface Temperature/Emissivity Monthly L3 Global 6 km
SIN Grid
</td>
<td style="text-align:left;">
6000 m
</td>
<td style="text-align:left;">
30 day
</td>
<td style="text-align:left;">
2002-07-01 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP21A2.001" style="     ">VNP21A2.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
VIIRS/NPP Land Surface Temperature and Emissivity 8-Day L3 Global 1 km
SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
8 day
</td>
<td style="text-align:left;">
2012-01-25 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP21A1N.001" style="     ">VNP21A1N.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
VIIRS/NPP Land Surface Temperature and Emissivity Daily L3 Global 1 km
SIN Grid Night
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
<a href="https://doi.org/10.5067/VIIRS/VNP21A1D.001" style="     ">VNP21A1D.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
VIIRS/NPP Land Surface Temperature and Emissivity Daily L3 Global 1 km
SIN Grid Day
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD15A2H.061" style="     ">MOD15A2H.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Leaf area index
</td>
<td style="text-align:left;">
MODIS/Terra Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD15A2H.061" style="     ">MYD15A2H.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Leaf area index
</td>
<td style="text-align:left;">
MODIS/Aqua Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD15A2H.061" style="     ">MCD15A2H.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Leaf area index
</td>
<td style="text-align:left;">
MODIS/Terra+Aqua Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD15A3H.061" style="     ">MCD15A3H.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Leaf area index
</td>
<td style="text-align:left;">
MODIS/Terra+Aqua Leaf Area Index/FPAR 4-Day L4 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
</td>
<td style="text-align:left;">
4 day
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP15A2H.001" style="     ">VNP15A2H.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Leaf area index
</td>
<td style="text-align:left;">
VIIRS/NPP Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid
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
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MODOCGA.061" style="     ">MODOCGA.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Ocean Reflectance
</td>
<td style="text-align:left;">
MODIS/Terra Ocean Reflectance Daily L2G-Lite Global 1 km SIN Grid
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
<a href="https://dx.doi.org/10.5067/MODIS/MYDOCGA.061" style="     ">MYDOCGA.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Ocean Reflectance
</td>
<td style="text-align:left;">
MODIS/Aqua Ocean Reflectance Daily L2G-Lite Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
Daily
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD17A3HGF.061" style="     ">MOD17A3HGF.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD17A3HGF.061" style="     ">MYD17A3HGF.061</a>
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
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD17A2H.061" style="     ">MOD17A2H.061</a>
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
2000-02-18 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD17A2HGF.061" style="     ">MOD17A2HGF.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD17A2H.061" style="     ">MYD17A2H.061</a>
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
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MYD17A2HGF.061" style="     ">MYD17A2HGF.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD09GA.061" style="     ">MYD09GA.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Aqua Surface Reflectance Daily L2G Global 1 km and 500 m SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
Daily
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD09GA.061" style="     ">MOD09GA.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Terra Surface Reflectance Daily L2G Global 1 km and 500 m SIN Grid
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD09GQ.061" style="     ">MOD09GQ.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Terra Surface Reflectance Daily L2G Global 250 m SIN Grid
</td>
<td style="text-align:left;">
250 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD09GQ.061" style="     ">MYD09GQ.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Aqua Surface Reflectance Daily L2G Global 250 m SIN Grid
</td>
<td style="text-align:left;">
250 m
</td>
<td style="text-align:left;">
Daily
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MYD09Q1.061" style="     ">MYD09Q1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Aqua Surface Reflectance 8-Day L3 Global 250 m SIN Grid
</td>
<td style="text-align:left;">
250 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD09Q1.061" style="     ">MOD09Q1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Terra Surface Reflectance 8-Day L3 Global 250 m SIN Grid
</td>
<td style="text-align:left;">
250 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD09A1.061" style="     ">MYD09A1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Aqua Surface Reflectance 8-Day L3 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MCD43A4.061" style="     ">MCD43A4.061</a>
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
<a href="https://dx.doi.org/10.5067/MODIS/MOD09A1.061" style="     ">MOD09A1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
MODIS/Terra Surface Reflectance 8-Day L3 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
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
<a href="https://doi.org/10.5067/VIIRS/VNP09A1.001" style="     ">VNP09A1.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
VIIRS/NPP Surface Reflectance 8-Day L3 Global 1 km SIN Grid
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
<a href="https://doi.org/10.5067/VIIRS/VNP43MA4.001" style="     ">VNP43MA4.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
VIIRS/NPP Nadir BRDF-Adjusted Reflectance Daily L3 Global 1 km SIN
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
<a href="https://doi.org/10.5067/VIIRS/VNP09H1.001" style="     ">VNP09H1.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
VIIRS/NPP Surface Reflectance 8-Day L3 Global 500 m SIN Grid
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
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP43IA4.001" style="     ">VNP43IA4.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Surface reflectance
</td>
<td style="text-align:left;">
VIIRS/NPP Nadir BRDF-Adjusted Reflectance Daily L3 Global 500 m SIN Grid
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
<a href="https://doi.org/10.5067/VIIRS/VNP14A1.001" style="     ">VNP14A1.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Thermal Anomalies/Fire
</td>
<td style="text-align:left;">
VIIRS/NPP Thermal Anomalies/Fire Daily L3 Global 1 km SIN Grid
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
<a href="https://dx.doi.org/10.5067/MODIS/MODTBGA.061" style="     ">MODTBGA.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Thermal Bands
</td>
<td style="text-align:left;">
MODIS/Terra Thermal Bands Daily L2G-Lite Global 1 km SIN Grid
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
<a href="https://dx.doi.org/10.5067/MODIS/MYDTBGA.061" style="     ">MYDTBGA.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Thermal Bands
</td>
<td style="text-align:left;">
MODIS/Aqua Thermal Bands Daily L2G-Lite Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
Daily
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD13A2.061" style="     ">MOD13A2.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Terra Vegetation Indices 16-Day L3 Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2000-02-18 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD13A3.061" style="     ">MOD13A3.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
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
<a href="https://dx.doi.org/10.5067/MODIS/MYD13A2.061" style="     ">MYD13A2.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Aqua Vegetation Indices 16-Day L3 Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MYD13A3.061" style="     ">MYD13A3.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Aqua Vegetation Indices Monthly L3 Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
30 day
</td>
<td style="text-align:left;">
2002-07-01 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD13Q1.061" style="     ">MOD13Q1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Terra Vegetation Indices 16-Day L3 Global 250m SIN Grid v061
</td>
<td style="text-align:left;">
250 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2000-02-18 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MYD13Q1.061" style="     ">MYD13Q1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Aqua Vegetation Indices 16-Day L3 Global 250m SIN Grid v061
</td>
<td style="text-align:left;">
250 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MOD13A1.061" style="     ">MOD13A1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Terra Vegetation Indices 16-Day L3 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2000-02-18 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://dx.doi.org/10.5067/MODIS/MYD13A1.061" style="     ">MYD13A1.061</a>
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
MODIS/Aqua Vegetation Indices 16-Day L3 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2002-07-04 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP13A2.001" style="     ">VNP13A2.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
VIIRS/NPP Vegetation Indices 16-Day L3 Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2012-01-17 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP13A3.001" style="     ">VNP13A3.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
VIIRS/NPP Vegetation Indices Monthly L3 Global 1 km SIN Grid
</td>
<td style="text-align:left;">
1000 m
</td>
<td style="text-align:left;">
30 day
</td>
<td style="text-align:left;">
2012-01-01 to present
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://doi.org/10.5067/VIIRS/VNP13A1.001" style="     ">VNP13A1.001</a>
</td>
<td style="text-align:left;">
VIIRS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
VIIRS/NPP Vegetation Indices 16-Day L3 Global 500 m SIN Grid
</td>
<td style="text-align:left;">
500 m
</td>
<td style="text-align:left;">
16 day
</td>
<td style="text-align:left;">
2012-01-17 to present
</td>
</tr>
</tbody>
</table>
</p>
</details>
<details>
<summary>
<b>Other (non-MODIS or VIIRS) data collections accessible with modisfast
(click to expand)</b>
</summary>
<p>
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
<a href="https://doi.org/10.5067/GPM/IMERGDE/DAY/06" style="     ">GPM_3IMERGDE.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERGDF/DAY/06" style="     ">GPM_3IMERGDF.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERGDF/DAY/07" style="     ">GPM_3IMERGDF.07</a>
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
<a href="https://doi.org/10.5067/GPM/IMERGDL/DAY/06" style="     ">GPM_3IMERGDL.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH/06" style="     ">GPM_3IMERGHH.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH/07" style="     ">GPM_3IMERGHH.07</a>
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
<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH-E/06" style="     ">GPM_3IMERGHHE.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERG/3B-HH-L/06" style="     ">GPM_3IMERGHHL.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERG/3B-MONTH/06" style="     ">GPM_3IMERGM.06</a>
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
<a href="https://doi.org/10.5067/GPM/IMERG/3B-MONTH/07" style="     ">GPM_3IMERGM.07</a>
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
</p>
</details>

## Manual testing of the functionality

Since most `modisfast` functions depend on EarthData credentials,
automated tests are disabled. However, after installation, users can
manually test the package’s functionality by running these lines of code
:

``` r
# replace "username" and "password" with your own EOSDIS (Earthdata) credentials 
earthdata_un <- "username" 
earthdata_pw <- "password"

devtools::test("modisfast")
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

Let’s take an example to understand.

The following URL :arrow_down:

https<nolink>://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.061/h17v08.ncml.nc4?MODIS_Grid_8Day_1km_LST_eos_cf_projection,LST_Day_1km\[775:793\]\[55:140\]\[512:560\],LST_Night_1km\[775:793\]\[55:140\]\[512:560\],QC_Day\[775:793\]\[55:140\]\[512:560\],QC_Night\[775:793\]\[55:140\]\[512:560\],time\[775:793\],YDim\[55:140\],XDim\[512:560\]

is a link to download the following subset of MOD11A2.061 data in netCDF
:

- bands LST_Day_1km, LST_Night_1km, QC_Day, QC_Night ;
- each available date between the 2017-01-01 and the 2017-06-01 ;
- within the following bounding box (lon/lat): -5.41 8.84, -5.82 9.54.

The indices within the `[]` refer to values encoding for the spatial and
temporal filters.

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

|                            Package                            |                Data                | Available on CRAN  | Utilizes open standards for data access protocols | Spatial subsetting\* | Dimensional subsetting\* | Maximum area size allowed for download |     Speed\*\*      |
|:-------------------------------------------------------------:|:----------------------------------:|:------------------:|:-------------------------------------------------:|:--------------------:|:------------------------:|:--------------------------------------:|:------------------:|
|     [`modisfast`](https://github.com/ptaconet/modisfast)      |         MODIS, VIIRS, GPM          | :white_check_mark: |                :white_check_mark:                 |  :white_check_mark:  |    :white_check_mark:    |               unlimited                | :white_check_mark: |
|   [`appeears`](https://github.com/bluegreen-labs/appeears)    |   MODIS, VIIRS, and many others    | :white_check_mark: |                :white_check_mark:                 |  :white_check_mark:  |    :white_check_mark:    |               unlimited                |      variable      |
| [`MODISTools`](https://github.com/bluegreen-labs/MODISTools/) |            MODIS, VIIRS            | :white_check_mark: |                        :x:                        |  :white_check_mark:  |    :white_check_mark:    |            200 km x 200 km             | :white_check_mark: |
|          [`rgee`](https://github.com/r-spatial/rgee)          | MODIS, VIIRS, GPM, and many others | :white_check_mark: |                        :x:                        |  :white_check_mark:  |    :white_check_mark:    |               unlimited                |     not tested     |
|      [`MODIStsp`](https://github.com/ropensci/MODIStsp)       |               MODIS                |        :x:         |                                                   |         :x:          |    :white_check_mark:    |               unlimited                |         NA         |
|          [`MODIS`](https://github.com/fdetsch/MODIS)          |               MODIS                |        :x:         |                        :x:                        |         :x:          |           :x:            |                   NA                   |         NA         |

\* at the downloading phase

\*\* Take a look at the article [“Comparison of performance with other
similar R
packages”](https://ptaconet.github.io/modisfast/articles/perf_comp.html)
to get an overview of how `modisfast` compares to these packages in
terms of data access time.

## Citation

This package is licensed under a [GNU General Public License v3.0 or
later](https://www.gnu.org/licenses/gpl-3.0-standalone.html) license.

We thank in advance people that use `modisfast` for citing it in their
work / publication(s). For this, please use the following citation :

> Taconet, P. & Moiroux N.(2024). modisfast: Fast and Efficient Access
> to MODIS Earth Observation Data. In CRAN: Contributed Packages. The R
> Foundation. <https://doi.org/10.32614/cran.package.modisfast>

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
