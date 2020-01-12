#' @name login_earthdata
#' @title Login to earthdata
#'
#' @param loginCredentials vector string of length 2 with username and password
#'
#' @return Invisible object with login to earthdata. Login will no longer be needed for the current sessions.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' earthdata_username="user"
#' earthdata_password="pass"
#' login<-login_earthdata(c(earthdata_username,earthdata_password))
#' }
#'

login_earthdata<-function(loginCredentials){

  x <- httr::POST(url = 'https://earthexplorer.usgs.gov/inventory/json/v/1.4.0/login',
                  body = utils::URLencode(paste0('jsonRequest={"username":"', loginCredentials[1], '","password":"', loginCredentials[2], '","authType":"EROS","catalogId":"EE"}')),
                  httr::content_type("application/x-www-form-urlencoded; charset=UTF-8"))
  httr::stop_for_status(x, "connect to server.")
  httr::warn_for_status(x)
  v <- httr::content(x)$data
  if(is.null(v)){
    stop("Login to EarthData failed. Check out username and password")
  } else {
    options(earthdata_user=loginCredentials[1])
    options(earthdata_pass=loginCredentials[2])
    options(earthdata_login=TRUE)
    cat("\nSuccessfull login to EarthData")
  }
}

