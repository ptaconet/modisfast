#' @name getUrl
#' @aliases getUrl
#' @title Get the URL of
#' @description
#'
#' @param collection string. Collection of interest.
#' @param variables  string vector. Variables to retrieve for the collection of interest
#' @param roi sf POINT or POLYGON. Region of interest
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
#'
#'
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

  existing_variables <- odap_coll_info <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- dim_proj$dim_proj <- NULL

  ## tests :
  # roi
  opendapr::.testRoi(roi)
  # timeRange
  opendapr::.testTimeRange(roi)
  # outputFormat
  if(!outputFormat %in% c("nc4","ascii")){stop("Specified output format is not valid. Please specify a valid output format \n")}
  # singleNetcdf
  if(!methods::is(singleNetcdf,"logical")){stop("singleNetcdf argument must be boolean\n")}
  # verbose
  if(!methods::is(verbose,"logical")){stop("verbose argument must be boolean\n")}
  # collection
  if(verbose){cat("Checking if specified collection exist and is implemented in the package...\n")}
  opendapr::.testIfCollExists(collection)
  # loginCredentials
  opendapr::.testLogin(loginCredentials)

  ## Retrieve opendap information for the collection of interest
  #odap_coll_info <- opendapr:::opendapMetadata_internal[which(opendapr:::opendapMetadata_internal$collection==collection),]
  ##source <- opendap_coll_info$source
  #odap_server <- odap_coll_info$url_opendapserver
  #odap_timeDimName <- odap_coll_info$time
  #odap_lonDimName <- odap_coll_info$dim_lon
  #odap_latDimName <- odap_coll_info$dim_lat
  #odap_gridDimName <- odap_coll_info$dim_proj


  if(is.null(optionalsOpendap)){
    optionalsOpendap <- opendapr::.getOdapOptArguments(collection,roi)
  }

  available_variables <- optionals_opendap$availableVariables

  # test variables
  if(verbose){cat("Checking if specified variables exist for the collection specified...\n")}
  opendapr::.testIfVarExists2(variables,available_variables)

  # build URLs
  if(verbose){cat("Building the opendap URLs...\n")}
  urls <- opendapr::.buildUrls(collection,roi,timeRange,optionals_opendap,singleNetcdf=singleNetcdf)










}
