#' @name .import_gpm
#' @title Import data  source=="GPM"
#' @noRd
.import_gpm <- function(dir_path, output_class, proj_epsg, roi_mask) {
  files <- list.files(dir_path, full.names = TRUE)

  if (output_class == "SpatRaster") {
    rasts <- withCallingHandlers(
      terra::rast(files),
      warning = function(w) {
        if (grepl("[rast] no geotransform; using GDAL geolocation arrays",
                  conditionMessage(w), fixed = TRUE)) {
          invokeRestart("muffleWarning")
        }
      }
    )

    terra::crs(rasts) <- "epsg:4326"

    if (!is.null(proj_epsg) &&
        !terra::same.crs(rasts, paste0("epsg:", proj_epsg))) {
      rasts <- terra::project(rasts, paste0("epsg:", proj_epsg))
    }

    if (!is.null(roi_mask)) {
      roi_mask <- terra::vect(roi_mask)
      if (!is.null(proj_epsg)) {
        roi_mask <- terra::project(roi_mask, paste0("epsg:", proj_epsg))
      } else {
        roi_mask <- terra::project(roi_mask, "epsg:4326")
      }

      rasts <- terra::mask(rasts, roi_mask)
    }
  } else if (output_class == "stars") {
    stop("stars output is not implemented for this collection")
    # rasts <- stars::read_stars(files) %>%
    #   st_transform(4326) %>%
    #   stars::t() %>%
    #   stars::flip("y")

    # if(!is.null(proj_epsg)){
    #   rasts <- stars::st_transform(rasts,paste0("epsg:",proj_epsg))
    # }
  }

  return(rasts)
}


#' @name .import_modis_viirs
#' @title Import data  source in% c("VNP46A1") , provider=="NASA USGS LAADS DAAC"
#' @noRd
.import_modis_viirs <- function(dir_path, output_class, proj_epsg, roi_mask, vrt) {
  files <- list.files(dir_path, full.names = TRUE)

  if (output_class == "SpatRaster") {
    if (length(files) > 1 & length(unique(regmatches(basename(files), regexpr("h[0-9]{2}v[0-9]{2}", basename(files))))) > 1) { # if there are multiple files from differents tiles, we need to merge them

      if (vrt) {
        rasts <- terra::vrt(files)
      } else {

        tab <- as.data.frame(table(substr(files, nchar(files) - 9, nchar(files) - 4)))  ## s'il y a plusieurs bandes

        if(nrow(tab)>=2 & tab$Freq[1]>1){

          rasts <- tab$Var1 %>%
                 as.character() %>%
                 purrr::map(~ list.files(dir_path, full.names = TRUE, pattern = .x)) %>%
                 purrr::map(rast) %>%
                 purrr::reduce(merge)

        } else {
        rasts <- files %>%
          terra::sprc() %>%
          terra::merge()
        }
      }
    } else { # if there is only one file or if the files cover multiple tiles, we do not need to merge them

      rasts <- terra::rast(files)
    }

    terra::crs(rasts) <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"

    if (!is.null(proj_epsg)) {
      rasts <- terra::project(rasts, paste0("epsg:", proj_epsg))
    }

    if (!is.null(roi_mask)) {
      roi_mask <- terra::vect(roi_mask)
      if (!is.null(proj_epsg)) {
        roi_mask <- terra::project(roi_mask, paste0("epsg:", proj_epsg))
      } else {
        roi_mask <- terra::project(roi_mask, "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
      }

      rasts <- terra::mask(rasts, roi_mask)
    }
  } else if (output_class == "stars") {
    stop("stars output is not implemented yet for this collection")
  }

  return(rasts)
}
