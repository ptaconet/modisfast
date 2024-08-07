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
date: 07 August 2024
bibliography: paper.bib
---

# Summary

`modisfast` is an R package designed for easy and fast downloads of various Earth Observation (EO) data, including the Moderate Resolution Imaging Spectroradiometer (MODIS) Land products, the Visible Infrared Imaging Radiometer Suite (VIIRS) Land products, and the Global Precipitation Measurement mission (GPM) products. It enables users to subset the data directly at the download phase using spatial, temporal, and dimensional filters and supports parallelized downloads. It also streamlines the process of importing the downloaded data into R. Overall, `modisfast` offers R users a cost-effective, time-efficient, and energy-saving approach to accessing a set of key EO datasets with R.

# Statement of need

Data from Earth Observation satellites are a crucial and increasingly valuable resource for monitoring and understanding our planet, especially in the context of global change. EO data from the U.S. federal government National Aeronautics and Space Administration (NASA) are among the richest and longest-standing in the field. Iconic and widely NASA EO data collections include the MODIS Land products [@JUSTICE20023], the VIIRS products - which continue the legacy of MODIS [@ROMAN2024113963], and the GPM mission products [@SkofronickJackson2017]. Collectively, these products have provided essential data for over 20 years, enabling the study of Earth's dynamics, including global land cover, vegetation health, burned areas, land surface temperature, rainfall patterns. They support research in climate change, disaster response, biodiversity, ecosystem monitoring, ecology, public health, and more [@modis-applications].

Despite the increasing availability and utility of these EO data, accessing and using them presents several challenges [@AGNOLI2023122357]. These data are typically distributed as multidimensional layers over vast areas. This results in large file sizes, making accessibility and processing difficult, especially when large time series are needed. This problem is particularly acute in developing regions where internet infrastructure, needed to access the data, can be limited. The complexity of accessing EO data can result in obstacles, such as underutilization or the creation of siloed data processing workflows, which separate data extraction from pre-processing and analysis, thereby hindering transparent and reproducible open science practices. While some powerful tools, such as [Google Earth Engine](https://earthengine.google.com/) [@GORELICK201718] offer some solutions to these problems, they also have important limitations, such as proprietary and energy-intensive software. Altogether, these barriers hinder the full potential of Earth observation data to support global research and decision-making. Efforts to simplify, lighten and streamline access to these data, while maintaining an open-source and open-science framework, are essential to overcoming these obstacles and maximizing the benefits of satellite data for all.

Here, we introduce `modisfast`, an open-source R package [@R] designed to simplify, streamline, and accelerate the download and import of MODIS, VIIRS, and GPM time series for R users. This package expands the existing ecosystem of R tools for accessing MODIS data, enhancing it by introducing new features and data sources. `modisfast` allows users to subset these datasets using spatial, temporal, and band/layer directly at the downloading phase - optimizing data download and processing - and to softly import them in R for further analysis. Additionally, downloads can be parallelized for increased efficiency. `modisfast` thus facilitates access to EO data for R users, particularly in regions with limited internet infrastructure, and enables embedding data extraction within complex and holistic data workflows in R - fostering transparency and reproducibility in the context of Open Science. Importantly, the foundational framework of `modisfast` guarantees the package's long-term sustainability, open-source nature, and cost-free availability.

# Target audience

`modisfast` is suitable to any R user looking to use MODIS, VIIRS or GPM Earth Observation data, either for research, education, or operational purposes.

`modisfast` is particularly suited for the following cases : 

- Retrieving MODIS, VIIRS or GPM data quickly over **long time series** and **areas** (as opposed to **short time series** and **specific points**),
- Users who want to integrate the data extraction process within complex data workflows in R (e.g., extraction, transformation, visualization, modeling, communication),
- Users in regions with limited internet infrastructure,
- Users who wish to promote international standards for data formats and access, and Open Science in general,
- Users who are concerned about digital sobriety.

# Main features

## Data collections available with `modisfast`

Currently `modisfast` supports download of 87 data collections, extracted from the following meta-collections : 

* [MODIS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) ;
* [VIIRS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/) made available by the [NASA / USGS LP DAAC](https://lpdaac.usgs.gov/) ;
* [Global Precipitation Measurement](https://gpm.nasa.gov/missions/GPM) (GPM) made available by the [NASA / JAXA GES DISC](https://disc.gsfc.nasa.gov/).

This list may change over time. The function `mf_list_collections()` enables to get the latest list of available data collections.

## Typical workflow with `modisfast`

The typical workflow to access and import MODIS, VIIRS or GPM data in R with `modisfast` is presented in \autoref{fig:wf_modisfast}, along with a toy example.

![Workflow for MODIS, VIIRS or GPM data download and import with `modisfast`.\label{fig:wf_modisfast}](workflow_modisfast.png){width="100%"}

## Long-form documentations and examples

`modisfast` provides three long-form documentations and examples to learn more about the package :

-   a [Get started](https://ptaconet.github.io/modisfast/articles/get_started.html) vignette describing the core features of the package;
-   a [Get data on several regions or periods of interest simultaneously](https://ptaconet.github.io/modisfast/articles/modisfast2.html) vignette detailing advanced functionalities of `modisfast` (for multi-time frame or multi-regions data access);
-   a [Full use case](https://ptaconet.github.io/modisfast/articles/use_case.html) vignette showcasing an example of use of the package in a scientific context (geo-epidemiology).

## Foundational framework of `modisfast`

Technically, `modisfast` is a programmatic interface to several NASA OPeNDAP (https://www.opendap.org/) servers. OPeNDAP is the acronym for "Open-source Project for a Network Data Access Protocol" and designates both the software, the access protocol, and the corporation that develops them. The OPeNDAP is designed to simplify access to structured and high-volume data, such as satellite products, over the Web. It is a collaborative effort involving multiple institutions and companies, with open-source code, free software, and adherence to the [Open Geospatial Consortium](https://www.ogc.org/) (OGC) standards. It is widely used by NASA, which partly finances it. 

A key feature of OPeNDAP is its capability to apply filters at the data download process, ensuring that only the necessary data is retrieved. These filters, specified within a URL, can be spatial, temporal, or dimensional. Although powerful, OPeNDAP URLs are not trivial to build. The main work of `modisfast` is to construct these URLs based on the filters that are specified by the user through standard R objects.

Importantly, the robust, sustainable, and cost-free foundational framework of `modisfast`, both for the data provider (NASA) and the software (R, OPeNDAP, the `tidyverse`  and `GDAL` suite of packages and associated software [@tidyverse; @gdal; @terra; @sf]), guarantees the long-term stability and reliability of the package.

# Alternatives

Besides `modisfast`, there are several open-source R packages available for accessing MODIS or VIIRS Land products. These packages vary in the number and diversity of data collections they provide access to, the data access time, their ability to filter data during the download phase (spatially or dimensionally), the maximum area size they allow for download, the data access protocol they rely on, and their availability on widely-recognized archives like [CRAN](https://cran.r-project.org/). Table 1 summarizes the main features of these packages. A thorough comparison of `modisfast` with these R packages in terms of data access time can be found in the [package documentation](https://ptaconet.github.io/modisfast/articles/perf_comp.html). 

|                              |  `modisfast` | `appeears` |   `MODIS`       | `MODIStsp`  | `MODIStools` | `rgee`       |
|------------------------------|:------------:|:------------:|:------------:|:------------:|:------------:|:------------:|
| EO Data collections accessible  | MODIS, VIIRS, GPM | MODIS, VIIRS, and many others | MODIS | MODIS | MODIS, VIIRS | MODIS, VIIRS, GPM, and many others 
| Last updated                    | August 2024 | March 2024 | January 2023 | July 2024 | December 2022 | August 2024
| License                         | GPL-3.0 | AGPL-3 | NA | GPL-3.0 | AGPL-3  | Apache License v.2.0
| Available on CRAN ?             | yes | yes | no | no | yes | yes 
| Utilizes open standards for data access protocols | yes | yes | no | NA | no | no
| Enables spatial subsetting at the download phase  | yes | yes | no |no | yes | yes
| Enables dimensional subsetting at the download phase | yes | yes | no | yes | yes | yes
| Maximum area size allowed for download  | unlimited | unlimited | NA | unlimited | 200 km x 200 km | unlimited
| Website                        | [`GitHub`](https://github.com/ptaconet/modisfast) |  [`GitHub`](https://github.com/bluegreen-labs/appeears) |  [`GitHub`](https://github.com/fdetsch/MODIS) | [`GitHub`](https://github.com/ropensci/MODIStsp) |  [`GitHub`](https://github.com/ropensci/MODISTools) |  [`GitHub`](https://github.com/r-spatial/rgee)
| Publication                    |  | @rgee | NA | @MODIStsp | @modistools | @rgee

Table 1: Comparison of `modisfast` with other popular alternatives. 

# Acknowledgements

We thank NASA and its partners for making all their Earth science data freely available, and financing and implementing open data access protocols such as OPeNDAP. `modisfast` heavily builds on top of the OPeNDAP, so we thank the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) for developing the eponym tool in an open and collaborative way. Likewise, we thank the developers of the R packages `modisfast` depends on.

We also thank the contributors that have tested the package, reviewed the documentation and brought valuable feedbacks to improve the package : Florian de Boissieu, Julien Taconet, Annelise Tran, Alexandre Cebeillac.

This work has been developed over the course of several research projects conducted by the French National Research Institute for Sustainable Development (IRD) and its partners :

-   the REACT 1 and REACT 2 projects funded by the *l'Initiative - Expertise France*.
-   the ANORHYTHM project (ANR-16-CE35-008) funded by the French National Research Agency (ANR).
-   the DIV-YOO project (ANR-23-CE35-0005) funded by the French National Research Agency (ANR).

# References
