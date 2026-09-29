#' Find download URLs for MODIS, VIIRS and GPM data
#'
#' Find the files covering your area and dates, and create URLs to download
#' only the selected bands and area. Use [mf_download_data()] to download them.
#'
#' Set `EARTHDATA_TOKEN` to your Earthdata token before calling this function.
#'
#' @param collection Collection identifier, e.g. `"MOD11A1.061"`,
#'   `"VNP43MA4.002"` or `"GPM_3IMERGDF.07"`.
#' @param variables One or more band names to retrieve, as returned by
#'   [mf_list_variables()].
#' @param roi An `sf` polygon with an `id` column.
#' @param time_range One date or two bounding dates.
#' @param collection_id Optional Earthdata Cloud collection ID. Usually leave
#'   this empty; the package finds it in its collection catalogue. Not used for GPM.
#' @param verbose Character string: `"quiet"`, `"inform"` (default), or
#'   `"debug"`. Controls progress messages; `"debug"` also shows request details.
#' @return A data frame with the download URLs for [mf_download_data()].
#' @export
#' @examples
#' \dontrun{
#' Sys.setenv(EARTHDATA_TOKEN = "your Earthdata bearer token")
#' roi <- sf::st_as_sf(data.frame(id = "test", geom =
#'   "POLYGON ((3.8 43.5, 4 43.5, 4 43.7, 3.8 43.7, 3.8 43.5))"),
#'   wkt = "geom", crs = 4326)
#' time_range <- as.Date(c("2026-01-01", "2026-01-30"))
#' urls_vj121a2 <- mf_get_url("VJ121A2.002",
#'   c("LST_Day_1KM", "LST_Night_1KM"), roi, time_range)
#' mf_download_data(urls_vj121a2)
#' }
mf_get_url <- function(collection, variables = NULL, roi, time_range,
                       collection_id = NULL, verbose = "inform") {
  .mf_check_verbose(verbose)
  .mf_require_token("mf_get_url")
  if (verbose != "quiet") cat("Building the URLs...\n")
  if (!is.character(collection) || length(collection) != 1L ||
      is.na(collection) || !nzchar(collection)) {
    .mf_unknown_collection(collection)
  }
  if (missing(roi)) {
    stop("roi must be a non-empty sf object containing polygon features ",
         "and an id column.")
  }
  .testRoi(roi)
  if (missing(time_range)) {
    stop("time_range must be one Date or two ordered Dates; for example, ",
         "as.Date(c('2026-01-01', '2026-01-30')).")
  }
  .testTimeRange(time_range)
  if (!is.character(variables) || !length(variables) || anyNA(variables) ||
      any(!nzchar(variables))) {
    stop("Provide at least one variable name. Run mf_list_variables(\"",
         collection, "\") to get the list of available variables.")
  }
  if (is.null(.mf_cloud_collection_source(collection))) {
    info <- .mf_collection_metadata(collection)
    if (nrow(info) == 1L && info$source == "GPM") {
      if (!is.null(collection_id)) {
        stop("collection_id applies only to LP DAAC Cloud collections.")
      }
      return(.mf_get_url_gpm(collection, variables, roi, time_range, verbose))
    }
    .mf_unknown_collection(collection)
  }
  dates <- as.Date(time_range)
  if (length(dates) == 1L) dates <- rep(dates, 2L)
  if (length(dates) != 2L || anyNA(dates) || dates[1] > dates[2]) {
    stop("time_range must contain one date or two ordered dates.")
  }
  collection_id <- .mf_cloud_collection_id(collection, collection_id)

  available <- mf_list_variables(collection, backend = "cloud",
                                 time_range = dates, collection_id = collection_id,
                                 verbose = "quiet")
  .testIfVarExists(variables, available$name[
    available$extractable_with_modisfast == "extractable"])

  rows <- list()
  for (i in seq_len(nrow(roi))) {
    one <- roi[i, ]
    tile_names <- .getMODIStileNames(one, "modis")$all_modis_tiles
    if (!length(tile_names)) next
    bbox <- sf::st_bbox(sf::st_transform(one, 4326))
    bbox_string <- paste(bbox[c("xmin", "ymin", "xmax", "ymax")], collapse = ",")
    page <- 1L
    repeat {
      response <- .mf_cloud_json("https://cmr.earthdata.nasa.gov/search/granules.json",
        list(collection_concept_id = collection_id,
             temporal = paste0(format(dates[1], "%Y-%m-%d"), "T00:00:00Z,",
                               format(dates[2], "%Y-%m-%d"), "T23:59:59Z"),
             bounding_box = bbox_string, page_size = 2000L, page_num = page))
      entries <- response$feed$entry
      if (!length(entries)) break
      for (entry in entries) {
        granule <- entry$producer_granule_id
        tile <- regmatches(granule, regexpr("h[0-9]{2}v[0-9]{2}", granule))
        if (!length(tile) || !tile %in% tile_names) next
        # Share CMR link resolution with the cloud availability checker.
        base <- .mf_cloud_granule_base(entry, collection_id)
        if (is.null(base)) next
        metadata <- .mf_cloud_dds(base)
        granule_variables <- .mf_cloud_dds_variables(metadata)
        .testIfVarExists(variables, granule_variables$name[
          granule_variables$extractable_with_modisfast == "extractable"])
        specs <- lapply(variables, .mf_cloud_variable, doc = metadata)
        sizes <- vapply(specs, function(spec) spec$size, integer(2))
        if (is.null(dim(sizes))) sizes <- matrix(sizes, nrow = 2L)
        if (any(sizes[1, ] != sizes[1, 1]) || any(sizes[2, ] != sizes[2, 1])) {
          stop("Selected variables have different grids; request them separately.")
        }
        indices <- .mf_cloud_indices(one, tile, sizes[1, 1], sizes[2, 1])
        if (is.null(indices)) next
        selections <- vapply(specs, function(spec) paste0(spec$path,
          "[", indices[1], ":", indices[2], "]",
          "[", indices[3], ":", indices[4], "]"), character(1))
        day <- as.Date(sub("^.*\\.A([0-9]{7})\\..*$", "\\1", granule), format = "%Y%j")
        if (is.na(day)) day <- as.Date(substr(entry$time_start, 1, 10))
        rows[[length(rows) + 1L]] <- data.frame(
          id_roi = as.character(one$id), time_start = day,
          collection = collection,
          name = paste0(basename(base), "_",
                        paste(variables, collapse = "-"), ".nc4"),
          url = paste0(base, ".nc4?",
                       gsub("]", "%5D", gsub("[", "%5B",
                         paste(selections, collapse = ","), fixed = TRUE),
                         fixed = TRUE)),
          grid_nrow = sizes[1, 1], grid_ncol = sizes[2, 1],
          maxFileSizeEstimated = prod(c(indices[2] - indices[1] + 1L,
                                        indices[4] - indices[3] + 1L)) *
            length(variables) * 4, stringsAsFactors = FALSE)
      }
      if (length(entries) < 2000L) break
      page <- page + 1L
    }
  }
  if (!length(rows)) {
    stop("No OPeNDAP granules intersect the requested dates and ROI in ", collection_id)
  }
  out <- do.call(rbind, rows)
  out[order(out$id_roi, out$time_start, out$name), , drop = FALSE]
}

.mf_cloud_json <- function(url, query) {
  response <- httr::GET(url, query = query)
  httr::stop_for_status(response)
  jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"),
                     simplifyVector = FALSE)
}

.mf_cloud_collection_id <- function(collection, collection_id = NULL,
                                    catalog_path = system.file(
                                      "extdata", "data_collections_cloud.csv",
                                      package = "modisfast")) {
  if (is.null(collection_id)) {
    catalogue <- .mf_cloud_catalogue(catalog_path)
    matches <- which(catalogue$collection == collection)
    if (length(matches) != 1L) {
      stop("Collection '", collection, "' is not in the bundled Cloud ",
           "catalogue. Run mf_list_collections_cloud() to see available ",
           "collections. Provide collection_id explicitly if known.")
    }
    collection_id <- catalogue$collection_id[matches]
  }
  if (!is.character(collection_id) || length(collection_id) != 1L ||
      is.na(collection_id) || !grepl("^C[0-9]+-LPCLOUD$", collection_id)) {
    stop("collection_id must be an LPCLOUD CMR collection concept ID ",
         "(C...-LPCLOUD). Check the Cloud catalogue or supply it explicitly.")
  }
  collection_id
}

.mf_cloud_catalogue <- function(catalog_path = system.file(
                                  "extdata", "data_collections_cloud.csv",
                                  package = "modisfast")) {
  if (!nzchar(catalog_path) || !file.exists(catalog_path)) {
    stop("The bundled Cloud collection catalogue is missing. Reinstall modisfast.")
  }
  catalogue <- utils::read.csv(catalog_path, stringsAsFactors = FALSE)
  if (!all(c("collection", "collection_id", "source") %in% names(catalogue))) {
    stop("The Cloud collection catalogue lacks collection, collection_id or source.")
  }
  catalogue
}

.mf_cloud_collection_source <- function(collection,
                                        catalog_path = system.file(
                                          "extdata", "data_collections_cloud.csv",
                                          package = "modisfast")) {
  if (!is.character(collection) || length(collection) != 1L ||
      is.na(collection)) return(NULL)
  if (grepl("^GPM_", collection)) return(NULL)
  if (nzchar(catalog_path) && file.exists(catalog_path)) {
    catalogue <- .mf_cloud_catalogue(catalog_path)
    matches <- which(catalogue$collection == collection &
      grepl("^C[0-9]+-LPCLOUD$", catalogue$collection_id) &
      catalogue$source %in% c("MODIS", "VIIRS"))
    if (length(matches) == 1L) return(catalogue$source[matches])
  }
  # Still permit an explicit collection_id for products absent from the CSV.
  metadata <- opendapMetadata_internal
  row <- metadata[metadata$collection == collection, , drop = FALSE]
  if (nrow(row) == 1L && grepl("LP DAAC", row$provider, fixed = TRUE) &&
      row$source == "MODIS") return("MODIS")
  # CMR checks the provider, existence and exact version before URL creation.
  if (grepl("^V(NP|J[12])[A-Z0-9]+\\.002$", collection)) return("VIIRS")
  NULL
}

.mf_cloud_base_url <- function(url) {
  base <- sub("\\?.*$", "", url)
  # CMR links may already point to metadata or to a data representation.
  # Remove the entire response suffix, not only the final '.html' or '.nc4'.
  base <- sub("\\.(dmr\\.html|dap\\.nc4|dmr|html|nc4)$", "", base,
              ignore.case = TRUE)
  sub("\\.(hdf|h5)$", "", base, ignore.case = TRUE)
}

.mf_cloud_dds <- function(base) {
  token <- Sys.getenv("EARTHDATA_TOKEN", unset = "")
  if (!nzchar(token)) {
    stop("Set EARTHDATA_TOKEN to an Earthdata bearer token before querying Cloud OPeNDAP.")
  }
  response <- httr::GET(paste0(base, ".dds"),
                        httr::add_headers(Authorization = paste("Bearer", token)))
  if (httr::http_error(response)) {
    body <- httr::content(response, "text", encoding = "UTF-8")
    if (httr::status_code(response) == 404L &&
        grepl("dmrpp_read_from_daac_bucket|\\.(hdf|h5)\\.dmrpp", body)) {
      stop("Cloud OPeNDAP cannot access the DMR++ metadata for ", base,
           "The server reports missing DMR++ metadata for this granule. ",
           "Other dates in the same collection may still work: ",
           "try a different time range. To obtain this specific granule, ",
           "try Earthdata Search or AppEEARS, or report the issue to LP DAAC.")
    }
    if (httr::status_code(response) == 404L &&
        grepl("does not identify a granule in CMR", body, fixed = TRUE)) {
      stop("Cloud OPeNDAP cannot identify the granule in CMR for ", base,
           ". Check that the CMR link points to this collection and granule.")
    }
    stop("Cloud OPeNDAP returned HTTP ", httr::status_code(response),
         " for ", base, ".dds. Check this granule URL in a browser.")
  }
  content_type <- httr::headers(response)[["content-type"]]
  if (!is.null(content_type) && grepl("text/html", content_type, fixed = TRUE)) {
    stop("The DDS request returned HTML; check Earthdata authorization.")
  }
  httr::content(response, "text", encoding = "UTF-8")
}

.mf_cloud_variable <- function(variable, doc) {
  lines <- strsplit(doc, "\n", fixed = TRUE)[[1]]
  declaration <- lines[grepl(paste0("/", variable, "["), lines, fixed = TRUE)]
  if (length(declaration) != 1L) {
    stop("Expected exactly one DDS variable named ", variable)
  }
  path <- sub("\\[.*$", "", sub("^[[:space:]]*[^[:space:]]+[[:space:]]+",
                               "", declaration))
  dimensions <- regmatches(declaration,
                            gregexpr("\\[[^]]+\\]", declaration))[[1]]
  if (length(dimensions) != 2L) {
    stop("Cloud subsetting currently requires a 2D variable: ", variable)
  }
  size <- as.integer(sub(".*=[[:space:]]*([0-9]+)\\]", "\\1", dimensions))
  if (anyNA(size)) stop("Cannot determine the grid dimensions of ", variable)
  list(path = path, size = size)
}

.mf_cloud_indices <- function(roi, tile, nrow, ncol) {
  # Standard MODIS/VIIRS sinusoidal grid: 36 x 18 ten-degree tiles.
  width <- 1111950.5196666666
  h <- as.integer(substr(tile, 2, 3))
  v <- as.integer(substr(tile, 5, 6))
  left <- -18 * width + h * width
  top <- 9 * width - v * width
  box <- sf::st_bbox(sf::st_transform(roi,
    "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"))
  x <- pmax(0L, pmin(ncol - 1L, c(floor((box$xmin - left) * ncol / width),
                                      ceiling((box$xmax - left) * ncol / width) - 1L)))
  y <- pmax(0L, pmin(nrow - 1L, c(floor((top - box$ymax) * nrow / width),
                                      ceiling((top - box$ymin) * nrow / width) - 1L)))
  if (box$xmax <= left || box$xmin >= left + width ||
      box$ymin >= top || box$ymax <= top - width) return(NULL)
  as.integer(c(y, x))
}
