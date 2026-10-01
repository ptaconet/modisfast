#' @name mf_import_data
#' @aliases mf_import_data
#' @title Import datasets downloaded using \code{modisfast} as a \code{terra::SpatRaster} object
#' @description Import datasets downloaded using \code{modisfast} as a \code{terra::SpatRaster} object
#'
#' @param path Download root folder supplied to [mf_download_data()],
#'   or a folder containing the NetCDF files for one ROI and collection.
#' @param output_class character string. Output object class. Currently only "SpatRaster" implemented.
#' @param proj_epsg numeric. EPSG of the desired projection for the output raster (default : source projection of the data).
#' @param roi_mask \code{SpatRaster} or \code{SpatVector} or \code{sf}. Area beyond which data will be masked. Typically, the input ROI of \link{mf_get_url} (default : NULL (no mask))
#' @param vrt boolean. Import virtual raster instead of SpatRaster. Useful for very large files. (default : FALSE)
#' @param verbose Character string: `"quiet"`, `"inform"` (default), or
#'   `"debug"`. Controls progress messages.
#' @inheritParams mf_get_url
#' @param ... not used
#'
#' @note
#'
#' Although the data downloaded through \code{modisfast} could be imported with any netcdf-compliant R package (\code{terra}, \code{stars}, \code{ncdf4}, etc.), care must be taken. In fact, depending on the collection, some “issues” were raised. These issues are independent from \code{modisfast} : they result most of time of a lack of full implementation of the OPeNDAP framework by the data providers. Namely, these issues are :
#' \itemize{
#'  \item{for MODIS and VIIRS collections : CRS has to be provided}
#'  \item{for GPM collections : EPSG:4326 is assigned to the grid}
#' }
#'
#' The function \link{mf_import_data} includes the processing that needs to be done at the data import phase in order to safely use the data as \code{terra} objects.
#'
#' Also note that reprojecting over large ROIs using the argument \code{proj_epsg} might take long. In this case, setting the argument \code{vrt} to TRUE might be a solution.
#'
#' @return a \code{terra::SpatRast} object
#'
#' @import purrr
#' @importFrom terra rast merge flip
#' @importFrom magrittr %>%
#' @importFrom cli cli_alert_success
#' @export
#'
#' @examples
#' \dontrun{
#'
#' ### Configure an Earthdata bearer token for LP DAAC Cloud
#' Sys.setenv(EARTHDATA_TOKEN = "your Earthdata bearer token")
#'
#' ### Set-up parameters of interest
#' coll <- "VJ121A2.002"
#'
#' bands <- c("LST_Day_1KM", "LST_Night_1KM")
#'
#' time_range <- as.Date(c("2026-01-01", "2026-01-30"))
#'
#' roi <- sf::st_as_sf(
#'   data.frame(
#'     id = "roi_test",
#'     geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"
#'   ),
#'   wkt = "geom", crs = 4326
#' )
#'
#' ### Get the URLs of the data
#' (urls_vj121a2 <- mf_get_url(
#'   collection = coll,
#'   variables = bands,
#'   roi = roi,
#'   time_range = time_range
#' ))
#'
#' ### Download the data
#' res_dl <- mf_download_data(urls_vj121a2)
#'
#' ### Import the data as terra::SpatRast
#' modis_ts <- mf_import_data(dirname(res_dl$destfile[1]), collection = coll)
#'
#' ### Plot the data
#' terra::plot(modis_ts)
#' }
mf_import_data <- function(path,
                           collection,
                           output_class = "SpatRaster",
                           proj_epsg = NULL,
                           roi_mask = NULL,
                           vrt = FALSE,
                           verbose = "inform",
                           ...) {
  .mf_check_verbose(verbose)
  rasts <- NULL

  if (!dir.exists(path)) {
    stop("Directory provided does not exist.")
  }
  path <- .mf_resolve_import_path(path, collection)

  if (!(output_class %in% c("SpatRaster", "stars"))) {
    stop("paramater 'output_class' must be SpatRaster.")
  }

  if (verbose %in% c("inform","debug")) {
    cat("Importing the dataset as a",output_class,"object...\n")
  }

  if (.mf_is_cloud_download(path)) {
    if (is.null(.mf_cloud_collection_source(collection))) {
      stop("This cloud collection is not a supported LP DAAC MODIS or VIIRS product.")
    }
    rasts <- .import_modis_cloud(path, collection, output_class,
                                proj_epsg, roi_mask, vrt)
  } else {
    .testIfCollExists(collection)
    odap_coll_info <- .mf_collection_metadata(collection)
    if (odap_coll_info$source %in% c("MODIS", "VIIRS")) {
      rasts <- .import_modis_viirs(path, output_class, proj_epsg, roi_mask, vrt)
    } else if (odap_coll_info$source == "GPM") {
      rasts <- .import_gpm(path, output_class, proj_epsg, roi_mask)
    }
  }

  if (verbose %in% c("inform","debug")) {
    cli_alert_success("Dataset imported")
  }

  return(rasts)
}
