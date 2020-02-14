#' @name download_data
#' @aliases download_data
#' @title  Download several datasets given their URLs and a destination files
#' @description This function enables to download datasets, enventually parallelizing the download.
#'
#' @inheritParams get_url
#' @param df_to_dl data.frame. Urls and destination files of dataset to download. See Details for the structure
#' @param parallel boolean. Parallelize the download ? Default to FALSE
#' @param data_source String. default to "usgs". Additional information is the Details
#' @param verbose boolean. Verbose ?
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
#' \item{"url": }{URL of the source file (character string)}
#' \item{"destfile": }{Destination file (character string)}
#' }
#'
#' Parameter \code{data_source} takes "usgs" as default value. Options are :
#' \itemize{
#' \item{ \code{NULL} : } {when no login is required to download the data). }
#' \item{ \code{"usgs"} : } {to download data requiring a login to Earthdata }
#'}
#'
#' @note In a data import workflow, this function is typically used after a call to the \link{get_url} function. The output value of \code{get_url} can be used as input of parameter \code{df_to_dl} of the \code{download_data} function.
#' @import dplyr parallel
#' @importFrom utils txtProgressBar
#' @export
#'

download_data<-function(df_to_dl,parallel=FALSE,login_credentials=NULL,data_source="usgs",verbose=FALSE){

  destfile <- fileDl <- NULL

  # check which data is already downloaded
  data_dl<-df_to_dl %>%
    dplyr::mutate(fileDl=file.exists(destfile)) %>%
    dplyr::mutate(fileSize=ifelse(fileDl==TRUE,file.size(destfile),NA)) %>%
    dplyr::mutate(fileDl=ifelse(fileDl==TRUE & fileSize>=5000,TRUE,FALSE)) %>%
    dplyr::mutate(dlStatus=ifelse(fileDl==TRUE,3,NA))

  file.remove(data_dl$destfile[which(data_dl$fileSize<=5000)])

  # data already downloaded
  data_already_exist<-data_dl %>%
    dplyr::filter(fileDl==TRUE)

  # data to download
  data_to_download<-data_dl %>%
    dplyr::filter(fileDl==FALSE)

  if(verbose){cat(nrow(df_to_dl)," datasets in total : ", nrow(data_already_exist)," already downloaded and ",nrow(data_to_download)," datasets to download\n")}

  if (nrow(data_to_download)>0){

    # Create directories if they do not exist
    unique(dirname(data_to_download$destfile)) %>%
      lapply(dir.create,recursive = TRUE, mode = "0777", showWarnings = FALSE)

    # download data
    #for (i in 1:nrow(data_to_download)){
    #    httr::GET(data_to_download$url[i],httr::authenticate(username,password),write_disk(data_to_download$destfile[i]))
    # }
    if(!is.null(data_source)){
      if(data_source=="usgs"){
        .testLogin(login_credentials)
        username<-getOption("usgs_user")
        password<-getOption("usgs_pass")
      }
    } else {
      username <- password <- "no_auth"
    }

    dl_func<-function(url,output,username,password) {httr::GET(url,httr::authenticate(username,password),httr::write_disk(output),httr::progress())}

    if(verbose){cat("Downloading the data...\n")}
    if (parallel){
      cl <- parallel::makeCluster(parallel::detectCores())
      parallel::clusterMap(cl, dl_func, url=data_to_download$url,output=data_to_download$destfile,username=username,password=password,
                           .scheduling = 'dynamic')
      parallel::stopCluster(cl)
    } else {
      for (i in 1:nrow(data_to_download)){
        if(verbose){cat(i," over ", nrow(data_to_download),"\n")}
        dl_func(url=data_to_download$url[i],output=data_to_download$destfile[i],username=username,password=password)
      }
    }
  }
  data_dl<-data_to_download %>%
    dplyr::mutate(fileDl=purrr::map_lgl(destfile,file.exists)) %>%
    dplyr::mutate(dlStatus=ifelse(fileDl==TRUE,1,2))  %>%
    dplyr::mutate(fileSize=file.size(destfile)) %>%
    rbind(data_already_exist)

  # to deal with pb when not all the data are downloaded
  data_downloaded <- dplyr::filter(data_dl,fileSize>=5000)

  if(!(identical(data_dl,data_downloaded))){
    download_data(df_to_dl=df_to_dl,parallel=FALSE,login_credentials=login_credentials,data_source=data_source)
  }

  # 1 : download ok
  # 2 : download error
  # 3 : data already existing in output folder

  return(data_dl)
}
