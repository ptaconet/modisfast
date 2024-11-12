# modisfast 1.0.0

## Breaking changes

* adding unit tests to test the functionality of the package 
(see file test/testthat.R) (#11, #15).
* `mf_modisfast()` : new function which enables to execute the whole workflow 
(login, get URL, download data, and eventually import data) at a glance.

## New features

* adding three modes for verbose mode : quiet, inform, debug (#13).
* using the `cli` package for textual outputs in verbose mode.

## Minor improvements and fixes

* `mf_get_url()` and `mf_download_data()` : including information on maximum 
file size expected (when verbose).
* `mf_import_data()` : default projection now set to source projection of the data.
* `mf_import_data()` : `collection_source` renamed `collection`.
* solving an issue with tile merging at extreme latitude.
* slight modifications in the Contributing.md file (#8).
* slight modifications in the vignettes (#13)
* improve comments in verbose mode



