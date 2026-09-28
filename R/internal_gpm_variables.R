# DAP2 .dds declares each variable exactly once. HTML .info has nested tables
# and can repeat coordinate variables, depending on the Hyrax version.
.mf_gpm_list_variables <- function(base, auth, metadata, verbose) {
  fetch <- function(suffix) {
    request <- function() httr::GET(paste0(base, suffix), auth)
    response <- if (identical(verbose, "debug"))
      httr::with_verbose(request()) else request()
    httr::stop_for_status(response)
    httr::content(response, "text", encoding = "UTF-8")
  }
  .mf_gpm_parse_variables(fetch(".dds"), fetch(".das"), metadata)
}

.mf_gpm_parse_variables <- function(dds, das, metadata) {
  lines <- trimws(strsplit(dds, "\n", fixed = TRUE)[[1]])
  # The declaration is: type name[dimension = size]...;
  declaration <- grep("^[A-Za-z][A-Za-z0-9]*[[:space:]]+[^;{}]+;[[:space:]]*$",
                      lines, value = TRUE)
  if (!length(declaration)) stop("No variables found in GPM OPeNDAP DDS.")
  raw <- sub("^[^[:space:]]+[[:space:]]+", "", declaration)
  names <- sub("\\[.*$", "", raw)
  names <- sub(";[[:space:]]*$", "", names)
  # Preserve the same schema as the LP DAAC cloud backend.
  indices <- substring(raw, nchar(names) + 1L)
  indices <- sub(";[[:space:]]*$", "", indices)
  indices <- gsub("\\]\\[", "] [", indices)
  # DAP2 Grid MAPS repeat the same coordinate declaration in every grid.
  keep <- !duplicated(names)
  names <- names[keep]
  indices <- indices[keep]
  attributes <- .mf_gpm_das_attributes(das)
  long_name <- units <- all_info <- rep(NA_character_, length(names))
  for (i in seq_along(names)) {
    attr <- attributes[[names[i]]]
    if (is.null(attr)) next
    all_info[i] <- paste(attr, collapse = "\n")
    for (key in c("long_name", "units")) {
      line <- grep(paste0("^[[:space:]]*[A-Za-z][A-Za-z0-9_]*[[:space:]]+",
                          key, "[[:space:]]+"), attr, value = TRUE)
      if (!length(line)) next
      value <- sub("^[^\"]*\"([^\"]*)\".*$", "\\1", line[1])
      if (key == "long_name") long_name[i] <- value else units[i] <- value
    }
  }
  axis <- c(metadata$dim_lon, metadata$dim_lat, metadata$dim_time,
            metadata$dim_proj)
  axis <- axis[!is.na(axis) & nzchar(axis)]
  dims <- lapply(strsplit(indices, "[", fixed = TRUE), function(parts) {
    trimws(sub("\\].*$", "", sub("=.*$", "", parts[-1L])))
  })
  required <- c(metadata$dim_lon, metadata$dim_lat)
  extractable <- vapply(dims, function(x) all(required %in% x) &&
    (is.na(metadata$dim_time) || metadata$dim_time %in% x), logical(1))
  status <- ifelse(names %in% axis, "automatically extracted",
                   ifelse(extractable, "extractable", "not extractable"))
  data.frame(name = names, long_name = long_name, units = units,
             indices = indices, all_info = all_info,
             extractable_with_modisfast = status, stringsAsFactors = FALSE)
}

.mf_gpm_das_attributes <- function(das) {
  lines <- trimws(strsplit(das, "\n", fixed = TRUE)[[1]])
  stack <- character()
  result <- list()
  for (line in lines) {
    if (grepl("^[^[:space:]{}]+[[:space:]]*\\{$", line)) {
      stack <- c(stack, sub("[[:space:]]*\\{$", "", line))
    } else if (grepl("^\\}", line)) {
      if (length(stack)) stack <- utils::head(stack, -1L)
    } else if (length(stack) >= 2L && nzchar(line)) {
      variable <- utils::tail(stack, 1L)
      result[[variable]] <- c(result[[variable]], line)
    }
  }
  result
}
