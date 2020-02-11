#' @name .testIfCollExists
#' @title Test if collection specified exists
#' @noRd
#'

.testIfCollExists<-function(collection){

  if(!inherits(collection,"character") || length(collection)!=1 ){stop("Argument collection must be a character string of length 1")}

  collection<-opendapMetadata_internal$collection[which(opendapMetadata_internal$collection==collection)]

  if(length(collection)==0){
    stop("The collection that you specified does not exist or is not implemented yet in opendapr. Check get_collections_available()$collection to see which collections are implemented\n")
  }

}


#' @name .testIfVarExists
#' @title Test if variables exists in specified collection
#' @noRd
#'

.testIfVarExists<-function(collection,specified_variables,login_credentials=NULL){

  variables <- NULL

  .testIfCollExists(collection)
  .testLogin(login_credentials)

  variables <- get_variables_info(collection,login_credentials)
  variables <- variables$name
  .testIfVarExists2(variables,specified_variables)

}

#' @name .testIfVarExists2
#' @title Test if variable exists given other variables
#' @noRd
#'

.testIfVarExists2<-function(specified_variables,existing_variables){

 diff_vars <- NULL
 diff_vars <- setdiff(specified_variables,existing_variables)
 if(length(diff_vars)>0){stop("Specified variables do not exist for the specified collection. Use the function get_variables_info to check which variables are available for the collection\n")}

}

#' @name .testLogin
#' @title Test login, else log
#' @noRd

.testLogin<-function(login_credentials=NULL){

  login <- NULL

  if(!is.null(login_credentials) || is.null(getOption("usgs_login"))){
    login <- login_usgs(login_credentials)
    return(login)
  }

}

#' @name .testRoi
#' @title Test roi
#' @noRd

.testRoi<-function(roi){
  if(!inherits(roi,c("sf","sfc")) || unique(sf::st_geometry_type(roi))!="POLYGON"){stop("Argument roi must be a object of class sf or sfc with only POLYGON-type geometries")}
}

#' @name .testTimeRange
#' @title Test time range
#' @noRd

.testTimeRange<-function(time_range){
  if(!inherits(time_range,"Date") && !inherits(time_range,"POSIXlt") || length(time_range)>2){stop("Argument time_range is not of class Date or POSIXlt or is not of length 1 or 2 \n")}
}

#' @name .testFormat
#' @title Test format
#' @noRd

.testFormat<-function(output_format){
  if(!(output_format %in% c("nc4","ascii","json"))){stop("Specified output format is not valid. Please specify a valid output format \n")}
}

