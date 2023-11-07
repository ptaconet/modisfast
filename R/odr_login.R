#' @name odr_login
#' @title Login to query servers and download data
#' @description Login before querying data servers
#'
#' @inheritParams odr_get_url
#' @param source source. See details
#'
#' @return None.
#' @export
#'
#' @details
#'
#' Current options for parameter \code{"source"} are :
#' \itemize{
#' \item{"earthdata"}{ : to query and download MODIS, VNP, SMAP, GPM collections}
#'}
#' Create an account to Earthdata here : \url{https://urs.earthdata.nasa.gov/}.
#'
#' @examples
#' # odr_login to Earthdata
#' \donttest{
#' username <- Sys.getenv("earthdata_un")
#' password <- Sys.getenv("earthdata_pw")
#' odr_login(credentials = c(username,password),source = "earthdata")
#' }
#'

odr_login<-function(credentials,source,verbose=TRUE){

  if(!inherits(credentials,"character") || length(credentials)!=2 ) {stop("credentials must be a vector character string of length 2 (username and password)\n")}
  .testInternetConnection()
  if(verbose){cat("Checking credentials...\n")}

  if(source=="earthdata"){
   x <- httr::GET(url = "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11_L2.061/MOD11_L2.061.ncml.ascii?time",httr::authenticate(user=credentials[1], credentials[2]),config = list(maxredirs=-1)) # testing credentials must be improved...
   httr::stop_for_status(x, "login to Earthdata. Check out username and password")
   httr::warn_for_status(x)
   options(earthdata_user=credentials[1])
   options(earthdata_pass=credentials[2])
   options(earthdata_odr_login=TRUE)
  }
  if(verbose){cat("Successfull login to",source,"\n")}

}

