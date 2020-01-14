#' @name login_earthdata
#' @title Login to Earthdata
#' @description Login to Earthdata with usual credentials
#'
#' @inheritParams getUrl
#'
#' @return Invisible object with login to earthdata. Login will no longer be needed for the current session.
#' @export
#'
#' @details To open an Earthdata account go to : https://urs.earthdata.nasa.gov/profile
#' @importFrom curl has_internet
#'
#' @examples
#'
#' \dontrun{
#' earthdata_username="user"
#' earthdata_password="pass"
#' login_earthdata(c(earthdata_username,earthdata_password))
#' }
#'

login_earthdata<-function(loginCredentials){

  if(!inherits(loginCredentials,"character") || length(loginCredentials)!=2 ) {stop("loginCredentials must be a vector character string of length 2 (username and password)\n")}
  if(!curl::has_internet()){stop("Internet connection is required. Are you connected to the Internet ?\n")}

  x <- httr::POST(url = 'https://earthexplorer.usgs.gov/inventory/json/v/1.4.0/login',
                  body = utils::URLencode(paste0('jsonRequest={"username":"', loginCredentials[1], '","password":"', loginCredentials[2], '","authType":"EROS","catalogId":"EE"}')),
                  httr::content_type("application/x-www-form-urlencoded; charset=UTF-8"))
  httr::stop_for_status(x, "connect to server.")
  httr::warn_for_status(x)
  v <- httr::content(x)$data
  if(is.null(v)){
    stop("Login to EarthData failed. Check out username and password\n")
  } else {
    options(earthdata_user=loginCredentials[1])
    options(earthdata_pass=loginCredentials[2])
    options(earthdata_login=TRUE)
    cat("Successfull login to EarthData\n")
  }
}

