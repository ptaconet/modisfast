#' @name get_url
#' @aliases get_url
#' @title Get the URL of
#' @description some descirption
#'
#' @param collection string. Collection of interest.
#' @param variables string vector. Variables to retrieve for the collection of interest. If not specified (default) all available variables will be extracted.
#' @param roi object of class \code{sf} or \code{sfc} Region of interest. Must be POLYGON-type geometry. Can be composed of several features (see details).
#' @param time_range date(s) / POSIXlt of interest (single date/datetime or time frame : vector with start and end dates/times) (see details)
#' @param output_format string. Output format. Available options are : "nc4" (default), "ascii", "json"
#' @param single_netcdf boolean. Get the URL either as a single file that encompasses the whole time frame (TRUE) or as multiple files (1 for each date) (FALSE). Default to TRUE. Currently enabled only for MODIS and VNP collections.
#' @param opt_param list of optional arguments (see details). This parameter is the output of the function \link{get_optional_parameters}.
#' @param login_credentials vector string. In case of data that needs login : string vector of length 2 with username and password
#' @param verbose boolean. Verbose (default FALSE)
#'
#' @return a data.frame with one row for each dataset to download and 4 columns  :
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
#'#' Argument \code{time_range} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))}) or as a POSIXlt single time or time range (e.g. "2010-01-01 18:00:00") for the half-hourly collection (GPM_3IMERGHH.06). If POSIXlt, times must be in UTC.
#'
#' Argument \code{optionals_opendap} is optional. This parameter is automatically calculated within the function if it is not provided. However, providing it optimizes the performances of the function (i.e. fasten the processing time).
#' It might be particularly useful to provide it if looping over the same ROI or dates is planned.
#' The parameter can be retrieved outside the function with the function \code{\link{get_optional_parameters}}.
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
#' ### First login to USGS
#' login_usgs(c("my.usgs.username","my.usgs.password"))
#'
#'############################################################
#' ### Retrieve the URLs (OPeNDAP) to download the following datasets :
#' # MODIS Terra LST Daily (MOD11A1.006) (collection)
#' # Day + Night bands (LST_Day_1km,LST_Night_1km) (variables)
#' # over a 50km x 70km region of interest (roi)
#' # for the time frame 2017-01-01 to 2017-01-30 (30 days) (time_range)
#'
#' (opendap_urls_mod11a1 <- get_url(collection = "MOD11A1.006",
#' variables = c("LST_Day_1km","LST_Night_1km"),
#' roi = sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE),
#' time_range = as.Date(c("2017-01-01","2017-01-30"))
#' ))
#'############################################################
#'
#' ### Download the data :
#'
#' res_dl <- download_data(opendap_urls_mod11a1)
#'
#' ### Open the data :
#' # When opening the data, do not forget to reset the CRS
#' # here, MODIS crs : https://spatialreference.org/ref/sr-org/modis-sinusoidal-3/proj4/
#' modis_crs <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
#'
#' ## open as a stars object (deals with multiple dimensions and time)
#'
#' require(stars)
#' require(magrittr)
#' (mod11a1_stars <- read_stars(res_dl$destfile) %>% st_set_crs(modis_crs))
#'
#' plot(mod11a1_stars)
#'
#' ## or open as a rasterBrick object (1 rasterBrick for each dimension)
#'
#' require(raster)
#' (mod11a1_rast_day <- brick(res_dl$destfile,varname="LST_Day_1km",crs=modis_crs))
#' (mod11a1_rast_night <- brick(res_dl$destfile,varname="LST_Night_1km",crs=modis_crs))
#'
#' plot(mod11a1_rast_day[[1]])
#' # Here the time dimension is set as the z dimension :
#' (getZ(mod11a1_rast_day))
#'}
#'
#' # Check out the vignettes for additional examples and more complex data import workflows
#'
#'


get_url<-function(collection,
                 variables=NULL,
                 roi,
                 time_range,
                 output_format="nc4",
                 single_netcdf=TRUE,
                 opt_param=NULL,
                 login_credentials=NULL,
                 verbose=FALSE){

  existing_variables <- odap_coll_info <- odap_timeDimName <- odap_lonDimName <- odap_latDimName  <- NULL

  ## tests :
  # collection
  if(verbose){cat("Checking if specified collection exist and is implemented in the package...\n")}
  .testIfCollExists(collection)
  # roi
  .testRoi(roi)
  # time_range_format
  .testTimeRange(time_range)
  # time_range_available_dates
  .testTimeRangeAvDates(time_range,collection)
  # output_format
  .testFormat(output_format)
  # single_netcdf
  if(!inherits(single_netcdf,"logical")){stop("single_netcdf argument must be boolean\n")}
  # verbose
  if(!inherits(verbose,"logical")){stop("verbose argument must be boolean\n")}
  # login_credentials
  .testLogin(login_credentials)

  if(is.null(opt_param)){
    if(verbose){cat("Retrieving opendap arguments for the collection specified...\n")}
    opt_param <- get_optional_parameters(collection,roi)
  }

  # test variables
  if(verbose){cat("Checking if specified variables exist for the collection specified...\n")}
  available_variables <- opt_param$availableVariables$name
  if(is.null(variables)){
    variables <- opt_param$availableVariables$name[which(opt_param$availableVariables$extractable_w_opendapr=="extractable")]
  }
  .testIfVarExists(variables,available_variables)

  # build URLs
  if(verbose){cat("Building the opendap URLs...\n")}
  table_urls <- .buildUrls(collection,variables,roi,time_range,output_format,single_netcdf,opt_param,login_credentials)

  table_urls <- table_urls %>%
    dplyr::mutate(name=stringr::str_replace(name,".*/","")) %>%
    dplyr::arrange(name) %>%
    transform(name = ifelse(duplicated(name) | duplicated(name, fromLast=TRUE),
                            paste(name, stats::ave(name, name, FUN=seq_along), sep='_'),
                            name)) %>%
    dplyr::mutate(destfile=paste0(file.path(collection,.$name),".",output_format)) %>%
    dplyr::arrange(date) %>%
    dplyr::select(date,name,url,destfile) %>%
    dplyr::rename(time_start = date)

  return(table_urls)

}
