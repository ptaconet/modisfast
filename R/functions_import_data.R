#' @name .import_gpm
#' @title Import data  source=="GPM"
#' @noRd
.import_gpm <- function(paths,variable,output){

  if(output=="RasterBrick"){

    rasts <- paths %>%
      purrr::map(~raster::raster(., varname = variable, crs = "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

    names_rasts <- purrr::map_chr(rasts, ~as.character(.@z[[1]]))

    rasts <- rasts %>%
      raster::brick() %>%
      raster::t() %>%
      raster::flip("y") %>%
      raster::flip("x")

    names(rasts) <- names_rasts

  } else if(output=="stars"){
    stop("stars output is not implemented yet for this collection")
    #a<-stars::read_stars(paths) %>%
    # st_set_crs(odap_coll_info$crs) %>% t() %>% flip("y")
  }

  return(rasts)

}


#' @name .import_modis_viirs_laadsdaac
#' @title Import data  source in% c("VNP46A1") , provider=="NASA USGS LAADS DAAC"
#' @noRd
.import_modis_viirs_laadsdaac <- function(paths,variable,output){

  if(output=="RasterBrick"){

      rasts <- paths %>%
        purrr::map(~raster::raster(., varname = variable,crs = "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")) %>%
        raster::brick()

      names_rasts <- paths %>%
        purrr::map(~ncdf4::nc_open(.)) %>%
        purrr::map(~ncdf4::ncatt_get(.,varid = 0,attname = "HDFEOS_GRIDS_VNP_Grid_DNB.RangeEndingDate")) %>%
        purrr::map_chr(~pluck(.,"value"))

      names(rasts) <- names_rasts


  } else if (output=="stars"){
    stop("stars output is not implemented yet for this collection")
  }

  return(rasts)
}


#' @name .import_modis_viirs_lpdaac
#' @title Import data  source in% c("MODIS","VIIRS") , provider=="NASA USGS LP DAAC"
#' @noRd
.import_modis_viirs_lpdaac <- function(paths,variable,output){

  . <- NULL

  crs_modis <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"

  if(length(paths)>1){warning("Multiple paths provided. In case the paths are not from multiple tiles, an error will be sent back")}

  if(output=="RasterBrick"){
    if(length(paths)==1){
      #rasts <- expand.grid(paths,variables,stringsAsFactors = F) %>%    # to import multiple variables at once
      #  purrr::map2(.x=.$Var1,.y=.$Var2, .f=~brick(.x,varname=.y,crs=crs_modis)) %>%
      #  set_names(variables)
      rasts <- paths %>%    # multiple variables
        raster::brick(.,varname=variable,crs=crs_modis)
    } else {  # case of multiple modis tiles
      rasts <- paths %>%
        purrr::map(~raster::brick(.,varname=variable,crs=crs_modis))
      names_rast <- names(rasts[[1]])
      rasts <- rasts %>%  do.call(raster::merge,.)
      names(rasts) <- names_rast
    }
  } else if (output=="stars"){
    if(length(paths)==1){
      rasts <- paths %>%
        stars::read_stars(.) %>%
        sf::st_set_crs(crs_modis)

    } else {
      stop("case of multiple tiles for this collection not implemented yet")
      #TODO : stars output format for several modis tiles
      #rasts <- df_data_to_import$destfile %>%
      #  map(~stars::read_stars(.)) %>%
      #  map(~st_set_crs(.,crs_modis)) %>%
      #  do.call(c,.)
    }

  }

  return(rasts)
}


#' @name .import_smap
#' @title Import data  source=="SMAP"
#' @noRd
.import_smap <- function(paths,collection,variable,roi,output,opt_param){

  smap_sp_bound <-  NULL

  if(is.null(roi) && is.null(opt_param)){stop("either roi or opt_param argument must be provided")}

  if(output=="RasterBrick"){

    raster(paths[[1]],varname=variable) # outputs error if no variable is provided

    if(is.null(opt_param)){
      smap_sp_bound <- opendapr::odr_get_opt_param(roi = roi, collection = collection)$roiSpatialBound$`1`
    } else {
      smap_sp_bound <- opt_param$roiSpatialBound$`1`
    }
    rasts <- paths %>%
      purrr::map(~ncdf4::nc_open(.))

    names_rasts <- rasts %>%
      purrr::map(~ncdf4::ncatt_get(.,varid = 0,attname = "history")) %>%
      purrr::map_chr(~pluck(.,"value")) %>%
      purrr::map_chr(~sub(paste0(".*",collection,"/ *(.*?) */.*"), "\\1", .)) %>%
      purrr::map_chr(~gsub("\\.","-",.))

    rasts <- rasts %>%
      purrr::map(~ncdf4::ncvar_get(., variable)) %>%
      purrr::map(~raster::raster(t(.), ymn=smap_sp_bound[1], ymx=smap_sp_bound[2], xmn=smap_sp_bound[3], xmx=smap_sp_bound[4], crs="+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")) %>%  # EPSG : 6933
      raster::brick()


    names(rasts) <- names_rasts

  } else if(output=="stars"){
    stop("stars output is not implemented yet for this collection")
  }

  return(rasts)

}


