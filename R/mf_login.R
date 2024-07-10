#' @name mf_login
#' @title Login to EOSDIS EarthData account
#' @description Login to EOSDIS EarthData before querying servers and download data
#'
#' @inheritParams mf_get_url
#'
#' @return None.
#' @export
#'
#' @details
#'
#' An EOSDIS EarthDataaccount is mandatory to download the data. You can create a free account here : \url{https://urs.earthdata.nasa.gov/}.
#'
#' @examples
#'
#' \dontrun{
#' username <- "earthdata_un"
#' password <- "earthdata_pw"
#' mf_login(credentials = c(username,password))
#' }
#'

mf_login<-function(credentials,verbose=TRUE){

  if(!inherits(credentials,"character") || length(credentials)!=2 ) {stop("credentials must be a vector character string of length 2 (username and password)\n")}
  .testInternetConnection()
  if(verbose){cat("Checking credentials...\n")}

  #if(source=="earthdata"){
   #x <- httr::GET(url = "https://urs.earthdata.nasa.gov/oauth/authorize?app_type=401&client_id=W8DRh2DCZP0iOacUCdwB1g&response_type=code&redirect_uri=https%3A%2F%2Fopendap.cr.usgs.gov%2Fopendap%2Fhyrax%2Foauth2&state=aHR0cHM6Ly9vcGVuZGFwLmNyLnVzZ3MuZ292L29wZW5kYXAvaHlyYXgvTU9EMTFBMi4wNjEvaDE3djA3Lm5jbWwuYXNjaWk%2FdGltZQ",httr::authenticate(user=credentials[1], credentials[2]),config = list(maxredirs=-1)) # testing credentials must be improved...
   x <- httr::GET(url = "https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.061/h17v07.ncml.ascii?time") # testing credentials must be improved...
   x <- httr::GET(x$url,httr::authenticate(credentials[1], credentials[2]),config = list(maxredirs=-1))
   httr::stop_for_status(x, "login to Earthdata. Check out username and password. The service might also be unavailable (error 503).")
   httr::warn_for_status(x)
   options(earthdata_user=credentials[1])
   options(earthdata_pass=credentials[2])
   options(earthdata_mf_login=TRUE)
  #}
  #if(verbose){cat("Successfull login to",source,"\n")}
  if(verbose){cat("Successfull login to Earthdata\n")}

}

