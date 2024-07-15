---
title: 'modisfast: An R package for fast and efficient access to MODIS, VIIRS and GPM Earth Observation data'
tags:
  - R
  - MODIS
  - VIIRS
  - GPM
  - Earth observation datacubes
  - OPeNDAP
authors:
  - name: Paul Taconet
    orcid: 0000-0001-7429-7204
    affiliation: 1 
  - name: Nicolas Moiroux
    orcid: 0000-0001-6755-6167
    affiliation: 1
affiliations:
 - name: MIVEGEC, Université de Montpellier, CNRS, IRD, Montpellier, France
   index: 1
date: 1 August 2024
bibliography: paper.bib
---

<!-- voir exemple : https://raw.githubusercontent.com/FRBCesab/chessboard/main/joss-paper/paper.md -->

# Summary

`modisfast` is an R package that allows for easy and fast downloads of various Earth Observation (EO) data, including Moderate Resolution Imaging Spectroradiometer (MODIS) Land products, Visible Infrared Imaging Radiometer Suite (VIIRS) Land products, and Global Precipitation Measurement mission (GPM) products. Based on the Open-source Project for a Network Data Access Protocol (OPeNDAP) standard framework, it enables users to apply filters (spatial, temporal, and dimensional) directly at the downloading phase, supports parallelized downloads, and streamlines data import into R. Therefore, `modisfast` offers R users a cost-effective, time-efficient, and energy-saving approach to accessing a set of EO datasets.

# Statement of need

<!-- Does the paper have a section titled ‘Statement of need’ that clearly states what problems the software is designed to solve, who the target audience is, and its relation to other work? -->
<!-- 1/what are MODIS data useful for,  2/ the problem of the accessibility  (overall, and for R users in particular),  3/ ethical considerations-->

Data from Earth Observation satellites are a crucial and increasingly valuable resource for monitoring and understanding our planet, especially in the context of global change. EO data from the U.S. federal government National Aeronautics and Space Administration (NASA) are among the richest and longest-standing in the field. Iconic and widely used NASA EO data collections include the MODIS Land products [@JUSTICE20023], the VIIRS products - which continue the legacy of MODIS [@ROMAN2024113963], and the GPM mission products [@SkofronickJackson2017] (in collaboration with the Japan Aerospace Exploration Agency (JAXA)). Collectively, these products have provided essential data for over 20 years, enabling the study of Earth's dynamics, including global land cover, vegetation health, land surface temperature, rainfall patterns, burned areas. They support research in climate change, disaster response, biodiversity, ecosystem monitoring, ecology, epidemiology, and more.

Despite the growing availability and usefulness of such EO data, accessing them presents several challenges. Many users face hurdles such as data complexity, large file sizes, and the need for advanced technical skills to process and interpret the information. Additionally, data accessibility can be limited by inadequate internet infrastructure, especially in developing regions, and if large time series are needed. These barriers hinder the full potential of Earth observation data to support global research and decision-making. Efforts to simplify access and provide user-friendly tools are essential to overcoming these obstacles and maximizing the benefits of satellite data for all.

Here, we introduce `modisfast`, an open-source R package [@R] aimed at simplifying, lightening, and fastening the download and import of MODIS, VIIRS and GPM data for R users. Concretely, given some user-defined parameters of interest (spatial area, temporal range, data collection, and variables (also called 'bands' or 'layers') for the specified collection), the `modisfast` package allows to download only and strictly the data that is required. In the event of multiple files, the data download can be conducted in parallel. The preferred and default output format is the widely used [NetCDF format](https://www.unidata.ucar.edu/software/netcdf/), although other formats can be defined. Subsequently, a function facilitates the import of the downloaded data into R as a `terra::SpatRaster` object [@terra] and its eventual preprocessing (mosaicking, reprojecting, masking).

Technically, `modisfast` is a programmatic interface to several NASA 'OPeNDAP' servers (<https://www.opendap.org/>). OPeNDAP, short for "Open-source Project for a Network Data Access Protocol," is a data access protocol designed to simplify access to structured data, such as satellite products, over the Web. The OPeNDAP is a collaborative effort involving multiple institutions and companies, with open-source code, free software, and adherence to OGC standards. It is widely used and partly financed by NASA. A key feature of OPeNDAP is its capability to apply filters at the data download process, ensuring that only the necessary data is retrieved. These filters, specified within a URL, can be spatial, temporal, or dimensional. OPeNDAP URLs are not trivial to build. `modisfast` constructs these URLs based on the filters that are specified by the user through standard R objects.

The development of `modisfast` was motivated by the following reasons : 



`modisfast` builds on top of robust, sustainable, and cost-free foundations for both the data provider (NASA) and the software (R, OPeNDAP, the `tidyverse` [@tidyverse] and GDAL [@gdal] suite of packages). This stability guarantees the long-term reliability of the package.

Several already existing R packages aim at accessing MODIS data, but they all have limits (see section Comparison with other similar packages)


`modisfast` can be used in complex and holistic data workflows, supporting transparency and reproducibility in the context of Open Science.

<!--
## Objectives
modisfast provides an entry point to some specific OPeNDAP servers (e.g. MODIS, VNP, GPM or SMAP) via HTTPS. The development of the package was motivated by the following reasons : 
* **Providing a simple and single way in R to download data stored on heterogeneous servers** : People that use Earth science data often struggle with data access. In modisfast we propose a harmonized way to download data from various providers that have implemented access to their data through OPeNDAP.
* **Fastening the data import phase**, especially for large time series analysis.
Apart from these performance aspects, ethical considerations have driven the development of this package :
* **Facilitating the access to Earth science data for R users in places where internet connection is slow or expensive** : Earth science products are generally huge files that can be quite difficult to download in places with slow or expensive internet connection, even more if large time series are needed. By enabling to download strictly the data that is needed, the products become more accessible in those places;
* **Caring about the environmental digital impact of our research work** : Downloading data has an impact on environment and to some extent contributes to global change. By downloading only the data that is need (rather than e.g a whole MODIS tile, or a global GPM dataset) we promote digital sobriety. 
* **Supporting the open-source-software movement** : The OPeNDAP is developed and advanced openly and collaboratively, by the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) This open, powerfull and standard data access protocol is more and more used, by major Earth science data providers (e.g. NASA or NOAA). Using OPeNDAP means supporting methods for data access protocols that are open, build collaboratively and shared.
-->

Currently `modisfast` supports download of 87 data collections, extracted from the following three meta-collections : 

* [MODIS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) (source OPeNDAP server : <https://opendap.cr.usgs.gov/opendap/hyrax/>) ;
* [VIIRS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) (source OPeNDAP server : <https://opendap.cr.usgs.gov/opendap/hyrax/>)
* [Global Precipitation Measurement](https://gpm.nasa.gov/missions/GPM) (GPM) made available by the [NASA / JAXA GES DISC](https://disc.gsfc.nasa.gov/) (source OPeNDAP server : <https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/>).

The full list of available data collections can be accessed with `mf_list_collections()`.

Future development of the package may involve including access to more data collections from other OPeNDAP servers. Furthermore, the creation of an RShiny application [@shiny] on top of the package is being considered as a means of further simplifying data access for users with limited coding skills.

# Installation 

The released version of `modisfast` can be installed from [CRAN](https://CRAN.R-project.org) with :

``` r
install.packages("modisfast")
```

or the development version (to get a bug fix or to use a feature from the development version) with : 

``` r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("ptaconet/modisfast")
```

# Example

Accessing and importing MODIS data in R with `modisfast` is a simple workflow, as shown in the example below.

1/ First, define the parameters of interest for you data query (Region Of Interest (ROI), time frame, data collection, and bands for the collection) :

```r
# Load the necessary packages
library(modisfast)
library(sf)
library(terra)

## ROI (format sf type POLYGON, with an 'id' column). Here, we provide the bounding box of Madagascar
roi_mada <- st_as_sf(data.frame(id = "madagascar", geom = "POLYGON((41.95 -11.37,51.26 -11.37,51.26 -26.17,41.95 -26.17,41.95 -11.37))"), wkt="geom", crs = 4326) 

## Time range (two dates, i.e. the first and the last)
t_range <- as.Date(c("2023-01-01","2023-12-31"))

## Collection. 
# run mf_list_collections() to get an exhaustive list of collections available
coll <- "MOD13A3.061" # Here we choose MODIS/Terra Vegetation Indices Monthly 1 km

# Variables for the collection 
## run mf_list_variables("MOD13A3.061") to get an exhaustive list of variables available for the collection "MOD13A3.061"
bands <- c("_1_km_monthly_NDVI")
```

2/ Then, download the data executing sequentially the functions `mf_login()`, `mf_get_url()`, and `mf_download_data()` :

```r
## Login to Earthdata servers with your EOSDIS credentials. 
# To create an account (free) go to : https://urs.earthdata.nasa.gov/.
log <- mf_login(credentials = c("username","password"))  # set your own EOSDIS username and password

## Get the URLs of the data 
urls <- mf_get_url(
  collection = coll,
  variables = bands,
  roi = roi_mada,
  time_range = t_range
 )

## Download the data. By default the data is downloaded in a temporary directory, but you can specify a folder
res_dl <- mf_download_data(urls, parallel = T)
```

3/ And finally, open the data in R as a `terra::SpatRaster` object using the function `mf_import_data()` :

```r
r <- mf_import_data(
  path = dirname(res_dl$destfile[1]),
  collection = coll, 
  proj_epsg = 4326
  )
```

You may now go ahead with any useful analysis, e.g. plot the data with : 

```r
plot(r, col = rev(terrain.colors(20)))
```
![Time series of monthly NDVI over Madagascar for the year 2023.\label{fig:example}](plot_mada_ndvi.png)

# Comparison with other similar packages

`modisfast` is particularly suited for retrieving MODIS, VIIRS OR GPM data **over long time series** and **over areas**, rather than short time series and points.

There are other R packages available for accessing MODIS data, which may be more suitable if your requirements differ. These include : 

* [`MODIS`](https://github.com/fdetsch/MODIS)
* [`MODIStsp`](https://github.com/ropensci/MODIStsp)
* [`MODIStools`](https://github.com/ropensci/MODIStools)
* [`appeears`](https://github.com/bluegreen-labs/appeears)

# Ongoing research projects using the software

# Acknowledgements

We thank NASA and its partners for making all their Earth science data freely available, and implementing open data access protocols such as OPeNDAP. `modisfast` heavily builds on top of the OPeNDAP, so we thank the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) for developing the eponym tool in an open and collaborative way.

We also thank the contributors that have tested the package, reviewed the documentation and brought valuable feedbacks to improve the package : [Florian de Boissieu](https://github.com/floriandeboissieu), Julien Taconet, Annelise Tran.

This work has been developed over the course of several research projects : 
- the REACT 1 project with funding from the French National Research Institute for Sustainable Development (IRD) through an international volunteer fellowship
- the REACT 2 project funded by the *l'Initiative - Expertise France*
- the ANORHYTHM project (ANR-16-CE35-008) funded by the French National Research Agency (ANR)
- the DIV-YOO project (ANR-23-CE35-0005) funded by the French National Research Agency (ANR)

# References
