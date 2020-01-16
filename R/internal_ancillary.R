#' @name .getMODIStileNames
#' @aliases .getMODIStileNames
#' @title Get MODIS tile(s) intersecting a given ROI
#' @description Get MODIS tile(s) intersecting a given ROI
#'
#' @inheritParams getUrl
#'
#' @return a character string vector with the MODIS tiles intersecting the ROI
#'
#' @details
#'
#' If the ROI is covering multiple MODIS tiles, consider splitting the ROI into multiple parts (1 for each MODIS tile) before executing the \code{getUrl} function.
#' Then loop \code{getUrl} over each part. Check out the example for some tips on how to proceed.
#'
#' @note
#' The function uses the MODIS tile gridding system available at https://modis.ornl.gov/files/modis_sin.kmz . The same dataset is available in the package through opendapr::modis_tiles
#'
#' @importFrom magrittr %>%
#' @import sf dplyr
#' @noRd





.getMODIStileNames<-function(roi){

  Name <- NULL

  .testRoi(roi)
  roi <- sf::st_transform(roi,4326) %>%
    sf::st_bbox() %>%
    sf::st_as_sfc()

  options(warn=-1)
  #modis_tile = sf::read_sf("https://modis.ornl.gov/files/modis_sin.kmz") %>%
  modis_tile <- modis_tiles %>%
    sf::st_intersection(roi) %>%
    dplyr::filter(sf::st_is(., "POLYGON")) %>%
    as.data.frame() %>%
    dplyr::select(Name)

  modis_tile <- modis_tile$Name

  options(warn=0)

    all_modis_tiles <- NULL
    for(i in 1:length(modis_tile)){
    th_modis_tile<-modis_tile[i] %>%
      unique() %>%
      stringr::str_replace_all(c(" "="",":"=""))
    for (i in 1:9){
      th_modis_tile<-gsub(paste0("h",i,"v"),paste0("h0",i,"v"),th_modis_tile)
    }
    if(nchar(th_modis_tile)!=6){
      th_modis_tile<-paste0(substr(th_modis_tile,1,4),"0",substr(th_modis_tile,5,5))
    }
    all_modis_tiles<-c(all_modis_tiles,th_modis_tile)
  }

  return(all_modis_tiles)
}

#' @name .getSRTMtileNames
#' @aliases .getSRTMtileNames
#' @title Get SRTM tile(s) intersecting a given ROI
#' @description Get SRTM tile(s) intersecting a given ROI
#'
#' @inheritParams getUrl
#'
#' @return a character string vector with the SRTM tiles intersecting the ROI
#' @importFrom geojsonsf geojson_sf
#' @noRd


.getSRTMtileNames<-function(roi){

  srtm_tiles <- NULL

  .testRoi(roi)
  roi<-sf::st_transform(roi,4326)

  srtm_tiles <- geojsonsf::geojson_sf("http://dwtkns.com/srtm30m/srtm30m_bounding_boxes.json")  %>%
    sf::st_intersection(roi) %>%
    as.data.frame()

  srtm_tiles<-substr(srtm_tiles$dataFile,1,7)

  return(srtm_tiles)
}

