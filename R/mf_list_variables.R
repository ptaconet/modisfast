#' @name mf_list_variables
#' @aliases mf_list_variables
#' @title Get information for the variables (bands) available for a given collection
#' @description Get the variables available for a given collection, along with a set of related information for each.
#'
#' @inheritParams mf_get_url
#' @param backend `"auto"` (default) chooses the service for the collection.
#'   `"cloud"` selects Earthdata Cloud; `"legacy"` selects GPM's GES DISC service.
#' @param time_range Optional date or pair of dates used to find a Cloud
#'   granule. Only used for Cloud collections.
#' @param collection_id Optional Earthdata Cloud collection ID. Usually leave
#'   this empty; the package looks it up. Only used for Cloud collections.
#' @param n_granules Maximum number of recent Cloud files to try (default 10).
#'
#' @return A data.frame with the variables available for the collection, and a set of related information for each variable.
#' The variables marked as "extractable" in the column "extractable_with_modisfast" can be provided as input parameter \code{variables} of \link{mf_get_url}. Cloud metadata comes from one accessible granule's DDS; it lists its two-dimensional fields but does not supply long names or units.
#'
#' @export
#'
#' @importFrom rvest html_table
#' @importFrom xml2 read_html
#' @importFrom stringr str_match word
#' @import purrr dplyr httr
#' @examples
#' \dontrun{
#' # Configure an Earthdata bearer token for Cloud OPeNDAP.
#' Sys.setenv(EARTHDATA_TOKEN = "your Earthdata bearer token")
#'
#' time_range <- as.Date(c("2026-01-01", "2026-01-30"))
#' bands <- mf_list_variables("VJ121A2.002", time_range = time_range)
#' subset(bands, name %in% c("LST_Day_1KM", "LST_Night_1KM"))
#' }
#'
mf_list_variables <- function(collection, verbose = "inform",
                              backend = c("auto", "cloud", "legacy"),
                              time_range = NULL, collection_id = NULL,
                              n_granules = 10L) { # for a given collection, get the available variables and associated information

  .mf_check_verbose(verbose)
  .mf_require_token("mf_list_variables")
  if (!is.character(collection) || length(collection) != 1L ||
      is.na(collection) || !nzchar(collection)) {
    .mf_unknown_collection(collection)
  }
  backend <- match.arg(backend)
  if (backend == "auto") {
    backend <- if (is.null(.mf_cloud_collection_source(collection))) "legacy" else "cloud"
  }
  if (backend == "cloud") {
    return(.mf_cloud_list_variables(collection, time_range, collection_id,
                                    n_granules, verbose))
  }

  if (backend == "legacy" &&
      !identical(.mf_collection_metadata(collection)$source, "GPM")) {
    .mf_unknown_collection(collection)
  }
  .testIfCollExists(collection)
  .testInternetConnection()
  auth <- .mf_earthdata_auth()

  opendapMetadata <- .mf_collection_metadata(collection)

  URL <- opendapMetadata$url_opendapexample
  if (length(URL) != 1L || is.na(URL) || !nzchar(URL)) {
    stop("No example OPeNDAP granule URL is configured for ", collection, ".")
  }
  if (identical(opendapMetadata$source, "GPM")) {
    return(.mf_gpm_list_variables(URL, auth, opendapMetadata, verbose))
  }

  InfoURL <- paste0(URL, ".info")
  f <- function(url) {
    httr::GET(url, auth)
  }
  if(verbose %in% c("quiet","inform")){
    vector_response <- f(InfoURL)
  } else if (verbose == "debug"){
    vector_response <- httr::with_verbose(f(InfoURL))
  }
  httr::stop_for_status(vector_response)
  httr::warn_for_status(vector_response)
  if (vector_response$status_code == 400) {
    stop("Bad request\n")
  }
  vector_content <- httr::content(vector_response, "text", encoding = "UTF-8")
  vector_html <- xml2::read_html(vector_content)
  tab <- rvest::html_table(vector_html)
  if (purrr::is_empty(tab)) {
    stop("The server might be temporarily unavailable. Try again later. Paste ", InfoURL, " to check the error message in your brower\n")
  }
  tab <- tab[[length(tab)]]
  colnames(tab) <- c("name", "all_info")
  tab$name <- gsub(":", "", tab$name)
  tab$long_name <- stringr::str_match(tab$all_info, "long_name: (.*?)\n")[, 2]
  tab$units <- stringr::str_match(tab$all_info, "units: (.*?)\n")[, 2]

  DdsURL <- paste0(URL, ".dds")
  if(verbose %in% c("quiet","inform")){
    vector_response <- f(DdsURL)
  } else if (verbose == "debug"){
    vector_response <- httr::with_verbose(f(DdsURL))
  }
  httr::stop_for_status(vector_response)
  httr::warn_for_status(vector_response)

  vector <- httr::content(vector_response, "text", encoding = "UTF-8")
  vector <- strsplit(vector, "\n")
  vector <- vector[[1]][-length(vector[[1]])]
  vector <- vector[-1]
  vector <- gsub("    ", "", vector)
  vector <- gsub(";", "", vector)

  variables <- gsub("\\[", " \\[", vector)

  indices <- gsub(" = ", "=", variables)
  indices <- purrr::map_chr(indices, ~ stringr::word(., 3, -1))
  indices <- gsub("=", " = ", indices)

  variables <- purrr::map_chr(variables, ~ stringr::word(., 2))

  variables_indices <- data.frame(name = variables, indices = indices, stringsAsFactors = FALSE)

  tab <- dplyr::left_join(tab, variables_indices, by = "name")

  # add a column to specify whether the variable is extractable or not with modisfast

  dim_lon <- opendapMetadata$dim_lon
  dim_lat <- opendapMetadata$dim_lat
  dim_time <- opendapMetadata$dim_time
  dim_proj <- opendapMetadata$dim_proj

  tab <- tab %>%
    dplyr::mutate(extractable_with_modisfast = dplyr::case_when(
      name %in% c(dim_lon, dim_lat, dim_time, dim_proj) ~ "automatically extracted",
      grepl(dim_lon, tab$indices) & grepl(dim_lat, tab$indices) & grepl(dim_time, tab$indices) & !is.na(dim_time) ~ "extractable",
      grepl(dim_lon, tab$indices) & grepl(dim_lat, tab$indices) & is.na(dim_time) ~ "extractable"
    ))

  tab$extractable_with_modisfast[which(is.na(tab$extractable_with_modisfast))] <- "not extractable"

  if (opendapMetadata$source == "SMAP") {
    tab$extractable_with_modisfast[which(tab$extractable_with_modisfast == "not extractable")] <- "extractable"
  }


  tab <- tab[c("name", "long_name", "units", "indices", "all_info", "extractable_with_modisfast")]

  return(tab)
}

.mf_cloud_list_variables <- function(collection, time_range, collection_id,
                                     n_granules, verbose) {
  if (is.null(.mf_cloud_collection_source(collection))) {
    .mf_unknown_collection(collection)
  }
  if (!is.numeric(n_granules) || length(n_granules) != 1L ||
      is.na(n_granules) || !is.finite(n_granules) ||
      n_granules < 1L || n_granules > 2000L ||
      n_granules != as.integer(n_granules)) {
    stop("n_granules must be an integer between 1 and 2000.")
  }
  if (!is.null(time_range)) {
    .testTimeRange(time_range)
    dates <- as.Date(time_range)
    if (length(dates) == 1L) dates <- rep(dates, 2L)
    if (length(dates) != 2L || anyNA(dates) || dates[1] > dates[2]) {
      stop("time_range must contain one date or two ordered dates.")
    }
  }
  if (!nzchar(Sys.getenv("EARTHDATA_TOKEN", unset = ""))) {
    stop("Set EARTHDATA_TOKEN before querying Cloud OPeNDAP.")
  }
  collection_id <- .mf_cloud_collection_id(collection, collection_id)
  query <- list(collection_concept_id = collection_id,
                page_size = as.integer(n_granules), page_num = 1L,
                `sort_key[]` = "-start_date")
  if (!is.null(time_range)) {
    query$temporal <- paste0(format(dates[1], "%Y-%m-%d"), "T00:00:00Z,",
                             format(dates[2], "%Y-%m-%d"), "T23:59:59Z")
  }
  granules <- .mf_cloud_json(
    "https://cmr.earthdata.nasa.gov/search/granules.json", query
  )$feed$entry
  if (!length(granules)) {
    stop("No CMR granules found for ", collection, " in the selected dates.")
  }
  failures <- character()
  for (entry in granules) {
    id <- entry$producer_granule_id
    if (is.null(id)) id <- entry$id
    if (is.null(id) || !grepl("h[0-9]{2}v[0-9]{2}", id)) next
    base <- .mf_cloud_granule_base(entry, collection_id)
    if (is.null(base)) next
    if (verbose %in% c("inform", "debug")) message("Reading Cloud DDS for ", id)
    result <- tryCatch(.mf_cloud_dds(base), error = function(e) e)
    if (inherits(result, "error")) {
      # A different granule can be usable even when its DMR++ is missing.
      failures <- c(failures, paste(id, conditionMessage(result)))
      next
    }
    variables <- .mf_cloud_dds_variables(result)
    if (nrow(variables) && any(variables$extractable_with_modisfast == "extractable")) {
      attr(variables, "granule") <- id
      return(variables)
    }
    failures <- c(failures, paste(id, "no unique 2D science field in DDS"))
  }
  if (length(failures)) {
    stop("No accessible two-dimensional Cloud granule found for ", collection,
         " among the ", length(granules), " sampled. Last error: ",
         utils::tail(failures, 1L), ". Try time_range or a larger n_granules.")
  }
  stop("No tiled OPeNDAP granule with a source link found for ", collection,
       " in the sampled CMR records.")
}

.mf_cloud_dds_variables <- function(dds) {
  lines <- strsplit(dds, "\n", fixed = TRUE)[[1]]
  declaration <- lines[grepl(
    "^[[:space:]]*[A-Za-z][A-Za-z0-9]*[[:space:]]+/[^;]+;[[:space:]]*$",
    lines)]
  if (!length(declaration)) {
    return(data.frame(name = character(), long_name = character(),
      units = character(), indices = character(), all_info = character(),
      extractable_with_modisfast = character()))
  }
  path <- sub(";$", "", sub("\\[.*$", "", sub(
    "^[[:space:]]*[^[:space:]]+[[:space:]]+", "", declaration)))
  dims <- regmatches(declaration, gregexpr("\\[[^]]+\\]", declaration))
  name <- basename(path)
  coordinates <- name %in% c("Latitude", "Longitude", "XDim", "YDim",
                              "eos_cf_projection")
  duplicate <- duplicated(name) | duplicated(name, fromLast = TRUE)
  extractable <- lengths(dims) == 2L & !coordinates & !duplicate
  data.frame(name = name, long_name = rep(NA_character_, length(name)),
    units = rep(NA_character_, length(name)),
    indices = vapply(dims, function(x) paste(x, collapse = ""), character(1)),
    all_info = trimws(declaration),
    extractable_with_modisfast = ifelse(coordinates, "automatically extracted",
      ifelse(extractable, "extractable", "not extractable")),
    stringsAsFactors = FALSE)
}
