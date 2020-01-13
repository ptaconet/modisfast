

#' @name .getMODIStileNames
#' @title get MODIS time name
#'
#' @export
#' @noRd


.getMODIStileNames<-function(roi){

  modis_tile <- NULL

  opendapr::.testRoi(roi)
  roi<-sf::st_transform(roi,4326)
  options(warn=-1)
  #modis_tile = sf::read_sf("https://modis.ornl.gov/files/modis_sin.kmz") %>%
  modis_tile = opendapr:::modis_tile %>%
    sf::st_intersection(roi) %>%
    as.data.frame() %>%
    dplyr::select(Name) %>%
    as.character()
  options(warn=0)

  if(length(unique(modis_tile))>1){
    stop("Your ROI is overlapping more than 1 MODIS tile. The package currently does not support multiple MODIS tiles\n")
  } else {
    modis_tile<-modis_tile %>%
      unique() %>%
      stringr::str_replace_all(c(" "="",":"=""))
    for (i in 1:9){
      modis_tile<-gsub(paste0("h",i,"v"),paste0("h0",i,"v"),modis_tile)
    }
    if(nchar(modis_tile)!=6){
      modis_tile<-paste0(substr(modis_tile,1,4),"0",substr(modis_tile,5,5))
    }
  }

  return(modis_tile)
}

#' @name .getSRTMtileNames
#' @title get SRTM time name
#'
#' @export
#' @noRd

.getSRTMtileNames<-function(roi){

  srtm_tiles <- NULL

  opendapr::.testRoi(roi)
  roi<-sf::st_transform(roi,4326)

  srtm_tiles <- geojsonsf::geojson_sf("http://dwtkns.com/srtm30m/srtm30m_bounding_boxes.json")  %>%
    sf::st_intersection(roi) %>%
    as.data.frame()

  srtm_tiles<-substr(srtm_tiles$dataFile,1,7)

  return(srtm_tiles)
}

