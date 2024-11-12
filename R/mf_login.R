#' @name mf_login
#' @title Login to EOSDIS EarthData account
#' @description Login to EOSDIS EarthData before querying servers and download data
#'
#' @inheritParams mf_get_url
#'
#' @import httr
#' @importFrom cli cli_alert_success
#'
#' @return None.
#' @export
#'
#' @details
#'
#' An EOSDIS EarthData account is mandatory to download the data. You can create a free account here : \url{https://urs.earthdata.nasa.gov/}.
#'
#' @examples
#' \dontrun{
#' username <- "earthdata_un"
#' password <- "earthdata_pw"
#' mf_login(credentials = c(username, password))
#' }
#'
mf_login <- function(credentials, verbose = "inform") {
  if (!inherits(credentials, "character") || length(credentials) != 2) {
    stop("credentials must be a vector character string of length 2 (username and password)\n")
  }
  .testInternetConnection()
  if (verbose %in% c("inform","debug")) {
    cat("Checking credentials...\n")
  }

  x <- httr::GET(url = "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.061/h17v07.ncml.ascii?time") # testing credentials must be improved...

  f <- function() {
    httr::GET(x$url, httr::authenticate(credentials[1], credentials[2]), config = list(maxredirs = -1))
  }
  if(verbose %in% c("quiet","inform")){
    x <- f()
  } else if (verbose == "debug"){
    x <- httr::with_verbose(f())
  }
  httr::stop_for_status(x, "login to Earthdata. Wrong username / password, or service / servers unavailable")
  httr::warn_for_status(x)
  options(earthdata_user = credentials[1])
  options(earthdata_pass = credentials[2])
  options(earthdata_mf_login = TRUE)

  if (verbose %in% c("inform","debug")) {
    cli::cli_alert_success("Successfull login to Earthdata\n")
  }
}
