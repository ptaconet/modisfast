#' @name getCollectionInfo
#' @aliases getCollectionInfo
#' @title Get information on a collection of interest
#' @description Opens a browser window with the metadata of the collection
#'
#' @return Opens a browser window with the metadata of the collection
#'
#' @export
#'
#'
#'
#' @examples
#'
#' # Get the collections implemented :
#' opendapr:::opendapMetadata_internal$collection
#'
#' getCollectionInfo("MOD11A1.006")
#'

getCollectionInfo<-function(collection){

  opendapr::.testIfCollExists(collection)

  URL<-opendapr:::opendapMetadata_internal$url_metadata[which(opendapr:::opendapMetadata_internal$collection==collection)]

  utils::browseURL(URL)

}
