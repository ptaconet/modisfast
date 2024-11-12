#' @name mf_download_data
#' @aliases mf_download_data
#' @title  Download several datasets given their URLs and destination path
#' @description This function enables to download datasets. In a data import workflow, this function is typically used after a call to the \link{mf_get_url} function. The output value of \link{mf_get_url} can be used as input of parameter \code{df_to_dl} of \link{mf_download_data}.
#'
#' The download can the parallelized.
#'
#' @inheritParams mf_get_url
#' @inheritParams mf_login
#' @param df_to_dl data.frame. Urls and destination files of dataset to download. Typically output of \link{mf_get_url}. See Details for the structure
#' @param path string. Target folder for the data to download. Default : temporary folder.
#' @param parallel boolean. Parallelize the download ? Default to FALSE
#' @param num_workers integer. Number of workers in case of parallel download. Default to number of workers available in the machine minus one.
#' @param min_filesize integer. Minimum file size expected (in bites) for one file downloaded. If files downloaded are less that this value, the files will be downloaded again. Default 5000.
#'
#' @return a data.frame with the same structure of the input data.frame \code{df_to_dl} + columns providing details of the data downloaded. The additional columns are :
#' \describe{
#' \item{fileDl}{Booloean (dataset downloaded or failure)}
#' \item{dlStatus}{Download status : 1 = download ok ; 2 = download error ; 3 = dataset was already existing in destination file }
#' \item{fileSize}{File size on disk (in bites)}
#' }
#'
#' @details
#'
#' Parameter \code{df_to_dl} must be a data.frame with the following minimal structure :
#' \describe{
#' \item{id_roi}{An id for the ROI (character string)}
#' \item{collection}{Collection (character string)}
#' \item{name}{}
#' \item{url}{URL of the file to download (character string)}
#' }
#'
#' @import dplyr parallel httr cli
#' @importFrom utils write.csv URLdecode
#' @export
#'
#' @examples
#' \dontrun{
#'
#' ### Login to EOSDIS Earthdata with your username and password
#' log <- mf_login(credentials = c("earthdata_un", "earthdata_pw"))
#'
#' ### Set-up parameters of interest
#' coll <- "MOD11A1.061"
#'
#' bands <- c("LST_Day_1km", "LST_Night_1km")
#'
#' time_range <- as.Date(c("2017-01-01", "2017-01-30"))
#'
#' roi <- sf::st_as_sf(
#'   data.frame(
#'     id = "roi_test",
#'     geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"
#'   ),
#'   wkt = "geom", crs = 4326
#' )
#'
#' ### Get the URLs of the data
#' (urls_mod11a1 <- mf_get_url(
#'   collection = coll,
#'   variables = bands,
#'   roi = roi,
#'   time_range = time_range
#' ))
#'
#' ### Download the data
#' res_dl <- mf_download_data(urls_mod11a1)
#'
#' ### Import the data as terra::SpatRast
#' modis_ts <- mf_import_data(dirname(res_dl$destfile[1]), collection = coll)
#'
#' ### Plot the data
#' terra::plot(modis_ts)
#' }
mf_download_data <- function(df_to_dl, path = tempfile("modisfast_"), parallel = FALSE, num_workers = parallel::detectCores() - 1, credentials = NULL, verbose = "inform", min_filesize = 5000) {
  fileSize <- destfile <- fileDl <- folders <- readme_files <- source <- maxFileSizeEstimated <- actualFileSize <- NULL

  source <- "earthdata"

  # tests
  if (!inherits(verbose, "character")) {
    stop("verbose argument must be a character string ('quiet'', 'inform', or 'debug') \n")
  }
  if (!inherits(parallel, "logical")) {
    stop("parallel argument must be boolean\n")
  }
  # if(!is.null(source) && !inherits(source,"character")){stop("source argument must be either NULL or 'earthdata' \n")}
  if (!inherits(df_to_dl, "data.frame")) {
    stop("df_to_dl argument must be a data.frame\n")
  }
  if (!("url" %in% colnames(df_to_dl))) {
    stop("df_to_dl argument must be a data.frame with at least 4 columns named 'url', 'collection', 'name', and 'id_roi' \n")
  }
  if (!("collection" %in% colnames(df_to_dl))) {
    stop("df_to_dl argument must be a data.frame with at least 4 columns named 'url', 'collection', 'name, and 'id_roi' '\n")
  }
  if (!("name" %in% colnames(df_to_dl))) {
    stop("df_to_dl argument must be a data.frame with at least 4 columns named 'url', 'collection', 'name, and 'id_roi' '\n")
  }
  if (!("id_roi" %in% colnames(df_to_dl))) {
    stop("df_to_dl argument must be a data.frame with at least 4 columns named 'url', 'collection', 'name, and 'id_roi' '\n")
  }
  if (num_workers > parallel::detectCores()) {
    stop("the number of workers that you set is greater than the number of available workers in your machine\n")
  }

  .testInternetConnection()

  df_to_dl$destfile <- file.path(path, "data", df_to_dl$id_roi, df_to_dl$collection, df_to_dl$name)

  # if(dir.exists(path)){warning("Target folder already exists\n")}

  # check which data is already downloaded
  data_dl <- df_to_dl %>%
    dplyr::mutate(fileDl = file.exists(destfile)) %>%
    dplyr::mutate(fileSize = ifelse(fileDl == TRUE, file.size(destfile), NA)) %>%
    dplyr::mutate(fileDl = ifelse(fileDl == TRUE & fileSize >= min_filesize, TRUE, FALSE)) %>%
    dplyr::mutate(dlStatus = ifelse(fileDl == TRUE, 3, NA))

  file.remove(data_dl$destfile[which(data_dl$fileSize <= min_filesize)])

  # data already downloaded
  data_already_exist <- data_dl %>%
    dplyr::filter(fileDl == TRUE)

  # data to download
  data_to_download <- data_dl %>%
    dplyr::filter(fileDl == FALSE)

  if (verbose %in% c("inform","debug")) {
    cat(nrow(df_to_dl), " datasets in total : ", nrow(data_already_exist), " already downloaded and ", nrow(data_to_download), " datasets to download\n")
  }

  if (nrow(data_to_download) > 0) {
    # Create directories if they do not exist
    unique(dirname(data_to_download$destfile)) %>%
      lapply(dir.create,
        recursive = TRUE, showWarnings = FALSE # , mode = "0777"
      )

    # download data
    # for (i in 1:nrow(data_to_download)){
    #    httr::GET(data_to_download$url[i],httr::authenticate(username,password),write_disk(data_to_download$destfile[i]))
    # }
    if (!is.null(source)) {
      if (source == "earthdata") {
        .testLogin(credentials)
        username <- getOption("earthdata_user")
        password <- getOption("earthdata_pass")
      }
    } else {
      username <- password <- "no_auth"
    }

    dl_func <- function(url, output, username, password) {
      u <- httr::GET(url)
      httr::GET(u$url, httr::authenticate(username, password), httr::write_disk(output), httr::progress(), config = list(maxredirs = -1))
      # GET(u$url, httr::write_disk(output), httr::progress(), config(maxredirs=-1, netrc = TRUE, netrc_file = netrc), set_cookies("LC" = "cookies"))
    }

    if (verbose %in% c("inform","debug")) {
       maxFileSizeEstimated <- sum(data_dl$maxFileSizeEstimated[which(data_dl$fileDl == FALSE)])
       maxFileSizeEstimated <- dplyr::if_else(round(maxFileSizeEstimated/1000000)>1,round(maxFileSizeEstimated/1000000),1)
       cat("Downloading the data (destination folder:",path,") ...\nEstimated maximum size of data to be downloaded is ~",maxFileSizeEstimated,"Mb\n")
      # cat("Downloading the data in",path,"...\n")
    }
    if (parallel) {
      cl <- parallel::makeCluster(num_workers)
      parallel::clusterMap(cl, dl_func,
        url = data_to_download$url, output = data_to_download$destfile, username = username, password = password,
        .scheduling = "dynamic"
        )
      parallel::stopCluster(cl)
    } else {
      for (i in seq_len(nrow(data_to_download))) {
        if (verbose %in% c("inform","debug")) {
          cat("[", i, " over ", nrow(data_to_download), "]\n")
        }
        if(verbose %in% c("quiet","inform")){
          dl_func(url = data_to_download$url[i], output = data_to_download$destfile[i], username = username, password = password)
        } else if (verbose == "debug"){
          httr::with_verbose(dl_func(url = data_to_download$url[i], output = data_to_download$destfile[i], username = username, password = password))
        }
      }
    }
  }
  data_dl <- data_to_download %>%
    dplyr::mutate(fileDl = purrr::map_lgl(destfile, file.exists)) %>%
    dplyr::mutate(dlStatus = ifelse(fileDl == TRUE, 1, 2)) %>%
    dplyr::mutate(fileSize = file.size(destfile)) %>%
    rbind(data_already_exist)

  # to deal with pb when not all the data are downloaded
  data_downloaded <- dplyr::filter(data_dl, fileSize >= min_filesize)

  if (!(identical(data_dl, data_downloaded))) {
    if (verbose %in% c("inform","debug")) {
      cli::cli_alert_warning("Not all the datasets were downloaded. Downloading the remaining datasets one by one...\n")
    }
    mf_download_data(df_to_dl = df_to_dl, path = path, parallel = FALSE, credentials = credentials) # ,source=source)
  } else {
    # 1 : download ok
    # 2 : download error
    # 3 : data already existing in output folder

    actualFileSize <- sum(data_dl$fileSize)
    actualFileSize <- dplyr::if_else(round(actualFileSize/1000000)>1,round(actualFileSize/1000000),1)

    if (verbose %in% c("inform","debug")) {
      cli::cli_alert_success(paste0("\nData were all properly downloaded under the folder(s) ", paste(as.character(unique(dirname(df_to_dl$destfile))), collapse = " and ")))
      cat("\nActual size of downloaded data is",actualFileSize,"Mb\n")
      cli::cli_alert_info("\nTo import the data in R, use the function modisfast::mf_import_data() rather than terra::rast() or stars::read_stars(). More info at help(mf_import_data)\n")
    }
  }

  # write readme
  sentence <- paste0("Query performed on the ", Sys.time(), "
Use the function modisfast::mf_import_data() rather than terra::rast() or stars::read_stars() to import the data in R ! More info at help(mf_import_data)
See the file Summary_downloaded_data.csv for more information on the data downloaded")
  writeLines(sentence, file.path(path, "Readme.txt"))
  # write csv dataset
  data_dl$url <- utils::URLdecode(data_dl$url)
  write.csv(data_dl, file.path(path, "Summary_downloaded_data.csv"), row.names = FALSE)

  return(data_dl)
}
