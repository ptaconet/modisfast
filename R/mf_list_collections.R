#' @name mf_list_collections
#' @title Get the collections available for download with the \code{modisfast} package
#' @description Get the collections available for download using the package and a set of related information
#'
#' @return A data.frame with the collections available, and a set of related information for each one. Main columns are :
#' \describe{
#'   \item{collection}{Collection short name}
#'   \item{source}{Data provider}
#'   \item{long_name}{Collection long name}
#'   \item{doi}{DOI of the collection}
#'   \item{start_date}{First available date for the collection}
#'   \item{url_opendapserver}{URL of the OPeNDAP server of the data}
#' }
#'
#' @export
#'
#' @examples
#'
#' (head(mf_list_collections()))
#'
mf_list_collections <- function() {
  return(opendapMetadata_internal)
}
