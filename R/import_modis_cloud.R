# Import granule subsets whose NetCDF files do not contain spatial coordinates.
# The download manifest keeps the original DAP2 constraint and full grid size.
.mf_cloud_manifest <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)

  manifest_path <- file.path(
    dirname(dirname(dirname(path))),
    "Summary_downloaded_data.csv"
  )

  if (!file.exists(manifest_path)) return(NULL)

  manifest <- utils::read.csv(
    manifest_path,
    stringsAsFactors = FALSE
  )

  if ("destfile" %in% names(manifest)) {
    manifest$destfile <- normalizePath(
      manifest$destfile,
      winslash = "/",
      mustWork = FALSE
    )
  }

  manifest
}

.mf_is_cloud_download <- function(path) {
  manifest <- .mf_cloud_manifest(path)
  if (is.null(manifest) || !all(c("url", "destfile") %in% names(manifest))) {
    return(FALSE)
  }
  files <- list.files(path, pattern = "\\.nc4$", full.names = TRUE)
  files <- normalizePath(files, winslash = "/", mustWork = TRUE)
  any(manifest$destfile %in% files &
        grepl("^https://opendap\\.earthdata\\.nasa\\.gov/collections/",
              manifest$url))
}

.mf_cloud_slice <- function(url) {
  query <- utils::URLdecode(sub("^[^?]*\\?", "", url))
  # All generated URLs begin with a 2D science variable in [row][column] order.
  slices <- regmatches(query, gregexpr("\\[[0-9]+:[0-9]+\\]", query))[[1]]
  if (length(slices) < 2L) stop("Cannot read the spatial indices from ", url)
  indices <- lapply(slices[1:2], function(x) {
    as.integer(strsplit(substr(x, 2, nchar(x) - 1), ":", fixed = TRUE)[[1]])
  })
  c(indices[[1]], indices[[2]])
}

.mf_cloud_requested_bands <- function(url) {
  query <- utils::URLdecode(sub("^[^?]*\\?", "", url))
  selections <- strsplit(query, ",", fixed = TRUE)[[1]]
  basename(sub("\\[.*$", "", selections))
}

.mf_cloud_clean_varnames <- function(variables) {
  basename(sub("^.*(?:/Data_Fields/|_Data_Fields_)", "", variables,
               perl = TRUE))
}

.mf_cloud_band_names <- function(raster, file, requested = NULL) {
  # terra exposes the NetCDF variable names before the raster is flipped,
  # merged or projected; these operations drop its source metadata.
  variables <- terra::varnames(raster)
  if (length(variables) != terra::nlyr(raster) || anyNA(variables) ||
      any(!nzchar(variables))) {
    stop("Cannot match NetCDF variable metadata to raster layers: ", file)
  }
  bands <- .mf_cloud_clean_varnames(variables)
  if (!is.null(requested) && !setequal(bands, requested)) {
    # HDF5 groups may be represented with a different prefix in NetCDF.
    # Match only complete requested names at the end of each source variable.
    matched <- lapply(variables, function(variable) {
      requested[endsWith(variable, paste0("_", requested)) |
                  endsWith(variable, paste0("/", requested)) |
                  variable == requested]
    })
    if (all(lengths(matched) == 1L)) bands <- unlist(matched, use.names = FALSE)
  }
  if (any(!nzchar(bands)) || anyDuplicated(bands)) {
    stop("Cannot determine distinct NetCDF band names from ", file)
  }
  bands
}

.mf_cloud_extent <- function(tile, indices, nrows, ncols) {
  width <- 1111950.5196666666
  h <- as.integer(substr(tile, 2, 3))
  v <- as.integer(substr(tile, 5, 6))
  left <- (h - 18) * width
  top <- (9 - v) * width
  terra::ext(left + indices[3] * width / ncols,
             left + (indices[4] + 1) * width / ncols,
             top - (indices[2] + 1) * width / nrows,
             top - indices[1] * width / nrows)
}

.mf_cloud_set_layer_metadata <- function(raster, layer_names) {
  if (terra::nlyr(raster) != length(layer_names)) {
    stop("The number of imported layers does not match the date and band labels.")
  }
  dates <- as.Date(sub("_.*$", "", layer_names))
  if (anyNA(dates)) stop("Cannot recover the dates of the imported layers.")
  names(raster) <- layer_names
  terra::time(raster) <- dates
  raster
}

.import_modis_cloud <- function(path, collection, output_class,
                                proj_epsg, roi_mask, vrt) {
  if (output_class != "SpatRaster" || vrt) {
    stop("Cloud MODIS import currently supports SpatRaster with vrt = FALSE.")
  }
  files <- list.files(path, pattern = "\\.nc4$", full.names = TRUE)
  files <- normalizePath(files, winslash = "/", mustWork = TRUE)
  if (!length(files)) stop("No NetCDF-4 files found in ", path)
  manifest <- .mf_cloud_manifest(path)
  records <- manifest[match(files, manifest$destfile), , drop = FALSE]
  if (anyNA(records$url)) stop("The download manifest does not list every NetCDF file.")
  tiles <- regmatches(basename(files),
                      regexpr("h[0-9]{2}v[0-9]{2}", basename(files)))
  if (length(tiles) != length(files) || any(!nzchar(tiles))) {
    stop("Cannot determine the MODIS tile from a file name.")
  }

  # The first prototype manifest did not yet include grid_nrow/grid_ncol.
  # MOD11A1.061 is known to use 1200 by 1200 cells per tile.
  if (!all(c("grid_nrow", "grid_ncol") %in% names(records))) {
    if (collection != "MOD11A1.061") {
      stop("This cloud download manifest lacks the full grid dimensions. ",
           "Regenerate its URLs with the updated mf_get_url().")
    }
    records$grid_nrow <- records$grid_ncol <- 1200L
  }

  crs <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
  loaded <- lapply(seq_along(files), function(i) {
    slice <- .mf_cloud_slice(records$url[i])
    raster <- terra::rast(files[i])
    requested <- .mf_cloud_requested_bands(records$url[i])
    band_names <- .mf_cloud_band_names(raster, files[i], requested)
    if (!setequal(band_names, requested)) {
      stop("NetCDF variable names do not match the requested bands: ", files[i])
    }
    if (terra::nrow(raster) != slice[2] - slice[1] + 1L ||
        terra::ncol(raster) != slice[4] - slice[3] + 1L) {
      stop("The array dimensions do not match the downloaded subset: ", files[i])
    }
    # These cloud subsets have no usable Y georeferencing. GDAL reads the
    # NetCDF Y index as bottom-up, while MODIS row zero is the north edge.
    raster <- terra::flip(raster, direction = "vertical")
    terra::ext(raster) <- .mf_cloud_extent(tiles[i], slice,
      records$grid_nrow[i], records$grid_ncol[i])
    terra::crs(raster) <- crs
    list(raster = raster, bands = band_names)
  })
  rasters <- lapply(loaded, `[[`, "raster")
  bands <- lapply(loaded, `[[`, "bands")

  days <- as.Date(sub("^.*\\.A([0-9]{7})\\..*$", "\\1", basename(files)),
                  format = "%Y%j")
  if (anyNA(days)) stop("Cannot determine the acquisition date from a file name.")
  groups <- split(seq_along(files), days)
  layer_names <- unlist(lapply(seq_along(groups), function(i) {
    index <- groups[[i]]
    reference <- bands[[index[1L]]]
    if (!all(vapply(bands[index], identical, logical(1), reference))) {
      stop("Tiles of the same date have different bands or band order: ",
           names(groups)[i])
    }
    paste(names(groups)[i], reference, sep = "_")
  }), use.names = FALSE)
  mosaics <- lapply(groups, function(index) {
    if (length(index) == 1L) return(rasters[[index]])
    do.call(terra::merge, rasters[index])
  })
  # Missing tiles on a date produce a smaller mosaic; pad them to the union.
  union_extent <- terra::ext(
    min(vapply(mosaics, function(x) terra::xmin(x), numeric(1))),
    max(vapply(mosaics, function(x) terra::xmax(x), numeric(1))),
    min(vapply(mosaics, function(x) terra::ymin(x), numeric(1))),
    max(vapply(mosaics, function(x) terra::ymax(x), numeric(1))))
  mosaics <- lapply(mosaics, terra::extend, y = union_extent)
  result <- if (length(mosaics) == 1L) mosaics[[1]] else terra::rast(mosaics)
  if (!inherits(result, "SpatRaster")) {
    stop("Could not stack the date mosaics as a SpatRaster.")
  }
  if (!is.null(proj_epsg)) result <- terra::project(result, paste0("epsg:", proj_epsg))
  if (!is.null(roi_mask)) {
    mask <- terra::project(terra::vect(roi_mask), terra::crs(result))
    result <- terra::mask(result, mask)
  }
  .mf_cloud_set_layer_metadata(result, layer_names)
}
