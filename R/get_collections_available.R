#' @name get_collections_available
#' @title Get the collections implemented in the package
#' @description Get the collections implemented in the package and a set of related information
#'
#' @return A data.frame with the available collections, and a set of related information. Main columns are :
#' \describe{
#'   \item{collection}{Collections name}
#'   \item{source}{Data provider}
#'   \item{long_name}{Collection long name}
#'   \item{doi}{DOI of the collection}
#'   \item{start_date}{Start date for the collection}
#'   \item{url_opendapserver}{URL of the OPeNDAP server from which the data is extracted }
#'}
#'
#' @export
#'
#' @examples
#'
#' (head(get_collections_available()))
#'
#'


get_collections_available <- function(){

  return(opendapMetadata_internal)

}
