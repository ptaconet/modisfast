
#' @name .getTimeIndex_modisVnp
#' @title get MODIS/VNP time index closest to actual provided date
#'
#' @export
#' @noRd

.getTimeIndex_modisVnp<-function(date,timeVector){
  date_julian<-as.integer(difftime(date ,"2000-01-01" , units = c("days")))
  index_opendap_closest_to_date<-which.min(abs(timeVector-date_julian))
  days_sep_from_date<-timeVector[index_opendap_closest_to_date]-date_julian
  if(days_sep_from_date<=0){
    index_opendap_closest_to_date<-index_opendap_closest_to_date-1
  } else {
    index_opendap_closest_to_date<-index_opendap_closest_to_date-2
  }

  date_closest_to_date<-as.Date("2000-01-01")+timeVector[index_opendap_closest_to_date+1]
  days_sep_from_date<--as.integer(difftime(date ,date_closest_to_date , units = c("days")))

  return(list(date,date_closest_to_date,days_sep_from_date,index_opendap_closest_to_date))
}


#' @name .getOpenDapURL_dimensions
#' @title get opendap url dimensions
#'
#' @export
#' @noRd

.getOpenDapURL_dimensions<-function(variables,timeIndex,roiSpatialIndexBound,odap_timeDimName,odap_lonDimName,odap_latDimName){

  dim<-NULL

  dim<-variables %>%
    purrr::map(~paste0(.x,"[",timeIndex,"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"],",odap_timeDimName,"[",timeIndex,"],",odap_latDimName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",odap_lonDimName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
    unlist() %>%
    paste(collapse=",")
  return(dim)
}

#' @name .getOpenDapURL_dimensions2
#' @title get opendap url dimensions-2
#'
#' @export
#' @noRd

.getOpenDapURL_dimensions2<-function(variables,timeIndex,roiSpatialIndexBound,odap_timeDimName,odap_lonDimName,odap_latDimName){

  dim<-NULL

  dim<-variables %>%
    purrr::map(~paste0(.x,"[",timeIndex[1],":",timeIndex[2],"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"],",odap_timeDimName,"[",timeIndex[1],":",timeIndex[2],"],",odap_latDimName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",odap_lonDimName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
    unlist() %>%
    paste(collapse=",")
  return(dim)
}

#' @name .getVarVector
#' @title get SRTM time name
#'
#' @export
#' @noRd

.getVarVector<-function(OpenDAPUrl,variableName,loginCredentials=NULL){

  vector_response <- vector <- NULL

  .testLogin(loginCredentials)

  httr::set_config(httr::authenticate(user=getOption("earthdata_user"), password=getOption("earthdata_pass"), type = "basic"))
  vector_response<-httr::GET(paste0(OpenDAPUrl,".ascii?",variableName))
  vector<-httr::content(vector_response,"text")
  vector<-strsplit(vector,",")
  vector<-vector[[1]]
  vector<-stringr::str_replace(vector,"\\n","")
  vector<-vector[-1]
  vector<-as.numeric(vector)

  return(vector)

}

#' @name .getOdapOptArguments
#' @title get opendap optional arguments
#'
#' @export
#' @noRd

.getOdapOptArguments<-function(collection,roi,loginCredentials=NULL){

  odap_coll_info <- odap_source <- odap_server <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- odap_crs <- odap_urlExample <- modis_tile <- OpendapURL <- OpenDAPtimeVector <- OpenDAPXVector <- OpenDAPYVector <- roi_bbox <- Opendap_minLat <- Opendap_maxLat <- Opendap_minLon <- Opendap_maxLon <- roiSpatialIndexBound <- minLat <- maxLat <- minLon <- maxLon <- roiSpatialBound <- availableDimensions <- NULL

  ## tests :
  opendapr::.testIfCollExists(collection)
  opendapr::.testRoi(roi)
  opendapr::.testLogin(loginCredentials)

  ## Retrieve opendap information for the collection of interest
  odap_coll_info <- opendapr:::opendapMetadata_internal[which(opendapr:::opendapMetadata_internal$collection==collection),]
  odap_source <- odap_coll_info$source
  odap_server <- odap_coll_info$url_opendapserver
  odap_timeDimName <- odap_coll_info$dim_time
  odap_lonDimName <- odap_coll_info$dim_lon
  odap_latDimName <- odap_coll_info$dim_lat
  odap_crs <- odap_coll_info$crs
  odap_urlExample <- odap_coll_info$url_opendapexample

  if(odap_source %in% c("MODIS","VNP")){

    modis_tile <- opendapr::.getMODIStileNames(roi)
    OpendapURL <- paste0(odap_server,"/",collection,"/",modis_tile,".ncml")
    OpenDAPtimeVector<-opendapr::.getVarVector(OpendapURL,variableName=odap_timeDimName)

  } else if (odap_source=="GPM"){

    OpendapURL <- odap_urlExample
    OpenDAPtimeVector <- NULL

  } else if (odap_source=="SMAP"){

    OpendapURL <- "https://n5eil02u.ecs.nsidc.org/opendap/hyrax/SMAP/SPL4CMDL.004/2016.01.06/SMAP_L4_C_mdl_20160106T000000_Vv4040_001.h5"
    odap_lonDimName <- "x"
    odap_latDimName <- "y"
    OpenDAPtimeVector <- NULL

  } else if (source=="SRTM"){

    OpenDAPtimeVector <- NULL

  }

  OpenDAPXVector <- opendapr::.getVarVector(OpendapURL,odap_lonDimName)
  OpenDAPYVector <- opendapr::.getVarVector(OpendapURL,odap_latDimName)

  roi_bbox <- sf::st_bbox(sf::st_transform(roi,odap_crs))

  Opendap_minLat <- which.min(abs(OpenDAPYVector-roi_bbox$ymin))-4
  Opendap_maxLat <- which.min(abs(OpenDAPYVector-roi_bbox$ymax))+4
  Opendap_minLon <- which.min(abs(OpenDAPXVector-roi_bbox$xmin))-4
  Opendap_maxLon <- which.min(abs(OpenDAPXVector-roi_bbox$xmax))+4
  roiSpatialIndexBound <- c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

  minLat <- OpenDAPYVector[Opendap_minLat]
  maxLat <- OpenDAPYVector[Opendap_maxLat]
  minLon <- OpenDAPXVector[Opendap_minLon]
  maxLon <- OpenDAPXVector[Opendap_maxLon]
  roiSpatialBound <- c(minLat,maxLat,minLon,maxLon)

  availableVariables <- opendapr::getVariablesInfo(collection)$name

  return(list(roiSpatialIndexBound = roiSpatialIndexBound, availableVariables = availableVariables, roiSpatialBound = roiSpatialBound, OpenDAPtimeVector = OpenDAPtimeVector))

}


#' @name .buildUrls
#' @title build opendap URLs in function of the collection, time frame and roi of interest
#'
#' @export
#' @noRd

.buildUrls<-function(collection,variables,roi,timeRange,outputFormat="nc4",singleNetcdf=TRUE,optionals_opendap=NULL,loginCredentials=NULL){

  odap_source <- modis_tile <- NULL

  opendapr::.testIfCollExists(collection)
  opendapr::.testRoi(roi)
  opendapr::.testTimeRange(timeRange)
  opendapr::.testLogin(loginCredentials)

  odap_coll_info <- opendapr:::opendapMetadata_internal[which(opendapr:::opendapMetadata_internal$collection==collection),]
  odap_source <- odap_coll_info$source
  odap_server <- odap_coll_info$url_opendapserver
  odap_timeDimName <- odap_coll_info$dim_time
  odap_lonDimName <- odap_coll_info$dim_lon
  odap_latDimName <- odap_coll_info$dim_lat
  odap_projDimName <- odap_coll_info$dim_proj

  if(is.null(optionals_opendap)){
    optionals_opendap <- opendapr::.getOdapOptArguments(collection,roi)
  }

  OpenDAPtimeVector <- optionals_opendap$OpenDAPtimeVector
  roiSpatialIndexBound <- optionals_opendap$roiSpatialIndexBound
  roiSpatialBound <- optionals_opendap$roiSpatialBound

  ############################################
  ##############  MODIS/VNP   ######################
  ############################################

  if(odap_source %in% c("MODIS","VNP")){

    modis_tile <- opendapr::.getMODIStileNames(roi)

    timeRange <- as.Date(timeRange,origin="1970-01-01")
    if (length(timeRange)==1){
      timeRange <- c(timeRange,timeRange)
    }

    revisit_time <- OpenDAPtimeVector[2]-OpenDAPtimeVector[1]

    timeIndices_of_interest <- seq(timeRange[2],timeRange[1],-revisit_time) %>%
      purrr::map(~opendapr::.getTimeIndex_modisVnp(.,OpenDAPtimeVector)) %>%
      do.call(rbind.data.frame,.) %>%
      purrr::set_names("ideal_date","date_closest_to_ideal_date","days_sep_from_ideal_date","index_opendap_closest_to_date") %>%
      dplyr::mutate(ideal_date=as.Date(ideal_date,origin="1970-01-01")) %>%
      dplyr::mutate(date_closest_to_ideal_date=as.Date(date_closest_to_ideal_date,origin="1970-01-01"))  %>%
      dplyr::mutate(name=paste0(collection,".",lubridate::year(date_closest_to_ideal_date),sprintf("%03d",lubridate::yday(date_closest_to_ideal_date)),".",modis_tile))

     if(singleNetcdf){ # download data in a single netcdf file
       timeIndex<-c(min(timeIndices_of_interest$index_opendap_closest_to_date),max(timeIndices_of_interest$index_opendap_closest_to_date))
       url<-opendapr::.getOpenDapURL_dimensions2(dimensions,timeIndex,roiSpatialIndexBound,odap_timeDimName,odap_lonDimName,odap_latDimName)
       url<-paste0(OpenDAPServerUrl,"/",collection,"/",modis_tile,".ncml.",outputFormat,"?",odap_projDimName,",",url)

       name=paste0(collection,".",lubridate::year(min(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(min(timeIndices_of_interest$date_closest_to_ideal_date))),"_",lubridate::year(max(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(max(timeIndices_of_interest$date_closest_to_ideal_date))),".",modis_tile,".nc4")

       res<-data.frame(time_start=min(timeIndices_of_interest$date_closest_to_ideal_date),name=name,url=url,stringsAsFactors = F)
     } else { # download data in multiple netcdf files (1/each time frame)
       table_urls<-timeIndices_of_interest %>%
         dplyr::mutate(dimensions_url=purrr::map(.x=index_opendap_closest_to_date,.f=~opendapr::.getOpenDapURL_dimensions(variables,.x,roiSpatialIndexBound,odap_timeDimName,odap_lonDimName,odap_latDimName))) %>%
         dplyr::mutate(url=paste0(OpenDAPServerUrl,"/",collection,"/",modis_tile,".ncml.",outputFormat,"?",odap_projDimName,",",dimensions_url))

       res<-data.frame(time_start=table_urls$date_closest_to_ideal_date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)
     }

    ############################################
    ##############  GPM   ######################
    ############################################

  } else if (odap_source=="GPM"){

    ##############  GPM_3IMERGHH.06   ######################
    if(collection %in% c("GPM/GPM_3IMERGHH.06","GPM/GPM_3IMERGHHL.06","GPM/GPM_3IMERGHHE.06")){

      if(collection=="GPM/GPM_3IMERGHHL.06"){
        indicatif<-"-L"
      } else if (collection=="GPM/GPM_3IMERGHHE.06"){
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
        dplyr::mutate(product_name=paste0("3B-HHR",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V06B.HDF5.",outputFormat)) %>%
        dplyr::mutate(url_product=paste(odap_server,collection,year,day,product_name,sep="/"))

      ##############  GPM_3IMERGDF.06,GPM_3IMERGDL.06   ######################
    } else if(collection %in% c("GPM/GPM_3IMERGDF.06","GPM/GPM_3IMERGDL.06","GPM/GPM_3IMERGDE.06")){

      if(collection=="GPM/GPM_3IMERGDL.06"){
        indicatif<-"-L"
      } else if (collection=="GPM/GPM_3IMERGDE.06"){
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
        dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06.nc4.",outputFormat)) %>%
        dplyr::mutate(url_product=paste(odap_server,collection,year,month,product_name,sep="/"))

      ##############  GPM_3IMERGM.06   ######################

    } else if(collection=="GPM/GPM_3IMERGM.06"){

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
        dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B.HDF5.",outputFormat)) %>%
        dplyr::mutate(url_product=paste(odap_server,collection,year,product_name,sep="/"))

    }

    ############################################
    ##############  SMAP   ######################
    ############################################

  } else if (odap_source=="SMAP"){

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
        dplyr::mutate(product_name=paste0("SMAP_L3_SM_P_E_",gsub("-","",date_character),"_R16510_001.h5",outputFormat)) %>%
        dplyr::mutate(url_product=paste(OpenDAPServerUrl,collection,gsub("-",".",date_character),product_name,sep="/"))
    }



  } else if (odap_source=="SRTM"){



  }


  return(urls)
}
