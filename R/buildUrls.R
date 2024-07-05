
#' @name .buildUrls
#' @title build opendap URLs in function of the collection, time frame and roi of interest
#'
#' @importFrom lubridate year yday hour minute second floor_date
#' @noRd

.buildUrls<-function(collection,variables,roi,time_range,output_format="nc4",single_netcdf=TRUE,optionalsOpendap=NULL,credentials=NULL,verbose=FALSE){

  ideal_date <- date_closest_to_ideal_date <- index_opendap_closest_to_date <- dimensions_url <- hour_end <- date_character <- hour_start <- number_minutes_from_start_day <- year <- day <- product_name <- month <- x <- . <- url_product <- dayofyear <- Var1 <- Var2 <- lines <- NULL

  .testIfCollExists(collection)
  .testRoi(roi)
  .testTimeRange(time_range)
  .testLogin(credentials)
  .testFormat(output_format)

  odap_coll_info <- opendapMetadata_internal[which(opendapMetadata_internal$collection==collection),]
  odap_source <- odap_coll_info$source
  odap_server <- odap_coll_info$url_opendapserver
  odap_timeDimName <- odap_coll_info$dim_time
  odap_lonDimName <- odap_coll_info$dim_lon
  odap_latDimName <- odap_coll_info$dim_lat
  odap_projDimName <- odap_coll_info$dim_proj

  if(is.null(optionalsOpendap)){
    optionalsOpendap <- mf_get_opt_param(collection,roi)
  }


  OpenDAPtimeVector <- optionalsOpendap$OpenDAPtimeVector
  roiSpatialIndexBound <- optionalsOpendap$roiSpatialIndexBound
  roiSpatialBound <- optionalsOpendap$roiSpatialBound
  modis_tile <- optionalsOpendap$modis_tile
  roiId <- optionalsOpendap$roiId

  if (length(time_range)==1){
    time_range <- c(time_range,time_range)
  }

  ############################################
  ##############  MODIS/VIIRS   ######################
  ############################################

  if(odap_source %in% c("MODIS","VIIRS")){

    if(odap_coll_info$provider=="NASA USGS LP DAAC"){

      .workflow_mf_get_url_modisvnp <- function(time_range,OpenDAPtimeVector,modis_tile,roiSpatialIndexBound,roiId){
        time_range <- as.Date(time_range,origin="1970-01-01")

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

          table_urls<-data.frame(date=min(timeIndices_of_interest$date_closest_to_ideal_date),name=name,url=url,roi_id=roiId,stringsAsFactors = F)
        } else { # download data in multiple netcdf files (1/each time frame)
          table_urls<-timeIndices_of_interest %>%
            dplyr::mutate(dimensions_url=purrr::map(.x=index_opendap_closest_to_date,.f=~.getOpenDapURL_dimensions(variables,c(.x,.x),roiSpatialIndexBound[1],roiSpatialIndexBound[2],roiSpatialIndexBound[3],roiSpatialIndexBound[4],odap_timeDimName,odap_lonDimName,odap_latDimName))) %>%
            dplyr::mutate(url=paste0(odap_server,collection,"/",modis_tile,".ncml.",output_format,"?",odap_projDimName,",",dimensions_url))

          table_urls<-data.frame(date=table_urls$date_closest_to_ideal_date,name=table_urls$name,url=table_urls$url,roi_id=roiId,stringsAsFactors = F)
        }

        return(table_urls)
      }

      table_urls <- purrr::pmap_dfr(list(OpenDAPtimeVector,modis_tile,roiSpatialIndexBound,roiId),
                                    ~.workflow_mf_get_url_modisvnp(time_range,..1,..2,..3,..4))


    } else if (odap_coll_info$provider=="NASA LAADS DAAC"){

      # e.g. VNP46A1
      if(verbose){cat("Getting the URLs for this collection might take some time...\n")}
      time_range=as.Date(time_range,origin="1970-01-01")

      datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=substr(date,1,10)) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(dayofyear=lubridate::yday(date)) %>%
        dplyr::mutate(dayofyear=sprintf("%03d", dayofyear))


      a <- datesToRetrieve %>%
        dplyr::mutate(lines=purrr::map2(.x=datesToRetrieve$year,.y=datesToRetrieve$dayofyear,.f=~readLines(paste0(odap_coll_info$url_opendapserver,"/",odap_coll_info$collection,"/",.x,"/",.y,"/","catalog.xml"))))

      urls <- expand.grid(a$date, unlist(modis_tile),stringsAsFactors = F) %>%
        dplyr::rename(date=Var1,modis_tile=Var2) %>%
        dplyr::left_join(a,by="date") %>%
        dplyr::mutate(product_name=purrr::map2_chr(lines,modis_tile,.f=~.getVNPladswebdataname(.x,.y))) %>%
        dplyr::select(-lines) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",dayofyear,"/",product_name,".",output_format))

      ## will have to be finished....
      dim<-purrr::map_chr(roiSpatialIndexBound,~.getOpenDapURL_dimensions(variables,NULL,.[1],.[2],.[3],.[4],NULL,odap_lonDimName,odap_latDimName))
      dim<-data.frame(dim=dim,modis_tile=unlist(modis_tile),stringsAsFactors = F)

      table_urls <- urls %>%
        dplyr::left_join(dim,by="modis_tile") %>%
        dplyr::mutate(url=paste0(url_product,"?",dim)) %>%
        dplyr::mutate(name=product_name)

    }

  } else if (odap_source=="GPM"){

    ############################################
    ##############  GPM   ######################
    ############################################

    ##############  GPM_3IMERGHH.06 and GPM_3IMERGHH.07  ######################
    if(collection %in% c("GPM_3IMERGHH.06","GPM_3IMERGHHL.06","GPM_3IMERGHHE.06","GPM_3IMERGHH.07")){

      if(collection %in% c("GPM_3IMERGHHL.06")){
        indicatif<-"-L"
      } else if (collection %in% c("GPM_3IMERGHHE.06")){
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
        #dplyr::mutate(product_name=paste0("3B-HHR",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V06B")) %>%
        dplyr::mutate(product_name=paste0("3B-HHR",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V0",substr(collection, nchar(collection), nchar(collection)),"B")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",day,"/",product_name,".HDF5.",output_format))

      ##############  GPM_3IMERGDF.06,GPM_3IMERGDL.06   ######################
    } else if(collection %in% c("GPM_3IMERGDF.06","GPM_3IMERGDL.06","GPM_3IMERGDE.06","GPM_3IMERGDF.07")){

      if(collection %in% c("GPM_3IMERGDL.06")){
        indicatif<-"-L"
      } else if (collection %in% c("GPM_3IMERGDE.06")){
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
        #dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06")) %>%
        dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V0",substr(collection, nchar(collection), nchar(collection)),ifelse(collection=="GPM_3IMERGDF.07","B",""))) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",month,"/",product_name,".nc4.",output_format))

      ##############  GPM_3IMERGM.06   ######################

    } else if(collection %in% c("GPM_3IMERGM.06","GPM_3IMERGM.07")){

      time_range=as.Date(time_range,origin="1970-01-01")

      datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
        lubridate::floor_date(., unit = "month") %>%
        unique() %>%
        data.frame(stringsAsFactors = F) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character=substr(date,1,10)) %>%
        dplyr::mutate(year=format(date,'%Y')) %>%
        dplyr::mutate(month=format(date,'%m'))

      urls<-datesToRetrieve %>%
        #dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B")) %>%
        dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V0",substr(collection, nchar(collection), nchar(collection)),"B")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",year,"/",product_name,".HDF5.",output_format))

    }

    dim<-purrr::map_chr(roiSpatialIndexBound,~.getOpenDapURL_dimensions(variables,c(0,0),.[3],.[4],.[2],.[1],odap_timeDimName,odap_latDimName,odap_lonDimName))

    table_urls<-NULL
    for(i in 1:length(dim)){
      th_table_urls<-urls %>%
        dplyr::mutate(url=paste0(url_product,"?",dim[i])) %>%
        dplyr::mutate(name=product_name) %>%
        dplyr::mutate(roi_id = roi$id[i])
      table_urls <- rbind(table_urls,th_table_urls)
    }

  }

  else if (odap_source=="CHIRPS"){

    ############################################
    ##############  CHIRPS   ######################
    ############################################

    time_range=as.Date(time_range,origin="1970-01-01")

    datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
      data.frame(stringsAsFactors = F) %>%
      purrr::set_names("date") %>%
      dplyr::mutate(date_character=substr(date,1,10)) %>%
      dplyr::mutate(year=format(date,'%Y')) %>%
      dplyr::mutate(month=format(date,'%m'))

    urls<-datesToRetrieve %>%
      mutate(product_name = paste0("ucsb-chirps.",gsub("-","",date_character),"T000000Z.global.0.05deg.daily")) %>%
      mutate(url_product = paste0("https://thredds.servirglobal.net/thredds/dodsC/climateserv/ucsb-chirps/global/0.05deg/daily/",product_name,".nc4.",output_format))

    dim<-purrr::map_chr(roiSpatialIndexBound,~.getOpenDapURL_dimensions(variables,c(0,0),.[3],.[4],.[2],.[1],odap_timeDimName,odap_latDimName,odap_lonDimName))

    table_urls<-NULL
    for(i in 1:length(dim)){
      th_table_urls<-urls %>%
        dplyr::mutate(url=paste0(url_product,"?",dim[i])) %>%
        dplyr::mutate(name=product_name) %>%
        dplyr::mutate(roi_id = roi$id[i])
      table_urls <- rbind(table_urls,th_table_urls)
    }

  }

  ############################################
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

    if(collection=="SPL3SMP_E.003"){
      urls<-datesToRetrieve %>%
        dplyr::mutate(product_name=paste0("SMAP_L3_SM_P_E_",gsub("-","",date_character),"_R16510_001")) %>%
        dplyr::mutate(url_product=paste0(odap_server,collection,"/",gsub("-",".",date_character),"/",product_name,".h5.",output_format)) %>%
        dplyr::filter(date!="2016-09-27") # the dataset for the date 2016-09-27 does not exist in the opendap server....
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
