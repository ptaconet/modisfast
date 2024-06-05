#' @name .import_gpm
#' @title Import data  source=="GPM"
#' @noRd
.import_gpm <- function(dir_path,output_class,proj_epsg){

  if(output_class=="SpatRaster"){

    files <- list.files(dir_path, full.names = T)

    rasts <- terra::rast(files)
    terra::crs(rasts) <- "epsg:4326"

    rasts <- rasts %>%
      terra::t() %>%
      terra::flip("vertical") %>%
      terra::flip("horizontal")

    if(proj_epsg != "4326"){
      rasts <- terra::project(rasts,paste0("epsg:",proj_epsg))
    }


  } else if(output_class=="stars"){
    stop("stars output is not implemented yet for this collection")
    #a<-stars::read_stars(paths) %>%
    # st_set_crs(odap_coll_info$crs) %>% t() %>% flip("y")
  }

  return(rasts)

}


#' @name .import_modis_viirs
#' @title Import data  source in% c("VNP46A1") , provider=="NASA USGS LAADS DAAC"
#' @noRd
.import_modis_viirs <- function(dir_path,output_class,proj_epsg){

  if(output_class=="SpatRaster"){

    files <- list.files(dir_path, full.names = T)

    if(length(files)>1 & length(unique(substr(files,nchar(files)-9,nchar(files)-4)))>1 ){ # if there are multiple files (length(files)>1) but all with the same tile (length(unique(substr(files,nchar(files)-9,nchar(files)-4)))==1), we do not need to merge them

    rasts <- files %>%
      purrr::map(~terra::rast(.)) %>%
      do.call(terra::merge,.)

    } else {

      rasts <- terra::rast(files)

    }

    terra::crs(rasts) <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"

    rasts <- terra::project(rasts,paste0("epsg:",proj_epsg))

  } else if (output_class=="stars"){
    stop("stars output is not implemented yet for this collection")
  }

  return(rasts)
}


#' @name .import_smap
#' @title Import data  source=="SMAP"
#' @noRd
.import_smap <- function(paths,collection,variable,roi,output_class,opt_param){

  smap_sp_bound <-  NULL

  if(is.null(roi) && is.null(opt_param)){stop("either roi or opt_param argument must be provided")}

  if(output_class=="SpatRaster"){

    raster(paths[[1]],varname=variable) # outputs error if no variable is provided

    if(is.null(opt_param)){
      smap_sp_bound <- modisfast::mf_get_opt_param(roi = roi, collection = collection)$roiSpatialBound$`1`
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

  } else if(output_class=="stars"){
    stop("stars output is not implemented yet for this collection")
  }

  return(rasts)

}


