#' @name odr_get_opt_param
#' @aliases odr_get_opt_param
#'
#' @title Precompute the parameter \code{opt_param} of the function \link{odr_get_url}
#' @description  Precompute the parameter \code{opt_param} to further provide as input of the \link{odr_get_url} function. Useful to speed-up the overall processing time.
#'
#' @inheritParams odr_get_url
#'
#' @return a list with the following named objects :
#' \describe{
#'  \item{roiSpatialIndexBound}{OPeNDAP indices for the spatial coordinates of the bounding box of the ROI (minLat, maxLat, minLon, maxLon)}
#'  \item{availableVariables}{Variables available for the collection of interest}
#'  \item{roiSpatialBound }{The spatial coordinates of the bounding box of the ROI expressed in the CRS of the collection}
#'  \item{OpenDAPXVector}{The X (longitude) vector}
#'  \item{OpenDAPYVector}{The Y (longitude) vector}
#'  \item{OpenDAPtimeVector}{The time vector, or NULL if the collection does not have a time vector}
#'  \item{modis_tile}{The MODIS tile(s) number(s) for the ROI or NULL if the collection is not MODIS}
#' }
#'
#' @details
#'
#' When it is needed to loop the function \link{odr_get_url} over several time frames, it is advised to previously run the function \code{odr_get_opt_param} and provide the output as input \code{opt_param} parameter of the \link{odr_get_url} function.
#' This will save much time, as internal parameters will be calculated only once.
#'
#' @export
#'
#' @examples
#'
#' \donttest{
#' require(sf)
#' require(purrr)
#'
#' # Login to Earthdata
#' log <- odr_login(c(Sys.getenv("earthdata_un"),Sys.getenv("earthdata_pw")),source="earthdata")
#'
#' # Get the optional parameters for the collection MOD11A1.006 and the roi :
#' roi <- st_as_sf(data.frame(
#' geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),
#' wkt="geom",crs = 4326)
#'
#' opt_param_mod11a1 <- odr_get_opt_param("MOD11A1.006",roi)
#' str(opt_param_mod11a1)
#'
#' # Now we can provide opt_param_mod11a1 as input parameter of the function odr_get_url().
#'
#' time_ranges <- list(as.Date(c("2016-01-01","2016-01-31")),
#'                    as.Date(c("2017-01-01","2017-01-31")),
#'                    as.Date(c("2018-01-01","2018-01-31")),
#'                    as.Date(c("2019-01-01","2019-01-31")))
#'
#' (urls_mod11a1 <- map(.x = time_ranges, ~odr_get_url(
#'  collection = "MOD11A1.006",
#'  variables = c("LST_Day_1km","LST_Night_1km","QC_Day","QC_Night"),
#'  roi = roi,
#'  time_range = .x,
#'  opt_param = opt_param_mod11a1)
#' ))
#'
#'}


odr_get_opt_param<-function(collection,roi,credentials=NULL,verbose=TRUE){

  . <- odap_coll_info <- odap_source <- odap_server <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- odap_crs <- odap_urlExample <- modis_tile <- OpendapURL <- OpenDAPtimeVector <- OpenDAPXVector <- OpenDAPYVector <- roi_bbox <- Opendap_minLat <- Opendap_maxLat <- Opendap_minLon <- Opendap_maxLon <- roiSpatialIndexBound <- minLat <- maxLat <- minLon <- maxLon <- roiSpatialBound <- availableDimensions <- NULL

  OpenDAPtimeVector <- modis_tile <- NULL


  ## define useful function
  .odr_get_opt_param_singleROIfeature <- function(OpenDAPYVector,OpenDAPXVector,roi_bbox){

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
    }

    OpenDAPXVector <- .getVarVector(OpendapURL,odap_coll_info$dim_lon)
    OpenDAPYVector <- .getVarVector(OpendapURL,odap_coll_info$dim_lat)

    roi_div_bboxes <- purrr::map(roi_div,~sf::st_bbox(.))
    list_roiSpatialIndexBound <- purrr::map(roi_div_bboxes,~.odr_get_opt_param_singleROIfeature(OpenDAPYVector,OpenDAPXVector,.)$roiSpatialIndexBound)
    list_roiSpatialBound <- purrr::map(roi_div_bboxes,~.odr_get_opt_param_singleROIfeature(OpenDAPYVector,OpenDAPXVector,.)$roiSpatialBound)

    ### MODIS
  } else if (odap_coll_info$source %in% c("MODIS","VIIRS")){

    if(verbose){cat("Note : messages 'although coordinates are longitude/latitude, st_intersection assumes that they are planar' and 'attribute variables are assumed to be spatially constant throughout all geometries' are not errors\n")}

    if (odap_coll_info$provider=="NASA USGS LP DAAC"){
     tiling <- modis_tiles
     modis_tile <- purrr::map(roi_div,~.getMODIStileNames(.,"modis"))
     OpendapURL <- purrr::map(modis_tile,~purrr::map_chr(.,~paste0(odap_coll_info$url_opendapserver,collection,"/",.,".ncml")))
     OpenDAPtimeVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_time)))
     OpenDAPtimeVector <- purrr::flatten(OpenDAPtimeVector)

     } else if (odap_coll_info$provider=="NASA LAADS DAAC"){
       tiling <- suomi_tiles
       modis_tile <- purrr::map(roi_div,~.getMODIStileNames(.,"suomi"))
       lines <- readLines(paste0(odap_coll_info$url_opendapserver,"/",odap_coll_info$collection,"/2013/019/","catalog.xml"))
       OpendapURL<-purrr::map(modis_tile,~purrr::map_chr(.,~paste0(odap_coll_info$url_opendapserver,odap_coll_info$collection,"/2013/019/",.getVNPladswebdataname(lines,.))))
     }

     OpenDAPXVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_lon)))
     OpenDAPYVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_lat)))

    #roi_div <- purrr::map(roi_div,~sf::st_bbox(.))

      roi_div_bboxes <- roi_div %>%
        purrr::map(.,~sf::st_transform(.,4326)) %>%
        purrr::map(.,~sf::st_intersection(.,tiling)) %>%
        purrr::map(.,~sf::st_transform(.,odap_coll_info$crs)) %>%
        purrr::map(.,~split(.,f = seq(nrow(.)))) %>%
        purrr::modify_depth(.,2,~sf::st_bbox(.))

      OpenDAPYVector <- purrr::flatten(OpenDAPYVector)
     OpenDAPXVector <- purrr::flatten(OpenDAPXVector)
     roi_div_bboxes <- purrr::flatten(roi_div_bboxes)
     modis_tile <- purrr::flatten(modis_tile)

    list_roiSpatialIndexBound <- purrr::pmap(list(OpenDAPYVector,OpenDAPXVector,roi_div_bboxes),
                                             ~.odr_get_opt_param_singleROIfeature(..1,..2,..3)$roiSpatialIndexBound)

    #if (odap_coll_info$crs=="+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"){
      #list_roiSpatialIndexBound <- purrr::map(list_roiSpatialIndexBound,~replace(.,. > 1199,1199))
      list_roiSpatialIndexBound <- purrr::map2(.x = list_roiSpatialIndexBound,.y = OpenDAPXVector , ~replace(.x,.x > length(.y),length(.y)))
    #} else if (odap_coll_info$crs=="+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"){
     # list_roiSpatialIndexBound <- purrr::map(list_roiSpatialIndexBound,~replace(.,. > 2399,2399))
    #}

    list_roiSpatialIndexBound <- purrr::map(list_roiSpatialIndexBound,~replace(.,.<= 10,0))

      list_roiSpatialBound <- NULL
    }

  availableVariables <- odr_list_variables(collection)

  return(list(roiSpatialIndexBound = list_roiSpatialIndexBound, availableVariables = availableVariables, roiSpatialBound = list_roiSpatialBound, OpenDAPXVector = OpenDAPXVector, OpenDAPYVector = OpenDAPYVector, OpenDAPtimeVector = OpenDAPtimeVector, modis_tile = modis_tile))

}

