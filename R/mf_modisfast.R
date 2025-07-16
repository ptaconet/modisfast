#' @name mf_modisfast
#' @aliases mf_modisfast
#' @title Download (and possibly import) MODIS, VIIRS and GPM
#' Earth Observation data
#' @description Download and possibly import MODIS, VIIRS and GPM
#' Earth Observation data quickly and efficiently.
#' This function is a wrapper for
#' \link{mf_login}, \link{mf_get_url}, \link{mf_download_data} and \link{mf_import_data}.
#' Whenever possible, users should prefer executing the functions \link{mf_login},
#' \link{mf_get_url}, \link{mf_download_data} and \link{mf_import_data} sequentially
#' rather than using this high-level function
#'
#' @inheritParams mf_get_url
#' @inheritParams mf_download_data
#' @inheritParams mf_import_data
#' @param earthdata_username EarthData username
#' @param earthdata_password EarthData username
#' @param import boolean. Import the data as a SpatRast object ? default TRUE. FALSE will download the data but not import them it in R.
#' @param ... Further arguments to be passed to \link{mf_import_data}
#'
#' @return if the parameter \code{import} is set to TRUE, a \code{terra::SpatRast}
#' object ; else a data.frame providing details of the data downloaded
#' (see output of \link{mf_download_data}).
#'
#' @seealso \link{mf_login}, \link{mf_get_url}, \link{mf_download_data}, \link{mf_import_data}
#' @export
#' @examples
#' \dontrun{
#'
#' ### Set-up parameters of interest
#' coll <- "MOD11A1.061"
#'
#' bands <- c("LST_Day_1km", "LST_Night_1km")
#'
#' time_range <- as.Date(c("2017-01-01", "2017-01-30"))
#'
#' roi <- sf::st_as_sf(
#'   data.frame(
#'     id = "roi_test",
#'     geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"
#'   ),
#'   wkt = "geom", crs = 4326
#' )
#'
#' ### Download and import the data
#' modis_ts <- mf_modisfast(
#'   collection = coll,
#'   variables = bands,
#'   roi = roi,
#'   time_range = time_range,
#'   earthdata_username = "earthdata_un",
#'   earthdata_password = "earthdata_pw"
#'  )
#'
#' ### Plot the data
#' terra::plot(modis_ts)
#' }
mf_modisfast <- function(collection,
                      variables,
                      roi,
                      time_range,
                      path = tempfile("modisfast_"),
                      earthdata_username,
                      earthdata_password,
                      parallel = FALSE,
                      verbose = "inform",
                      import = TRUE,
                      ...) {
  log <- mf_login(c(earthdata_username, earthdata_password), verbose = verbose)
  urls <- mf_get_url(collection = collection,
                     variables = variables,
                     roi = roi,
                     time_range = time_range,
                     verbose = verbose)
  r <- mf_download_data(df_to_dl = urls,
                        path = path,
                        parallel = parallel,
                        verbose = verbose)
  if (import) {
    r <- mf_import_data(path = dirname(r$destfile[1]),
                        collection = collection,
                        roi_mask = roi,
                        verbose = verbose,
                        ...)
  }
  return(r)
}
