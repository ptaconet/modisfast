#' @name .getTimeIndex_modisVnp
#' @title get MODIS/VIIRS time index closest to actual provided date
#' @noRd

.getTimeIndex_modisVnp <- function(date, timeVector) {
  date_julian <- as.integer(difftime(date, "2000-01-01", units = c("days")))
  index_opendap_closest_to_date <- which.min(abs(timeVector - date_julian))
  days_sep_from_date <- timeVector[index_opendap_closest_to_date] - date_julian
  if (days_sep_from_date <= 0) {
    index_opendap_closest_to_date <- index_opendap_closest_to_date - 1
  } else {
    index_opendap_closest_to_date <- index_opendap_closest_to_date - 2
  }

  date_closest_to_date <- as.Date("2000-01-01") + timeVector[index_opendap_closest_to_date + 1]
  days_sep_from_date <- -as.integer(difftime(date, date_closest_to_date, units = c("days")))

  return(list(date, date_closest_to_date, days_sep_from_date, index_opendap_closest_to_date))
}

#' @name .getOpenDapURL_dimensions
#' @title get opendap url dimensions
#'
#' @import purrr
#' @noRd

.getOpenDapURL_dimensions <- function(variables, timeIndex, minLat, maxLat, minLon, maxLon, odap_timeDimName, odap_lonDimName, odap_latDimName) {
  dim <- NULL

  if (!is.null(timeIndex)) {
    dim <- variables %>%
      purrr::map(~ paste0(.x, "[", timeIndex[1], ":", timeIndex[2], "][", minLat, ":", maxLat, "][", minLon, ":", maxLon, "]")) %>%
      unlist() %>%
      paste(collapse = ",") %>%
      paste0(",", odap_timeDimName, "[", timeIndex[1], ":", timeIndex[2], "],", odap_latDimName, "[", minLat, ":", maxLat, "],", odap_lonDimName, "[", minLon, ":", maxLon, "]")
  } else {
    dim <- variables %>%
      purrr::map(~ paste0(.x, "[", minLat, ":", maxLat, "][", minLon, ":", maxLon, "]")) %>%
      unlist() %>%
      paste(collapse = ",") %>%
      paste0(",", odap_latDimName, "[", minLat, ":", maxLat, "],", odap_lonDimName, "[", minLon, ":", maxLon, "]")
  }
  return(dim)
}


#' @name .getVarVector
#' @title get var vector
#' @import httr
#' @noRd

.getVarVector <- function(OpenDAPUrl, variableName, credentials = NULL) {
  vector_response <- vector <- NULL

  .testLogin(credentials)

  httr::set_config(httr::authenticate(user = getOption("earthdata_user"), password = getOption("earthdata_pass"), type = "basic"))
  httr::config(maxredirs = -1)
  vector_response <- httr::GET(paste0(OpenDAPUrl, ".ascii?", variableName), config = list(maxredirs = -1))

  vector_response <- httr::GET(vector_response$url)
  httr::stop_for_status(vector_response)
  httr::warn_for_status(vector_response)

  if (vector_response$status_code != 404) {
    vector <- httr::content(vector_response, "text", encoding = "UTF-8")
    vector <- strsplit(vector, ",")
    vector <- vector[[1]]
    vector <- stringr::str_replace(vector, "\\n", "")
    vector <- vector[-1]
    vector <- as.numeric(vector)

    return(vector)
  }
}

#' @name .getVNPladswebdataname
#' @title get VNPladsweb dataset name on the opendap server for a given modis tile
#' @noRd

.getVNPladswebdataname <- function(lines, modis_tile) {
  dataset_name <- . <- NULL

  # lines <- readLines(paste0(OpenDAPUrl,"catalog.xml"))
  dataset_name <- lines[which(grepl(modis_tile, lines))[1]] %>%
    gsub("\"", "", .) %>%
    gsub(".*name=\\s*", "", .)

  return(dataset_name)
}
