#' @name getUrl
#' @aliases getUrl
#' @title Get the URL of
#' @description some descirption
#'
#' @param collection string. Collection of interest.
#' @param variables string vector. Variables to retrieve for the collection of interest
#' @param roi object of class \code{sf} or \code{sfc} Region of interest. Must be POLYGON-type geometry. Can be composed of several features (see details)
#' @param timeRange date(s) / POSIXlt of interest (single date/datetime or time frame : vector with start and end dates/times) (see details)
#' @param outputFormat string. Output format. Available options are : "nc4" (default), "ascii", "json"
#' @param singleNetcdf boolean. Get the URL either as a single file that encompasses the whole time frame (TRUE) or as multiple files (1 for each date) (FALSE). Default to TRUE. Currently enabled only for MODIS and VNP collections.
#' @param optParam list of optional arguments (see details). Can be retrieved with the function \link{getOptParam}.
#' @param loginCredentials vector string. In case of data that needs login : string vector of length 2 with username and password
#' @param verbose boolean. Verbose (default FALSE)
#'
#' @return a data.frame with one row for each dataset and 3 columns  :
#'  \itemize{
#'  \item{*time_start* : }{Start Date/time for the dataset}
#'  \item{*name* : }{An indicative name for the dataset}
#'  \item{*url* : }{http URL of the dataset}
#'  \item{*destfile* : }{An indicative destination file for the dataset}
#'  }
#'
#' @details
#'
#' This is the main function of the package. It enables to retrieve
#'
#' @note
#'
#' some note
#'
#' @export
#'
#' @importFrom stringr str_replace
#' @importFrom stats ave
#' @import dplyr
#'
#' @examples
#'
#' \dontrun{
#' ### First login to Earthdata
#' login_earthdata(c("my.earthdata.username","my.earthdata.password"))
#'
#'############################################################
#' ### Retrieve the URLs to download the following datasets :
#' # MODIS Terra LST Daily (MOD11A1.006) (collection)
#' # Day + Night bands (LST_Day_1km,LST_Night_1km) (variables)
#' # over a 50km x 70km region of interest located in Northern Ivory Coast (roi)
#' # for the time frame 2017-01-01 to 2017-01-30 (30 days) (timeRange)
#'
#' (opendap_urls_mod11a1 <- getUrl(collection = "MOD11A1.006",
#' variables = c("LST_Day_1km","LST_Night_1km"),
#' roi = sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE),
#' timeRange = as.Date(c("2017-01-01","2017-01-30"))
#' ))
#'############################################################
#'
#' ### Download the data :
#'
#' res_dl <- downloadData(opendap_urls_mod11a1)
#'
#' ### Open the data :
#' # When opening the data, do not forget to reset the CRS
#' # here, MODIS crs : https://spatialreference.org/ref/sr-org/modis-sinusoidal-3/proj4/
#' modis_crs <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
#'
#' ## open as a stars object (deals with multiple dimensions and time)
#'
#' require(stars)
#' (mod11a1_stars <- read_stars(res_dl$destfile) %>% st_set_crs(modis_crs))
#'
#' ## or open as a rasterBrick object (1 rasterBrick for each dimension)
#'
#' require(raster)
#' (mod11a1_rast_day <- brick(res_dl$destfile,varname="LST_Day_1km",crs=modis_crs))
#' (mod11a1_rast_night <- brick(res_dl$destfile,varname="LST_Night_1km",crs=modis_crs))
#'
#' # Here the time dimension is set as the z dimension :s
#' (getZ(mod11a1_rast_day))
#'}
#'
#' # Check out the vignette for additional examples and exhaustive data import workflows
#'
#'


getUrl<-function(collection,
                 variables,
                 roi,
                 timeRange,
                 outputFormat="nc4",
                 singleNetcdf=TRUE,
                 optParam=NULL,
                 loginCredentials=NULL,
                 verbose=FALSE){

  existing_variables <- odap_coll_info <- odap_timeDimName <- odap_lonDimName <- odap_latDimName  <- NULL

  ## tests :
  # roi
  .testRoi(roi)
  # timeRange
  .testTimeRange(timeRange)
  # outputFormat
  .testFormat(outputFormat)
  # singleNetcdf
  if(!inherits(singleNetcdf,"logical")){stop("singleNetcdf argument must be boolean\n")}
  # verbose
  if(!inherits(verbose,"logical")){stop("verbose argument must be boolean\n")}
  # collection
  if(verbose){cat("Checking if specified collection exist and is implemented in the package...\n")}
  .testIfCollExists(collection)
  # loginCredentials
  .testLogin(loginCredentials)

  if(is.null(optParam)){
    if(verbose){cat("Retrieving opendap arguments for the collection specified...\n")}
    optParam <- getOptParam(collection,roi)
  }

  # test variables
  if(verbose){cat("Checking if specified variables exist for the collection specified...\n")}
  available_variables <- optParam$availableVariables
  .testIfVarExists2(variables,available_variables)

  # build URLs
  if(verbose){cat("Building the opendap URLs...\n")}
  table_urls <- .buildUrls(collection,variables,roi,timeRange,outputFormat,singleNetcdf,optParam,loginCredentials)

  table_urls <- table_urls %>%
    dplyr::mutate(name=stringr::str_replace(name,".*/","")) %>%
    dplyr::arrange(name) %>%
    transform(name = ifelse(duplicated(name) | duplicated(name, fromLast=TRUE),
                            paste(name, stats::ave(name, name, FUN=seq_along), sep='_'),
                            name)) %>%
    dplyr::mutate(destfile=paste0(file.path(collection,.$name),".",outputFormat)) %>%
    dplyr::arrange(date) %>%
    dplyr::select(date,name,url,destfile) %>%
    dplyr::rename(time_start = date)

  return(table_urls)

}
