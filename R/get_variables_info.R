#' @name get_variables_info
#' @aliases get_variables_info
#' @title Get informations related to the variables available for a given collection
#' @description Outputs a data frame with the variables available for a given collection
#'
#' @inheritParams get_url
#'
#' @return A data.frame with the available variables for the collection, and a set of related information for each variable.
#' These variables can be provided as input parameter \code{variables} of the function \link{get_url}
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
#' # login to usgs
#' usgs_credentials<-readLines("/home/ptaconet/opendapr/.usgs_credentials.txt")
#' username=strsplit(usgs_credentials,"=")[[1]][2]
#' password=strsplit(usgs_credentials,"=")[[2]][2]
#' login<-login_usgs(c(username,password))
#'
#' # Get the collections implemented in the package :
#' collections_available <- get_collections_available()
#'
#' # Get the variables available for the collection MOD11A1.006
#' (df_varinfo<-get_variables_info("MOD11A1.006"))
#'}
#'

get_variables_info<-function(collection,login_credentials=NULL){  # for a given collection, get the available variables and associated information

  .testIfCollExists(collection)

  .testLogin(login_credentials)

  httr::set_config(httr::authenticate(user=getOption("usgs_user"), password=getOption("usgs_pass"), type = "basic"))

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
