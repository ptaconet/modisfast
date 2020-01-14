
#' @name getOdapOptParam2
#' @title build opendap URLs in function of the collection, time frame and roi of interest
#'
#' @export
#' @noRd

getOdapOptParam2<-function(collection,roi,loginCredentials=NULL){

  odap_coll_info <- odap_source <- odap_server <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- odap_crs <- odap_urlExample <- modis_tile <- OpendapURL <- OpenDAPtimeVector <- OpenDAPXVector <- OpenDAPYVector <- roi_bbox <- Opendap_minLat <- Opendap_maxLat <- Opendap_minLon <- Opendap_maxLon <- roiSpatialIndexBound <- minLat <- maxLat <- minLon <- maxLon <- roiSpatialBound <- availableDimensions <- NULL

  OpenDAPtimeVector <- modis_tile <- NULL


  ## define useful function
  .getOdapOptParam_singleROIfeature <- function(OpenDAPYVector,OpenDAPXVector,roi_bbox){

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
  list_roiSpatialIndexBound <- purrr::map(roi_div_bboxes,~.getOdapOptParam_singleROIfeature(OpenDAPYVector,OpenDAPXVector,.))

  ### MODIS
  } else if (odap_coll_info$source %in% c("MODIS","VNP")){

    modis_tile <- purrr::map(roi_div,~getMODIStileNames(.))
    OpendapURL <- purrr::map(modis_tile,~purrr::map_chr(.,~paste0(odap_coll_info$url_opendapserver,collection,"/",.,".ncml")))

    OpenDAPtimeVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_time)))
    OpenDAPXVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_lon)))
    OpenDAPYVector<-purrr::map(OpendapURL,~purrr::map(.,~.getVarVector(.,odap_coll_info$dim_lat)))

    #roi_div <- purrr::map(roi_div,~sf::st_bbox(.))

     roi_div_bboxes <- roi_div %>%
       purrr::map(.,~sf::st_transform(.,4326)) %>%
       purrr::map(.,~sf::st_intersection(.,opendapr:::modis_tiles)) %>%
       purrr::map(.,~sf::st_transform(.,odap_coll_info$crs)) %>%
       purrr::map(.,~split(.,f = seq(nrow(.)))) %>%
       purrr::modify_depth(.,2,~sf::st_bbox(.))

     OpenDAPtimeVector <- purrr::flatten(OpenDAPtimeVector)
     OpenDAPYVector <- purrr::flatten(OpenDAPYVector)
     OpenDAPXVector <- purrr::flatten(OpenDAPXVector)
     roi_div_bboxes <- purrr::flatten(roi_div_bboxes)
     modis_tile <- purrr::flatten(modis_tile)

     list_roiSpatialIndexBound <- purrr::pmap(list(OpenDAPYVector,OpenDAPXVector,roi_div_bboxes),
                                              ~.getOdapOptParam_singleROIfeature(..1,..2,..3)
     )


  }


  availableVariables <- getVariablesInfo(collection)$name

  return(list(roiSpatialIndexBound = list_roiSpatialIndexBound, availableVariables = availableVariables, roiSpatialBound = roiSpatialBound, OpenDAPXVector = OpenDAPXVector, OpenDAPYVector = OpenDAPYVector, OpenDAPtimeVector = OpenDAPtimeVector, modis_tile = modis_tile))

}






#' @name .buildUrls2
#' @title build opendap URLs in function of the collection, time frame and roi of interest
#'
#' @export
#' @importFrom lubridate year yday hour minute second floor_date
#' @noRd

.buildUrls2<-function(collection,variables,roi,timeRange,outputFormat="nc4",singleNetcdf=TRUE,optionalsOpendap=NULL,loginCredentials=NULL){

  ideal_date <- date_closest_to_ideal_date <- index_opendap_closest_to_date <- dimensions_url <- hour_end <- date_character <- hour_start <- number_minutes_from_start_day <- year <- day <- product_name <- month <- x <- . <- url_product <- NULL

  .testIfCollExists(collection)
  .testRoi(roi)
  .testTimeRange(timeRange)
  .testLogin(loginCredentials)

  odap_coll_info <- opendapMetadata_internal[which(opendapMetadata_internal$collection==collection),]
  odap_source <- odap_coll_info$source
  odap_server <- odap_coll_info$url_opendapserver
  odap_timeDimName <- odap_coll_info$dim_time
  odap_lonDimName <- odap_coll_info$dim_lon
  odap_latDimName <- odap_coll_info$dim_lat
  odap_projDimName <- odap_coll_info$dim_proj

  if(is.null(optionalsOpendap)){
    optionalsOpendap <- getOdapOptParam2(collection,roi)
  }


  OpenDAPtimeVector <- optionalsOpendap$OpenDAPtimeVector
  roiSpatialIndexBound <- optionalsOpendap$roiSpatialIndexBound
  roiSpatialBound <- optionalsOpendap$roiSpatialBound
  modis_tile <- optionalsOpendap$modis_tile

  ############################################
  ##############  MODIS/VNP   ######################
  ############################################

  if(odap_source %in% c("MODIS","VNP")){

    .workflow_getUrl_modisvnp <- function(timeRange,OpenDAPtimeVector,modis_tile,roiSpatialIndexBound){
    timeRange <- as.Date(timeRange,origin="1970-01-01")
    if (length(timeRange)==1){
      timeRange <- c(timeRange,timeRange)
    }

    revisit_time <- OpenDAPtimeVector[2]-OpenDAPtimeVector[1]

    timeIndices_of_interest <- seq(timeRange[2],timeRange[1],-revisit_time) %>%
      purrr::map(~.getTimeIndex_modisVnp(.,OpenDAPtimeVector)) %>%
      do.call(rbind.data.frame,.) %>%
      purrr::set_names("ideal_date","date_closest_to_ideal_date","days_sep_from_ideal_date","index_opendap_closest_to_date") %>%
      dplyr::mutate(ideal_date=as.Date(ideal_date,origin="1970-01-01")) %>%
      dplyr::mutate(date_closest_to_ideal_date=as.Date(date_closest_to_ideal_date,origin="1970-01-01"))  %>%
      dplyr::mutate(name=paste0(collection,".",lubridate::year(date_closest_to_ideal_date),sprintf("%03d",lubridate::yday(date_closest_to_ideal_date)),".",modis_tile))

    if(singleNetcdf){ # download data in a single netcdf file
      timeIndex<-c(min(timeIndices_of_interest$index_opendap_closest_to_date),max(timeIndices_of_interest$index_opendap_closest_to_date))
      url<-.getOpenDapURL_dimensions(variables,timeIndex,roiSpatialIndexBound[1],roiSpatialIndexBound[2],roiSpatialIndexBound[3],roiSpatialIndexBound[4],odap_timeDimName,odap_lonDimName,odap_latDimName)
      url<-paste0(odap_server,collection,"/",modis_tile,".ncml.",outputFormat,"?",odap_projDimName,",",url)

      name=paste0(collection,".",lubridate::year(min(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(min(timeIndices_of_interest$date_closest_to_ideal_date))),"_",lubridate::year(max(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(max(timeIndices_of_interest$date_closest_to_ideal_date))),".",modis_tile)

      table_urls<-data.frame(date=min(timeIndices_of_interest$date_closest_to_ideal_date),name=name,url=url,stringsAsFactors = F)
    } else { # download data in multiple netcdf files (1/each time frame)
      table_urls<-timeIndices_of_interest %>%
        dplyr::mutate(dimensions_url=purrr::map(.x=index_opendap_closest_to_date,.f=~.getOpenDapURL_dimensions(variables,c(.x,.x),roiSpatialIndexBound[1],roiSpatialIndexBound[2],roiSpatialIndexBound[3],roiSpatialIndexBound[4],odap_timeDimName,odap_lonDimName,odap_latDimName))) %>%
        dplyr::mutate(url=paste0(odap_server,collection,"/",modis_tile,".ncml.",outputFormat,"?",odap_projDimName,",",dimensions_url))

      table_urls<-data.frame(date=table_urls$date_closest_to_ideal_date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)
    }

    return(table_urls)
    }

    table_urls <- purrr::pmap_dfr(list(OpenDAPtimeVector,modis_tile,roiSpatialIndexBound),
                               ~.workflow_getUrl_modisvnp(timeRange,..1,..2,..3))


  ############################################
  ##############  GPM   ######################
  ############################################

  } else if (odap_source=="GPM"){

    ##############  GPM_3IMERGHH.06   ######################
    if(collection %in% c("GPM_L3/GPM_3IMERGHH.06","GPM_L3/GPM_3IMERGHHL.06","GPM_L3/GPM_3IMERGHHE.06")){

      if(collection=="GPM_L3/GPM_3IMERGHHL.06"){
        indicatif<-"-L"
      } else if (collection=="GPM_L3/GPM_3IMERGHHE.06"){
        indicatif<-"-E"
      } else {
        indicatif<-NULL
      }

      #times_gpm_hhourly<-seq(from=as.POSIXlt(paste0(this_date_hlc," ",hh_rainfall_hour_begin,":00:00")),to=as.POSIXlt(as.POSIXlt(paste0(this_date_hlc+1," ",hh_rainfall_hour_end,":00:00"))),by="30 min")
      timeRange=as.POSIXlt(timeRange,tz="GMT")

      datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by="-30 min") %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=as.character(as.Date(date))) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(month=format(date,'%m')) %>%
        dplyr::mutate(day=sprintf("%03d",lubridate::yday(date))) %>%
        dplyr::mutate(hour_start=paste0(sprintf("%02d",lubridate::hour(date)),sprintf("%02d",lubridate::minute(date)),sprintf("%02d",lubridate::second(date)))) %>%
        dplyr::mutate(hour_end=date+lubridate::minutes(29)+lubridate::seconds(59)) %>%
        dplyr::mutate(hour_end=paste0(sprintf("%02d",lubridate::hour(hour_end)),sprintf("%02d",lubridate::minute(hour_end)),sprintf("%02d",lubridate::second(hour_end)))) %>%
        dplyr::mutate(number_minutes_from_start_day=sprintf("%04d",difftime(date,as.POSIXlt(paste0(as.Date(date)," 00:00:00"),tz="GMT"),units="mins")))

      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("3B-HHR",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V06B")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",day,"/",product_name,".HDF5.",outputFormat))

      ##############  GPM_3IMERGDF.06,GPM_3IMERGDL.06   ######################
    } else if(collection %in% c("GPM_L3/GPM_3IMERGDF.06","GPM_L3/GPM_3IMERGDL.06","GPM_L3/GPM_3IMERGDE.06")){

      if(collection=="GPM_L3/GPM_3IMERGDL.06"){
        indicatif<-"-L"
      } else if (collection=="GPM_L3/GPM_3IMERGDE.06"){
        indicatif<-"-E"
      } else {
        indicatif<-NULL
      }

      timeRange=as.Date(timeRange,origin="1970-01-01")

      datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=substr(date,1,10)) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(month=format(date,'%m'))

      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",month,"/",product_name,".nc4.",outputFormat))

      ##############  GPM_3IMERGM.06   ######################

    } else if(collection=="GPM_L3/GPM_3IMERGM.06"){

      timeRange=as.Date(timeRange,origin="1970-01-01")

      datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
        lubridate::floor_date(x, unit = "month") %>%
        unique() %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=substr(date,1,10)) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(month=format(date,'%m'))

      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",product_name,".HDF5.",outputFormat))

    }

    dim<-purrr::map_chr(roiSpatialIndexBound,~.getOpenDapURL_dimensions(variables,c(0,0),.[3],.[4],.[2],.[1],odap_timeDimName,odap_latDimName,odap_lonDimName))

    table_urls<-NULL
    for(i in 1:length(dim)){
      th_table_urls<-urls %>%
        dplyr::mutate(url=paste0(url_product,"?",dim[i])) %>%
        dplyr::mutate(name=product_name)
      table_urls <- rbind(table_urls,th_table_urls)
    }

  }  ############################################
  ##############  SMAP   ######################
  ############################################
  else if (odap_source=="SMAP"){

  timeRange=as.Date(timeRange,origin="1970-01-01")

  datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
    data.frame(stringsAsFactors = F) %>%
    purrr::set_names("date") %>%
    dplyr::mutate(date_character=substr(date,1,10)) %>%
    dplyr::mutate(year=format(date,'%Y')) %>%
    dplyr::mutate(month=format(date,'%m')) %>%
    dplyr::mutate(day=format(date,'%d'))

  if(collection=="SMAP/SPL3SMP_E.003"){
    urls<-datesToRetrieve %>%
      dplyr::mutate(product_name=paste0("SMAP_L3_SM_P_E_",gsub("-","",date_character),"_R16510_001")) %>%
      dplyr::mutate(url_product=paste0(odap_server,collection,"/",gsub("-",".",date_character),"/",product_name,".h5.",outputFormat))
  }

  getdim <- function (roiSpatialIndexBound){
    dim <- c(variables,"Soil_Moisture_Retrieval_Data_AM_longitude","Soil_Moisture_Retrieval_Data_AM_latitude","Soil_Moisture_Retrieval_Data_PM_longitude_pm","Soil_Moisture_Retrieval_Data_PM_latitude_pm") %>%
      purrr::map(~paste0(.x,"[",roiSpatialIndexBound[1],":1:",roiSpatialIndexBound[2],"][",roiSpatialIndexBound[3],":1:",roiSpatialIndexBound[4],"]")) %>%
      unlist() %>%
      paste(collapse=",")
    return(dim)
  }

  dim <- roiSpatialIndexBound %>%
    purrr::map(.,~getdim(.))

  table_urls<-NULL
  for(i in 1:length(dim)){
    th_table_urls<-urls %>%
      dplyr::mutate(url=paste0(url_product,"?",dim[i])) %>%
      dplyr::mutate(name=product_name)
    table_urls <- rbind(table_urls,th_table_urls)
  }


  }

  return(table_urls)

}

