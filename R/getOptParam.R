#' @name getOptParam
#' @aliases getOptParam
#'
#' @title Precompute the parameter \code{optParam} of the function \link{getUrl}
#' @description  Precompute the parameter \code{optParam} to further provide as input of the \link{getUrl} function. Useful to speed-up the overall processing time.
#'
#' @inheritParams getUrl
#'
#' @return a list with the following named objects :
#' \itemize{
#'  \item{*roiSpatialIndexBound*: }{OPeNDAP indices for the spatial coordinates of the bounding box of the ROI (minLat, maxLat, minLon, maxLon)}
#'  \item{*availableVariables*: }{Variables available for the collection of interest}
#'  \item{*roiSpatialBound*: }{The spatial coordinates of the bounding box of the ROI expressed in the CRS of the collection}
#'  \item{*OpenDAPXVector*: }{The X (longitude) vector}
#'  \item{*OpenDAPYVector*: }{The Y (longitude) vector}
#'  \item{*OpenDAPtimeVector*: }{The time vector, or NULL if the collection does not have a time vector}
#'  \item{*modis_tile*: }{The MODIS tile(s) number(s) for the ROI or NULL if the collection is not MODIS}
#' }
#'
#' @details
#'
#' When it is needed to loop the function \link{getUrl} over several time frames, it is advised to previously run the function \code{getOptParam} and provide the output as input \code{optParam} parameter of the \link{getUrl} function.
#' This will save much time, as internal parameters will be calculated only once.
#'
#' @export
#'
#' @examples
#'
#' require(sf)
#'
#' # Login to Earthdata
#' earthdata_credentials<-readLines("/home/ptaconet/opendapr/.earthdata_credentials.txt")
#' earthdata_username=strsplit(earthdata_credentials,"=")[[1]][2]
#' earthdata_password=strsplit(earthdata_credentials,"=")[[2]][2]
#' login<-login_earthdata(c(earthdata_username,earthdata_password))
#'
#' # Get the optional parameters for the collection MOD11A1.006 and the roi :
#' roi <- sf::st_read(system.file("extdata/roi_example.gpkg", package = "opendapr"),quiet=TRUE)
#' (optParam_mod11a1 <- getOptParam("MOD11A1.006",roi) )
#'


getOptParam<-function(collection,roi,loginCredentials=NULL){

  odap_coll_info <- odap_source <- odap_server <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- odap_crs <- odap_urlExample <- modis_tile <- OpendapURL <- OpenDAPtimeVector <- OpenDAPXVector <- OpenDAPYVector <- roi_bbox <- Opendap_minLat <- Opendap_maxLat <- Opendap_minLon <- Opendap_maxLon <- roiSpatialIndexBound <- minLat <- maxLat <- minLon <- maxLon <- roiSpatialBound <- availableDimensions <- NULL

  OpenDAPtimeVector <- modis_tile <- NULL


  ## define useful function
  .getOptParam_singleROIfeature <- function(OpenDAPYVector,OpenDAPXVector,roi_bbox){

    Opendap_minLat <- which.min(abs(OpenDAPYVector-roi_bbox$ymax))
    Opendap_maxLat <- which.min(abs(OpenDAPYVector-roi_bbox$ymin))
    Opendap_minLon <- which.min(abs(OpenDAPXVector-roi_bbox$xmin))
    Opendap_maxLon <- which.min(abs(OpenDAPXVector-roi_bbox$xmax))
    roiSpatialIndexBound <- c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

    return(roiSpatialIndexBound)
  }

  ## tests :
  .testIfCollExists(collection)
  .testRoi(roi)
  .testLogin(loginCredentials)

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
    list_roiSpatialIndexBound <- purrr::map(roi_div_bboxes,~.getOptParam_singleROIfeature(OpenDAPYVector,OpenDAPXVector,.))

    ### MODIS
  } else if (odap_coll_info$source %in% c("MODIS","VNP")){

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
                                             ~.getOptParam_singleROIfeature(..1,..2,..3)
    )


  }


  availableVariables <- getVariablesInfo(collection)$name

  return(list(roiSpatialIndexBound = list_roiSpatialIndexBound, availableVariables = availableVariables, roiSpatialBound = roiSpatialBound, OpenDAPXVector = OpenDAPXVector, OpenDAPYVector = OpenDAPYVector, OpenDAPtimeVector = OpenDAPtimeVector, modis_tile = modis_tile))

}

