
#' @name .getTimeIndex_modisVnp
#' @title get MODIS/VIIRS time index closest to actual provided date
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
#' @import purrr
#' @noRd

.getOpenDapURL_dimensions<-function(variables,timeIndex,minLat,maxLat,minLon,maxLon,odap_timeDimName,odap_lonDimName,odap_latDimName){

  dim<-NULL

  dim<-variables %>%
    purrr::map(~paste0(.x,"[",timeIndex[1],":",timeIndex[2],"][",minLat,":",maxLat,"][",minLon,":",maxLon,"]")) %>%
    unlist() %>%
    paste(collapse=",") %>%
    paste0(",",odap_timeDimName,"[",timeIndex[1],":",timeIndex[2],"],",odap_latDimName,"[",minLat,":",maxLat,"],",odap_lonDimName,"[",minLon,":",maxLon,"]")

  return(dim)
}


#' @name .getVarVector
#' @title get SRTM time name
#' @import httr
#' @noRd

.getVarVector<-function(OpenDAPUrl,variableName,login_credentials=NULL){

  vector_response <- vector <- NULL

  .testLogin(login_credentials)

  httr::set_config(httr::authenticate(user=getOption("usgs_user"), password=getOption("usgs_pass"), type = "basic"))
  vector_response<-httr::GET(paste0(OpenDAPUrl,".ascii?",variableName))
  vector<-httr::content(vector_response,"text",encoding="UTF-8")
  vector<-strsplit(vector,",")
  vector<-vector[[1]]
  vector<-stringr::str_replace(vector,"\\n","")
  vector<-vector[-1]
  vector<-as.numeric(vector)

  return(vector)

}


#' @name .buildUrls
#' @title build opendap URLs in function of the collection, time frame and roi of interest
#'
#' @importFrom lubridate year yday hour minute second floor_date
#' @noRd

.buildUrls<-function(collection,variables,roi,time_range,output_format="nc4",single_netcdf=TRUE,optionalsOpendap=NULL,login_credentials=NULL){

  ideal_date <- date_closest_to_ideal_date <- index_opendap_closest_to_date <- dimensions_url <- hour_end <- date_character <- hour_start <- number_minutes_from_start_day <- year <- day <- product_name <- month <- x <- . <- url_product <- NULL

  .testIfCollExists(collection)
  .testRoi(roi)
  .testTimeRange(time_range)
  .testLogin(login_credentials)
  .testFormat(output_format)

  odap_coll_info <- opendapMetadata_internal[which(opendapMetadata_internal$collection==collection),]
  odap_source <- odap_coll_info$source
  odap_server <- odap_coll_info$url_opendapserver
  odap_timeDimName <- odap_coll_info$dim_time
  odap_lonDimName <- odap_coll_info$dim_lon
  odap_latDimName <- odap_coll_info$dim_lat
  odap_projDimName <- odap_coll_info$dim_proj

  if(is.null(optionalsOpendap)){
    optionalsOpendap <- get_optional_parameters(collection,roi)
  }


  OpenDAPtimeVector <- optionalsOpendap$OpenDAPtimeVector
  roiSpatialIndexBound <- optionalsOpendap$roiSpatialIndexBound
  roiSpatialBound <- optionalsOpendap$roiSpatialBound
  modis_tile <- optionalsOpendap$modis_tile

  ############################################
  ##############  MODIS/VIIRS   ######################
  ############################################

  if(odap_source %in% c("MODIS","VIIRS")){

    .workflow_get_url_modisvnp <- function(time_range,OpenDAPtimeVector,modis_tile,roiSpatialIndexBound){
      time_range <- as.Date(time_range,origin="1970-01-01")
      if (length(time_range)==1){
        time_range <- c(time_range,time_range)
      }

      revisit_time <- OpenDAPtimeVector[2]-OpenDAPtimeVector[1]

      timeIndices_of_interest <- seq(time_range[2],time_range[1],-revisit_time) %>%
        purrr::map(~.getTimeIndex_modisVnp(.,OpenDAPtimeVector)) %>%
        do.call(rbind.data.frame,.) %>%
        purrr::set_names("ideal_date","date_closest_to_ideal_date","days_sep_from_ideal_date","index_opendap_closest_to_date") %>%
        dplyr::mutate(ideal_date=as.Date(ideal_date,origin="1970-01-01")) %>%
        dplyr::mutate(date_closest_to_ideal_date=as.Date(date_closest_to_ideal_date,origin="1970-01-01"))  %>%
        dplyr::mutate(name=paste0(collection,".",lubridate::year(date_closest_to_ideal_date),sprintf("%03d",lubridate::yday(date_closest_to_ideal_date)),".",modis_tile))

      if(single_netcdf){ # download data in a single netcdf file
        timeIndex<-c(min(timeIndices_of_interest$index_opendap_closest_to_date),max(timeIndices_of_interest$index_opendap_closest_to_date))
        url<-.getOpenDapURL_dimensions(variables,timeIndex,roiSpatialIndexBound[1],roiSpatialIndexBound[2],roiSpatialIndexBound[3],roiSpatialIndexBound[4],odap_timeDimName,odap_lonDimName,odap_latDimName)
        url<-paste0(odap_server,collection,"/",modis_tile,".ncml.",output_format,"?",odap_projDimName,",",url)

        name=paste0(collection,".",lubridate::year(min(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(min(timeIndices_of_interest$date_closest_to_ideal_date))),"_",lubridate::year(max(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(max(timeIndices_of_interest$date_closest_to_ideal_date))),".",modis_tile)

        table_urls<-data.frame(date=min(timeIndices_of_interest$date_closest_to_ideal_date),name=name,url=url,stringsAsFactors = F)
      } else { # download data in multiple netcdf files (1/each time frame)
        table_urls<-timeIndices_of_interest %>%
          dplyr::mutate(dimensions_url=purrr::map(.x=index_opendap_closest_to_date,.f=~.getOpenDapURL_dimensions(variables,c(.x,.x),roiSpatialIndexBound[1],roiSpatialIndexBound[2],roiSpatialIndexBound[3],roiSpatialIndexBound[4],odap_timeDimName,odap_lonDimName,odap_latDimName))) %>%
          dplyr::mutate(url=paste0(odap_server,collection,"/",modis_tile,".ncml.",output_format,"?",odap_projDimName,",",dimensions_url))

        table_urls<-data.frame(date=table_urls$date_closest_to_ideal_date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)
      }

      return(table_urls)
    }

    table_urls <- purrr::pmap_dfr(list(OpenDAPtimeVector,modis_tile,roiSpatialIndexBound),
                                  ~.workflow_get_url_modisvnp(time_range,..1,..2,..3))


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
      time_range=as.POSIXlt(time_range,tz="GMT")

      datesToRetrieve<-seq(from=time_range[2],to=time_range[1],by="-30 min") %>%
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
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",day,"/",product_name,".HDF5.",output_format))

      ##############  GPM_3IMERGDF.06,GPM_3IMERGDL.06   ######################
    } else if(collection %in% c("GPM_L3/GPM_3IMERGDF.06","GPM_L3/GPM_3IMERGDL.06","GPM_L3/GPM_3IMERGDE.06")){

      if(collection=="GPM_L3/GPM_3IMERGDL.06"){
        indicatif<-"-L"
      } else if (collection=="GPM_L3/GPM_3IMERGDE.06"){
        indicatif<-"-E"
      } else {
        indicatif<-NULL
      }

      time_range=as.Date(time_range,origin="1970-01-01")

      datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=substr(date,1,10)) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(month=format(date,'%m'))

      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",month,"/",product_name,".nc4.",output_format))

      ##############  GPM_3IMERGM.06   ######################

    } else if(collection=="GPM_L3/GPM_3IMERGM.06"){

      time_range=as.Date(time_range,origin="1970-01-01")

      datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
        lubridate::floor_date(x, unit = "month") %>%
        unique() %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=substr(date,1,10)) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(month=format(date,'%m'))

      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",product_name,".HDF5.",output_format))

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

    time_range=as.Date(time_range,origin="1970-01-01")

    datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
      data.frame(stringsAsFactors = F) %>%
      purrr::set_names("date") %>%
      dplyr::mutate(date_character=substr(date,1,10)) %>%
      dplyr::mutate(year=format(date,'%Y')) %>%
      dplyr::mutate(month=format(date,'%m')) %>%
      dplyr::mutate(day=format(date,'%d'))

    if(collection=="SMAP/SPL3SMP_E.003"){
      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("SMAP_L3_SM_P_E_",gsub("-","",date_character),"_R16510_001")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",gsub("-",".",date_character),"/",product_name,".h5.",output_format))
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

