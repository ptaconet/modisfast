#' @name .getMODIStileNames
#' @aliases .getMODIStileNames
#' @title Get MODIS tile(s) intersecting a given ROI
#' @description Get MODIS tile(s) intersecting a given ROI
#'
#' @inheritParams mf_get_url
#'
#' @return a character string vector with the MODIS tiles intersecting the ROI
#'
#' @details
#'
#' If the ROI is covering multiple MODIS tiles, consider splitting the ROI into multiple parts (1 for each MODIS tile) before executing the \code{mf_get_url} function.
#' Then loop \code{mf_get_url} over each part. Check out the example for some tips on how to proceed.
#'
#' @note
#' The function uses the MODIS tile gridding system available at https://modis.ornl.gov/files/modis_sin.kmz . The same dataset is available in the package through modisfast::modis_tiles
#'
#' @importFrom magrittr %>%
#' @import sf dplyr
#' @noRd



.getMODIStileNames <- function(roi, type) {
  . <- Name <- NULL

  .testRoi(roi)

  roi_id <- roi$id

  # modis_tile = sf::read_sf("https://modis.ornl.gov/files/modis_sin.kmz") %>%
  if (type == "modis") {
    tiling_system <- modis_tiles
  } else if (type == "suomi") {
    tiling_system <- suomi_tiles
  }

  sf::st_agr(tiling_system) <- "constant"
  sf::st_agr(roi) <- "constant"

  roi <- sf::st_transform(roi, 4326) %>%
    sf::st_bbox() %>%
    sf::st_as_sfc()

  modis_tile <- tiling_system %>%
    sf::st_intersection(roi) %>%
    dplyr::filter(sf::st_is(., "POLYGON")) %>%
    as.data.frame() %>%
    dplyr::select(Name)

  modis_tile <- modis_tile$Name

  all_modis_tiles <- NULL
  for (i in seq_along(modis_tile)) {
    th_modis_tile <- modis_tile[i] %>%
      unique() %>%
      stringr::str_replace_all(c(" " = "", ":" = ""))
    for (i in 1:9) {
      th_modis_tile <- gsub(paste0("h", i, "v"), paste0("h0", i, "v"), th_modis_tile)
    }
    if (nchar(th_modis_tile) != 6) {
      th_modis_tile <- paste0(substr(th_modis_tile, 1, 4), "0", substr(th_modis_tile, 5, 5))
    }
    all_modis_tiles <- c(all_modis_tiles, th_modis_tile)
  }

  roi_id <- rep(roi_id, length(all_modis_tiles))

  return(list(all_modis_tiles = all_modis_tiles, roi_id = roi_id))
}
