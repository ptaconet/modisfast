#' @name odr_import_data
#' @aliases odr_import_data
#' @title Import the time series in R as a \code{RasterBrick} or a \code{stars} object
#' @description Import a time series as a \code{RasterBrick} or a \code{stars} object
#'
#' @param paths string character vector. mandatory.
#' @param collection character string. mandatory. The name of a collection
#' @param variable character string. The variable to import. If output="stars", all variables will be imported
#' @param roi sf the ROI. Mandatory for SMAP collection, else, not necessary
#' @param output character string. Output object class. "RasterBrick" or "stars". See Details.
#' @param opt_param list of optional arguments. optional. (see details).
#'
#' @details
#' \code{output} : Currently "RasterBrick" implemented for all the collections and "stars" only for MODIS and VIIRS collections
#' \code{opt_param} : for SMAP products only. See sections Details of \link{odr_get_url}
#'
#' @import purrr
#' @importFrom raster raster brick t merge flip
#' @importFrom stars read_stars
#' @importFrom ncdf4 nc_open ncvar_get
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#'
#' \donttest{
#'
#' require(sf)
#' require(magrittr)
#' require(raster)
#' require(stars)
#'
#' username <- Sys.getenv("earthdata_un")
#' password <- Sys.getenv("earthdata_pw")
#' log <- odr_login(credentials = c(username,password), source = "earthdata")
#'
#' roi = st_as_sf(data.frame(
#' geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),
#' wkt="geom",crs = 4326)
#'
#' time_range = as.Date(c("2017-01-01","2017-01-30"))
#'
#' urls_mod11a1 <- odr_get_url(collection = "MOD11A1.006",
#' variables = c("LST_Day_1km","LST_Night_1km"),
#' roi = roi,
#' time_range = time_range
#' )
#'
#' res_dl <- odr_download_data(urls_mod11a1)
#'
#' ## import as RasterBrick
#' # here we import only the band LST_Day_1km
#' (mod11a1_rast <- odr_import_data(df_data_to_import = urls_mod11a1,
#' collection = "MOD11A1.006",
#' variable = "LST_Day_1km",
#' output = "RasterBrick"))
#'
#' ## import os stars
#' # in a stars object, all the bands are imported, so no need to specify a variable
#' (mod11a1_stars <- odr_import_data(df_data_to_import = urls_mod11a1,
#' collection = "MOD11A1.006",
#' output = "stars"))
#'
#' plot(mod11a1_rast)
#'
#' plot(mod11a1_stars)
#'
#' }

odr_import_data <- function(paths,
                            collection,
                            variable = NULL,
                            roi = NULL,
                            output = "RasterBrick",
                            opt_param = NULL){

  rasts <- NULL

  .testIfCollExists(collection)

  coll_info <- opendapMetadata_internal[which(opendapMetadata_internal$collection==collection),]

  if(!(output %in% c("RasterBrick","stars"))){stop("parmater 'output' must be either RasterBrick or stars")}
  #if(is.null(variable) && output=="RasterBrick"){stop("for RasterBrick output you must provide one variables")}
  if(!is.null(variable) && length(variable)>1){stop("you must provide only one variable")}
  if(is.null(variable)){ variable <- "NULL" }


  if(coll_info$source %in% c("MODIS","VIIRS")){

    if (coll_info$provider=="NASA USGS LP DAAC"){

      rasts <- .import_modis_viirs_lpdaac(paths,variable,output)

    } else if (coll_info$provider=="NASA LAADS DAAC"){

      rasts <- .import_modis_viirs_laadsdaac(paths,variable,output)

    }

  } else if (coll_info$source=="GPM"){

    rasts <- .import_gpm(paths,variable,output)

  } else if (coll_info$source=="SMAP"){

    rasts <- .import_smap(paths,collection,variable,roi,output,opt_param)

  }

  return(rasts)

}
