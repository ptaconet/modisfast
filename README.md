
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opendapr <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

<!--
[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![Travis build status](https://travis-ci.org/ptaconet/opendapr.svg?branch=master)](https://travis-ci.org/ptaconet/opendapr)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/opendapr)](https://cran.r-project.org/package=opendapr)
[![Github_Status_Badge](https://img.shields.io/badge/Github-0.1.0-blue.svg)](https://github.com/ptaconet/opendapr)
<!-- badges: end -->

**opendapr** is an R package that provides functions to **harmonize**
and **speed-up** the **download** of some well-known and widely-used
**spatiotemporal Earth science datacubes** (e.g.
[MODIS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/),
[VIIRS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/),
[GPM](https://pmm.nasa.gov/GPM) or [SMAP](https://smap.jpl.nasa.gov/))
using the [**OPeNDAP framework**](https://www.opendap.org/about)
(*Open-source Project for a Network Data Access Protocol*)

***Harmonize ?***

**opendapr** proposes a single function to query the various data
servers, and another single function to download the data.

***Speed-up ?***

**opendapr** uses the abilities offered by the OPeNDAP to download a
subset of data cube, along spatial, temporal or any other data dimension
(depth, …). This way, it reduces downloading time and disk usage to
their minimum : no more 1° x 1° MODIS tiles when your region of interest
is only 100 km x 100 km wide \! Moreover, opendapr supports parallelized
downloads.

Below is a comparison of opendapr with other packages available for
downloading chunks of remote sensing data
:

| Package                                                |          Data           | Spatial subsetting\* | Dimensional subsetting\* |
| :----------------------------------------------------- | :---------------------: | :------------------: | :----------------------: |
| [`opendapr`](https://github.com/ptaconet/opendapr)     | MODIS, VIIRS, SMAP, GPM |          ✅           |            ✅             |
| [`MODIS`](https://github.com/MatMatt/MODIS)            |          MODIS          |          ❌           |            ❌             |
| [`MODIStsp`](https://github.com/ropensci/MODIStsp)     |          MODIS          |          ❌           |            ✅             |
| [`MODISTools`](https://github.com/ropensci/MODISTools) |          MODIS          |          ✅           |            ✅             |
| [`smapr`](https://github.com/ropensci/smapr)           |          SMAP           |          ❌           |            ❌             |

\* at the downloading phase

By enabling to download subsets of data cubes, opendapr facilites the
access to Earth science data for R users in places where internet
connection is slow or expensive and promotes digital sobriety for our
research work.

The OPeNDAP, over which the package builds, is developed and advanced
openly and collaboratively, by the non-profit [OPeNDAP,
Inc.](https://www.opendap.org/about). By using this data access
protocol, opendapr support the open-source-software movement.

## Installation

<!--
You can install the released version of opendapr from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("opendapr")
```
-->

The package can be installed with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/opendapr")
```

Work is ongoing to publish the package on the CRAN.

## Collections available in opendapr

Currently **opendapr** supports download of 77 data collections,
extracted from the following meta-collections :

  - [MODIS land
    products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/)
    made available by the [NASA / USGS LP
    DAAC](https://lpdaac.usgs.gov/) (➡️ [source OPeNDAP
    server](https://opendap.cr.usgs.gov/opendap/hyrax/)) ;
  - [VIIRS land
    products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/)
    made available by the [NASA / USGS LP
    DAAC](https://lpdaac.usgs.gov/) (➡️ [source OPeNDAP
    server](https://opendap.cr.usgs.gov/opendap/hyrax/)) ;
  - [VIIRS land
    products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/)
    made available by the [NASA LAADS DAAC](https://lpdaac.usgs.gov/)
    (➡️ [source OPeNDAP
    server](https://ladsweb.modaps.eosdis.nasa.gov/opendap/hyrax/allData/5000/))
    ;
  - [Global Precipitation Measurement](https://pmm.nasa.gov/GPM) (GPM)
    made available by the [NASA / JAXA GES
    DISC](https://disc.gsfc.nasa.gov/) (➡️ [source OPeNDAP
    server](https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3)) ;
  - [Soil Moisture Active-Passive](https://smap.jpl.nasa.gov/) (SMAP)
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

GPM\_3IMERGDE.06

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

GPM\_3IMERGDF.06

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

GPM\_3IMERGDL.06

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

GPM\_3IMERGHH.06

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

GPM\_3IMERGHHE.06

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

GPM\_3IMERGHHL.06

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

GPM\_3IMERGM.06

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

SPL3SMP\_E.003

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

<tr>

<td style="text-align:left;">

VNP46A1

</td>

<td style="text-align:left;">

VIIRS/NPP Daily Gridded Day Night Band 500m Linear Lat Lon Grid Night

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Nighttime
lights

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP46A1.001>

</td>

<td style="text-align:left;">

<https://ladsweb.modaps.eosdis.nasa.gov/opendap/hyrax/allData/5000/VNP46A1/contents.html>

</td>

</tr>

</tbody>

</table>

</p>

</details>

## Get Started

Downloading the data with **opendapr** is a simple two-steps workflow :

  - With the function **`odr_get_url()`**, get the URL(s) of the data
    for :
    
      - a collection : see [previous section](#coll-available),
      - variables,
      - region of interest,
      - time range,
      - output data format (netcdf, ascii, json)

  - Next, with the function **`odr_download_data()`** : download the
    data to your computer.

Additional functions include : list collection available for download (
`odr_list_collections()` ), list variables available for each collection
( `odr_list_variables()` ), login to EOSDIS Earthdata before querying
the servers and downloading the data (`odr_login()`).

**Have a look at the
[`vignette("opendapr1")`](https://ptaconet.github.io/opendapr/articles/opendapr1.html)
to get started with a simple example, and for a more advanced workflow
see the
[`vignette("opendapr2")`](https://ptaconet.github.io/opendapr/articles/opendapr2.html)
\!**

<!--

## Example {#example}

Let's say we want to download over the 50 km x 70 km wide region of interest located in Northern Ivory Coast (mapped above):

- a 30 days-long time series of [MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN Grid](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (collection="MOD11A1.006") ;
- the same 30 days-long times series of [GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (collection="GPM_3IMERGDF.06")

<details><summary>Map of the region of interest (click to expand)</summary>
<p>



</p>
</p>
</details>

We prepare the script : load the packages and login to EOSDIS Earthdata with our credentials (to create an account go to : https://urs.earthdata.nasa.gov/) .


```r
# Load the packages
require(opendapr)
require(sf)

# Define ROI and time range of interest
roi <- st_as_sf(data.frame(geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"), wkt="geom", crs = 4326)
time_range <- as.Date(c("2017-01-01","2017-01-30"))

# Login to Earthdata servers with username and password. To create an account go to : https://urs.earthdata.nasa.gov/.
# Here we have stored our credentials in local environment variables
username <- Sys.getenv("earthdata_un") 
password <- Sys.getenv("earthdata_pw")
log <- odr_login(credentials = c(username,password), source = "earthdata")
```

Download the data in two steps : 

1. Get the URLs with the function `odr_get_url()`;
2. Download the data with the function `odr_download_data()`.

Let's also see how much the downloaded files weight.


```r
## Get the URLs for MOD11A1.006
urls_mod11a1 <- odr_get_url(
  collection = "MOD11A1.006",
  roi = roi,
  time_range = time_range
 )

## Get the URLs for GPM_3IMERGDF.06
urls_gpm <- odr_get_url(
  collection = "GPM_3IMERGDF.06",
  roi = roi,
  time_range = time_range
 )

print(str(urls_mod11a1))

print(str(urls_gpm))

## Download the data. Destination file for each dataset is specified in the column "destfile" of the data.frames urls_mod11a1 and urls_gpm
df_to_dl <- rbind(urls_mod11a1,urls_gpm)
res_dl <- odr_download_data(df_to_dl,source="earthdata",parallel = TRUE)

print(str(res_dl))

(tot_weight <- sum(res_dl$fileSize)/1000000)
#`r round(tot_weight,1)` Mb in total !

```


We could also have subset the bands to download, using the parameter `variables` of the function `odr_get_url()`.

To further import the data in R, have a look at the section [Important note regarding the further import of the data in R](#important-note-regarding-the-further-import-of-the-data-in-r) ! 

Simple or advanced data download and import workflows are provided respectively in the vignettes `vignette("opendapr1")` and `vignette("opendapr2")`.

## Important note regarding the further import of the data in R {#important-note-import}

Various packages and related classes can be used to read the data downloaded through OPeNDAP. If `raster` is surely the most famous class for raster objects, many packages facilitate the use of spatiotemporal data cubes in formats such as those proposed through opendapr (e.g. NetCDF). For instance, MODIS or VIIRS products can be imported as a `stars` object from the excellent [`stars`](https://cran.r-project.org/package=stars) package for data cubes manipulation. All the data can also be imported as `ncdf4` objects using e.g. the [`ncdf4`](https://cran.r-project.org/package=ncdf4) package, or `RasterLayer` of the [`raster`](https://cran.r-project.org/package=raster) package.

In any case, care must be taken when importing data that was downloaded through the OPeNDAP data providers servers. Depending on the collection, some "issues" were raised. These issues are independant from opendapr : they result most of time of a kind of lack of full implementation of the OPeNDAP framework by the data providers. These issues are :

- for MODIS and VNP collections : CRS has to be provided
- for GPM collections : CRS has to be provided + data have to be flipped
- for SMAP collections : CRS + bounding coordinates of the data have to be provided

These issues can easily be dealt at the import phase in R. The functions below includes the processings that have to be done at the data import phase in order to open the data as `raster` objects. (argument `destfiles` is the path to a dataset downloaded with opendapr - output of `odr_get_url()$destfile` - and `variable` is the name of a variable to import).


```r
require(raster)
require(purrr)
## Function to import MODIS or VIIRS products as RasterLayer object. 
# In case the ROI covers one single MODIS tile :
.import_modis_onetile <- function(destfiles,variable){
  rasts <- destfiles %>%
    raster::brick(.,varname=variable,crs="+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
  return(rasts)
}
# In case the ROI covers multiple MODIS tiles :
.import_modis_moretiles <- function(destfiles,variable){
  rasts <- destfiles %>%
    purrr::map(~raster::brick(.,varname=variable,crs="+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")) %>%
    do.call(merge,.)
  return(rasts)
}
```


```r
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


```r
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
-->

<!--
## Objectives

opendapr provides an entry point to some specific OPeNDAP servers (e.g. MODIS, VNP, GPM or SMAP) via HTTPS. The development of the package was motivated by the following reasons : 

* **Providing a simple and single way in R to download data stored on heterogeneous servers** : People that use Earth science data often struggle with data access. In opendapr we propose a harmonized way to download data from various providers that have implemented access to their data through OPeNDAP.
* **Fastening the data import phase**, especially for large time series analysis.

Apart from these performance aspects, ethical considerations have driven the development of this package :

* **Facilitating the access to Earth science data for R users in places where internet connection is slow or expensive** : Earth science products are generally huge files that can be quite difficult to download in places with slow internet connection, even more if large time series are needed. By enabling to download strictly the data that is needed, the products become more accessible in those places;
* **Caring about the environmental digital impact of our research work** : Downloading data has an impact on environment and to some extent contributes to climate change. By downloading only the data that is need (rather than e.g a whole MODIS tile, or a global SMAP or GPM dataset) we somehow promote digital sobriety. 
* **Supporting the open-source-software movement** : The OPeNDAP is developed and advanced openly and collaboratively, by the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about) This open, powerfull and standard data access protocol is more and more used, by major Earth science data providers (e.g. NASA or NOAA). Using OPeNDAP means supporting methods for data access protocols that are open, build collaboratively and shared.
-->

<!--
## Citation

We thank in advance people that use opendapr for citing it in their work / publication(s). For this, please use the citation provided at this link [zenodo link to add] or through `citation("opendapr")`.
-->

## Next steps

Next developments may involve :

  - Short term : including more SMAP collections (at now only
    SPL3SMP\_3.003 collection is available)
  - Longer term : including access to more collections and OPeNDAP
    servers

Any contribution is welcome \!

## Acknowledgments

We thank NASA and its partners for making all their Earth science data
freely available, and implementing open data access protocols such as
OPeNDAP. opendapr heavily builds on top of the OPeNDAP, so we thank the
non-profit [OPeNDAP, Inc.](https://www.opendap.org/about) for developing
the eponym tool in an open and collaborative way.

We also thank the contributors that have tested the package, reviewed
the documentation and brought valuable feedbacks to improve the package
: [Florian de Boissieu](https://github.com/floriandeboissieu)

The initial development and first release of this package were financed
by the [MIVEGEC](https://www.mivegec.ird.fr/en/) unit of the [French
Research Institute for Sustainable Development](https://en.ird.fr/), as
part of the [REACT
project](https://burkina-faso.ird.fr/la-recherche/projets-de-recherche2/gestion-de-la-resistance-aux-insecticides-au-burkina-faso-et-en-cote-d-ivoire-recherche-sur-les-strategies-de-lutte-anti-vectorielle-react).
