#' @name login_usgs
#' @title Login to USGS EROS ERS
#' @description Login to USGS EROS Registration System (ERS) with usual credentials
#'
#' @inheritParams get_url
#'
#' @return None.
#' @export
#'
#' @details Register on \url{https://ers.cr.usgs.gov/register/}.
#'
#' @note
#' The function is inspired from : https://github.com/16EAGLE/getSpatialData/blob/master/R/gSD_login.R
#'
#' @importFrom curl has_internet
#'
#' @examples
#'
#' \dontrun{
#' username="user"
#' password="pass"
#' login_usgs(c(username,password))
#' }
#'

login_usgs<-function(login_credentials){

  if(!inherits(login_credentials,"character") || length(login_credentials)!=2 ) {stop("login_credentials must be a vector character string of length 2 (username and password)\n")}
  if(!curl::has_internet()){stop("Internet connection is required. Are you connected to the Internet ?\n")}

  x <- httr::POST(url = 'https://earthexplorer.usgs.gov/inventory/json/v/1.4.0/login',
                  body = utils::URLencode(paste0('jsonRequest={"username":"', login_credentials[1], '","password":"', login_credentials[2], '","authType":"EROS","catalogId":"EE"}')),
                  httr::content_type("application/x-www-form-urlencoded; charset=UTF-8"))
  httr::stop_for_status(x, "connect to server.")
  httr::warn_for_status(x)
  v <- httr::content(x)$data
  if(is.null(v)){
    stop("Login to USGS failed. Check out username and password\n")
  } else {
    options(usgs_user=login_credentials[1])
    options(usgs_pass=login_credentials[2])
    options(usgs_login=TRUE)
    cat("Successfull login to USGS\n")
  }
}

