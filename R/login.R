#' @name login
#' @title Login to download data
#' @description In case a login is required, login before querying data servers
#'
#' @inheritParams get_url
#' @param source source. Currently available: Earthdata for EOSDIS Earthdata Login with usual credentials
#'
#' @return None.
#' @export
#'
#' @details
#'
#' Earthdata login enables to download MODIS, VNP, SMAP, GPM data.
#'
#' Create an account to Earthdata here : \url{https://urs.earthdata.nasa.gov/}.
#'
#' @examples
#'
#' \donttest{
#' username <- Sys.getenv("earthdata_un")
#' password <- Sys.getenv("earthdata_pw")
#' login(credentials = c(username,password),source = "earthdata")
#' }
#'

login<-function(credentials,source,verbose=TRUE){

  if(!inherits(credentials,"character") || length(credentials)!=2 ) {stop("credentials must be a vector character string of length 2 (username and password)\n")}
  .testInternetConnection()
  if(verbose){cat("Checking credentials...\n")}

  if(source=="earthdata"){
   x <- httr::GET(url = "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.006/h17v07.ncml.ascii?time",httr::authenticate(user=credentials[1], credentials[2]),config = list(maxredirs=-1)) # testing credentials must be improved...
   httr::stop_for_status(x, "login to Earthdata. Check out username and password")
   httr::warn_for_status(x)
   options(earthdata_user=credentials[1])
   options(earthdata_pass=credentials[2])
   options(earthdata_login=TRUE)
  }
  if(verbose){cat("Successfull login to ",source,"\n")}

}

