
#' @name .testIfCollExists
#' @title Test if collection specified exists
#' @export
#' @noRd
#'

.testIfCollExists<-function(collection){

  if(!inherits(collection,"character") || length(collection)!=1 ){stop("Argument collection must be a character string of length 1")}

  collection<-opendapMetadata_internal$collection[which(opendapMetadata_internal$collection==collection)]

  if(length(collection)==0){
    stop("The collection that you specified does not exist or is not implemented yet in opendapr. Check opendapMetadata$collection to see which collections are implemented\n")
  }

}


#' @name .testIfVarExists
#' @title Test if variables exists in specified collection
#' @export
#' @noRd
#'

.testIfVarExists<-function(collection,specified_variables,loginCredentials=NULL){

  variables <- NULL

  .testIfCollExists(collection)
  .testLogin(loginCredentials)

  variables <- getVariablesInfo(collection,loginCredentials)
  variables <- variables$name
  .testIfVarExists2(variables,specified_variables)

}

#' @name .testIfVarExists2
#' @title Test if variable exists given other variables
#' @export
#' @noRd
#'

.testIfVarExists2<-function(specified_variables,existing_variables){

 diff_vars <- NULL
 diff_vars <- setdiff(specified_variables,existing_variables)
 if(length(diff_vars)>0){stop("Specified variables do not exist for the specified collection. Use the function getVariablesInfo to check which variables are available for the collection\n")}

}

#' @name .testLogin
#' @title Test login, else log
#' @export
#' @noRd

.testLogin<-function(loginCredentials=NULL){

  login <- NULL

  if(!is.null(loginCredentials) || is.null(getOption("earthdata_login"))){
    login <- login_earthdata(loginCredentials)
    return(login)
  }

}

#' @name .testRoi
#' @title Test roi
#' @export
#' @noRd

.testRoi<-function(roi){
  if(!inherits(roi,c("sf","sfc"))){stop("Argument roi must be of class sf or sfc")}
}

#' @name .testTimeRange
#' @title Test time range
#' @export
#' @noRd

.testTimeRange<-function(timeRange){
  if(!inherits(timeRange,"Date") && !inherits(timeRange,"POSIXlt") || length(timeRange)>2){stop("Argument timeRange is not of class Date or POSIXlt or is not of length 1 or 2 \n")}
}
