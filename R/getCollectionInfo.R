#' @name getCollectionInfo
#' @aliases getCollectionInfo
#' @title Get information on a collection of interest
#' @description Opens a browser window with the metadata of the collection
#'
#' @inheritParams getUrl
#'
#' @return Opens a browser window with the metadata of the collection
#'
#' @export
#'
#' @importFrom utils browseURL
#'
#' @examples
#'
#' # Get the collections implemented :
#' opendapMetadata$collection
#'
#' getCollectionInfo("MOD11A1.006")
#'

getCollectionInfo<-function(collection){

  .testIfCollExists(collection)

  URL<-opendapMetadata_internal$url_metadata[which(opendapMetadata_internal$collection==collection)]

  utils::browseURL(URL)

}
