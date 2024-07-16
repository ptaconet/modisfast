---
title: 'modisfast: An R package for fast and efficient access to MODIS, VIIRS and
  GPM Earth Observation data'
tags:
- R
- MODIS
- VIIRS
- GPM
- Earth observation datacubes
- OPeNDAP
date: "1 August 2024"
output:
  html_document: default
  pdf_document: default
authors:
- name: Paul Taconet
  orcid: "0000-0001-7429-7204"
  affiliation: 1
- name: Nicolas Moiroux
  orcid: "0000-0001-6755-6167"
  affiliation: 1
bibliography: paper.bib
affiliations:
- name: MIVEGEC, Université de Montpellier, CNRS, IRD, Montpellier, France
  index: 1
---

<!-- voir exemple : https://raw.githubusercontent.com/FRBCesab/chessboard/main/joss-paper/paper.md -->

# Summary

`modisfast` is an R package that allows for easy and fast downloads of various Earth Observation (EO) data, including Moderate Resolution Imaging Spectroradiometer (MODIS) Land products, Visible Infrared Imaging Radiometer Suite (VIIRS) Land products, and Global Precipitation Measurement mission (GPM) products. Based on the Open-source Project for a Network Data Access Protocol (OPeNDAP) standard framework, it enables users to apply filters (spatial, temporal, and dimensional) directly at the downloading phase, supports parallelized downloads, and streamlines data import into R. Therefore, `modisfast` offers R users a cost-effective, time-efficient, and energy-saving approach to accessing a set of EO datasets.

# Statement of need

<!-- Does the paper have a section titled ‘Statement of need’ that clearly states what problems the software is designed to solve, who the target audience is, and its relation to other work? -->

<!-- 1/what are MODIS data useful for,  2/ the problem of the accessibility  (overall, and for R users in particular),  3/ ethical considerations-->

Data from Earth Observation satellites are a crucial and increasingly valuable resource for monitoring and understanding our planet, especially in the context of global change. EO data from the U.S. federal government National Aeronautics and Space Administration (NASA) are among the richest and longest-standing in the field. Iconic and widely used NASA EO data collections include the MODIS Land products [@JUSTICE20023], the VIIRS products - which continue the legacy of MODIS [@ROMAN2024113963], and the GPM mission products [@SkofronickJackson2017] (in collaboration with the Japan Aerospace Exploration Agency (JAXA)). Collectively, these products have provided essential data for over 20 years, enabling the study of Earth's dynamics, including (but not limited to) global land cover, vegetation health, land surface temperature, rainfall patterns, burned areas. They support research in climate change, disaster response, biodiversity, ecosystem monitoring, ecology, epidemiology, and more.

Despite the increasing availability and utility of EO data, accessing them presents several challenges. Researchers often encounter issues such as multiple data sources, data complexity, large file sizes, and the need for advanced technical skills to process the information. These data are typically distributed as multidimensional layers over extensive areas, making accessibility and processing difficult, especially when large time series are required. This problem is particularly acute in developing regions where internet infrastructure can be limited. The complexity of accessing EO data often leads to siloed data processing workflows, separating data extraction from pre-processing and analysis, thereby hindering transparent and reproducible open science practices. While tools like Google Earth Engine offer some solutions, they also have limitations, such as requiring the use of new programming languages and proprietary software. Altogether, these barriers hinder the full potential of Earth observation data to support global research and decision-making. Efforts to simplify and streamline access to this data, while maintaining an open-source and open-science framework, are essential to overcoming these obstacles and maximizing the benefits of satellite data for all.

Here, we introduce `modisfast`, an open-source R package [@R] designed to simplify, streamline, and accelerate the download and import of MODIS, VIIRS, and GPM time series for R users. `modisfast` allows users to download and import only the specific chunks of satellite data needed, filtered spatially, temporally, and dimensionally, optimizing data download and processing. Additionally, downloads can be parallelized for increased efficiency. `modisfast` thus facilitates access to EO data for R users (especially in regions with limited internet infrastructure), promotes digital sobriety, supports the open-source software movement, and enables embedding data extraction within complex and holistic data workflows in R, fostering transparency and reproducibility in the context of Open Science. Importantly, the foundational framework of `modisfast` (see section \ref(foundational-fmwrk)) ensures the long-term sustainability and cost-free nature of the package. This package enhances the existing ecosystem of R tools for accessing MODIS data by introducing new features (see section \ref(comp-other-soft).

# Main features

## Typical workflow

The typical workflow to access and import MODIS, VIIRS or GPM data in R with `modisfast` involves the following steps :

1.  Defining the parameters of interest as natural R objects,
2.  Login to NASA EOSDIS EarthData with the function `mf_login()`,
3.  Building the URL(s) of the dataset(s) of interest with the function `mf_get_url()`,
4.  Downloading the dataset(s) with the function `mf_download_data()` (the preferred and default output format is the widely used [NetCDF format](https://www.unidata.ucar.edu/software/netcdf/), although other formats can be defined),
5.  Importing the dataset(s) in R as a SpatRast object of `terra` library [@terra] with the function `mf_import_data()`.

This workflow is graphically summarized in figure \autoref{fig:wf_modisfast}.

![Workflow for data download and import with `modisfast`.\label{fig:wf_modisfast}](workflow_modisfast.png){width="70%"}

Other functions available in the package include :

-   `mf_list_collections()` to list all the EO data collections available through `modisfast`,
-   `mf_list_variables()` to list the available layers for a given collection.

## Special features

To further simplify and fasten data download and import in R, `modisfast` offers several interesting features :

-   Ability to download data for multiple regions of interest simultaneously (see [dedicated vignette](https://ptaconet.github.io/modisfast/articles/modisfast2.html));
-   Ability to download data for multiple time periods of interest simultaneously (see [dedicated vignette](https://ptaconet.github.io/modisfast/articles/modisfast2.html)) ;
-   Ability to import the downloaded data as a [*Virtual Raster Dataset* (VRT)](https://search.r-project.org/CRAN/refmans/terra/html/vrt.html) (useful for high-volume data, e.g. country or continental scale data at high spatial resolution) (see documentation of function `mf_import_data()`).

## Available data collections

Currently `modisfast` supports download of 87 data collections, extracted from the following three meta-collections :

-   [MODIS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) (source server : <https://opendap.cr.usgs.gov/opendap/hyrax/>) ;
-   [VIIRS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) (source server : <https://opendap.cr.usgs.gov/opendap/hyrax/>)
-   [Global Precipitation Measurement](https://gpm.nasa.gov/missions/GPM) (GPM) made available by the [NASA / JAXA GES DISC](https://disc.gsfc.nasa.gov/) (source server : <https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/>).

The full list of available data collections can be accessed with the function `mf_list_collections()`.

## Foundational framework of `modisfast` {#foundational-fmwrk}

Technically, `modisfast` is a programmatic interface to several NASA OPeNDAP servers (<https://www.opendap.org/>). OPeNDAP is the acronym for "Open-source Project for a Network Data Access Protocol" and designates both the software, the access protocol, and the corporation that develops them. The OPeNDAP is designed to simplify access to structured and high-volume data, such as satellite products, over the Web. It is a collaborative effort involving multiple institutions and companies, with open-source code, free software, and adherence to OGC standards. It is widely used by NASA, which partly finances the project. A key feature of OPeNDAP is its capability to apply filters at the data download process, ensuring that only the necessary data is retrieved. These filters, specified within a URL, can be spatial, temporal, or dimensional. Nevertheless, OPeNDAP URLs are not trivial to build. `modisfast` constructs these URLs based on the filters that are specified by the user through standard R objects.

A key feature of `modisfast` is that it builds on top of robust, sustainable, and cost-free foundations for both the data provider (NASA) and the software (R, OPeNDAP, the `tidyverse` [@tidyverse] and `GDAL` [@gdal] suite of packages). This stability guarantees the long-term reliability of the package.

# Comparison with similar packages {#comp-other-soft}

There are other R packages available for accessing MODIS data, which may be more suitable if your requirements differ. These include :

-   [`MODIS`](https://github.com/fdetsch/MODIS)
-   [`MODIStsp`](https://github.com/ropensci/MODIStsp)
-   [`MODIStools`](https://github.com/ropensci/MODIStools)
-   [`appeears`](https://github.com/bluegreen-labs/appeears)

`modisfast` is particularly suited for retrieving MODIS, VIIRS OR GPM data **over long time series** and **over areas**, rather than short time series and points.

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

Downloading and importing EO data in R with `modisfast` is a simple workflow, as shown in the example below.

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

Future development of the package may include access to additional data collections from other OPeNDAP servers, and support for a variety of data formats as they become available from data providers through their OPeNDAP servers. Furthermore, the creation of an RShiny application [@shiny] on top of the package is being considered, as a means of further simplifying data access for users with limited coding skills.

# Acknowledgements

We thank NASA and its partners for making all their Earth science data freely available, and implementing open data access protocols such as OPeNDAP. `modisfast` heavily builds on top of the OPeNDAP, so we thank the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) for developing the eponym tool in an open and collaborative way.

We also thank the contributors that have tested the package, reviewed the documentation and brought valuable feedbacks to improve the package : Florian de Boissieu, Julien Taconet, Annelise Tran.

This work has been developed over the course of several research projects :

-   the REACT 1 project with funding from the French National Research Institute for Sustainable Development (IRD),
-   the REACT 2 project funded by the *l'Initiative - Expertise France*,
-   the ANORHYTHM project (ANR-16-CE35-008) funded by the French National Research Agency (ANR),
-   the DIV-YOO project (ANR-23-CE35-0005) funded by the French National Research Agency (ANR).

# References
