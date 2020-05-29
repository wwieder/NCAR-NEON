##########################################################################
### CODE FOR DOWNLOADING AND WRANGLING DATA FROM NEON DATA PORTAL
### Created Feb 28th, 2018
### Updated June 15, 2018
### Edits, programmatic upload to Google Drive, Jan 7 2019
### Edits, interact with Google Drive + add other vars, July 2019
### Edits, provide biome and cover type for megapit data, Oct 2019
### Edits, provide size categories for root data, Jan 2020
### S. Weintraub
### W.  Wieder modified for soil moisture, temperature & soil resp. fluxes
##########################################################################

### Reset workspace
rm(list = ls())

### Load packages - CRAN
library(tidyverse) # joining and wrangling functions
library(neonUtilities) # to download NEON data
#library(googlesheets) # to interact with good drive,
#devtools::install_github("tidyverse/googledrive", dependencies = T, force = T) # dev version

### Load packages - Git 
library(devtools)
# geoNEON - for getting spatial data about sampling sites. uncomment and run line below if need this package
# install_github('NEONScience/NEON-geolocation/geoNEON', dependencies=T) 
library(geoNEON)
# neonNTrans - to work up net rates from raw data. uncomment and run line below if need this package
# install_github("NEONScience/NEON-Nitrogen-Transformations/neonNTrans", dependencies=T)
library(neonNTrans) 

### Set directories - add for new users as needed
# If you've run code before, make a new folder with the date to put data-files into and change path below
# Code won't run if old files present in the working dir
if (file.exists('/Users/wwieder/')){
  dir <- ("/Users/wwieder/Will/git_repos_local/NCAR-NEON/Soil_fluxes")
  setwd(dir)
}

### READ ME!
### Code to add Soil-Relevant NEON Data to LTER-SOM google drive
## Not all potentially relevant DPs are included, code can be expanded as desired
## Info about NEON DPs can be found at http://data.neonscience.org/data-product-catalog
## The Code chunks below do the following: 
# First, get rid of older versions of files on google drive (googledrive::drive_trash and drive_mkdir)
# Next 2 lines (zipsBy and stackBy) download all data for a DP, then unzip, stack by table, keep 'stacked' outputs (neonUtilities)
# Last 2 lines (file.list and map) push to google drive in NEON folders (googledrive in tidyverse)
# Run code chunks below (each takes a few mins), then review on google drive to make sure files appear
# if drive_upload is not working, manually drop the data downloads into the gdrive folders

## SOIL sensors - 3 tables
{
#  googledrive::drive_trash("~/LTER-SOM/Data_downloads/NEON_megapitSoil/data-files/")
#  googledrive::drive_mkdir("~/LTER-SOM/Data_downloads/NEON_megapitSoil/data-files")
  site = 'NIWO'

stackByTable(paste0(dir, "/filesToStack00041"), folder=T, saveUnzippedFiles = F)
  
# TODO get the stacked files saved with site name
# Soil temperature, DP1.00041.001
  zipsByProduct(dpID="DP1.00041.001", site=site, package="basic", check.size=F, avg=30) +
    stackByTable(paste0(dir, "/filesToStack00041"), folder=T, saveUnzippedFiles = F)

# Soil water content, DP1.00094.001
  zipsByProduct(dpID="DP1.00094.001", site=site, package="basic", check.size=F, avg=30) +
    stackByTable(paste0(dir, "/filesToStack00094"), folder=T, saveUnzippedFiles = F)
  
# Soil CO2 concentrations, DP1.00095.001  
  zipsByProduct(dpID="DP1.00095.001", site=site, package="basic", check.size=F) +
    stackByTable(paste0(dir, "/filesToStack00095"), folder=T, saveUnzippedFiles = F)
  
}

# read in soil temperature
tsoi <- read.csv(paste(dir, "/filesToStack00041/stackedFiles/ST_",site,"_30_minute.csv", 
                       sep = ""), header = T)

theta <- read.csv(paste(dir, "/filesToStack00094/stackedFiles',site,'SWS_30_minute.csv", 
                       sep = "/"), header = T)

str(tsoi)
# join  data
sJoin = intersect(colnames(tsoi), colnames(theta))
sObs <- left_join(x = tsoi, y = theta, by=sJoin)

