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

Data from Earth Observation satellites are a crucial and increasingly valuable resource for monitoring and understanding our planet, especially in the context of global change. EO data from the NASA are among the richest and longest-standing in the field. Iconic and widely NASA EO data collections include the MODIS Land products [@JUSTICE20023], the VIIRS products - which continue the legacy of MODIS [@ROMAN2024113963], and the GPM mission products [@SkofronickJackson2017]. Collectively, these products have provided essential data for over 20 years, enabling the study of Earth's dynamics, including global land cover, vegetation health, burned areas, land surface temperature, rainfall patterns. They support research in climate change, disaster response, biodiversity, ecosystem monitoring, ecology, public health, and more [@modis-applications].

Despite the growing availability and usefulness of these Earth Observation (EO) data, accessing and utilizing it poses significant challenges [@AGNOLI2023122357]. These data are often distributed as large, multidimensional layers, making them difficult to access and process, particularly for extended time series and in regions with limited internet infrastructure. This complexity can lead to underutilization or fragmented data processing workflows, which hinders transparent and reproducible open science. While powerful tools like [Google Earth Engine](https://earthengine.google.com/) [@GORELICK201718] offer some solutions, they come with limitations such as proprietary and energy-intensive software. To fully realize the potential of EO data for global research and decision-making, it is crucial to simplify, lighten and streamline access while maintaining an open-source framework.

In this context we have developed `modisfast`, an open-source R package [@R] designed to simplify, streamline, and speed-up the download and import of MODIS, VIIRS, and GPM time series for R users. Enhancing the existing R ecosystem for accessing MODIS data, modisfast introduces new features and supports additional data sources. Built on the [OPeNDAP](https://www.opendap.org/) protocol, `modisfast` allows users to apply spatial, temporal, and band/layer filters during the download phase, optimizing data retrieval and processing. The package also supports parallelized downloads for increased efficiency. Thus, `modisfast` facilitates access to a set of EO data for R users, while using and promoting open-source international standards for data access. Importantly, the robust, sustainable, and cost-free foundational framework of `modisfast` - both for the data provider (NASA) and the software (R, OPeNDAP, the `tidyverse` and `GDAL` suite of packages and software [@tidyverse; @gdal; @terra; @sf]) - guarantees the long-term reliability and open-source nature of the package.

# Target audience

`modisfast` is suitable to any R user looking to use MODIS, VIIRS or GPM Earth Observation data, either for research, education, or operational purposes.

`modisfast` is particularly suited for :

-   Retrieving MODIS, VIIRS or GPM data over **long time series** and **large areas**,
-   **Embedding data extraction within complex R workflows**,
-   Users in regions with **limited internet access**,
-   Promoting **international data access standards** and Open Science in general,
-   Users who are concerned about **digital sobriety**.

# Main features

## Data collections available with `modisfast`

Currently `modisfast` supports download of 77 data collections, extracted from [MODIS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/), [VIIRS land products](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/s-npp-nasa-viirs-overview/), and [Global Precipitation Measurement](https://gpm.nasa.gov/missions/GPM).

This list may change over time. The function `mf_list_collections()` enables to get the latest list of available data collections.

## Typical workflow with `modisfast`

The typical workflow to access and import MODIS, VIIRS or GPM data in R with `modisfast` is presented in \autoref{fig:wf_modisfast}, along with a toy example.

![Workflow for MODIS, VIIRS or GPM data download and import with `modisfast`.\label{fig:wf_modisfast}](workflow_modisfast.png){width="100%"}

## Long-form documentations and examples

`modisfast` provides three long-form documentations and examples to learn more about the package :

-   a [Get started](https://ptaconet.github.io/modisfast/articles/get_started.html) vignette describing the core features of the package;
-   a [Get data on several regions or periods of interest simultaneously](https://ptaconet.github.io/modisfast/articles/modisfast2.html) vignette detailing advanced functionalities of `modisfast` (for multi-time frame or multi-regions data access);
-   a [Full use case](https://ptaconet.github.io/modisfast/articles/use_case.html) vignette showcasing an example of use of the package in a scientific context (geo-epidemiology).

# Alternatives

Besides `modisfast`, there are several open-source R packages available for accessing MODIS or VIIRS Land products. Table 1 summarizes the main features of these packages. A thorough comparison of `modisfast` with these R packages in terms of data access time can be found in the [package documentation](https://ptaconet.github.io/modisfast/articles/perf_comp.html).

|                                                      |                    `modisfast`                    |                       `appeears`                       |                   `MODIS`                    |                    `MODIStsp`                    |                    `MODIStools`                    |                    `rgee`                     |
|-----------|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
| EO Data collections accessible                       |                 MODIS, VIIRS, GPM                 |             MODIS, VIIRS, and many others              |                    MODIS                     |                      MODIS                       |                    MODIS, VIIRS                    |      MODIS, VIIRS, GPM, and many others       |
| Last updated                                         |                    August 2024                    |                       March 2024                       |                 January 2023                 |                    July 2024                     |                   December 2022                    |                  August 2024                  |
| License                                              |                      GPL-3.0                      |                         AGPL-3                         |                      NA                      |                     GPL-3.0                      |                       AGPL-3                       |             Apache License v.2.0              |
| Available on CRAN ?                                  |                        yes                        |                          yes                           |                      no                      |                        no                        |                        yes                         |                      yes                      |
| Utilizes open standards for data access protocols    |                        yes                        |                          yes                           |                      no                      |                        NA                        |                         no                         |                      no                       |
| Enables spatial subsetting at the download phase     |                        yes                        |                          yes                           |                      no                      |                        no                        |                        yes                         |                      yes                      |
| Enables dimensional subsetting at the download phase |                        yes                        |                          yes                           |                      no                      |                       yes                        |                        yes                         |                      yes                      |
| Maximum area size allowed for download               |                     unlimited                     |                       unlimited                        |                      NA                      |                    unlimited                     |                  200 km x 200 km                   |                   unlimited                   |
| Website                                              | [`GitHub`](https://github.com/ptaconet/modisfast) | [`GitHub`](https://github.com/bluegreen-labs/appeears) | [`GitHub`](https://github.com/fdetsch/MODIS) | [`GitHub`](https://github.com/ropensci/MODIStsp) | [`GitHub`](https://github.com/ropensci/MODISTools) | [`GitHub`](https://github.com/r-spatial/rgee) |
| Publication                                          |                                                   |                         @rgee                          |                      NA                      |                    @MODIStsp                     |                    @modistools                     |                     @rgee                     |

Table 1: Comparison of `modisfast` with other popular alternatives.

# Acknowledgements

We thank NASA and its partners for making all their Earth science data freely available, and financing and implementing open data access protocols such as OPeNDAP. We also thank the non-profit [OPeNDAP, Inc.](https://www.opendap.org/about/) for developing and maintaining the eponym tool, and the developers of the R packages `modisfast` depends on.

This work has been developed over the course of several research projects :

-   the REACT 1 and REACT 2 projects funded by the *l'Initiative - Expertise France* ;
-   the ANORHYTHM (ANR-16-CE35-008) and DIV-YOO project (ANR-23-CE35-0005) funded by the French National Research Agency (ANR).

# References
