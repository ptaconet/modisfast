#' @name getVariablesInfo
#' @aliases getVariablesInfo
#' @title Get variables/dimensions information for a collection of interest
#' @description Outputs a data frame with the variables available for a given collection
#'
#' @inheritParams getUrl
#'
#' @return A data.frame with the available variables for the collection, and a set of related information for each variable.
#' These variables can be provided as input parameter \code{variables} of the function \link{getUrl}
#'
#' @export
#'
#' @importFrom rvest html_table
#' @importFrom xml2 read_html
#' @importFrom stringr str_match word
#' @import purrr dplyr httr
#' @examples
#'
#' \dontrun{
#' # login to earthdata
#' earthdata_credentials<-readLines("/home/ptaconet/opendapr/.earthdata_credentials.txt")
#' earthdata_username=strsplit(earthdata_credentials,"=")[[1]][2]
#' earthdata_password=strsplit(earthdata_credentials,"=")[[2]][2]
#' login<-login_earthdata(c(earthdata_username,earthdata_password))
#'
#' # Get the collections implemented in the package :
#' collections_available <- getCollections()
#'
#' # Get the variables available for the collection MOD11A1.006
#' (df_varinfo<-getVariablesInfo("MOD11A1.006"))
#'}
#'

getVariablesInfo<-function(collection,loginCredentials=NULL){  # for a given collection, get the available variables and associated information

  .testIfCollExists(collection)

  .testLogin(loginCredentials)

  httr::set_config(httr::authenticate(user=getOption("earthdata_user"), password=getOption("earthdata_pass"), type = "basic"))

  URL<-opendapMetadata_internal$url_opendapexample[which(opendapMetadata_internal$collection==collection)]

  InfoURL<-paste0(URL,".info")
  vector_response<-httr::GET(InfoURL)
  vector_content<-httr::content(vector_response,"text")
  vector_html<-xml2::read_html(vector_content)
  tab<-rvest::html_table(vector_html)
  if(purrr::is_empty(tab)){ stop("The server might be temporarily unavailable. Try again later. Paste ",InfoURL," to check the error message in your brower\n")}
  tab<-tab[[length(tab)]]
  colnames(tab)<-c("name","all_info")
  tab$name<-gsub(":","",tab$name)
  tab$long_name<-stringr::str_match(tab$all_info, "long_name: (.*?)\n")[,2]
  tab$units<-stringr::str_match(tab$all_info, "units: (.*?)\n")[,2]

  DdsURL<-paste0(URL,".dds")
  vector_response<-httr::GET(DdsURL)
  vector<-httr::content(vector_response,"text")
  vector<-strsplit(vector,"\n")
  vector<-vector[[1]][-length(vector[[1]])]
  vector<-vector[-1]
  vector<-gsub("    ","",vector)
  vector<-gsub(";","",vector)

  variables<-gsub("\\["," \\[",vector)

  indices<-gsub(" = ","=",variables)
  indices<-purrr::map_chr(indices,~stringr::word(., 3,-1))
  indices<-gsub("="," = ",indices)

  variables<-purrr::map_chr(variables,~stringr::word(., 2))

  variables_indices<-data.frame(name=variables,indices=indices, stringsAsFactors = F)

  tab<-dplyr::left_join(tab,variables_indices,by="name")

  tab <- tab[c("name", "long_name", "units","indices", "all_info")]

  return(tab)
}
