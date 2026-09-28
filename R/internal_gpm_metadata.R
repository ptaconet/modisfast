# GPM needs a file URL and a server root. The Cloud catalogue only records
# the collection directory; it cannot replace the original OPeNDAP metadata.
.mf_collection_metadata <- function(collection) {
  if (is.character(collection) && length(collection) == 1L &&
      !is.na(collection) && startsWith(collection, "GPM_")) {
    path <- system.file("extdata", "gpm_opendap_metadata.csv",
                        package = "modisfast")
    if (!nzchar(path)) stop("The bundled GPM OPeNDAP metadata is missing.")
    metadata <- utils::read.csv(path, stringsAsFactors = FALSE,
                                na.strings = c("", "NA"))
  } else {
    metadata <- opendapMetadata_internal
  }
  metadata[metadata$collection == collection, , drop = FALSE]
}
