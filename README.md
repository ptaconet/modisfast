
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opendapr <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

[![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
[![Travis build
status](https://travis-ci.org/ptaconet/opendapr.svg?branch=master)](https://travis-ci.org/ptaconet/opendapr)
<!-- badges: end -->

**\[ Caution : Package still in development … \]**

The goal of opendapr is to …

## Installation

You can install the released version of opendapr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("opendapr")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/opendapr")
```

`opendapr` is not a generic wrapper around the OPeNDAP framework. Its
objective is more to provide an entry point to some specific OPeNDAP
servers (e.g. MODIS, VNP, GPM, SMAP)

## Which products are available for download through `opendapr` ?

The collections currently available for download are listed above. The
function `get_collections_available()` returns that same table. Want
more details on a specific collection ? Click on the `DOI` column of the
table above \!

<details>

<summary>Products available for download with opendapr (click to
expand)</summary>

<p>

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

collection

</th>

<th style="text-align:left;">

long\_name

</th>

<th style="text-align:left;">

source

</th>

<th style="text-align:left;">

DOI

</th>

<th style="text-align:left;">

url\_opendapserver

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

We want to download over the 50 km x 50 km (3500 km<sup>2</sup>) wide
region of interest :

  - a 40 days time series of [MODIS Terra Land Surface Temperature
    (LST)](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (spatial
    resolution : 1 km ; temporal resolution : 1 day),
  - the same 40 days times series of [Global Precipitation Measurement
    (GPM)](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (spatial
    resolution : 1° ; temporal resolution : 1 day)

First prepare the script : set-up ROI, time frame and login to USGS ERS

``` r
### Prepare script
# Packages
require(opendapr)
require(sf)

# Set ROI and time range of interest
roi <- st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
time_range <- as.Date(c("2017-01-01","2017-01-30"))

# Login to USGS servers with username and password. To create an account : https://ers.cr.usgs.gov/register/
credentials_usgs <- config::get("usgs")
log <- login_usgs(c(credentials_usgs$usr,credentials_usgs$pwd))
```

Download MODIS and GPM data in two steps : i) get the OPeNDAP URLs with
the `get_url()` function and ii) download the data with the
`download_data()` function.

``` r
## Get the URLs for MOD11A1.006
urls_mod11a1 <- get_url(
  collection = "MOD11A1.006",
  roi = roi,
  time_range = time_range
 )

## Get the URLs for GPM_L3/GPM_3IMERGDF.06
urls_gpm <- get_url(
  collection = "GPM_L3/GPM_3IMERGDF.06",
  roi = roi,
  time_range = time_range
 )

## Download the data. Destination file for each dataset is specified in the column "destfile" of the dataframe urls_mod11a1 and urls_gpm
df_to_dl <- rbind(urls_mod11a1,urls_gpm)
res_dl <- download_data(df_to_dl,data_source="usgs",parallel = TRUE)

## Check that data have been properly downloaded :
list.files(res_dl$destile)
```

It is also possible to subset the bands to download with the parameter
`variables` of the function `get_url()`.

To further import the data in R, have a look at the [last section of the
Readme](#important-note-import) and / or the [dedicated section in the
vignettes](https://ptaconet.github.io/opendapr/articles/simple_workflow.html#import)
\!

Simple or more complex data download + import workflows are provided in
the vignettes
[here](https://ptaconet.github.io/opendapr/articles/simple_workflow.html)
or [there]().

## Important note regarding the further import of the data in R

Various packages and related classes can be used to read the data
downloaded through OPeNDAP. In any case, care must be taken when
importing data that was downloaded through OPeNDAP. Depending on the
collection, some “issues” were raised. These issues are independant from
`opendapr` : they result most of time of a kind of lack of full
implementation of the OPeNDAP framework by the data providers. These
issues are :

  - for MODIS and VNP collections : CRS has to be provided
  - for GPM collections : CRS has to be provided + data have to be
    flipped
  - for SMAP collections :information on the bounding coordinates of the
    data have to be provided

These issues can easily be dealt at the import phase in R. The functions
below includes the manipulations that have to be done at the data import
phase (“path.to.nc4” is the path to a dataset downloaded with `opendapr`
and “variable.of.interest” is the name of a variable).

``` r
#################### 
#To import as a raster object a single variable of a MODIS or VNP product (with the raster package) : 
rast_modis_vnp <- raster(path="path.to.nc4",varname="variable.of.interest",crs="+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
####################
```

``` r
#################### 
#To import as a raster object a single variable of a GPM product (with the raster package) : 
rast_gpm <- raster(path="path.to.nc4",varname="variable.of.interest",crs="+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") %>%
  t() %>%
  flip("y") %>%
  flip("x")
####################
```

``` r
#################### 
#To import as a raster object a single variable of a SMAP product (with the raster and ncdf4 package) : 
smap_sp_bound <- opendapr::get_optional_parameters(roi = roi, collection = "SMAP/SPL3SMP_E.003")$roiSpatialBound$`1`
  
rast_smap <- ncdf4::nc_open("path.to.nc4")) %>%
  ncdf4::ncvar_get("variable.of.interest")) %>%
  raster(t(.), ymn=smap_sp_bound[1], ymx=smap_sp_bound[2], xmn=smap_sp_bound[3], xmx=smap_sp_bound[4], crs="+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0") # EPSG : 6933
####################
```
