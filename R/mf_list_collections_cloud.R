#' Check LP DAAC MODIS and VIIRS collections on Earthdata Cloud OPeNDAP
#'
#' CMR is paginated to discover every LPCLOUD collection supported by
#' modisfast. For each collection, the function tests up to `n_granules`
#' granules (newest first), including a single pixel data request. A successful
#' sample does not imply that every granule or date is available.
#'
#' @param collections Optional character vector of collection names, for example
#'   `c("MOD11A1.061", "VNP43MA4.002")`. By default check LP DAAC MODIS
#'   collections from the modisfast catalogue and tiled VIIRS `.002`
#'   collections published by LPCLOUD in CMR.
#' @param time_range Optional one or two Dates restricting sampled granules.
#' @param n_granules Number of granules to check per collection (default 2).
#' @param verbose Character string: `"quiet"`, `"inform"` (default), or
#'   `"debug"`. Controls progress messages.
#' @return A data.frame with collection, collection_id, status, tested,
#'   succeeded, checked_at, and detail. Status is `operational` when all sampled
#'   granules served one pixel, `partial` when only some did, `unavailable` when
#'   none did, and `no_granules` when CMR found none for the chosen dates.
#'   `unverified` means no suitable two-dimensional variable was found. These
#'   statuses apply only to the granules sampled at `checked_at`.
#' @export
#' @examples
#' \dontrun{
#' Sys.setenv(EARTHDATA_TOKEN = "your Earthdata bearer token")
#' status <- mf_list_collections_cloud("VJ121A2.002")
#' subset(status, status == "operational")
#' mf_list_collections_cloud("VJ121A2.002",
#'   time_range = as.Date(c("2026-01-01", "2026-01-30")))
#' }
mf_list_collections_cloud <- function(collections = NULL, time_range = NULL,
                                      n_granules = 2L, verbose = "inform") {
  .mf_check_verbose(verbose)
  if (!is.numeric(n_granules) || length(n_granules) != 1L ||
      is.na(n_granules) || !is.finite(n_granules) ||
      n_granules < 1L || n_granules > 2000L ||
      n_granules != as.integer(n_granules)) {
    stop("n_granules must be an integer between 1 and 2000.")
  }
  if (!is.null(collections) &&
      (!is.character(collections) || anyNA(collections))) {
    stop("collections must be a character vector of collection names.")
  }
  if (!is.null(time_range)) {
    dates <- as.Date(time_range)
    if (length(dates) == 1L) dates <- rep(dates, 2L)
    if (length(dates) != 2L || anyNA(dates) || dates[1] > dates[2]) {
      stop("time_range must contain one date or two ordered dates.")
    }
  }
  token <- Sys.getenv("EARTHDATA_TOKEN", unset = "")
  if (!nzchar(token)) stop("Set EARTHDATA_TOKEN before checking Cloud OPeNDAP.")

  metadata <- opendapMetadata_internal
  lpdaac <- grepl("LP DAAC", metadata$provider, fixed = TRUE)
  modis <- metadata$collection[lpdaac & metadata$source == "MODIS"]
  supported <- unique(modis)
  if (!is.null(collections)) {
    unknown <- collections[!collections %in% supported &
      !grepl("^V(NP|J[12])[A-Z0-9]+\\.002$", collections)]
    if (length(unknown)) stop("Unsupported LP DAAC cloud collections: ",
                              paste(unknown, collapse = ", "))
  }

  # Page through CMR instead of trusting the package's historical catalogue.
  cmr <- list()
  page <- 1L
  repeat {
    entries <- .mf_cloud_json(
      "https://cmr.earthdata.nasa.gov/search/collections.json",
      list(provider = "LPCLOUD", page_size = 2000L, page_num = page)
    )$feed$entry
    if (!length(entries)) break
    cmr <- c(cmr, entries)
    if (length(entries) < 2000L) break
    page <- page + 1L
  }
  candidates <- Filter(function(x) {
    name <- paste0(x$short_name, ".", x$version_id)
    (name %in% supported || grepl("^V(NP|J[12])[A-Z0-9]+\\.002$", name)) &&
      (is.null(collections) || name %in% collections)
  }, cmr)
  if (!length(candidates)) stop("No requested supported LPCLOUD collections in CMR.")
  candidates <- candidates[!duplicated(vapply(candidates, function(x) {
    paste0(x$short_name, ".", x$version_id)
  }, character(1)))]
  candidates <- candidates[order(vapply(candidates, function(x) {
    paste0(x$short_name, ".", x$version_id)
  }, character(1)))]

  results <- lapply(candidates, function(x) {
    name <- paste0(x$short_name, ".", x$version_id)
    if (verbose != "quiet") message("Checking ", name, " (", x$id, ")")
    query <- list(collection_concept_id = x$id,
                  page_size = as.integer(n_granules), page_num = 1L,
                  `sort_key[]` = "-start_date")
    if (!is.null(time_range)) {
      query$temporal <- paste0(format(dates[1], "%Y-%m-%d"), "T00:00:00Z,",
                               format(dates[2], "%Y-%m-%d"), "T23:59:59Z")
    }
    checked_at <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    answer <- tryCatch({
      granules <- .mf_cloud_json(
        "https://cmr.earthdata.nasa.gov/search/granules.json", query
      )$feed$entry
      if (!length(granules)) {
        list(status = "no_granules", tested = 0L, succeeded = 0L,
             detail = "No granules in CMR for the selected dates")
      } else {
        checks <- lapply(granules, .mf_cloud_probe_granule, collection_id = x$id,
                         token = token)
        successes <- sum(vapply(checks, function(z) z$status == "ok", logical(1)))
        failures <- vapply(checks, function(z) z$status, character(1))
        status <- if (successes == length(checks)) "operational" else if (
          successes > 0L) "partial" else if (all(failures == "unverified"))
          "unverified" else "unavailable"
        list(status = status, tested = length(checks), succeeded = successes,
             detail = paste(vapply(checks, function(z) z$detail, character(1)),
                            collapse = "; "))
      }
    }, error = function(e) {
      list(status = "unverified", tested = 0L, succeeded = 0L,
           detail = paste("CMR query failed:", conditionMessage(e)))
    })
    data.frame(collection = name, collection_id = x$id,
               status = answer$status, tested = answer$tested,
               succeeded = answer$succeeded, checked_at = checked_at,
               detail = answer$detail, stringsAsFactors = FALSE)
  })
  do.call(rbind, results)
}

.mf_cloud_probe_granule <- function(entry, collection_id, token) {
  id <- entry$producer_granule_id
  if (is.null(id)) id <- entry$id
  result <- tryCatch({
    if (!grepl("h[0-9]{2}v[0-9]{2}", id)) {
      return(list(status = "unverified", detail = paste(id, "not a sinusoidal tile")))
    }
    base <- .mf_cloud_granule_base(entry, collection_id)
    if (is.null(base)) stop("No HDF/HDF5 or OPeNDAP link in CMR")
    dds <- .mf_cloud_dds(base)
    lines <- strsplit(dds, "\n", fixed = TRUE)[[1]]
    # Select a two-dimensional science field, excluding coordinate arrays.
    fields <- lines[grepl("\\[[^]]+\\]\\[[^]]+\\];", lines) &
                      grepl("/", lines, fixed = TRUE) &
                      !grepl("/(Latitude|Longitude|XDim|YDim)\\[", lines)]
    if (!length(fields)) {
      return(list(status = "unverified", detail = paste(id, "no 2D data field")))
    }
    variable <- sub("\\[.*$", "", sub("^[[:space:]]*[^[:space:]]+[[:space:]]+",
                                  "", fields[1]))
    selection <- paste0(variable, "%5B0:0%5D%5B0:0%5D")
    response <- httr::GET(paste0(base, ".ascii?", selection),
                          httr::add_headers(Authorization = paste("Bearer", token)))
    body <- httr::content(response, "text", encoding = "UTF-8")
    content_type <- httr::headers(response)[["content-type"]]
    if (httr::http_error(response) || !nzchar(body) ||
        grepl("^[[:space:]]*Error[[:space:]]*\\{", body) ||
        isTRUE(grepl("text/html", content_type, fixed = TRUE))) {
      stop("one-pixel data request returned HTTP ", httr::status_code(response))
    }
    list(status = "ok", detail = paste(id, "one pixel served"))
  }, error = function(e) {
    # Never include server response bodies: they can contain signed S3 URLs.
    reason <- conditionMessage(e)
    reason <- sub("^.*Cloud OPeNDAP returned HTTP ([0-9]+).*$",
                  "OPeNDAP HTTP \\1", reason)
    if (grepl("DMR\\+\\+ metadata", reason)) reason <- "missing DMR++ metadata"
    if (grepl("cannot identify the granule in CMR", reason, fixed = TRUE)) {
      reason <- "OPeNDAP path does not identify a granule in CMR"
    }
    list(status = "failed", detail = paste(id, reason))
  })
  result
}

.mf_cloud_granule_base <- function(entry, collection_id) {
  links <- vapply(entry$links, function(link) {
    if (is.null(link$href)) "" else link$href
  }, character(1))
  opendap <- links[grepl("^https://opendap\\.earthdata\\.nasa\\.gov/collections/",
                         links)]
  if (!length(opendap)) {
    source <- links[grepl("\\.(hdf|h5)$", links, ignore.case = TRUE)]
    if (!length(source)) return(NULL)
    granule_id <- sub("\\.(hdf|h5)$", "", basename(source[1]),
                      ignore.case = TRUE)
    opendap <- paste0("https://opendap.earthdata.nasa.gov/collections/",
                      collection_id, "/granules/", granule_id)
  }
  .mf_cloud_base_url(opendap[1])
}
