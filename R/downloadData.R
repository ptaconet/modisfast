#' @name downloadData
#' @aliases downloadData
#' @title Wrapper to download several datasets
#' @description This function enables to download datasets, enventually parallelizing the download.
#'
#' @param df_to_dl data.frame. Urls and destination files of dataset to download. See Details for the structure
#' @param parallelDL boolean. Parallelize the download ? Default to FALSE
#' @param loginCredentials vector string. In case of data that needs login : string vector of length 2 with username and password
#' @param data_source String. default to NULL. Additional information is the Details
#'
#' @return a data.frame with the same structure of the input data.frame \code{df_to_dl} + columns providing details of the data downloaded. The additional olumns are :
#' \itemize{
#' \item{"fileDl": }{Booloean (dataset downloaded or failure)}
#' \item{"dlStatus": }{Download status : 1 = download ok ; 2 = download error ; 3 = dataset was already existing in destination file }
#' \item{"fileSize": }{file size on disk}
#' }
#'
#' @details
#'
#' Parameter \code{df_to_dl} is a data.frame with the following minimal structure :
#' \itemize{
#' \item{"url": }{URL of the source file}
#' \item{"destfile": }{Destination file}
#' }
#'
#' Parameter \code{data_source} takes NULL as default value (i.e. when no login is required to download the data). Other possible values are :
#' - "earthdata" : to download data requiring a login to Earthdata
#'
#' @export
#'

downloadData<-function(df_to_dl,parallelDL=FALSE,loginCredentials=NULL,data_source=NULL){

  destfile <- fileDl <- NULL

  # check which data is already downloaded
  data_dl<-df_to_dl %>%
    dplyr::mutate(fileDl=purrr::map_lgl(destfile,file.exists)) %>%
    dplyr::mutate(dlStatus=ifelse(fileDl==TRUE,3,NA))

  # data already downloaded
  data_already_exist<-data_dl %>%
    dplyr::filter(fileDl==TRUE)

  # data to download
  data_to_download<-data_dl %>%
    dplyr::filter(fileDl==FALSE)

  if (nrow(data_to_download)>0){
    # Create directories if they do not exist
    unique(dirname(data_to_download$destfile)) %>%
      lapply(dir.create,recursive = TRUE, mode = "0777", showWarnings = FALSE)

    # download data
    #for (i in 1:nrow(data_to_download)){
    #    httr::GET(data_to_download$url[i],httr::authenticate(username,password),write_disk(data_to_download$destfile[i]))
    # }
    if(!is.null(data_source)){
      if(data_source=="earthdata"){
        opendapr::.testLogin(loginCredentials)
        username<-getOption("earthdata_user")
        password<-getOption("earthdata_pass")
      }
    } else {
      username <- password <- "no_auth"
    }

    dl_func<-function(url,output,username,password) {httr::GET(url,httr::authenticate(username,password),httr::write_disk(output),httr::progress())}

    cat("\nDownloading the data...")
    if (parallelDL){
      cl <- parallel::makeCluster(parallel::detectCores())
      parallel::clusterMap(cl, dl_func, url=data_to_download$url,output=data_to_download$destfile,username=username,password=password,
                           .scheduling = 'dynamic')
      parallel::stopCluster(cl)
    } else {
      for (i in 1:nrow(data_to_download)){
        dl_func(url=data_to_download$url[i],output=data_to_download$destfile[i],username=username,password=password)
      }
    }
  }
  data_dl<-data_to_download %>%
    dplyr::mutate(fileDl=purrr::map_lgl(destfile,file.exists)) %>%
    dplyr::mutate(dlStatus=ifelse(fileDl==TRUE,1,2))  %>%
    dplyr::mutate(fileSize=file.size(destfile)) %>%
    rbind(data_already_exist)


  # 1 : download ok
  # 2 : download error
  # 3 : data already existing in output folder

  return(data_dl)
}
