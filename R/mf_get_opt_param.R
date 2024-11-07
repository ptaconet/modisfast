#' @name mf_get_opt_param
#' @aliases mf_get_opt_param
#'
#' @title Precompute the parameter \code{opt_param} of the function \link{mf_get_url}
#' @description  Precompute the parameter \code{opt_param} to further provide as input of the \link{mf_get_url} function. Useful to speed-up the overall processing time.
#'
#' @inheritParams mf_get_url
#'
#' @return a list with the following named objects :
#' \describe{
#'  \item{roiSpatialIndexBound}{OPeNDAP indices for the spatial coordinates of the bounding box of the ROI (minLat, maxLat, minLon, maxLon)}
#'  \item{availableVariables}{Variables available for the collection of interest}
#'  \item{roiSpatialBound}{The spatial coordinates of the bounding box of the ROI expressed in the CRS of the collection}
#'  \item{OpenDAPXVector}{The X (longitude) vector}
#'  \item{OpenDAPYVector}{The Y (longitude) vector}
#'  \item{OpenDAPtimeVector}{The time vector, or NULL if the collection does not have a time vector}
#'  \item{modis_tile}{The MODIS tile(s) number(s) for the ROI or NULL if the collection is not MODIS}
#' }
#'
#' @details
#'
#' When it is needed to loop the function \link{mf_get_url} over several time frames, it is advised to previously run the function \code{mf_get_opt_param} and provide the output as input \code{opt_param} parameter of the \link{mf_get_url} function.
#' This will save much time, as internal parameters will be calculated only once.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Login to Earthdata
#'
#' log <- mf_login(credentials = c("earthdata_un", "earthdata_pw"))
#'
#' # Get the optional parameters for the collection MOD11A1.061 and the following roi :
#' roi <- sf::st_as_sf(
#'   data.frame(
#'     id = "roi_test",
#'     geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"
#'   ),
#'   wkt = "geom", crs = 4326
#' )
#'
#' opt_param_mod11a1 <- mf_get_opt_param("MOD11A1.061", roi)
#' str(opt_param_mod11a1)
#'
#' # Now we can provide opt_param_mod11a1 as input parameter of the function mf_get_url().
#'
#' time_ranges <- list(
#'   as.Date(c("2016-01-01", "2016-01-31")),
#'   as.Date(c("2017-01-01", "2017-01-31")),
#'   as.Date(c("2018-01-01", "2018-01-31")),
#'   as.Date(c("2019-01-01", "2019-01-31"))
#' )
#'
#' (urls_mod11a1 <- map(.x = time_ranges, ~ mf_get_url(
#'   collection = "MOD11A1.061",
#'   variables = c("LST_Day_1km", "LST_Night_1km", "QC_Day", "QC_Night"),
#'   roi = roi,
#'   time_range = .x,
#'   opt_param = opt_param_mod11a1
#' )))
#' }
mf_get_opt_param <- function(collection, roi, credentials = NULL, verbose = "inform") {
  . <- odap_coll_info <- odap_source <- odap_server <- odap_timeDimName <- odap_lonDimName <- odap_latDimName <- odap_crs <- odap_urlExample <- modis_tile <- OpendapURL <- OpenDAPtimeVector <- OpenDAPXVector <- OpenDAPYVector <- roi_bbox <- Opendap_minLat <- Opendap_maxLat <- Opendap_minLon <- Opendap_maxLon <- roiSpatialIndexBound <- minLat <- maxLat <- minLon <- maxLon <- roiSpatialBound <- availableDimensions <- null_elements <- NULL

  OpenDAPtimeVector <- modis_tile <- NULL


  ## define useful function
  .mf_get_opt_param_singleROIfeature <- function(OpenDAPYVector, OpenDAPXVector, roi_bbox) {
    Opendap_minLat <- which.min(abs(OpenDAPYVector - roi_bbox$ymax))
    Opendap_maxLat <- which.min(abs(OpenDAPYVector - roi_bbox$ymin))
    Opendap_minLon <- which.min(abs(OpenDAPXVector - roi_bbox$xmin))
    Opendap_maxLon <- which.min(abs(OpenDAPXVector - roi_bbox$xmax))
    roiSpatialIndexBound <- c(Opendap_minLat, Opendap_maxLat, Opendap_minLon, Opendap_maxLon)

    minLon <- OpenDAPXVector[Opendap_minLon]
    maxLon <- OpenDAPXVector[Opendap_maxLon]
    minLat <- OpenDAPYVector[Opendap_minLat]
    maxLat <- OpenDAPYVector[Opendap_maxLat]
    roiSpatialBound <- c(maxLat, minLat, minLon, maxLon)

    return(list(roiSpatialIndexBound = roiSpatialIndexBound, roiSpatialBound = roiSpatialBound))
  }

  ## tests :
  .testIfCollExists(collection)
  .testRoi(roi)
  .testInternetConnection()
  .testLogin(credentials)

  ## Retrieve opendap information for the collection of interest
  odap_coll_info <- opendapMetadata_internal[which(opendapMetadata_internal$collection == collection), ]

  ## Split ROI into single parts
  roi_div <- roi %>%
    sf::st_transform(odap_coll_info$crs) %>%
    split(f = seq(nrow(.)))

  ### GMP and SMAP and SRTM
  if (odap_coll_info$source %in% c("GPM", "SMAP", "SRTM", "CHIRPS")) {
    if (odap_coll_info$source %in% c("GPM", "CHIRPS")) {
      OpendapURL <- odap_coll_info$url_opendapexample
    } else if (odap_coll_info$source == "SMAP") {
      OpendapURL <- "https://n5eil02u.ecs.nsidc.org/opendap/hyrax/SMAP/SPL4CMDL.004/2016.01.06/SMAP_L4_C_mdl_20160106T000000_Vv4040_001.h5"
      odap_coll_info$dim_lon <- "x"
      odap_coll_info$dim_lat <- "y"
    }

    OpenDAPXVector <- .getVarVector(OpendapURL, odap_coll_info$dim_lon)
    OpenDAPYVector <- .getVarVector(OpendapURL, odap_coll_info$dim_lat)

    roi_div_bboxes <- purrr::map(roi_div, ~ sf::st_bbox(.))
    list_roiSpatialIndexBound <- purrr::map(roi_div_bboxes, ~ .mf_get_opt_param_singleROIfeature(OpenDAPYVector, OpenDAPXVector, .)$roiSpatialIndexBound)
    list_roiSpatialBound <- purrr::map(roi_div_bboxes, ~ .mf_get_opt_param_singleROIfeature(OpenDAPYVector, OpenDAPXVector, .)$roiSpatialBound)
    list_roi_id <- roi$id

    ### MODIS
  } else if (odap_coll_info$source %in% c("MODIS", "VIIRS")) {
    if (odap_coll_info$provider == "NASA USGS LP DAAC") {
      tiling <- modis_tiles
      modis_tile <- purrr::map(roi_div, ~ .getMODIStileNames(., "modis"))
      modis_tile_numbers <- purrr::map(modis_tile, purrr::pluck("all_modis_tiles"))
      roi_ids <- purrr::map(modis_tile, purrr::pluck("roi_id"))
      OpendapURL <- purrr::map(modis_tile_numbers, ~ purrr::map_chr(., ~ paste0(odap_coll_info$url_opendapserver, collection, "/", ., ".ncml")))
      OpenDAPtimeVector <- purrr::map(OpendapURL, ~ purrr::map(., ~ .getVarVector(., odap_coll_info$dim_time)))
      OpenDAPtimeVector <- purrr::flatten(OpenDAPtimeVector)
      OpenDAPtimeVector <- purrr::discard(OpenDAPtimeVector, is.null)
    } else if (odap_coll_info$provider == "NASA LAADS DAAC") {
      tiling <- suomi_tiles
      modis_tile <- purrr::map(roi_div, ~ .getMODIStileNames(., "suomi"))
      modis_tile_numbers <- purrr::map(modis_tile, purrr::pluck("all_modis_tiles"))
      roi_ids <- purrr::map(modis_tile, purrr::pluck("roi_id"))
      lines <- readLines(paste0(odap_coll_info$url_opendapserver, "/", odap_coll_info$collection, "/2013/019/", "catalog.xml"))
      OpendapURL <- purrr::map(modis_tile_numbers, ~ purrr::map_chr(., ~ paste0(odap_coll_info$url_opendapserver, odap_coll_info$collection, "/2013/019/", .getVNPladswebdataname(lines, .))))
    }

    OpenDAPXVector <- purrr::map(OpendapURL, ~ purrr::map(., ~ .getVarVector(., odap_coll_info$dim_lon)))
    OpenDAPYVector <- purrr::map(OpendapURL, ~ purrr::map(., ~ .getVarVector(., odap_coll_info$dim_lat)))

    # roi_div <- purrr::map(roi_div,~sf::st_bbox(.))

    sf::st_agr(tiling) <- "constant"

    roi_div_bboxes <- roi_div %>%
      purrr::map(., ~ sf::st_set_agr(., "constant")) %>%
      purrr::map(., ~ sf::st_transform(., 4326)) %>%
      purrr::map(., ~ sf::st_bbox(.)) %>%
      purrr::map(., ~ sf::st_as_sfc(.)) %>%
      purrr::map(., ~ sf::st_sf(.)) %>%
      purrr::map(., ~ sf::st_intersection(., tiling)) %>%
      purrr::map(., ~ sf::st_transform(., odap_coll_info$crs)) %>%
      purrr::map(., ~ split(., f = seq(nrow(.)))) %>%
      purrr::modify_depth(., 2, ~ sf::st_bbox(.))

    OpenDAPYVector <- purrr::flatten(OpenDAPYVector)
    OpenDAPXVector <- purrr::flatten(OpenDAPXVector)
    roi_div_bboxes <- purrr::flatten(roi_div_bboxes)
    modis_tile <- purrr::flatten(modis_tile_numbers)
    list_roi_id <- purrr::flatten(roi_ids)

    null_elements <- which(lengths(OpenDAPYVector) == 0)

    if (length(null_elements) > 0) {
      roi_div_bboxes <- roi_div_bboxes[-null_elements]
      modis_tile <- modis_tile[-null_elements]
      list_roi_id <- list_roi_id[-null_elements]
    }

    OpenDAPYVector <- purrr::discard(OpenDAPYVector, is.null)
    OpenDAPXVector <- purrr::discard(OpenDAPXVector, is.null)


    list_roiSpatialIndexBound <- purrr::pmap(
      list(OpenDAPYVector, OpenDAPXVector, roi_div_bboxes),
      ~ .mf_get_opt_param_singleROIfeature(..1, ..2, ..3)$roiSpatialIndexBound
    )

    # if (odap_coll_info$crs=="+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"){
    # list_roiSpatialIndexBound <- purrr::map(list_roiSpatialIndexBound,~replace(.,. > 1199,1199))
    list_roiSpatialIndexBound <- purrr::map2(.x = list_roiSpatialIndexBound, .y = OpenDAPXVector, ~ replace(.x, .x >= length(.y), length(.y) - 1))
    # } else if (odap_coll_info$crs=="+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"){
    # list_roiSpatialIndexBound <- purrr::map(list_roiSpatialIndexBound,~replace(.,. > 2399,2399))
    # }


    # 40 is an arbitrary threshold... could be more but not less
    list_roiSpatialIndexBound <- purrr::map2(list_roiSpatialIndexBound, OpenDAPXVector, ~ {
      x <- .x
      len <- length(.y)

      x[1] <- ifelse(x[1] <= 40, 0, ifelse(x[1] >= len - 40, len - 40, x[1]))
      x[2] <- ifelse(x[2] <= 40, 40, ifelse(x[2] >= len - 40, len - 1, x[2]))
      x[3] <- ifelse(x[3] <= 40, 0, ifelse(x[3] >= len - 40, len - 40, x[3]))
      x[4] <- ifelse(x[4] <= 40, 40, ifelse(x[4] >= len - 40, len - 1, x[4]))

      return(x)
    })

    ## above is equal to :
    # for(i in 1:length(list_roiSpatialIndexBound)){
    #
    #   if(list_roiSpatialIndexBound[[i]][1] <= 40){ list_roiSpatialIndexBound[[i]][1] = 0}
    #   if(list_roiSpatialIndexBound[[i]][2] <= 40){ list_roiSpatialIndexBound[[i]][2] = 40}
    #   if(list_roiSpatialIndexBound[[i]][3] <= 40){ list_roiSpatialIndexBound[[i]][3] = 0}
    #   if(list_roiSpatialIndexBound[[i]][4] <= 40){ list_roiSpatialIndexBound[[i]][4] = 40}
    #
    #   if(list_roiSpatialIndexBound[[i]][1] >= length(OpenDAPXVector[[i]])-40){ list_roiSpatialIndexBound[[i]][1] = length(OpenDAPXVector[[i]])-40}
    #   if(list_roiSpatialIndexBound[[i]][2] >= length(OpenDAPXVector[[i]])-40){ list_roiSpatialIndexBound[[i]][2] = length(OpenDAPXVector[[i]])-1}
    #   if(list_roiSpatialIndexBound[[i]][3] >= length(OpenDAPXVector[[i]])-40){ list_roiSpatialIndexBound[[i]][3] = length(OpenDAPXVector[[i]])-40}
    #   if(list_roiSpatialIndexBound[[i]][4] >= length(OpenDAPXVector[[i]])-40){ list_roiSpatialIndexBound[[i]][4] = length(OpenDAPXVector[[i]])-1}
    #
    # }

    list_roiSpatialBound <- NULL
  }

  availableVariables <- mf_list_variables(collection)

  return(list(roiSpatialIndexBound = list_roiSpatialIndexBound, availableVariables = availableVariables, roiSpatialBound = list_roiSpatialBound, OpenDAPXVector = OpenDAPXVector, OpenDAPYVector = OpenDAPYVector, OpenDAPtimeVector = OpenDAPtimeVector, modis_tile = modis_tile, roiId = list_roi_id))
}
