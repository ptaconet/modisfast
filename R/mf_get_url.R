#' @name mf_get_url
#' @aliases mf_get_url
#' @title Build the URL(s) of the data to download
#' @description Builds the OPeNDAP URL(s) of the spatiotemporal datacube to download, given a collection, variables, region and time range of interest.
#'
#' @param collection string. mandatory. Collection of interest (see details of \link{mf_get_url}).
#' @param variables string vector. optional. Variables to retrieve for the collection of interest. If not specified (default) all available variables will be extracted (see details of \link{mf_get_url}).
#' @param roi object of class \code{sf}. mandatory. Area of region of interest. Must be a Simple feature collection with geometry type POLYGON, composed of one or several rows (i.e. one or several ROIs), and with at least two columns: 'id' (an identifier for the roi) and 'geom' (the geometry).
#' @param time_range date(s) / POSIXlt of interest . mandatory. Single date/datetime or time frame : vector with start and end dates/times (see details).
#' @param output_format string. Output data format. optional. Available options are : "nc4" (default), "ascii", "json"
#' @param single_netcdf boolean. optional. Get the URL either as a single file that encompasses the whole time frame (TRUE) or as multiple files (1 for each date) (FALSE). Default to TRUE. Currently enabled only for MODIS and VIIRS collections.
#' @param opt_param list of optional arguments. optional. (see details).
#' @param credentials vector string of length 2 with username and password. optional if the function \link{mf_login} was previously executed.
#' @param verbose boolean. optional. Verbose (default TRUE)
#'
#' @return a data.frame with one row for each dataset to download and 5 columns :
#'  \describe{
#'  \item{id_roi}{Identifier of the ROI}
#'  \item{time_start}{Start Date/time for the dataset}
#'  \item{collection}{Name of the collection}
#'  \item{name}{Indicative name for the dataset}
#'  \item{url}{https OPeNDAP URL of the dataset}
#'  }
#'
#' @details
#'
#' Argument \code{collection} : Collections available can be retrieved with the function \link{mf_list_collections}
#'
#' Argument \code{variables} : For each collection, variables available can be retrieved with the function \link{mf_list_variables}
#'
#' Argument \code{time_range} : Can be provided either as i) a single date (e.g. \code{as.Date("2017-01-01"))} or ii) a time frame provided as two bounding dates (starting and ending time) ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))}) or iii) a POSIXlt single time (e.g. \code{as.POSIXlt("2010-01-01 18:00:00")}) or iv) a POSIXlt time range (e.g. \code{as.POSIXlt(c("2010-01-01 18:00:00","2010-01-02 09:00:00"))}) for the half-hourly collection (GPM_3IMERGHH.06). If POSIXlt, times must be in UTC.
#'
#' Argument \code{single_netcdf} : for MODIS and VIIRS products from LP DAAC: download the data as a single file encompassing the whole time frame (TRUE) or as multiple files : one for each date, which is the behavious for the other collections - GPM and SMAP) (FALSE) ?
#'
#' Argument \code{opt_param} : list of parameters related to the queried OPeNDAP server and the roi. See \link{mf_get_opt_param} for additional details. This list can be retrieved outside the function with the function \link{mf_get_opt_param}. If not provided, it will be automatically calculated within the \link{mf_get_url} function. However, providing it fastens the processing time.
#' It might be particularly useful to precompute it with \link{mf_get_opt_param} in case the function is used within a loop for a single ROI.
#'
#' Argument \code{credentials} : Login to the OPeNDAP servers is required to use the function. Login can be done either within the function or outside with the function \link{mf_login}
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
#'
#' ### First login to EOSDIS Earthdata with username and password.
#' # To create an account go to : https://urs.earthdata.nasa.gov/.
#' username <- "earthdata_un"
#' password <- "earthdata_pw"
#' log <- mf_login(credentials = c(username,password))
#'
#' ### Get the URLs to download the following datasets :
#' # MODIS Terra LST Daily (MOD11A1.061) (collection)
#' # Day + Night bands (LST_Day_1km,LST_Night_1km) (variables)
#' # over a 50km x 70km region of interest (roi)
#' # for the time frame 2017-01-01 to 2017-01-30 (30 days) (time_range)
#'
#' roi <- sf::st_as_sf(data.frame(
#' id = "roi_test",
#' geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),
#' wkt="geom",crs = 4326)
#'
#' time_range = as.Date(c("2017-01-01","2017-01-30"))
#'
#' (urls_mod11a1 <- mf_get_url(
#' collection = "MOD11A1.061",
#' variables = c("LST_Day_1km","LST_Night_1km"),
#' roi = roi,
#' time_range = time_range
#' ))
#'
#' ## Download the data :
#'
#' res_dl <- mf_download_data(urls_mod11a1)
#'
#' ## Import as terra::SpatRast
#'
#' modis_ts <- mf_import_data(dirname(res_dl$destfile[1]), collection = "MOD11A1.061")
#'
#' ## Plot the data
#'
#' terra::plot(modis_ts)
#'}


mf_get_url<-function(collection,
                 variables=NULL,
                 roi,
                 time_range,
                 output_format="nc4",
                 single_netcdf=TRUE,
                 opt_param=NULL,
                 credentials=NULL,
                 verbose=TRUE){

  existing_variables <- odap_coll_info <- odap_timeDimName <- odap_lonDimName <- odap_latDimName  <- . <- name <- destfile <- roi_id <- NULL

  ## tests :
  # collection
  #if(verbose){cat("Checking if specified collection exist and is implemented in the package...\n")}
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
  # Internet connection
  .testInternetConnection()
  # credentials
  .testLogin(credentials)

  if(verbose){cat("Building the URLs...\n")}

  if(is.null(opt_param)){
    #if(verbose){cat("Retrieving opendap arguments for the collection specified...\n")}
    opt_param <- mf_get_opt_param(collection,roi,verbose=verbose)
  }

  if(length(opt_param$roiSpatialIndexBound)==0){stop("Your ROI does not cover a region where there is any data. Please provide a correct ROI.")}

  # test variables
  #if(verbose){cat("Checking if specified variables exist for the collection specified...\n")}
  available_variables <- opt_param$availableVariables$name[which(opt_param$availableVariables$extractable_w_opendapr=="extractable")]
  if(is.null(variables)){
    variables <- available_variables
  } else {
    .testIfVarExists(variables,available_variables)
  }

  # build URLs
  table_urls <- .buildUrls(collection,variables,roi,time_range,output_format,single_netcdf,opt_param,credentials,verbose)

  table_urls <- table_urls %>%
    dplyr::mutate(name=stringr::str_replace(name,".*/","")) %>%
    dplyr::mutate(url=gsub("\\[","%5B",url)) %>%
    dplyr::mutate(url=gsub("\\]","%5D",url)) %>%
    dplyr::arrange(name) %>%
    # transform(name = ifelse(duplicated(name) | duplicated(name, fromLast=TRUE),
    #                         paste0(roi_id,"_",name), #paste(name, stats::ave(name, name, FUN=seq_along), sep='_'),
    #                         name)) %>%
    dplyr::mutate(name=paste0(name,".",output_format)) %>%
    dplyr::arrange(roi_id,date) %>%
    dplyr::mutate(collection=collection) %>%
    dplyr::select(roi_id,date,collection,name,url) %>%
    dplyr::rename(time_start = date,id_roi = roi_id)

  if(verbose){cat("OK\n")}

  return(table_urls)

}
