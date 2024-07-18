---
title: 'modisfast: An R package for fast and efficient access to MODIS, VIIRS and GPM Earth Observation data'
tags:
  - R
  - MODIS
  - VIIRS
  - GPM
  - Earth observation
  - Datacubes
  - Remote sensing
  - OPeNDAP
authors:
 - name: Paul Taconet
   corresponding: true
   orcid: "0000-0001-7429-7204"
   affiliation: 1
 - name: Nicolas Moiroux
   orcid: "0000-0001-6755-6167"
   affiliation: 1
affiliations:
- name: MIVEGEC, Université de Montpellier, CNRS, IRD, Montpellier, France
  index: 1
date: 18 July 2024
bibliography: paper.bib
---

# Summary

`modisfast` is an R package designed for easy and fast downloads of various Earth Observation (EO) data, including the Moderate Resolution Imaging Spectroradiometer (MODIS) Land products, the Visible Infrared Imaging Radiometer Suite (VIIRS) Land products, and the Global Precipitation Measurement mission (GPM) products. It enables users to subset the data directly during the download phase using spatial, temporal, and dimensional filters and supports parallelized downloads. It also streamlines the process of importing the downloaded data into R. Overall, `modisfast` offers R users a cost-effective, time-efficient, and energy-saving approach to accessing a set of key EO datasets with R.

# Statement of need

Data from Earth Observation satellites are a crucial and increasingly valuable resource for monitoring and understanding our planet, especially in the context of global change. EO data from the U.S. federal government National Aeronautics and Space Administration (NASA) are among the richest and longest-standing in the field. Iconic, widely used and free NASA EO data collections include the MODIS Land products [@JUSTICE20023], the VIIRS products - which continue the legacy of MODIS [@ROMAN2024113963], and the GPM mission products [@SkofronickJackson2017]. Collectively, these products have provided essential data for over 20 years, enabling the study of Earth's dynamics, including global land cover, vegetation health, burned areas, land surface temperature, rainfall patterns. They support research in climate change, disaster response, biodiversity, ecosystem monitoring, ecology, public health, and more [@modis-applications].

Despite the increasing availability and utility of these EO data, accessing and using them presents several challenges. Researchers often encounter issues such as multiple data sources, data complexity, or large file sizes [@AGNOLI2023122357]. These data are typically distributed as multidimensional layers over extensive areas, making accessibility and processing difficult, especially when large time series are required. This problem is particularly acute in developing regions where internet infrastructure, needed to access the data, can be limited. The complexity of accessing EO data can result in obstacles such as underutilization or the creation of siloed data processing workflows, which separate data extraction from pre-processing and analysis, thereby hindering transparent and reproducible open science practices. While some powerful tools, such as [Google Earth Engine](https://earthengine.google.com/) [@GORELICK201718] offer some solutions to these problems, they also have important limitations, such as proprietary and energy-intensive software. Altogether, these barriers hinder the full potential of Earth observation data to support global research and decision-making. Efforts to simplify and streamline access to these data, while maintaining an open-source and open-science framework, are essential to overcoming these obstacles and maximizing the benefits of satellite data for all.

Here, we introduce `modisfast`, an open-source R package [@R] designed to simplify, streamline, and accelerate the download and import of MODIS, VIIRS, and GPM time series for R users. This package expands and the existing ecosystem of R tools for accessing MODIS data, enhancing it by introducing new features and data sources (see section \autoref(comp-other-soft)). `modisfast` allows users to subset these datasets using spatial, temporal, and band/layer directly at the downloading phase, optimizing data download and processing. Additionally, downloads can be parallelized for increased efficiency. `modisfast` thus facilitates access to EO data for R users, particularly in regions with limited internet infrastructure, and enables embedding data extraction within complex and holistic data workflows in R - fostering transparency and reproducibility in the context of Open Science. Importantly, the foundational framework of `modisfast` (see section \autoref(foundational-fmwrk)) guarantees the package's long-term sustainability, open-source nature, and cost-free availability.

# Target audience

`modisfast` is suitable to any R user looking to use MODIS, VIIRS or GPM Earth Observation data, either for research, education, or operational purposes.

`modisfast` is particularly suited for the following cases : 

- Retrieving MODIS, VIIRS or GPM data quickly over **long time series** and **areas** (as opposed to **short time series** and **specific points**).
- Users who want to integrate the data extraction process within complex data workflows in R (e.g., extraction, transformation, visualization, modeling, communication).
- Users in regions with limited internet infrastructure.
- Users who wish to promote international standards for data formats and access, and Open Science in general.
- Users who are concerned about digital sobriety.

# Main features

## Typical workflow

 The typical workflow to access and import MODIS, VIIRS or GPM data in R with `modisfast` involves the following steps :

1.  Defining the parameters of interest as natural R objects,
2.  Login to NASA EOSDIS EarthData, with the function `mf_login()`,
3.  Building the URL(s) of the dataset(s) of interest, with the function `mf_get_url()`,
4.  Downloading the dataset(s), with the function `mf_download_data()` (the preferred and default output format is the widely used [NetCDF format](https://www.unidata.ucar.edu/software/netcdf/), although other formats can be defined),
5.  Importing the dataset(s) in R as a `SpatRast` object of the `terra` library [@terra], with the function `mf_import_data()`.

This workflow is graphically summarized in figure \autoref{fig:wf_modisfast} along with a toy example.

![Workflow for MODIS, VIIRS or GPM data download and import with `modisfast`.\label{fig:wf_modisfast}](workflow_modisfast.png){width="90%"}

Other functions available in the package include :

-   `mf_list_collections()` to list all the EO data collections available through `modisfast`,
-   `mf_list_variables()` to list the available layers for a given collection.

## Special features

To further simplify and fasten data download and import in R, `modisfast` offers several interesting features :

-   Ability to download data for multiple regions of interest simultaneously (see [dedicated vignette](https://ptaconet.github.io/modisfast/articles/modisfast2.html));
-   Ability to download data for multiple time periods of interest simultaneously (see [dedicated vignette](https://ptaconet.github.io/modisfast/articles/modisfast2.html)) ;
-   Ability to import the downloaded data as a [*Virtual Raster Dataset* (VRT)](https://search.r-project.org/CRAN/refmans/terra/html/vrt.html) (useful for high-volume data, e.g. country or continental scale data at high spatial resolution) (see documentation of the function `mf_import_data()`).

## Available data collections

Currently `modisfast` supports download of 87 data collections, extracted from the following three meta-collections :

-   [MODIS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) (source server : <https://opendap.cr.usgs.gov/opendap/hyrax/>) ;
-   [VIIRS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) (source server : <https://opendap.cr.usgs.gov/opendap/hyrax/>)
-   [Global Precipitation Measurement](https://gpm.nasa.gov/missions/GPM) (GPM) made available by the [NASA / JAXA GES DISC](https://disc.gsfc.nasa.gov/) (source server : <https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/>).

The full list of available data collections can be accessed with the function `mf_list_collections()`.

## Foundational framework of `modisfast` {#foundational-fmwrk}

Technically, `modisfast` is a programmatic interface to several NASA OPeNDAP (https://www.opendap.org/) servers. OPeNDAP is the acronym for "Open-source Project for a Network Data Access Protocol" and designates both the software, the access protocol, and the corporation that develops them. The OPeNDAP is designed to simplify access to structured and high-volume data, such as satellite products, over the Web. It is a collaborative effort involving multiple institutions and companies, with open-source code, free software, and adherence to the [Open Geospatial Consortium](https://www.ogc.org/) (OGC) standards. It is widely used by NASA, which partly finances it. 

A key feature of OPeNDAP is its capability to apply filters at the data download process, ensuring that only the necessary data is retrieved. These filters, specified within a URL, can be spatial, temporal, or dimensional. Although powerful, OPeNDAP URLs are not trivial to build. The main objective of `modisfast` is to construct these URLs based on the filters that are specified by the user through standard R objects.

Importantly, the robust, sustainable, and cost-free foundational framework of `modisfast`, both for the data provider (NASA) and the software (R, OPeNDAP, the `tidyverse`  and `GDAL` suite of packages [@tidyverse; @gdal]), guarantees the long-term stability and reliability of the package.

# Comparison with similar packages {#comp-other-soft}

Besides `modisfast`, there are several open-source R packages available for accessing MODIS or VIIRS data :

The [`MODIS`](https://github.com/fdetsch/MODIS) package offers access to some MODIS data through global online data archives, but it lacks comprehensive documentation and was removed from the CRAN repository in 2023 for policy violations. Furthermore, some of its dependencies are not available anymore on CRAN.

The [`MODIStsp`](https://github.com/ropensci/MODIStsp) package [@MODIStsp] provides both a command-line and a user-friendly graphical interface to extract MODIS data in standard TIFF or original HDF formats. However, it does not allow to extract data at a sub-tile level (i.e. spatial subsetting capabilities are limited), and it was also removed from the CRAN repository in 2023 at the maintainer's request.

The [`MODIStools`](https://github.com/ropensci/MODISTools) package [@modistools] serves as a programmatic interface to the ['MODIS Land Products Subsets' web service](https://modis.ornl.gov/data/modis_webservice.html), providing access to 46 MODIS and VIIRS collections. This package, available on CRAN, extracts data at specific points or buffer zones around coordinates, outputting a R `data.frame` or a file in .csv format, which is not a standard geospatial format. This makes it suitable for point-based data extraction but less effective for area-based queries.

The [`appeears`](https://github.com/bluegreen-labs/appeears) package [@appeears] acts as a programmatic interface to the [NASA AppEEARS API](https://appeears.earthdatacloud.nasa.gov/) services. AppEEARS is a NASA-built application that offers a simple and efficient way to access and transform geospatial data from a variety of federal data archives (including MODIS and VIIRS, but not GPM). AppEEARS allows accessing data from various NASA federal archives, including MODIS and VIIRS, and enables users to subset geospatial datasets using spatial, temporal, and band/layer parameters. Indeed, as for `modisfast`, AppEEARS uses OPeNDAP. While similar to `modisfast`, `appeears` offers a broader range of data sources but has a latency period (ranging from minutes to hours) for query processing due to server-side post-processing (mosaicking, reprojection, etc.).

Finally, some R packages, such as [`rgee`](https://github.com/r-spatial/rgee) [@rgee], rely on proprietary software or data access protocols and are not discussed here for that reason.

# Installation

The released version of `modisfast` can be installed from [CRAN](https://CRAN.R-project.org) in R with :

``` r
install.packages("modisfast")
```

or the development version (to get a bug fix or to use a feature from the development version) with :

``` r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("ptaconet/modisfast")
```

# Example {#example}

This example shows how to download a one-year-long monthly time series of MODIS Normalized Difference Vegetation Index (NDVI) at 1 km spatial resolution over the whole country of Madagascar.

1/ First, load the packages and define the parameters of interest (region, time frame, data collection, and variables for the collection) :

``` r
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

2/ Then, download the data by executing sequentially the functions `mf_login()`, `mf_get_url()`, and `mf_download_data()` :

``` r
## Login to Earthdata servers with your EOSDIS credentials. 
# To create an account (free) go to : https://urs.earthdata.nasa.gov/.
log <- mf_login(credentials = c("earthdata_username","earthdata_password"))  # set your own EOSDIS username and password

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

3/ And finally, import the data in R as a `terra::SpatRaster` object using the function `mf_import_data()` :

``` r
r <- mf_import_data(
  path = dirname(res_dl$destfile[1]),
  collection = coll, 
  proj_epsg = 4326
  )
```

You may now go ahead with any useful analysis, e.g. plot the data with (see \autoref{fig:example} for the output) :

``` r
plot(r, col = rev(terrain.colors(20)))
```

![Time series of monthly MODIS NDVI over Madagascar for the year 2023, retrieved with `modisfast`.\label{fig:example}](plot_mada_ndvi.png)

`modisfast` provides three long-form documentations and examples to learn more about the package :

-   a [Get started](https://ptaconet.github.io/modisfast/articles/get_started.html) vignette describing the core features of the package;
-   a [Get data on several regions or periods of interest simultaneously](https://ptaconet.github.io/modisfast/articles/modisfast2.html) vignette detailing advanced functionalities of `modisfast` (for multi-time frame or multi-regions data access);
-   a [Full use case](https://ptaconet.github.io/modisfast/articles/use_case.html) vignette showcasing an example of use of the package in a scientific context (here: landscape epidemiology).

# Future work

Future development of the package may include access to additional data collections from other OPeNDAP servers, and support for a variety of data formats as they become available from data providers through their OPeNDAP servers. The addition of a meta-function that facilitates executing the entire process at once (login, URL building, data download, and data import into R) is also envisaged. Furthermore, the creation of an RShiny application [@shiny] on top of the package is being considered, as a means of further simplifying data access for users with limited coding skills.

# Acknowledgements

We thank NASA and its partners for making all their Earth science data freely available, and financing and implementing open data access protocols such as OPeNDAP. `modisfast` heavily builds on top of the OPeNDAP, so we thank the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) for developing the eponym tool in an open and collaborative way.

We also thank the contributors that have tested the package, reviewed the documentation and brought valuable feedbacks to improve the package : Florian de Boissieu, Julien Taconet, Annelise Tran, Alexandre Cebeillac.

This work has been developed over the course of several research projects conducted by the French National Research Institute for Sustainable Development (IRD) and its partners :

-   the REACT 1 and REACT 2 projects funded by the *l'Initiative - Expertise France*.
-   the ANORHYTHM project (ANR-16-CE35-008) funded by the French National Research Agency (ANR).
-   the DIV-YOO project (ANR-23-CE35-0005) funded by the French National Research Agency (ANR).

# References
