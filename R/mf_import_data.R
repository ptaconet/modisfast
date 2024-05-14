#' @name mf_import_data
#' @aliases mf_import_data
#' @title Import the time series in R as a \code{SpatRaster} object
#' @description Import a time series as a \code{SpatRaster}object
#'
#' @param dir_path string character vector. mandatory. The path to the local directory where the data are stored.
#' @param collection_source character string. mandatory. The collection source (one of "MODIS", "VIIRS", "GPM")
#' @param output_class character string. Output object class. Currently only "SpatRaster" implemented.
#' @param proj_epsg character string. EPSG of the desired projection for the output raster (default : 4326)
#'
#' @import purrr
#' @importFrom terra rast t merge flip
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#'
#' \donttest{
#'
#' require(sf)
#' require(magrittr)
#' require(terra)
#'
#' username <- Sys.getenv("earthdata_un")
#' password <- Sys.getenv("earthdata_pw")
#' log <- mf_login(credentials = c(username,password))
#'
#' roi_id <- "korhogo"
#' roi = st_as_sf(data.frame(
#' geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),
#' wkt="geom",crs = 4326)
#'
#' time_range = as.Date(c("2017-01-01","2017-01-30"))
#'
#' urls_mod11a1 <- mf_get_url(collection = "MOD11A1.061",
#' variables = c("LST_Day_1km","LST_Night_1km"),
#' roi = roi,
#' roi_id = roi_id,
#' time_range = time_range
#' )
#'
#' res_dl <- mf_download_data(urls_mod11a1)
#'
#' ## import as terra::SpatRast
#'
#' modis_ts <- mf_import_data(file.path(roi_id,"MOD11A1.061"), collection_source = "MODIS")
#'
#' plot(mod11a1_rast)
#'
#' }

mf_import_data <- function(dir_path,
                           collection_source,
                           output_class = "SpatRaster",
                           proj_epsg = "4326"){

  rasts <- NULL

  if(!dir.exists(dir_path)){stop("Directory provided does not exist.")}

  if(!(collection_source %in% c("MODIS","VIIRS","GPM"))){stop("parmater 'collection_source' must be either 'MODIS' or 'VIIRS' or 'GPM'.")}

  if(!(output_class %in% c("SpatRaster","stars"))){stop("parmater 'output_class' must be either SpatRaster or stars.")}

  if(collection_source %in% c("MODIS","VIIRS")){

      rasts <- .import_modis_viirs(dir_path,output_class,proj_epsg)

  } else if (collection_source=="GPM"){

      rasts <- .import_gpm(dir_path,output_class,proj_epsg)

  }

  return(rasts)

}