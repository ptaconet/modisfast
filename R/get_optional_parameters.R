#' @name get_optional_parameters
#' @aliases get_optional_parameters
#'
#' @title Precompute the parameter \code{opt_param} of the function \link{get_url}
#' @description  Precompute the parameter \code{opt_param} to further provide as input of the \link{get_url} function. Useful to speed-up the overall processing time.
#'
#' @inheritParams get_url
#'
#' @return a list with the following named objects :
#' \itemize{
#'  \item{*roiSpatialIndexBound*: }{OPeNDAP indices for the spatial coordinates of the bounding box of the ROI (minLat, maxLat, minLon, maxLon)}
#'  \item{*availableVariables*: }{Variables available for the collection of interest}
#'  \item{*roiSpatialBound*: }{}
#'  \item{*roiSpatialBound*: }{The spatial coordinates of the bounding box of the ROI expressed in the CRS of the collection}
#'  \item{*OpenDAPXVector*: }{The X (longitude) vector}
#'  \item{*OpenDAPYVector*: }{The Y (longitude) vector}
#'  \item{*OpenDAPtimeVector*: }{The time vector, or NULL if the collection does not have a time vector}
#'  \item{*modis_tile*: }{The MODIS tile(s) number(s) for the ROI or NULL if the collection is not MODIS}
#' }
#'
#' @details
#'
#' When it is needed to loop the function \link{get_url} over several time frames, it is advised to previously run the function \code{get_optional_parameters} and provide the output as input \code{opt_param} parameter of the \link{get_url} function.
#' This will save much time, as internal parameters will be calculated only once.
#'
#' @export
#'
#' @examples
#'
#' \donttest{
#' require(sf)
#'
#' # Login to Earthdata
#' log <- login(c(Sys.getenv("earthdata_un"),Sys.getenv("earthdata_pw")))
#'
#' # Get the optional parameters for the collection MOD11A1.006 and the roi :
#' roi <- sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
#' (opt_param_mod11a1 <- get_optional_parameters("MOD11A1.006",roi) )
#'
#' # Now we can
#'
#'}


get_optional_parameters<-function(collection,roi,credentials=NULL){

  . <- odap_coll_info <- odap_source <- odap_server <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- odap_crs <- odap_urlExample <- modis_tile <- OpendapURL <- OpenDAPtimeVector <- OpenDAPXVector <- OpenDAPYVector <- roi_bbox <- Opendap_minLat <- Opendap_maxLat <- Opendap_minLon <- Opendap_maxLon <- roiSpatialIndexBound <- minLat <- maxLat <- minLon <- maxLon <- roiSpatialBound <- availableDimensions <- NULL

  OpenDAPtimeVector <- modis_tile <- NULL


  ## define useful function
  .get_optional_parameters_singleROIfeature <- function(OpenDAPYVector,OpenDAPXVector,roi_bbox){

    Opendap_minLat <- which.min(abs(OpenDAPYVector-roi_bbox$ymax))
    Opendap_maxLat <- which.min(abs(OpenDAPYVector-roi_bbox$ymin))
    Opendap_minLon <- which.min(abs(OpenDAPXVector-roi_bbox$xmin))
    Opendap_maxLon <- which.min(abs(OpenDAPXVector-roi_bbox$xmax))
    roiSpatialIndexBound <- c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

    minLon<-OpenDAPXVector[Opendap_minLon]
    maxLon<-OpenDAPXVector[Opendap_maxLon]
    minLat<-OpenDAPYVector[Opendap_minLat]
    maxLat<-OpenDAPYVector[Opendap_maxLat]
    roiSpatialBound<-c(maxLat,minLat,minLon,maxLon)

    return(list(roiSpatialIndexBound=roiSpatialIndexBound,roiSpatialBound=roiSpatialBound))
  }

  ## tests :
  .testIfCollExists(collection)
  .testRoi(roi)
  .testInternetConnection()
  .testLogin(credentials)

  ## Retrieve opendap information for the collection of interest
  odap_coll_info <- opendapMetadata_internal[which(opendapMetadata_internal$collection==collection),]

  ## Split ROI into single parts
  roi_div <- roi %>%
    sf::st_transform(odap_coll_info$crs) %>%
    split(f = seq(nrow(.)))

  ### GMP and SMAP and SRTM
  if (odap_coll_info$source %in% c("GPM","SMAP","SRTM")){

    if (odap_coll_info$source=="GPM"){
      OpendapURL <- odap_coll_info$url_opendapexample
    } else if (odap_coll_info$source=="SMAP"){
      OpendapURL <- "https://n5eil02u.ecs.nsidc.org/opendap/hyrax/SMAP/SPL4CMDL.004/2016.01.06/SMAP_L4_C_mdl_20160106T000000_Vv4040_001.h5"
      odap_coll_info$dim_lon <- "x"
      odap_coll_info$dim_lat <- "y"
    } else if (odap_coll_info$source=="SRTM"){

    }

    OpenDAPXVector <- .getVarVector(OpendapURL,odap_coll_info$dim_lon)
    OpenDAPYVector <- .getVarVector(OpendapURL,odap_coll_info$dim_lat)

    roi_div_bboxes <- purrr::map(roi_div,~sf::st_bbox(.))
    list_roiSpatialIndexBound <- purrr::map(roi_div_bboxes,~.get_optional_parameters_singleROIfeature(OpenDAPYVector,OpenDAPXVector,.)$roiSpatialIndexBound)
    list_roiSpatialBound <- purrr::map(roi_div_bboxes,~.get_optional_parameters_singleROIfeature(OpenDAPYVector,OpenDAPXVector,.)$roiSpatialBound)

    ### MODIS
  } else if (odap_coll_info$source %in% c("MODIS","VIIRS")){

    modis_tile <- purrr::map(roi_div,~.getMODIStileNames(.))
    OpendapURL <- purrr::map(modis_tile,~purrr::map_chr(.,~paste0(odap_coll_info$url_opendapserver,collection,"/",.,".ncml")))

    OpenDAPtimeVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_time)))
    OpenDAPXVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_lon)))
    OpenDAPYVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_lat)))

    #roi_div <- purrr::map(roi_div,~sf::st_bbox(.))

    roi_div_bboxes <- roi_div %>%
      purrr::map(.,~sf::st_transform(.,4326)) %>%
      purrr::map(.,~sf::st_intersection(.,modis_tiles)) %>%
      purrr::map(.,~sf::st_transform(.,odap_coll_info$crs)) %>%
      purrr::map(.,~split(.,f = seq(nrow(.)))) %>%
      purrr::modify_depth(.,2,~sf::st_bbox(.))

    OpenDAPtimeVector <- purrr::flatten(OpenDAPtimeVector)
    OpenDAPYVector <- purrr::flatten(OpenDAPYVector)
    OpenDAPXVector <- purrr::flatten(OpenDAPXVector)
    roi_div_bboxes <- purrr::flatten(roi_div_bboxes)
    modis_tile <- purrr::flatten(modis_tile)

    list_roiSpatialIndexBound <- purrr::pmap(list(OpenDAPYVector,OpenDAPXVector,roi_div_bboxes),
                                             ~.get_optional_parameters_singleROIfeature(..1,..2,..3)$roiSpatialIndexBound
    )

    list_roiSpatialBound <- NULL
  }


  availableVariables <- get_variables_info(collection)

  return(list(roiSpatialIndexBound = list_roiSpatialIndexBound, availableVariables = availableVariables, roiSpatialBound = list_roiSpatialBound, OpenDAPXVector = OpenDAPXVector, OpenDAPYVector = OpenDAPYVector, OpenDAPtimeVector = OpenDAPtimeVector, modis_tile = modis_tile))

}

