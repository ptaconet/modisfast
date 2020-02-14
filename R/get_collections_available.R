#' @name get_collections_available
#' @title Get the collections implemented in the package
#' @description Get the collections implemented in the package and a set of related information
#'
#' @inheritParams get_url
#'
#' @return A data.frame with the available collections, and a set of related information. Columns are :
#' \itemize{
#'   \item{collection :}{Collections available through \code{opendapr} }
#'   \item{source :}{source}
#'   \item{long_name :}{Collection long name}
#'   \item{url_metadata :}{URL pointing to metadata about the collection}
#'   \item{DOI :}{DOI of the dataset}
#'   \item{url_opendapserver :}{URL of the OPeNDAP server from which the data is extracted }
#'   \item{status :}{Implemented status in s\code{opendapr} }
#'   \item{crs :}{Coordinates reference system of the collection }
#'}
#'
#' @export
#'
#' @examples
#'
#' (collections <- get_collections_available())
#'
#'


get_collections_available <- function(collection){

  opendapMetadata <- opendapMetadata_internal %>%
    dplyr::select(collection,long_name,source,url_metadata,DOI,url_programmatic_access,crs,status) %>%
    dplyr::rename(url_opendapserver = url_programmatic_access)

  return(opendapMetadata)

}
