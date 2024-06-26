% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mf_download_data.R
\name{mf_download_data}
\alias{mf_download_data}
\title{Download several datasets given their URLs and destination path}
\usage{
mf_download_data(
  df_to_dl,
  path = tempfile("tmp"),
  parallel = TRUE,
  num_workers = parallel::detectCores() - 1,
  credentials = NULL,
  source = "earthdata",
  verbose = TRUE,
  min_filesize = 5000
)
}
\arguments{
\item{df_to_dl}{data.frame. Urls and destination files of dataset to download. Typically output of \link{mf_get_url}. See Details for the structure}

\item{path}{string. Target folder for the data to download. Default : \code{tempfile()}}

\item{parallel}{boolean. Parallelize the download ? Default to FALSE}

\item{num_workers}{integer. Number of workers in case of parallel download. Default to number of workers available in the machine minus one.}

\item{credentials}{vector string of length 2 with username and password. optional.}

\item{verbose}{boolean. optional. Verbose (default TRUE)}

\item{min_filesize}{integer. minimum file size expected (in bites) for one file downloaded. If files downloaded are less that this value, the files will be downloaded again. Default 5000.}
}
\value{
a data.frame with the same structure of the input data.frame \code{df_to_dl} + columns providing details of the data downloaded. The additional columns are :
\describe{
\item{fileDl}{Booloean (dataset downloaded or failure)}
\item{dlStatus}{Download status : 1 = download ok ; 2 = download error ; 3 = dataset was already existing in destination file }
\item{fileSize}{File size on disk}
}
}
\description{
This function enables to download datasets. In a data import workflow, this function is typically used after a call to the \link{mf_get_url} function. The output value of \link{mf_get_url} can be used as input of parameter \code{df_to_dl} of \link{mf_download_data}.

The download can the parallelized.
}
\details{
Parameter \code{df_to_dl} must a data.frame with the following minimal structure :
\describe{
\item{id_roi}{An id for the ROI (character string)}
\item{collection}{Collection (character string)}
\item{name}{}
\item{url}{URL of the source file (character string)}
}
}
