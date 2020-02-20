
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opendapr <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![Travis build
status](https://travis-ci.org/ptaconet/opendapr.svg?branch=master)](https://travis-ci.org/ptaconet/opendapr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/opendapr)](https://cran.r-project.org/package=opendapr)
[![Github\_Status\_Badge](https://img.shields.io/badge/Github-0.0.9007-blue.svg)](https://github.com/ptaconet/opendapr)
<!-- badges: end -->

opendapr is an R package that provides functions to **harmonize** and
**speed-up** the **download** of some well-known and widely-used
**spatiotemporal Earth science datacubes** (e.g.
[MODIS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/),
[VIIRS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/),
[GPM](https://pmm.nasa.gov/GPM) or [SMAP](https://smap.jpl.nasa.gov/))
using the [**OPeNDAP framework**](https://www.opendap.org/about).

***Harmonize ?***

opendapr uses a single function to query the various data servers.

***Speed-up ?***

opendapr uses the OPeNDAP (*Open-source Project for a Network Data
Access Protocol*) abilities to download strictly the data that is needed
: no more 1° x 1° MODIS tiles when our region of interest is only 100 km
x 100 km wide \! This results in a reduction of the physical size of the
data that is imported, and hence of the downloading time. In addition,
opendapr enables to parallelize the download.

[*Another package to download MODIS or SMAP data ?*](#other-packages)
Yes. But opendapr acts a bit differently and hopefully helps if you :

  - are looking to import multiple kind of spatio-temporal Earth science
    data in R (e.g. MODIS, SMAP, GPM),
  - are concerned about downloading time and / or data storage.

## Installation

<!--
You can install the released version of opendapr from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("opendapr")
```
-->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/opendapr")
```

Work is ongoing to publish the package on the CRAN.

## How to use opendapr ?

Downloading the data with opendapr is a simple two-steps workflow :

1.  With the function **`odr_get_url()`**: Retrieve the URL(s) of the
    data for a given collection, variables, time frame, region and
    output data format of interest ;
2.  With the function **`odr_download_data()`**: Download the data to
    your computer.

The `odr_get_url()` function has the following input parameters that
enable to select and filter the data of interest :

  - `collection` : collection of interest (see [next
    section](#coll-available));
  - `variables` : variables to retrieve for the collection of interest.
    If not specified (default) all available variables will be extracted
    ;
  - `roi` : region of interest (`sf` or `sfc` POLYGON-type object) ;
  - `time_range` : date(s) / time(s) of interest (single date / datetime
    or time frame ) ;
  - `output_format` : output format. Available options are : “nc4”
    (default), “ascii”, “json”

Additional functions include : login to EOSDIS Earthdata before querying
the servers and downloading the data (`odr_login()`), list collection
available for download ( `odr_list_collections()` ), list variables
available for each collection ( `odr_list_variables()` ).

Have a look at the [example](#example) below for a simple use case \!

## Which products are available for download through opendapr ?

Currently opendapr enables to download data from four main collections :

  - [MODIS land
    products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/),
    made available by the [NASA / USGS LP
    DAAC](https://lpdaac.usgs.gov/) (➡️ [source OPeNDAP
    server](https://opendap.cr.usgs.gov/opendap/hyrax/)) ;
  - [VIIRS land
    products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/),
    made available by the [NASA / USGS LP
    DAAC](https://lpdaac.usgs.gov/) (➡️ [source OPeNDAP
    server](https://opendap.cr.usgs.gov/opendap/hyrax/)) ;
  - [Global Precipitation Measurement](https://pmm.nasa.gov/GPM) (GPM),
    made available by the [NASA / JAXA GES
    DISC](https://disc.gsfc.nasa.gov/) (➡️ [source OPeNDAP
    server](https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3)) ;
  - [Soil Moisture Active-Passive](https://smap.jpl.nasa.gov/) (SMAP),
    made available by the [NASA NSIDC DAAC](https://nsidc.org/) (➡️
    [source OPeNDAP
    server](https://n5eil02u.ecs.nsidc.org/opendap/SMAP/))

Details of each product available for download are provided in the table
above or through the function `odr_list_collections()`. Want more
details on a specific collection ? Click on the “DOI” column \!

<details>

<summary><b>Data collections available for download with opendapr (click
to expand)</b></summary>

<p>

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection

</th>

<th style="text-align:left;">

Name

</th>

<th style="text-align:left;">

Source

</th>

<th style="text-align:left;">

Nature

</th>

<th style="text-align:left;">

DOI

</th>

<th style="text-align:left;">

url\_opendap\_server

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGDE.06

</td>

<td style="text-align:left;">

GPM IMERG Early Precipitation L3 1 day 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERGDE/DAY/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDE.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGDF.06

</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERGDF/DAY/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGDL.06

</td>

<td style="text-align:left;">

GPM IMERG Late Precipitation L3 1 day 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERGDL/DAY/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDL.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGHH.06

</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERG/3B-HH/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHH.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGHHE.06

</td>

<td style="text-align:left;">

GPM IMERG Early Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERG/3B-HH-E/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHHE.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGHHL.06

</td>

<td style="text-align:left;">

GPM IMERG Late Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERG/3B-HH-L/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHHL.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM\_L3/GPM\_3IMERGM.06

</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 month 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERG/3B-MONTH/06>

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGM.06/>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD12Q1.006

</td>

<td style="text-align:left;">

MODIS/Terra+Aqua Land Cover Type Yearly L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land cover

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD12Q1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD12Q1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD15A2H.006

</td>

<td style="text-align:left;">

MODIS/Terra+Aqua Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Leaf area index

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD15A2H.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD15A2H.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD15A3H.006

</td>

<td style="text-align:left;">

MODIS/Terra+Aqua Leaf Area Index/FPAR 4-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Leaf area index

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD15A3H.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD15A3H.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD43A1.006

</td>

<td style="text-align:left;">

MODIS/Terra and Aqua BRDF/Albedo Model Parameters Daily L3 Global 500 m
SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD43A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD43A2.006

</td>

<td style="text-align:left;">

MODIS/Terra and Aqua BRDF/Albedo Quality Daily L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD43A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD43A3.006

</td>

<td style="text-align:left;">

MODIS/Terra and Aqua Albedo Daily L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD43A3.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A3.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD43A4.006

</td>

<td style="text-align:left;">

MODIS/Terra and Aqua Nadir BRDF-Adjusted Reflectance Daily L3 Global 500
m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD43A4.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A4.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MCD64A1.006

</td>

<td style="text-align:left;">

MODIS/Terra+Aqua Burned Area Monthly L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Burned areas

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MCD64A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MCD64A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD09A1.006

</td>

<td style="text-align:left;">

MODIS/Terra Surface Reflectance 8-Day L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD09A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD09GA.006

</td>

<td style="text-align:left;">

MODIS/Terra Surface Reflectance Daily L2G Global 1 km and 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD09GA.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09GA.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD09GQ.006

</td>

<td style="text-align:left;">

MODIS/Terra Surface Reflectance Daily L2G Global 250 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD09GQ.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09GQ.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD09Q1.006

</td>

<td style="text-align:left;">

MODIS/Terra Surface Reflectance 8-Day L3 Global 250 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD09Q1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09Q1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD11A1.006

</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD11A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD11A2.006

</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD11A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD11B2.006

</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 6 km SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD11B2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11B2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD11B3.006

</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity Monthly L3 Global 6 km
SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD11B3.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11B3.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD13A1.006

</td>

<td style="text-align:left;">

MODIS/Terra Vegetation Indices 16-Day L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD13A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD13A2.006

</td>

<td style="text-align:left;">

MODIS/Terra Vegetation Indices 16-Day L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD13A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD13A3.006

</td>

<td style="text-align:left;">

MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD13A3.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD13Q1.006

</td>

<td style="text-align:left;">

MODIS/Terra Vegetation Indices 16-Day L3 Global 250m SIN Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD13Q1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13Q1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD15A2H.006

</td>

<td style="text-align:left;">

MODIS/Terra Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Leaf area index

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD15A2H.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD15A2H.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD16A2.006

</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration 8-Day L4 Global 500m SIN Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD16A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD16A2GF.006

</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration Gap-Filled 8-Day L4 Global 500 m SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD16A2GF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A2GF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD16A3GF.006

</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration Gap-Filled Yearly L4 Global 500 m SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD16A3GF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A3GF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD17A2H.006

</td>

<td style="text-align:left;">

MODIS/Aqua Gross Primary Productivity 8-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD17A2H.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A2H.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD17A2HGF.006

</td>

<td style="text-align:left;">

MODIS/Terra Gross Primary Productivity Gap-Filled 8-Day L4 Global 500 m
SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD17A2HGF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A2HGF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD17A3.055

</td>

<td style="text-align:left;">

MODIS/Terra Net Primary Production Yearly L4 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD17A3.055>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A3.055/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MOD17A3HGF.006

</td>

<td style="text-align:left;">

MODIS/Terra Net Primary Production Gap-Filled Yearly L4 Global 500 m SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD17A3HGF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A3HGF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODOCGA.006

</td>

<td style="text-align:left;">

MODIS/Terra Ocean Reflectance Daily L2G-Lite Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Ocean Reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MODOCGA.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MODOCGA.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODTBGA.006

</td>

<td style="text-align:left;">

MODIS/Terra Thermal Bands Daily L2G-Lite Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Thermal Bands

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MODTBGA.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MODTBGA.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD09A1.006

</td>

<td style="text-align:left;">

MODIS/Aqua Surface Reflectance 8-Day L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD09A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD09GA.006

</td>

<td style="text-align:left;">

MODIS/Aqua Surface Reflectance Daily L2G Global 1 km and 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD09GA.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09GA.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD09GQ.006

</td>

<td style="text-align:left;">

MODIS/Aqua Surface Reflectance Daily L2G Global 250 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD09GQ.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09GQ.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD09Q1.006

</td>

<td style="text-align:left;">

MODIS/Aqua Surface Reflectance 8-Day L3 Global 250 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD09Q1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09Q1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD11A1.006

</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD11A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD11A2.006

</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD11A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD11B2.006

</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity 8-Day L3 Global 6 km SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD11B2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11B2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD11B3.006

</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity Monthly L3 Global 6 km
SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD11B3.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11B3.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD13A1.006

</td>

<td style="text-align:left;">

MODIS/Aqua Vegetation Indices 16-Day L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD13A1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13A1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD13A2.006

</td>

<td style="text-align:left;">

MODIS/Aqua Vegetation Indices 16-Day L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD13A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD13A3.006

</td>

<td style="text-align:left;">

MODIS/Aqua Vegetation Indices Monthly L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD13A3.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13A3.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD13Q1.006

</td>

<td style="text-align:left;">

MODIS/Aqua Vegetation Indices 16-Day L3 Global 250m SIN Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD13Q1.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13Q1.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD15A2H.006

</td>

<td style="text-align:left;">

MODIS/Aqua Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Leaf area index

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD15A2H.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD15A2H.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD16A2.006

</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration 8-Day L4 Global 500m SIN Grid V006

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD16A2.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A2.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD16A2GF.006

</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration Gap-Filled 8-Day L4 Global 500 m SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD16A2GF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A2GF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD16A3GF.006

</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration Gap-Filled Yearly L4 Global 500 m SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD16A3GF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A3GF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD17A2H.006

</td>

<td style="text-align:left;">

MODIS/Terra Gross Primary Productivity 8-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD17A2H.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD17A2H.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD17A2HGF.006

</td>

<td style="text-align:left;">

MODIS/Aqua Gross Primary Productivity Gap-Filled 8-Day L4 Global 500 m
SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD17A2HGF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD17A2HGF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYD17A3HGF.006

</td>

<td style="text-align:left;">

MODIS/Aqua Net Primary Production Gap-Filled Yearly L4 Global 500 m SIN
Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Primary Productivity

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD17A3HGF.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD17A3HGF.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYDOCGA.006

</td>

<td style="text-align:left;">

MODIS/Aqua Ocean Reflectance Daily L2G-Lite Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Ocean Reflectance

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYDOCGA.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYDOCGA.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

MYDTBGA.006

</td>

<td style="text-align:left;">

MODIS/Aqua Thermal Bands Daily L2G-Lite Global 1 km SIN Grid

</td>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Thermal Bands

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYDTBGA.006>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYDTBGA.006/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

SMAP/SPL3SMP\_E.003

</td>

<td style="text-align:left;">

SMAP Enhanced L3 Radiometer Global Daily 9 km EASE-Grid Soil Moisture,
Version 3

</td>

<td style="text-align:left;">

SMAP

</td>

<td style="text-align:left;">

Soil Moisture

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/T90W6VRLCBHI>

</td>

<td style="text-align:left;">

<https://n5eil02u.ecs.nsidc.org/opendap/SMAP/SPL3SMP_E.003/>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP09A1.001

</td>

<td style="text-align:left;">

VIIRS/NPP Surface Reflectance 8-Day L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP09A1.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP09A1.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP09H1.001

</td>

<td style="text-align:left;">

VIIRS/NPP Surface Reflectance 8-Day L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP09H1.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP09H1.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP13A1.001

</td>

<td style="text-align:left;">

VIIRS/NPP Vegetation Indices 16-Day L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP13A1.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP13A1.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP13A2.001

</td>

<td style="text-align:left;">

VIIRS/NPP Vegetation Indices 16-Day L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP13A2.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP13A2.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP13A3.001

</td>

<td style="text-align:left;">

VIIRS/NPP Vegetation Indices Monthly L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP13A3.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP13A3.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP14A1.001

</td>

<td style="text-align:left;">

VIIRS/NPP Thermal Anomalies/Fire Daily L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Thermal Anomalies/Fire

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP14A1.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP14A1.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP15A2H.001

</td>

<td style="text-align:left;">

VIIRS/NPP Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Leaf area index

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP15A2H.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP15A2H.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP21A1D.001

</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Temperature and Emissivity Daily L3 Global 1 km
SIN Grid Day

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP21A1D.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP21A1D.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP21A1N.001

</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Temperature and Emissivity Daily L3 Global 1 km
SIN Grid Night

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP21A1N.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP21A1N.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP21A2.001

</td>

<td style="text-align:left;">

VIIRS/NPP Land Surface Temperature and Emissivity 8-Day L3 Global 1 km
SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Land surface temperature

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP21A2.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP21A2.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43IA2.001

</td>

<td style="text-align:left;">

VIIRS/NPP BRDF/Albedo Quality Daily L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43IA2.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43IA2.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43IA3.001

</td>

<td style="text-align:left;">

VIIRS/NPP Albedo Daily L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43IA3.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43IA3.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43IA4.001

</td>

<td style="text-align:left;">

VIIRS/NPP Nadir BRDF-Adjusted Reflectance Daily L3 Global 500 m SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43IA4.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43IA4.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43MA1.001

</td>

<td style="text-align:left;">

VIIRS/NPP BRDF/Albedo Model Parameters Daily L3 Global 1 km SIN

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43MA1.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43MA1.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43MA2.001

</td>

<td style="text-align:left;">

VIIRS/NPP BRDF/Albedo Quality Daily L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43MA2.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43MA2.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43MA3.001

</td>

<td style="text-align:left;">

VIIRS/NPP Albedo Daily L3 Global 1 km SIN Grid

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Albedo

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43MA3.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43MA3.001/contents.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP43MA4.001

</td>

<td style="text-align:left;">

VIIRS/NPP Nadir BRDF-Adjusted Reflectance Daily L3 Global 1 km SIN

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Surface reflectance

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP43MA4.001>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/VNP43MA4.001/contents.html>

</td>

</tr>

</tbody>

</table>

</p>

</details>

## Example

Let’s say we want to download over the 50 km x 50 km wide region of
interest (ROI) located in Northern Ivory Coast :

  - a 40 days time series of [MODIS/Terra Land Surface
    Temperature/Emissivity Daily L3 Global 1km SIN
    Grid](https://dx.doi.org/10.5067/MODIS/MOD11A1.006)
    (collection=“MOD11A1.006”)
  - the same 40 days times series of [GPM IMERG Final Precipitation L3 1
    day 0.1 degree x 0.1
    degree](https://doi.org/10.5067/GPM/IMERGDF/DAY/06)
    (collection=“GPM\_L3/GPM\_3IMERGDF.06”)

<!-- end list -->

``` r
### Prepare script
# Load the packages
require(opendapr)
require(sf)

# Define ROI and time range of interest
roi <- st_as_sf(data.frame(geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),wkt="geom",crs = 4326)
time_range <- as.Date(c("2017-01-01","2017-01-30"))

# Login to Earthdata servers with username and password. To create an account go to : https://urs.earthdata.nasa.gov/.
# Here we have stored our credentials in local environment variables
username <- Sys.getenv("earthdata_un") 
password <- Sys.getenv("earthdata_pw")
log <- odr_login(credentials = c(username,password), source = "earthdata")
#> Checking credentials...
#> Successfull odr_login to earthdata
```

Download the data in two steps :

1.  Get the OPeNDAP URLs with the `odr_get_url()` function ;
2.  Download the data with the `odr_download_data()` function.

<!-- end list -->

``` r
## Get the URLs for MOD11A1.006
urls_mod11a1 <- odr_get_url(
  collection = "MOD11A1.006",
  roi = roi,
  time_range = time_range
 )

## Get the URLs for GPM_L3/GPM_3IMERGDF.06
urls_gpm <- odr_get_url(
  collection = "GPM_L3/GPM_3IMERGDF.06",
  roi = roi,
  time_range = time_range
 )

print(str(urls_mod11a1))
#> 'data.frame':    1 obs. of  4 variables:
#>  $ time_start: Date, format: "2017-01-01"
#>  $ name      : chr "MOD11A1.006.2017001_2017030.h17v08"
#>  $ url       : chr "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.006/h17v08.ncml.nc4?MODIS_Grid_Daily_1km_LST_eos_cf_projectio"| __truncated__
#>  $ destfile  : chr "MOD11A1.006/MOD11A1.006.2017001_2017030.h17v08.nc4"
#> NULL

print(str(urls_gpm))
#> 'data.frame':    30 obs. of  4 variables:
#>  $ time_start: Date, format: "2017-01-01" "2017-01-02" ...
#>  $ name      : chr  "3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V06" "3B-DAY.MS.MRG.3IMERG.20170102-S000000-E235959.V06" "3B-DAY.MS.MRG.3IMERG.20170103-S000000-E235959.V06" "3B-DAY.MS.MRG.3IMERG.20170104-S000000-E235959.V06" ...
#>  $ url       : chr  "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170101-S0000"| __truncated__ "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170102-S0000"| __truncated__ "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170103-S0000"| __truncated__ "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170104-S0000"| __truncated__ ...
#>  $ destfile  : chr  "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V06.nc4" "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170102-S000000-E235959.V06.nc4" "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170103-S000000-E235959.V06.nc4" "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170104-S000000-E235959.V06.nc4" ...
#> NULL

## Download the data. Destination file for each dataset is specified in the column "destfile" of the data.frames urls_mod11a1 and urls_gpm
df_to_dl <- rbind(urls_mod11a1,urls_gpm)
res_dl <- odr_download_data(df_to_dl,source="earthdata",parallel = TRUE)

print(str(res_dl))
#> 'data.frame':    31 obs. of  7 variables:
#>  $ time_start: Date, format: "2017-01-01" "2017-01-01" ...
#>  $ name      : chr  "MOD11A1.006.2017001_2017030.h17v08" "3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V06" "3B-DAY.MS.MRG.3IMERG.20170102-S000000-E235959.V06" "3B-DAY.MS.MRG.3IMERG.20170103-S000000-E235959.V06" ...
#>  $ url       : chr  "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.006/h17v08.ncml.nc4?MODIS_Grid_Daily_1km_LST_eos_cf_projectio"| __truncated__ "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170101-S0000"| __truncated__ "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170102-S0000"| __truncated__ "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170103-S0000"| __truncated__ ...
#>  $ destfile  : chr  "MOD11A1.006/MOD11A1.006.2017001_2017030.h17v08.nc4" "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V06.nc4" "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170102-S000000-E235959.V06.nc4" "GPM_L3/GPM_3IMERGDF.06/3B-DAY.MS.MRG.3IMERG.20170103-S000000-E235959.V06.nc4" ...
#>  $ fileDl    : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
#>  $ fileSize  : num  274915 60802 60817 60827 60794 ...
#>  $ dlStatus  : num  3 3 3 3 3 3 3 3 3 3 ...
#> NULL
```

It is also possible to subset the bands to download with the parameter
`variables` of the function `odr_get_url()`.

To further import the data in R, have a look at the section [Important
note regarding the further import of the data in
R](#important-note-import) \!

Simple or advanced data download and import workflows are provided in
the vignettes `vignette("simple_workflow")` and
`vignette("advanced_workflow")`.

## Important note regarding the further import of the data in R

Various packages and related classes can be used to read the data
downloaded through OPeNDAP. If `raster` is surely the most famous class
for raster objects, many packages facilitate the use of spatiotemporal
data cubes. For instance, MODIS or VIIRS products can be imported as a
`stars` object from the excellent
[`stars`](https://cran.r-project.org/package=stars) package for data
cubes manipulation. All the data can also be imported as `ncdf4` objects
using e.g. the [`ncdf4`](https://cran.r-project.org/package=ncdf4)
package, or `RasterLayer` of the
[`raster`](https://cran.r-project.org/package=raster) package.

In any case, care must be taken when importing data that was downloaded
through the OPeNDAP data providers servers. Depending on the collection,
some “issues” were raised. These issues are independant from opendapr :
they result most of time of a kind of lack of full implementation of the
OPeNDAP framework by the data providers. These issues are :

  - for MODIS and VNP collections : CRS has to be provided
  - for GPM collections : CRS has to be provided + data have to be
    flipped
  - for SMAP collections : CRS + bounding coordinates of the data have
    to be provided

These issues can easily be dealt at the import phase in R. The functions
below includes the processings that have to be done at the data import
phase in order to open the data as `raster` objects. (argument
`destfiles` is the path to a dataset downloaded with opendapr - output
of `odr_get_url()$destfile` - and `variable` is the name of a variable
to import).

``` r
require(raster)
## Function to import MODIS or VIIRS products as RasterLayer object
.import_modis <- function(destfiles,variable){
  rasts <- destfiles %>%
    raster::brick(varname = variable, crs = "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
  return(rasts)
}
```

``` r
require(raster)
require(purrr)
## Function to import GPM products as RasterLayer object
.import_gpm <- function(destfiles,variable){
  rasts <- destfiles %>%
    purrr::map(~raster(., varname = variable,crs = "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ")) %>%
    raster::brick() %>%
    raster::t() %>%
    raster::flip("y") %>%
    raster::flip("x")
  return(rasts)
}
```

``` r
require(raster)
require(purrr)
require(ncdf4)
## Function to import SMAP products as RasterLayer object
smap_sp_bound <- opendapr::odr_get_opt_param(roi = roi, collection = "SMAP/SPL3SMP_E.003")$roiSpatialBound$`1`

.import_smap <- function(destfiles,variable,smap_sp_bound){
 rasts <- destfiles %>%
   purrr::map(~ncdf4::nc_open(.)) %>%
   purrr::map(~ncdf4::ncvar_get(., "Soil_Moisture_Retrieval_Data_AM_soil_moisture")) %>%
   purrr::map(~raster(t(.), ymn=smap_sp_bound[1], ymx=smap_sp_bound[2], xmn=smap_sp_bound[3], xmx=smap_sp_bound[4], crs="+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")) %>%  # EPSG : 6933
   raster::brick()
  return(rasts)
}
```

## Other packages

Many packages enable to download the data that are proposed through
opendapr. Above we list some of them, along with some of their
characteristics
:

| Package                                                |          Data           | Spatial subsetting\* | Dimensional subsetting\* | Image preprocessing |
| :----------------------------------------------------- | :---------------------: | :------------------: | :----------------------: | :-----------------: |
| [`MODIS`](https://github.com/MatMatt/MODIS)            |          MODIS          |          ❌           |            ❌             |          ✅          |
| [`MODIStsp`](https://github.com/ropensci/MODIStsp)     |          MODIS          |          ❌           |            ✅             |          ✅          |
| [`MODISTools`](https://github.com/ropensci/MODISTools) |          MODIS          |          ✅           |            ✅             |          ✅          |
| [`smapr`](https://github.com/ropensci/smapr)           |          SMAP           |          ❌           |            ❌             |          ❌          |
| [`opendapr`](https://github.com/ptaconet/opendapr)     | MODIS, VIIRS, SMAP, GPM |          ✅           |            ✅             |          ❌          |

\* at the downloading phase

<!--
## Citation

We thank in advance people that use opendapr for citing it in their work / publication(s). For this, please use the citation provided at this link [zenodo link to add] or through `citation("opendapr")`.
-->

## Next steps

Next developments may involve :

  - Short term : including more SMAP collections (at now only
    SPL3SMP\_3.003 collection is available)
  - Longer term : including access to other collections and OPeNDAP
    servers

Any contribution is welcome \!

## Context and other thoughts

opendapr provides an entry point to some specific OPeNDAP servers
(e.g. MODIS, VNP, GPM or SMAP). The development of the package was
motivated by the following reasons :

  - **Providing a simple and single way in R to download data stored on
    heterogeneous servers** : People that use Earth science data often
    struggle with data access. In opendapr we propose an harmonized way
    to download data from various providers that have implemented access
    to their data through OPeNDAP.
  - **Fastening the data import phase**, especially for large time
    series analysis.

Apart from these performance aspects, ethical considerations have driven
the development of this package :

  - **Facilitating the access to Earth science data in places of the
    World where internet connections is slow or expensive** : Earth
    science products are generally huge files that can be quite
    difficult to download in places with slow internet connection, even
    more if large time series are needed. By enabling to download
    strictly the data that is needed, the products become more
    accessible in those places;
  - **Caring about the environmental digital impact of our research
    work** : Downloading data has an impact on environment and to some
    extent contributes to climate change. By downloading only the data
    that is need (rather than e.g a whole MODIS tile, or a global SMAP
    or GPM dataset) we somehow contribute to digital sobriety.
  - **Supporting the open-source-software movement** : The OPeNDAP is
    developed and advanced openly and collaboratively, by the non-profit
    [OPeNDAP, Inc.](https://www.opendap.org/about) This data access
    protocol is more and more used, by major Earth science data
    providers (e.g. NASA or NOAA). Using OPeNDAP means supporting
    methods and data access protocols that are open.

## Acknowledgment

We thank NASA and its partners for making all their Earth science data
freely available, and implementing open data access protocols such as
OPeNDAP. opendapr heavily builds on top of the OPeNDAP, so we thank the
non-profit [OPeNDAP, Inc.](https://www.opendap.org/about) for developing
the eponym tool in an open and collaborative way.

The initial development and first release of this package were financed
by the [MIVEGEC](https://www.mivegec.ird.fr/en/) unit of the [French
Research Institute for Sustainable Development](https://en.ird.fr/), as
part of the [REACT
project](https://burkina-faso.ird.fr/la-recherche/projets-de-recherche2/gestion-de-la-resistance-aux-insecticides-au-burkina-faso-et-en-cote-d-ivoire-recherche-sur-les-strategies-de-lutte-anti-vectorielle-react).
