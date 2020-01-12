

#' @name .testIfCollExists
#' @title Test if collection specified exists
#'
#' @export
#' @noRd
#'

.testIfCollExists<-function(collection){

  collection<-opendapr:::opendapMetadata_internal$collection[which(opendapr:::opendapMetadata_internal$collection==collection)]

  if(length(collection)==0){
    stop("The collection that you specified does not exist or is not implemented yet in opendapr. Check opendapr:::opendapMetadata_internal$collection to see which collections are implemented\n")
  }

}

#' @name .testLogin
#' @title Test login, else log
#'
#' @export
#' @noRd

.testLogin<-function(loginCredentials){

  if(!is.null(loginCredentials) || is.null(getOption("earthdata_login"))){
    login<-opendapr::login_earthdata(loginCredentials[1],loginCredentials[2])
    return(login)
  }

}
