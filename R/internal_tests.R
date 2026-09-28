#' @name .testIfCollExists
#' @title Test if collection specified exists
#' @noRd
#'

.testIfCollExists <- function(collection) {
  if (!is.character(collection) || length(collection) != 1L ||
      is.na(collection) || !nzchar(collection)) {
    stop("collection must be one non-empty collection name. Run ",
         "mf_list_collections_cloud() for MODIS/VIIRS or ",
         "mf_list_collections() for GPM.")
  }

  if (nrow(.mf_collection_metadata(collection)) == 0L) {
    stop("Collection '", collection, "' is not available. Run ",
         "mf_list_collections_cloud() for MODIS/VIIRS or ",
         "mf_list_collections() for GPM.")
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

.mf_earthdata_auth <- function() {
  token <- Sys.getenv("EARTHDATA_TOKEN", unset = "")
  if (!nzchar(token)) {
    stop("Set EARTHDATA_TOKEN to an Earthdata bearer token.")
  }
  httr::add_headers(Authorization = paste("Bearer", token))
}

.mf_require_token <- function(function_name) {
  if (!nzchar(trimws(Sys.getenv("EARTHDATA_TOKEN", unset = "")))) {
    stop("Set EARTHDATA_TOKEN to an Earthdata bearer token before using ",
         function_name, "().")
  }
  invisible(TRUE)
}

.mf_unknown_collection <- function(collection) {
  label <- if (length(collection) == 1L && !is.na(collection)) {
    as.character(collection)
  } else {
    "<invalid name>"
  }
  stop("Collection '", label, "' is not available in modisfast. ",
       "Run mf_list_collections_cloud() for supported MODIS/VIIRS collections ",
       "or mf_list_collections() for GPM collections.")
}

.mf_check_verbose <- function(verbose) {
  if (!is.character(verbose) || length(verbose) != 1L ||
      is.na(verbose) || !verbose %in% c("quiet", "inform", "debug")) {
    stop("verbose must be one of 'quiet', 'inform', or 'debug'.")
  }
  invisible(verbose)
}

#' @name .testRoi
#' @title Test roi
#' @noRd

.testRoi <- function(roi) {
  if (!inherits(roi, "sf") || !nrow(roi)) {
    stop("roi must be a non-empty sf object containing polygon features ",
         "and an id column.")
  }
  types <- as.character(sf::st_geometry_type(roi))
  empty <- sf::st_is_empty(roi)
  if (anyNA(types) || anyNA(empty) || !all(types == "POLYGON") ||
      any(empty)) {
    stop("roi must contain non-empty POLYGON geometries.")
  }
  if (!("id" %in% names(roi)) || anyNA(roi$id) ||
      any(!nzchar(as.character(roi$id)))) {
    stop("roi must contain an id column with a value for each polygon.")
  }
  if (is.na(sf::st_crs(roi))) {
    stop("roi must have a coordinate reference system (CRS).")
  }
}

#' @name .testTimeRange
#' @title Test time range
#' @noRd

.testTimeRange <- function(time_range) {
  if (!(inherits(time_range, "Date") || inherits(time_range, "POSIXt")) ||
      !length(time_range) %in% 1:2 || anyNA(time_range)) {
    stop("time_range must be one Date or two ordered Dates (or POSIXct/POSIXlt ",
         "date-times for GPM); for example, as.Date(c('2026-01-01', ",
         "'2026-01-30')).")
  }
  if (length(time_range) == 2L && time_range[1] > time_range[2]) {
    stop("time_range must have its start date before its end date.")
  }
  invisible(TRUE)
}

#' @name .testTimeRangeAvDates
#' @title Test that time range provided is ok with the collection
#' @noRd

.testTimeRangeAvDates <- function(time_range, collection) {
  metadata <- .mf_collection_metadata(collection)
  start_date <- metadata$start_date
  if (time_range[1] < as.Date(start_date)) {
    stop("Time start in time_range argument is out of the temporal extent of the collection. Please modify time start.\n")
  }
  end_date <- metadata$end_date
  if(end_date != "ongoing"){
    if (length(time_range) == 2 && (time_range[2] > as.Date(end_date) | time_range[2] > Sys.Date())) {
     stop("Time end in time_range argument is out of the temporal extent of the collection. Please modify time end.\n")
    }
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
