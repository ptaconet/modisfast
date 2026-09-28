# Build GPM subsets from the GES DISC granule names and coordinate indices.
.buildUrls <- function(collection, variables, roi, time_range, params,
                       verbose = "inform") {
  date_character <- hour_end <- hour_start <- number_minutes_from_start_day <-
    year <- day <- product_name <- month <- url_product <- NULL
  metadata <- .mf_collection_metadata(collection)
  odap_server <- metadata$url_opendapserver
  odap_timeDimName <- metadata$dim_time
  odap_lonDimName <- metadata$dim_lon
  odap_latDimName <- metadata$dim_lat
  roiSpatialIndexBound <- params$roiSpatialIndexBound

  if (length(time_range) == 1L) time_range <- rep(time_range, 2L)

    ##############  GPM_3IMERGHH.06 and GPM_3IMERGHH.07  ######################
    if (collection %in% c("GPM_3IMERGHH.06", "GPM_3IMERGHHL.06", "GPM_3IMERGHHE.06", "GPM_3IMERGHH.07")) {
      if (verbose != "quiet") {
        cli::cli_alert_info("For this collection, please provide hours in GMT.\n")
      }
      if (collection %in% c("GPM_3IMERGHHL.06")) {
        indicatif <- "-L"
      } else if (collection %in% c("GPM_3IMERGHHE.06")) {
        indicatif <- "-E"
      } else {
        indicatif <- NULL
      }

      # times_gpm_hhourly<-seq(from=as.POSIXlt(paste0(this_date_hlc," ",hh_rainfall_hour_begin,":00:00")),to=as.POSIXlt(as.POSIXlt(paste0(this_date_hlc+1," ",hh_rainfall_hour_end,":00:00"))),by="30 min")
      time_range <- as.POSIXlt(time_range, tz = "GMT")

      datesToRetrieve <- seq(from = time_range[2], to = time_range[1], by = "-30 min") %>%
        data.frame(stringsAsFactors = FALSE) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character = as.character(as.Date(date))) %>%
        dplyr::mutate(year = format(date, "%Y")) %>%
        dplyr::mutate(month = format(date, "%m")) %>%
        dplyr::mutate(day = sprintf("%03d", lubridate::yday(date))) %>%
        dplyr::mutate(hour_start = paste0(sprintf("%02d", lubridate::hour(date)), sprintf("%02d", lubridate::minute(date)), sprintf("%02d", lubridate::second(date)))) %>%
        dplyr::mutate(hour_end = date + lubridate::minutes(29) + lubridate::seconds(59)) %>%
        dplyr::mutate(hour_end = paste0(sprintf("%02d", lubridate::hour(hour_end)), sprintf("%02d", lubridate::minute(hour_end)), sprintf("%02d", lubridate::second(hour_end)))) %>%
        dplyr::mutate(number_minutes_from_start_day = sprintf("%04d", difftime(date, as.POSIXlt(paste0(as.Date(date), " 00:00:00"), tz = "GMT"), units = "mins")))

      urls <- datesToRetrieve %>%
        # dplyr::mutate(product_name=paste0("3B-HHR",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V06B")) %>%
        dplyr::mutate(product_name = paste0("3B-HHR", indicatif, ".MS.MRG.3IMERG.", gsub("-", "", date_character), "-S", hour_start, "-E", hour_end, ".", number_minutes_from_start_day, ".V0", substr(collection, nchar(collection), nchar(collection)), "B")) %>%
        dplyr::mutate(url_product = paste0(odap_server, collection, "/", year, "/", day, "/", product_name, ".HDF5.", "nc4"))

      ##############  GPM_3IMERGDF.06,GPM_3IMERGDL.06   ######################
    } else if (collection %in% c("GPM_3IMERGDF.06", "GPM_3IMERGDL.06", "GPM_3IMERGDE.06", "GPM_3IMERGDF.07")) {
      if (collection %in% c("GPM_3IMERGDL.06")) {
        indicatif <- "-L"
      } else if (collection %in% c("GPM_3IMERGDE.06")) {
        indicatif <- "-E"
      } else {
        indicatif <- NULL
      }

      time_range <- as.Date(time_range, origin = "1970-01-01")

      datesToRetrieve <- seq(time_range[2], time_range[1], -1) %>%
        data.frame(stringsAsFactors = FALSE) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character = substr(date, 1, 10)) %>%
        dplyr::mutate(year = format(date, "%Y")) %>%
        dplyr::mutate(month = format(date, "%m"))

      urls <- datesToRetrieve %>%
        # dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06")) %>%
        dplyr::mutate(product_name = paste0("3B-DAY", indicatif, ".MS.MRG.3IMERG.", gsub("-", "", date_character), "-S000000-E235959.V0", substr(collection, nchar(collection), nchar(collection)), ifelse(collection == "GPM_3IMERGDF.07", "B", ""))) %>%
        dplyr::mutate(url_product = paste0(odap_server, collection, "/", year, "/", month, "/", product_name, ".nc4.", "nc4"))

      ##############  GPM_3IMERGM.06   ######################
    } else if (collection %in% c("GPM_3IMERGM.06", "GPM_3IMERGM.07")) {
      time_range <- as.Date(time_range, origin = "1970-01-01")

      datesToRetrieve <- seq(time_range[2], time_range[1], -1) %>%
        lubridate::floor_date(unit = "month") %>%
        unique() %>%
        data.frame(stringsAsFactors = FALSE) %>%
        purrr::set_names("date") %>%
        dplyr::mutate(date_character = substr(date, 1, 10)) %>%
        dplyr::mutate(year = format(date, "%Y")) %>%
        dplyr::mutate(month = format(date, "%m"))

      urls <- datesToRetrieve %>%
        # dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B")) %>%
        dplyr::mutate(product_name = paste0("3B-MO.MS.MRG.3IMERG.", year, month, "01-S000000-E235959.", month, ".V0", substr(collection, nchar(collection), nchar(collection)), "B")) %>%
        dplyr::mutate(url_product = paste0(odap_server, collection, "/", year, "/", product_name, ".HDF5.", "nc4"))
    }

    dim <- purrr::map_chr(roiSpatialIndexBound, ~ .getOpenDapURL_dimensions(variables, c(0, 0), .[3], .[4], .[2], .[1], odap_timeDimName, odap_latDimName, odap_lonDimName))

    table_urls <- NULL
    for (i in seq_along(dim)) {
      th_table_urls <- urls %>%
        dplyr::mutate(url = paste0(url_product, "?", dim[i])) %>%
        dplyr::mutate(name = product_name) %>%
        dplyr::mutate(roi_id = roi$id[i]) %>%
        dplyr::mutate(maxFileSizeEstimated = (abs(roiSpatialIndexBound$'1'[1] - roiSpatialIndexBound$'1'[2]) * abs(roiSpatialIndexBound$'1'[4] - roiSpatialIndexBound$'1'[3]) * length(variables)) * 4) # ie. total number of cells / size of a cell in bites)
      table_urls <- rbind(table_urls, th_table_urls)
    }
  return(table_urls)
}
