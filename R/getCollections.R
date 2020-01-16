#' @name getCollections
#' @title Get the collections implemented in the package
#' @description Get the collections implemented in the package and a set of related information
#'
#' @inheritParams getUrl
#'
#' @return A data.frame with the available collections, and a set of related information. Columns are :
#' \itemize{
#'   \item{collection :}{Collections available through \code{opendapr} }
#'   \item{source :}{source}
#'   \item{long_name :}{Collection long name}
#'   \item{url_metadata :}{URL pointing to metadata about the collection}
#'   \item{DOI of the dataset :}{DOI}
#'   \item{url_opendapserver :}{URL of the OPeNDAP server from which the data is extracted }
#'   \item{status :}{Implemented status in s\code{opendapr} }
#'   \item{crs :}{Coordinates reference system of the collection }
#'}
#'
#' @export
#'
#' @details To open an Earthdata account go to : (https://urs.earthdata.nasa.gov/profile)
#'
#' @examples
#'
#' (collections <- getCollections())
#'
#'


getCollections <- function(collection){

  opendapMetadata <- opendapMetadata_internal %>%
    dplyr::select(collection,source,long_name,url_metadata,DOI,url_programmatic_access,crs,status) %>%
    dplyr::rename(url_opendapserver = url_programmatic_access)

  return(opendapMetadata)

}
