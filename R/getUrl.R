#' @name getUrl
#' @aliases getUrl
#' @title Get the URL of
#' @description
#'
#' @param collection string. Collection of interest.
#' @param variables string vector. Variables to retrieve for the collection of interest
#' @param roi object of class \code{sf} or \code{sfc}. Region of interest
#' @param timeRange date(s) / POSIXlt of interest (single date/datetime or time frame) (see details)
#' @param outputFormat string. Output format. Available choices : "nc4" (default), "ascii", "",
#' @param singleNetcdf boolean. Get the URL either as a single netcdf file that encompasses the whole time frame (TRUE) or as multiple files (1 for each date) (FALSE). Default to TRUE
#' @param optionalsOpendap list of optional arguments (see details)
#' @param loginCredentials vector string. In case of data that needs login : string vector of length 2 with username and password
#' @param verbose boolean. Verbose (default FALSE)
#'
#' @return a data.frame with one row for each dataset and 3 columns  :
#'  \itemize{
#'  \item{*time_start*: }{Start Date/time for the dataset}
#'  \item{*name*: }{An indicative name for the dataset}
#'  \item{*url*: }{URL of the dataset}
#'  \item{*destfile*: }{An indicative destination file for the dataset}
#'  }
#'
#' @details
#'
#'
#' @note
#'
#' @export
#'
#' @examples
#'
#' @importFrom stringr str_replace
#' @import dplyr
#'
#'


getUrl<-function(collection,
                 variables,
                 roi,
                 timeRange,
                 outputFormat="nc4",
                 singleNetcdf=TRUE,
                 optionalsOpendap=NULL,
                 loginCredentials=NULL,
                 verbose=FALSE){

  existing_variables <- odap_coll_info <- odap_timeDimName <- odap_lonDimName <- odap_latDimName  <- NULL

  ## tests :
  # roi
  .testRoi(roi)
  # timeRange
  .testTimeRange(timeRange)
  # outputFormat
  if(!outputFormat %in% c("nc4","ascii")){stop("Specified output format is not valid. Please specify a valid output format \n")}
  # singleNetcdf
  if(!inherits(singleNetcdf,"logical")){stop("singleNetcdf argument must be boolean\n")}
  # verbose
  if(!inherits(verbose,"logical")){stop("verbose argument must be boolean\n")}
  # collection
  if(verbose){cat("Checking if specified collection exist and is implemented in the package...\n")}
  .testIfCollExists(collection)
  # loginCredentials
  .testLogin(loginCredentials)

  if(is.null(optionalsOpendap)){
    if(verbose){cat("Retrieving opendap arguments for the collection specified...\n")}
    optionalsOpendap <- getOdapOptParam2(collection,roi)
  }

  # test variables
  if(verbose){cat("Checking if specified variables exist for the collection specified...\n")}
  available_variables <- optionalsOpendap$availableVariables
  .testIfVarExists2(variables,available_variables)

  # build URLs
  if(verbose){cat("Building the opendap URLs...\n")}
  table_urls <- .buildUrls2(collection,variables,roi,timeRange,outputFormat,singleNetcdf,optionalsOpendap,loginCredentials)

  table_urls <- table_urls %>%
    dplyr::mutate(name=stringr::str_replace(name,".*/","")) %>%
    dplyr::arrange(name) %>%
    transform(name = ifelse(duplicated(name) | duplicated(name, fromLast=TRUE),
                            paste(name, ave(name, name, FUN=seq_along), sep='_'),
                            name)) %>%
    dplyr::mutate(destfile=paste0(file.path(collection,.$name),".",outputFormat)) %>%
    dplyr::arrange(date) %>%
    dplyr::select(date,name,url,destfile) %>%
    dplyr::rename(time_start = date)

  return(table_urls)

}
