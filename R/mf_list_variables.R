#' @name mf_list_variables
#' @aliases mf_list_variables
#' @title Get information for the variables (bands) available for a given collection
#' @description Get the variables available for a given collection, along with a set of related information for each.
#'
#' @inheritParams mf_get_url
#'
#' @return A data.frame with the variables available for the collection, and a set of related information for each variable.
#' The variables marked as "extractable" in the column "extractable_w_opendapr" can be provided as input parameter \code{variables} of the function \link{mf_get_url}
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
#' # login to Earthdata
#' log <- mf_login(c("earthdata_un","earthdata_pw"))
#'
#' # Get the variables available for the collection MOD11A1.061
#' (df_varinfo <- mf_list_variables("MOD11A1.061"))
#'}
#'

mf_list_variables<-function(collection,credentials=NULL){  # for a given collection, get the available variables and associated information

  .testIfCollExists(collection)
  .testInternetConnection()
  .testLogin(credentials)

  httr::set_config(httr::authenticate(user=getOption("earthdata_user"), password=getOption("earthdata_pass"), type = "basic"))

  opendapMetadata <- opendapMetadata_internal[which(opendapMetadata_internal$collection==collection),]

  URL<-opendapMetadata$url_opendapexample

  InfoURL<-paste0(URL,".info")
  vector_response<-httr::GET(InfoURL)
  vector_response<-httr::GET(vector_response$url)
  if(vector_response$status_code==400){ stop("Bad request\n")}
  vector_content<-httr::content(vector_response,"text",encoding="UTF-8")
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
  vector_response<-httr::GET(vector_response$url)
  vector<-httr::content(vector_response,"text",encoding="UTF-8")
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

  # add a column to specify whether the variable is extractable or not with modisfast

  dim_lon<-opendapMetadata$dim_lon
  dim_lat<-opendapMetadata$dim_lat
  dim_time<-opendapMetadata$dim_time
  dim_proj<-opendapMetadata$dim_proj

  tab <- tab %>%
    dplyr::mutate(extractable_w_opendapr=dplyr::case_when(name %in% c(dim_lon,dim_lat,dim_time,dim_proj) ~ "automatically extracted",
                                                   grepl(dim_lon,tab$indices) & grepl(dim_lat,tab$indices) & grepl(dim_time,tab$indices) & !is.na(dim_time) ~ "extractable",
                                                   grepl(dim_lon,tab$indices) & grepl(dim_lat,tab$indices) & is.na(dim_time) ~ "extractable")
    )

   tab$extractable_w_opendapr[which(is.na(tab$extractable_w_opendapr))] <- "not extractable"

  if(opendapMetadata$source=="SMAP"){
   tab$extractable_w_opendapr[which(tab$extractable_w_opendapr=="not extractable")] <- "extractable"
  }


  tab <- tab[c("name", "long_name", "units","indices", "all_info","extractable_w_opendapr")]

  return(tab)
}
