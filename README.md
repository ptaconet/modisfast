
<!-- README.md is generated from README.Rmd. Please edit that file -->

# modisfast

<!-- <img src="man/figures/logo.png" align="right" /> -->
<!-- badges: start -->

[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![Travis build
status](https://travis-ci.org/ptaconet/modisfast.svg?branch=master)](https://travis-ci.org/ptaconet/modisfast)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/modisfast)](https://cran.r-project.org/package=modisfast)
[![Github_Status_Badge](https://img.shields.io/badge/Github-0.1.0-blue.svg)](https://github.com/ptaconet/modisfast)
<!-- badges: end -->

<!-- ATTENTION A CHANGER : FUSEAUX HORAIRES POUR DONNEES GPM HALF HOURLY !!!!!!
AUSSI : min filesize (le fichier peut etre plus petit que 50 k.. e.g. titi)
renvoyer erreur ou warning si le fichier n'existe pas
-->

<!-- ⚠️ Package still under development ! -->

<!--
R package to access various spatiotemporal Earth science data collections in R using the [OPeNDAP framework](https://www.opendap.org/about). Currently implemented data collections are [MODIS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/), [VIIRS](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/), [GPM](https://pmm.nasa.gov/GPM) and [SMAP](https://smap.jpl.nasa.gov/)). 
Opendap (*Open-source Project for a Network Data Access Protocol*) is a data access protocol that enables to subset the data  - spatially, temporally, etc. - directly at the downloading phase. Filters are provided directly within a http url. For example the following URL : 
https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.006/h17v08.ncml.nc4?MODIS_Grid_Daily_1km_LST_eos_cf_projection,LST_Day_1km[6093:6122][55:140][512:560],LST_Night_1km[6093:6122][55:140][512:560],QC_Day[6093:6122][55:140][512:560],QC_Night[6093:6122][55:140][512:560],time[6093:6122],YDim[55:140],XDim[512:560]
provides the MOD11A1.006 (MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN Grid V006) data in netCDF, subsetted for bands LST_Day_1km, LST_Night_1km, QC_Day, QC_Night, for each day between the 2017-01-01 and the 2017-01-30, and within the following bounding box (lon/lat): -5.41 8.84, -5.82 9.54.
This package enables to build OPeNDAP (https) URLs given input parameters such as a data collection, region and time range of interst . These URLs can then be used to either download the data to your workspace or computer, or access the datacube directly as an R object (of class `ndcf4`, `raster`, `stars`, etc.)
-->

**`modisfast`** is an R package that provides functions to **speed-up**
the **download** of time-series data products derived from
[**MODIS**](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/)
and
[**VIIRS**](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/)
observations, as well as other widely-used satellite-derived
environmental data (e.g. Global Precipitation Measurement Mission).

**`modisfast`** uses the abilities offered by the [OPeNDAP
framework](https://www.opendap.org/about) (*Open-source Project for a
Network Data Access Protocol*) to download a subset of data cube, along
spatial, temporal or any other data dimension (depth, …). This way, it
reduces downloading time and disk usage to their minimum : no more 1° x
1° MODIS tiles when your region of interest is only 100 km x 100 km wide
! Moreover, modisfast supports parallelized downloads.

`modisfast` is hence particularly suited for retrieving MODIS or VIIRS
data **over long time series** and **over areas**, rather than short
time series and points.

Below is a comparison of modisfast with other packages available for
downloading chunks of remote sensing data :

| Package                                                |       Data        | Spatial subsetting\* | Dimensional subsetting\* |
|:-------------------------------------------------------|:-----------------:|:--------------------:|:------------------------:|
| [`modisfast`](https://github.com/ptaconet/modisfast)   | MODIS, VIIRS, GPM |          ✅          |            ✅            |
| [`MODIS`](https://github.com/MatMatt/MODIS)            |       MODIS       |          ❌          |            ❌            |
| [`MODIStsp`](https://github.com/ropensci/MODIStsp)     |       MODIS       |          ❌          |            ✅            |
| [`MODISTools`](https://github.com/ropensci/MODISTools) |       MODIS       |          ✅          |            ✅            |

\* at the downloading phase

## Installation

<!--
You can install the released version of modisfast from [CRAN](https://CRAN.R-project.org) with:
``` r
install.packages("modisfast")
```
-->

The package can be installed with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/modisfast")
```

Work is ongoing to publish the package on the CRAN.

## Get Started

Accessing and opening MODIS data with `modisfast` is a simple workflow,
as shown in the example below.

First, define the variables of interest :

``` r
# Load the packages
library(modisfast)
library(sf)

# MODIS collections and variables (bands) of interest
collection <- "MOD11A1.061"  # run mf_list_collections() for an exhaustive list of collections available
variables <- c("LST_Day_1km","LST_Night_1km","QC_Day","QC_Night") # run mf_list_variables("MOD11A1.061") for an exhaustive list of variables available for the collection "MOD11A1.061"

# ROI and time range of interest
roi <- st_as_sf(data.frame(geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"), wkt="geom", crs = 4326) # a ROI of interest, format sf polygon
roi_id <- "korhogo"  # a name for the area of interest
time_range <- as.Date(c("2017-01-01","2017-01-30"))  # a time range of interest
```

Then, download the data with `modisfast`:

``` r
## Login to Earthdata servers with your EOSDIS credentials. 
# To create an account go to : https://urs.earthdata.nasa.gov/.
log <- mf_login(credentials = c("username","password"))

## Get the URLs of the data 
urls <- mf_get_url(
  collection = collection,
  variables = variables,
  roi = roi,
  roi_id = roi_id,
  time_range = time_range
 )

## Download the data. By default the data is downloaded in a file named 'roi/collection'
res_dl <- mf_download_data(urls)
```

And finally, open the data in R as a `terra::SpatRaster` object :

``` r
r <- mf_import_data(
  dir_path = file.path(roi_id,collection), 
  collection_source = "MODIS"
  )
```

et voilà !

Want more examples of use of `modisfast` ? **Have a look at the
[`vignette("get_started")`](https://ptaconet.github.io/modisfast/articles/get_started.html)
to get started with a simple example, and see the
[`vignette("advanced_use")`](https://ptaconet.github.io/modisfast/articles/advanced_use.html)
for a more advanced workflow !**

<!--
## Example {#example}
Let's say we want to download over the 50 km x 70 km wide region of interest located in Northern Ivory Coast (mapped above):
- a 30 days-long time series of [MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN Grid](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (collection="MOD11A1.006") ;
- the same 30 days-long times series of [GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (collection="GPM_3IMERGDF.06")
<details><summary>Map of the region of interest (click to expand)</summary>
<p>
&#10;</p>
</p>
</details>
We prepare the script : load the packages and login to EOSDIS Earthdata with our credentials (to create an account go to : https://urs.earthdata.nasa.gov/) .
&#10;```r
# Load the packages
require(modisfast)
require(sf)
# Define ROI and time range of interest
roi <- st_as_sf(data.frame(geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"), wkt="geom", crs = 4326)
time_range <- as.Date(c("2017-01-01","2017-01-30"))
# Login to Earthdata servers with username and password. To create an account go to : https://urs.earthdata.nasa.gov/.
# Here we have stored our credentials in local environment variables
username <- Sys.getenv("earthdata_un") 
password <- Sys.getenv("earthdata_pw")
log <- mf_login(credentials = c(username,password), source = "earthdata")
```
Download the data in two steps : 
1. Get the URLs with the function `mf_get_url()`;
2. Download the data with the function `mf_download_data()`.
Let's also see how much the downloaded files weight.
&#10;```r
## Get the URLs for MOD11A1.006
urls_mod11a1 <- mf_get_url(
  collection = "MOD11A1.006",
  roi = roi,
  time_range = time_range
 )
## Get the URLs for GPM_3IMERGDF.06
urls_gpm <- mf_get_url(
  collection = "GPM_3IMERGDF.06",
  roi = roi,
  time_range = time_range
 )
print(str(urls_mod11a1))
print(str(urls_gpm))
## Download the data. Destination file for each dataset is specified in the column "destfile" of the data.frames urls_mod11a1 and urls_gpm
df_to_dl <- rbind(urls_mod11a1,urls_gpm)
res_dl <- mf_download_data(df_to_dl,source="earthdata",parallel = TRUE)
print(str(res_dl))
(tot_weight <- sum(res_dl$fileSize)/1000000)
#`r round(tot_weight,1)` Mb in total !
```
We could also have subset the bands to download, using the parameter `variables` of the function `mf_get_url()`.
To further import the data in R, have a look at the section [Important note regarding the further import of the data in R](#important-note-regarding-the-further-import-of-the-data-in-r) ! 
Simple or advanced data download and import workflows are provided respectively in the vignettes `vignette("opendapr1")` and `vignette("opendapr2")`.
## Important note regarding the further import of the data in R {#important-note-import}
Various packages and related classes can be used to read the data downloaded through OPeNDAP. If `raster` is surely the most famous class for raster objects, many packages facilitate the use of spatiotemporal data cubes in formats such as those proposed through modisfast (e.g. NetCDF). For instance, MODIS or VIIRS products can be imported as a `stars` object from the excellent [`stars`](https://cran.r-project.org/package=stars) package for data cubes manipulation. All the data can also be imported as `ncdf4` objects using e.g. the [`ncdf4`](https://cran.r-project.org/package=ncdf4) package, or `RasterLayer` of the [`raster`](https://cran.r-project.org/package=raster) package.
In any case, care must be taken when importing data that was downloaded through the OPeNDAP data providers servers. Depending on the collection, some "issues" were raised. These issues are independant from modisfast : they result most of time of a kind of lack of full implementation of the OPeNDAP framework by the data providers. These issues are :
- for MODIS and VNP collections : CRS has to be provided
- for GPM collections : CRS has to be provided + data have to be flipped
- for SMAP collections : CRS + bounding coordinates of the data have to be provided
These issues can easily be dealt at the import phase in R. The functions below includes the processings that have to be done at the data import phase in order to open the data as `raster` objects. (argument `destfiles` is the path to a dataset downloaded with modisfast - output of `mf_get_url()$destfile` - and `variable` is the name of a variable to import).
&#10;```r
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
&#10;```r
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
&#10;```r
require(raster)
require(purrr)
require(ncdf4)
## Function to import SMAP products as RasterLayer object
smap_sp_bound <- modisfast::mf_get_opt_param(roi = roi, collection = "SMAP/SPL3SMP_E.003")$roiSpatialBound$`1`
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
modisfast provides an entry point to some specific OPeNDAP servers (e.g. MODIS, VNP, GPM or SMAP) via HTTPS. The development of the package was motivated by the following reasons : 
* **Providing a simple and single way in R to download data stored on heterogeneous servers** : People that use Earth science data often struggle with data access. In modisfast we propose a harmonized way to download data from various providers that have implemented access to their data through OPeNDAP.
* **Fastening the data import phase**, especially for large time series analysis.
Apart from these performance aspects, ethical considerations have driven the development of this package :
* **Facilitating the access to Earth science data for R users in places where internet connection is slow or expensive** : Earth science products are generally huge files that can be quite difficult to download in places with slow internet connection, even more if large time series are needed. By enabling to download strictly the data that is needed, the products become more accessible in those places;
* **Caring about the environmental digital impact of our research work** : Downloading data has an impact on environment and to some extent contributes to climate change. By downloading only the data that is need (rather than e.g a whole MODIS tile, or a global SMAP or GPM dataset) we somehow promote digital sobriety. 
* **Supporting the open-source-software movement** : The OPeNDAP is developed and advanced openly and collaboratively, by the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about) This open, powerfull and standard data access protocol is more and more used, by major Earth science data providers (e.g. NASA or NOAA). Using OPeNDAP means supporting methods for data access protocols that are open, build collaboratively and shared.
-->
<!--
## Citation
We thank in advance people that use `modisfast` for citing it in their work / publication(s). For this, please use the citation provided at this link [zenodo link to add] or through `citation("modisfast")`.
-->

## Collections available in modisfast

Currently `modisfast` supports download of 78 data collections,
extracted from the following meta-collections :

- [MODIS land
  products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/)
  made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/)
  (➡️ [source OPeNDAP
  server](https://opendap.cr.usgs.gov/opendap/hyrax/)) ;
- [VIIRS land
  products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/)
  made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/)
  (➡️ [source OPeNDAP
  server](https://opendap.cr.usgs.gov/opendap/hyrax/))

In addition, `modisfast` supports download of the following
satellite-derived environmental data :

- [Global Precipitation Measurement](https://pmm.nasa.gov/GPM) (GPM)
  made available by the [NASA / JAXA GES
  DISC](https://disc.gsfc.nasa.gov/) (➡️ [source OPeNDAP
  server](https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3)).

Details of each product available for download are provided in the
tables above or through the function `mf_list_collections()`. Want more
details on a specific collection ? Click on the “DOI” column !

<details>
<summary>
<b>MODIS and VIIRS data collections accessible with modisfast (click to
expand)</b>
</summary>
<p>
<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
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
Opendap_server
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
MCD12Q1.061
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
<https://dx.doi.org/10.5067/MODIS/MCD12Q1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD12Q1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD15A2H.061
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
<https://dx.doi.org/10.5067/MODIS/MCD15A2H.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD15A2H.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD15A3H.061
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
<https://dx.doi.org/10.5067/MODIS/MCD15A3H.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD15A3H.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD43A1.061
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
<https://dx.doi.org/10.5067/MODIS/MCD43A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD43A2.061
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
<https://dx.doi.org/10.5067/MODIS/MCD43A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD43A3.061
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
<https://dx.doi.org/10.5067/MODIS/MCD43A3.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A3.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD43A4.061
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
<https://dx.doi.org/10.5067/MODIS/MCD43A4.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD43A4.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MCD64A1.061
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
<https://dx.doi.org/10.5067/MODIS/MCD64A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MCD64A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD09A1.061
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
<https://dx.doi.org/10.5067/MODIS/MOD09A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD09GA.061
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
<https://dx.doi.org/10.5067/MODIS/MOD09GA.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09GA.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD09GQ.061
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
<https://dx.doi.org/10.5067/MODIS/MOD09GQ.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09GQ.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD09Q1.061
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
<https://dx.doi.org/10.5067/MODIS/MOD09Q1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD09Q1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD11A1.061
</td>
<td style="text-align:left;">
MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MOD11A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD11A2.061
</td>
<td style="text-align:left;">
MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MOD11A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD11B2.061
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
<https://dx.doi.org/10.5067/MODIS/MOD11B2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11B2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD11B3.061
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
<https://dx.doi.org/10.5067/MODIS/MOD11B3.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11B3.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD13A1.061
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
<https://dx.doi.org/10.5067/MODIS/MOD13A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD13A2.061
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
<https://dx.doi.org/10.5067/MODIS/MOD13A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD13A3.061
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
<https://dx.doi.org/10.5067/MODIS/MOD13A3.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13A3.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD13Q1.061
</td>
<td style="text-align:left;">
MODIS/Terra Vegetation Indices 16-Day L3 Global 250m SIN Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MOD13Q1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13Q1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD15A2H.061
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
<https://dx.doi.org/10.5067/MODIS/MOD15A2H.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD15A2H.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD16A2.061
</td>
<td style="text-align:left;">
MODIS/Terra Net Evapotranspiration 8-Day L4 Global 500m SIN Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Evapotranspiration
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MOD16A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD16A2GF.061
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
<https://dx.doi.org/10.5067/MODIS/MOD16A2GF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A2GF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD16A3GF.061
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
<https://dx.doi.org/10.5067/MODIS/MOD16A3GF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A3GF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD17A2H.061
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
<https://dx.doi.org/10.5067/MODIS/MOD17A2H.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A2H.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MOD17A2HGF.061
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
<https://dx.doi.org/10.5067/MODIS/MOD17A2HGF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A2HGF.061/contents.html>
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
MOD17A3HGF.061
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
<https://dx.doi.org/10.5067/MODIS/MOD17A3HGF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MOD17A3HGF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MODOCGA.061
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
<https://dx.doi.org/10.5067/MODIS/MODOCGA.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MODOCGA.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MODTBGA.061
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
<https://dx.doi.org/10.5067/MODIS/MODTBGA.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MODTBGA.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD09A1.061
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
<https://dx.doi.org/10.5067/MODIS/MYD09A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD09GA.061
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
<https://dx.doi.org/10.5067/MODIS/MYD09GA.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09GA.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD09GQ.061
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
<https://dx.doi.org/10.5067/MODIS/MYD09GQ.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09GQ.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD09Q1.061
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
<https://dx.doi.org/10.5067/MODIS/MYD09Q1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD09Q1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD11A1.061
</td>
<td style="text-align:left;">
MODIS/Aqua Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MYD11A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD11A2.061
</td>
<td style="text-align:left;">
MODIS/Aqua Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Land surface temperature
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MYD11A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD11B2.061
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
<https://dx.doi.org/10.5067/MODIS/MYD11B2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11B2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD11B3.061
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
<https://dx.doi.org/10.5067/MODIS/MYD11B3.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11B3.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD13A1.061
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
<https://dx.doi.org/10.5067/MODIS/MYD13A1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13A1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD13A2.061
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
<https://dx.doi.org/10.5067/MODIS/MYD13A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD13A3.061
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
<https://dx.doi.org/10.5067/MODIS/MYD13A3.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13A3.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD13Q1.061
</td>
<td style="text-align:left;">
MODIS/Aqua Vegetation Indices 16-Day L3 Global 250m SIN Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Vegetation indices
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MYD13Q1.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13Q1.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD15A2H.061
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
<https://dx.doi.org/10.5067/MODIS/MYD15A2H.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD15A2H.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD16A2.061
</td>
<td style="text-align:left;">
MODIS/Aqua Net Evapotranspiration 8-Day L4 Global 500m SIN Grid v061
</td>
<td style="text-align:left;">
MODIS
</td>
<td style="text-align:left;">
Evapotranspiration
</td>
<td style="text-align:left;">
<https://dx.doi.org/10.5067/MODIS/MYD16A2.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A2.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD16A2GF.061
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
<https://dx.doi.org/10.5067/MODIS/MYD16A2GF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A2GF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD16A3GF.061
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
<https://dx.doi.org/10.5067/MODIS/MYD16A3GF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A3GF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD17A2H.061
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
<https://dx.doi.org/10.5067/MODIS/MYD17A2H.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD17A2H.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD17A2HGF.061
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
<https://dx.doi.org/10.5067/MODIS/MYD17A2HGF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD17A2HGF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYD17A3HGF.061
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
<https://dx.doi.org/10.5067/MODIS/MYD17A3HGF.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYD17A3HGF.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYDOCGA.061
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
<https://dx.doi.org/10.5067/MODIS/MYDOCGA.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYDOCGA.061/contents.html>
</td>
</tr>
<tr>
<td style="text-align:left;">
MYDTBGA.061
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
<https://dx.doi.org/10.5067/MODIS/MYDTBGA.061>
</td>
<td style="text-align:left;">
<https://opendap.cr.usgs.gov/opendap/hyrax/MYDTBGA.061/contents.html>
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
<details>
<summary>
<b>Other (non-MODIS or VIIRS) data collections accessible with modisfast
(click to expand)</b>
</summary>
<p>
<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
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
Opendap_server
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
GPM_3IMERGDE.06
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
GPM_3IMERGDF.06
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
GPM_3IMERGDF.07
</td>
<td style="text-align:left;">
GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree V07
</td>
<td style="text-align:left;">
GPM
</td>
<td style="text-align:left;">
Rainfall
</td>
<td style="text-align:left;">
<https://doi.org/10.5067/GPM/IMERGDF/DAY/07>
</td>
<td style="text-align:left;">
<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.07/>
</td>
</tr>
<tr>
<td style="text-align:left;">
GPM_3IMERGDL.06
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
GPM_3IMERGHH.06
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
GPM_3IMERGHH.07
</td>
<td style="text-align:left;">
GPM IMERG Final Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V07
</td>
<td style="text-align:left;">
GPM
</td>
<td style="text-align:left;">
Rainfall
</td>
<td style="text-align:left;">
<https://doi.org/10.5067/GPM/IMERG/3B-HH/07>
</td>
<td style="text-align:left;">
<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHH.07/>
</td>
</tr>
<tr>
<td style="text-align:left;">
GPM_3IMERGHHE.06
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
GPM_3IMERGHHL.06
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
GPM_3IMERGM.06
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
GPM_3IMERGM.07
</td>
<td style="text-align:left;">
GPM IMERG Final Precipitation L3 1 month 0.1 degree x 0.1 degree V07
</td>
<td style="text-align:left;">
GPM
</td>
<td style="text-align:left;">
Rainfall
</td>
<td style="text-align:left;">
<https://doi.org/10.5067/GPM/IMERG/3B-MONTH/07>
</td>
<td style="text-align:left;">
<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGM.07/>
</td>
</tr>
</tbody>
</table>
</p>
</details>

## Similar packages

`modisfast` is particularly suited for retrieving MODIS or VIIRS data
**over long time series** and **over areas**, rather than short time
series and points.

There are other R packages available for accessing MODIS data, which may
be more suitable if your requirements differ. These include :

- [`MODIS`](https://github.com/MatMatt/MODIS)
- [`MODIStsp`](https://github.com/ropensci/MODIStsp)
- [`MODIStools`](https://github.com/ropensci/MODIStools)
- [`appeears`](https://github.com/bluegreen-labs/appeears)

## Next steps

Next developments may involve including access to more collections from
other OPeNDAP servers.

Any contribution is welcome !

## Acknowledgments

We thank NASA and its partners for making all their Earth science data
freely available, and implementing open data access protocols such as
OPeNDAP. `modisfast` heavily builds on top of the OPeNDAP, so we thank
the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about) for
developing the eponym tool in an open and collaborative way.

We also thank the contributors that have tested the package, reviewed
the documentation and brought valuable feedbacks to improve the package
: [Florian de Boissieu](https://github.com/floriandeboissieu), Julien
Taconet, [Nicolas Moiroux](https://github.com/Nmoiroux)

The initial development and first release of this package were financed
by the [MIVEGEC](https://www.mivegec.ird.fr/en/) unit of the [French
Research Institute for Sustainable Development](https://en.ird.fr/), as
part of the REACT project.

By enabling to download subsets of data cubes, `modisfast` facilites the
access to Earth science data for R users in places where internet
connection is slow or expensive and promotes digital sobriety for our
research work.

The OPeNDAP, over which the package builds, is a project developed by
the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about) and
advanced openly and collaboratively. By using this data access protocol,
`modisfast` support the open-source-software movement.
