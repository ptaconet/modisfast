# Find the GPM coordinate indices once for each ROI feature.
.mf_gpm_parameters <- function(collection, roi) {
  metadata <- .mf_collection_metadata(collection)
  if (nrow(metadata) != 1L || metadata$source != "GPM") {
    stop("GPM collection expected.")
  }
  .testRoi(roi)
  .testInternetConnection()
  .mf_earthdata_auth()

  longitude <- .getVarVector(metadata$url_opendapexample, metadata$dim_lon)
  latitude <- .getVarVector(metadata$url_opendapexample, metadata$dim_lat)
  features <- sf::st_transform(roi, metadata$crs)
  bounds <- lapply(seq_len(nrow(features)), function(i) {
    box <- sf::st_bbox(features[i, ])
    c(which.min(abs(latitude - box$ymax)),
      which.min(abs(latitude - box$ymin)),
      which.min(abs(longitude - box$xmin)),
      which.min(abs(longitude - box$xmax)))
  })
  names(bounds) <- as.character(seq_along(bounds))
  list(roiSpatialIndexBound = bounds,
       availableVariables = mf_list_variables(collection, verbose = "quiet"))
}
