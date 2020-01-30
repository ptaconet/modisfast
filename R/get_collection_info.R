#' @name get_collection_info
#' @aliases get_collection_info
#' @title Get information on a collection of interest
#' @description Opens a browser window with the metadata of the collection
#'
#' @inheritParams get_url
#'
#' @return Opens a browser window with the metadata of the collection (points to the DOI of the collection)
#'
#' @export
#'
#' @importFrom utils browseURL
#'
#' @examples
#'
#' # Get the collections implemented :
#'
#' (get_collection_info("MOD11A1.006"))
#'

get_collection_info<-function(collection){

  .testIfCollExists(collection)

  URL<-opendapMetadata_internal$DOI[which(opendapMetadata_internal$collection==collection)]

  utils::browseURL(URL)

}
