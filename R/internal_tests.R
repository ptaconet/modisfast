#' @name .testIfCollExists
#' @title Test if collection specified exists
#' @noRd
#'

.testIfCollExists <- function(collection) {
  if (!inherits(collection, "character") || length(collection) != 1) {
    stop("Argument collection must be a character string of length 1")
  }

  collection <- opendapMetadata_internal$collection[which(opendapMetadata_internal$collection == collection)]

  if (length(collection) == 0) {
    stop("The collection that you specified does not exist. Check mf_list_collections() to see which collections are implemented\n")
  }
}

#' @name .testIfVarExists
#' @title Test if variable exists given other variables
#' @noRd
#'

.testIfVarExists <- function(specified_variables, existing_variables) {
  diff_vars <- NULL
  diff_vars <- setdiff(specified_variables, existing_variables)
  if (length(diff_vars) > 0) {
    stop("Specified variables do not exist or are not extractable for the specified collection. Use the function mf_list_variables to check which variables are available and extractable for the collection\n")
  }
}

# .testIfVarExists2<-function(collection,specified_variables,credentials=NULL){
#  variables <- NULL
#  .testIfCollExists(collection)
#  .testLogin(credentials)
#  variables <- mf_list_variables(collection,credentials)
#  variables <- variables$name
#  .testIfVarExists2(variables,specified_variables)
# }

#' @name .testLogin
#' @title Test login, else log
#' @noRd

.testLogin <- function(credentials = NULL) {
  mf_login <- NULL

  if (!is.null(credentials) || is.null(getOption("earthdata_mf_login"))) {
    mf_login <- mf_login(credentials)
    return(mf_login)
  }
}

#' @name .testRoi
#' @title Test roi
#' @noRd

.testRoi <- function(roi) {
  # if(!inherits(roi,"sf") || as.character(unique(sf::st_geometry_type(roi)))!="POLYGON" || !("id" %in% colnames(roi)) || !("geom" %in% colnames(roi)) || length(which(is.na(roi$id))) || length(which(is.na(roi$geom)))){stop("Argument roi must be an object of class sf or sfc with POLYGON-type feature geometry and at least two columns : 'id' and 'geom' that must not be NULL or NA")}
  if (!inherits(roi, "sf") || as.character(unique(sf::st_geometry_type(roi))) != "POLYGON" || !("id" %in% colnames(roi)) || length(which(is.na(roi$id)))) {
    stop("Argument roi must be an object of class sf or sfc with POLYGON-type feature geometry and at least two columns : 'id' and a geometry column that must not be NULL or NA")
  }
}

#' @name .testTimeRange
#' @title Test time range
#' @noRd

.testTimeRange <- function(time_range) {
  if (!inherits(time_range, "Date") && !inherits(time_range, "POSIXlt") || length(time_range) > 2 || is.na(time_range[1]) || is.na(time_range[2])) {
    stop("Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n")
  }
  if (length(time_range) == 2 && time_range[1] > time_range[2]) {
    stop("Time end is superior to time start in time_range argument \n")
  }
}

#' @name .testTimeRangeAvDates
#' @title Test that time range provided is ok with the collection
#' @noRd

.testTimeRangeAvDates <- function(time_range, collection) {
  start_date <- opendapMetadata_internal$start_date[which(opendapMetadata_internal$collection == collection)]
  if (time_range[1] < as.Date(start_date)) {
    stop("First time frame in time_range argument is before the beginning of the mission\n")
  }
}

#' @name .testFormat
#' @title Test format
#' @noRd

.testFormat <- function(output_format) {
  if (!(output_format %in% c("nc4", "ascii", "json"))) {
    stop("Specified output format is not valid. Please specify a valid output format \n")
  }
}

#' @name .testInternetConnection
#' @title Test internet connection
#' @importFrom curl has_internet
#' @noRd

.testInternetConnection <- function() {
  if (!curl::has_internet()) {
    stop("Internet connection is required. Are you connected to the Internet ?\n")
  }
}
