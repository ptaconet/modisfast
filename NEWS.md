# modisfast 2.0.1

## Improvements and fixes

* Added Earthdata token authentication to CMR requests to resolve HTTP 401 errors encountered in some environments.
* Normalized file paths during cloud to fix path-matching issues, particularly on Windows.
* `mf_import_data()` now accepts the download root folder and locates the files for the requested collection. A clearer error lists matching folders when several ROIs are available.
* Improved URL-building progress messages.
* Improved parallel download error messages to suggest retrying with parallel = FALSE, and ensured workers are stopped when a download fails.

# modisfast 2.0.0

## Breaking changes

* `mf_get_url()` now uses NASA Earthdata Cloud for supported MODIS and VIIRS collections. GPM data continue to use the GES DISC OPeNDAP service (#21, #23, #24).
* Authentication now uses an Earthdata bearer token set in `EARTHDATA_TOKEN`. Username and password authentication and `mf_login()` have been removed.
* The `opt_param`, `single_netcdf`, and `output_format` arguments have been removed.

## New features

* Added support for tiled VIIRS `.002` collections available through Earthdata Cloud.
* Added `mf_list_collections_cloud()` to check whether sampled granules from supported cloud collections can be accessed through OPeNDAP. Results describe the granules tested; they do not guarantee access to every date or tile.
* Updated `mf_list_variables()` to retrieve available bands from the current MODIS, VIIRS, and GPM OPeNDAP services.
* `mf_get_url()` uses the package’s collection catalogue to identify cloud collections and creates subset URLs for the requested area, dates, and bands.

## Improvements and fixes

* Updated `mf_import_data()` to assemble cloud granules across tiles and dates, restore their spatial coordinates, and retain band names and acquisition dates in imported `terra::SpatRaster` objects.
* Improved validation and error messages for collection names, band names, dates, ROIs, missing tokens, and granules that cannot be accessed through OPeNDAP.
* Updated the documentation and examples for the new authentication and download workflow.

# modisfast 1.0.0

## Breaking changes

* adding unit tests to test the functionality of the package (see file `test/testthat.R`) (#11, #15).
* `mf_modisfast()` : new function which enables to execute the whole workflow (login, get URL, download data, and eventually import data) at a glance.

## New features

* adding three modes for verbose mode : quiet, inform, debug (#13).
* using the `cli` package for textual outputs in verbose mode.

## Minor improvements and fixes

* `mf_get_url()` and `mf_download_data()` : including information on maximum file size expected (when verbose).
* `mf_import_data()` : default projection now set to source projection of the data.
* `mf_import_data()` : collection_source renamed collection.
* solving an issue with tile merging at extreme latitude.
* slight modifications in the `Contributing.md` file (#8).
* slight modifications in the vignettes (#13)
* improve comments in verbose mode
