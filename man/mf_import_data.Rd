% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mf_import_data.R
\name{mf_import_data}
\alias{mf_import_data}
\title{Import datasets downloaded using \code{modisfast} as a \code{terra::SpatRaster} object}
\usage{
mf_import_data(
  path,
  collection,
  output_class = "SpatRaster",
  proj_epsg = NULL,
  roi_mask = NULL,
  vrt = FALSE,
  verbose = "inform",
  ...
)
}
\arguments{
\item{path}{character string. mandatory. The path to the local directory where the data are stored.}

\item{collection}{string. mandatory. Collection of interest (see details of \link{mf_get_url}).}

\item{output_class}{character string. Output object class. Currently only "SpatRaster" implemented.}

\item{proj_epsg}{numeric. EPSG of the desired projection for the output raster (default : source projection of the data).}

\item{roi_mask}{\code{SpatRaster} or \code{SpatVector} or \code{sf}. Area beyond which data will be masked. Typically, the input ROI of \link{mf_get_url} (default : NULL (no mask))}

\item{vrt}{boolean. Import virtual raster instead of SpatRaster. Useful for very large files. (default : FALSE)}

\item{verbose}{string. Verbose mode ("quiet", "inform", or "debug"). Default "inform".}

\item{...}{not used}
}
\value{
a \code{terra::SpatRast} object
}
\description{
Import datasets downloaded using \code{modisfast} as a \code{terra::SpatRaster} object
}
\note{
Although the data downloaded through \code{modisfast} could be imported with any netcdf-compliant R package (\code{terra}, \code{stars}, \code{ncdf4}, etc.), care must be taken. In fact, depending on the collection, some “issues” were raised. These issues are independent from \code{modisfast} : they result most of time of a lack of full implementation of the OPeNDAP framework by the data providers. Namely, these issues are :
\itemize{
 \item{for MODIS and VIIRS collections : CRS has to be provided}
 \item{for GPM collections : CRS has to be provided + data have to be flipped}
}

The function \link{mf_import_data} includes the processing that needs to be done at the data import phase in order to safely use the data as \code{terra} objects.

Also note that reprojecting over large ROIs using the argument \code{proj_epsg} might take long. In this case, setting the argument \code{vrt} to TRUE might be a solution.
}
\examples{
\dontrun{

### Login to EOSDIS Earthdata with your username and password
log <- mf_login(credentials = c("earthdata_un", "earthdata_pw"))

### Set-up parameters of interest
coll <- "MOD11A1.061"

bands <- c("LST_Day_1km", "LST_Night_1km")

time_range <- as.Date(c("2017-01-01", "2017-01-30"))

roi <- sf::st_as_sf(
  data.frame(
    id = "roi_test",
    geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"
  ),
  wkt = "geom", crs = 4326
)

### Get the URLs of the data
(urls_mod11a1 <- mf_get_url(
  collection = coll,
  variables = bands,
  roi = roi,
  time_range = time_range
))

### Download the data
res_dl <- mf_download_data(urls_mod11a1)

### Import the data as terra::SpatRast
modis_ts <- mf_import_data(dirname(res_dl$destfile[1]), collection = coll)

### Plot the data
terra::plot(modis_ts)
}
}
