# Internal GPM URL builder retained for the GES DISC endpoint.
.mf_get_url_gpm <- function(collection,
                       variables,
                       roi,
                       time_range,
                       verbose = "inform") {
  existing_variables <- odap_coll_info <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- . <- name <- destfile <- roi_id <- maxFileSizeEstimated <- NULL

  ## tests :
  # collection
  # if(verbose){cat("Checking if specified collection exist and is implemented in the package...\n")}
  .testIfCollExists(collection)
  # roi
  .testRoi(roi)
  # time_range_format
  .testTimeRange(time_range)
  # time_range_available_dates
  .testTimeRangeAvDates(time_range, collection)
  # Internet connection
  .testInternetConnection()
  params <- .mf_gpm_parameters(collection, roi)

  if (length(params$roiSpatialIndexBound) == 0) {
    stop("Your ROI does not cover a region where there is any data.
         Please provide a correct ROI.")
  }

  # test variables
  # if(verbose){cat("Checking if specified variables exist for the collection specified...\n")}
  available_variables <- params$availableVariables$name[which(params$availableVariables$extractable_with_modisfast == "extractable")]
  .testIfVarExists(variables, available_variables)

  # build URLs
  table_urls <- .buildUrls(collection, variables, roi, time_range,
                           params, verbose)

  table_urls <- table_urls %>%
    dplyr::mutate(name = stringr::str_replace(name, ".*/", "")) %>%
    dplyr::mutate(url = gsub("\\[", "%5B", url)) %>%
    dplyr::mutate(url = gsub("\\]", "%5D", url)) %>%
    dplyr::arrange(name) %>%
    dplyr::mutate(name = paste0(name, ".nc4")) %>%
    dplyr::arrange(roi_id, date) %>%
    dplyr::mutate(collection = collection) %>%
    dplyr::mutate(grid_nrow = NA, grid_ncol = NA) %>%
    dplyr::select(roi_id, date, collection, name, url, "grid_nrow", "grid_ncol", maxFileSizeEstimated) %>%
    dplyr::rename(time_start = date, id_roi = roi_id)

  maxFileSizeEstimated <- dplyr::if_else(round(sum(table_urls$maxFileSizeEstimated)/1000000)>1,round(sum(table_urls$maxFileSizeEstimated)/1000000),1)

  if (verbose %in% c("inform","debug")) {
    cli::cli_alert_success("URL(s) built.\n")
    cat("Estimated maximum size of data to be downloaded is",maxFileSizeEstimated,"Mb\n")
  }

  return(table_urls)
}
