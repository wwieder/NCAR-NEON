##########################################################################
### CODE FOR plotting soil moisture and temperature data
### Created April 10th, 2020
### Updated 
### Edits, 
### W.  Wieder 
##########################################################################

### Reset workspace
rm(list = ls())

### Load packages - CRAN
library(ggplot2)
library(dplyr)
library(tidyverse) # joining and wrangling functions
library(lubridate)

### Set directories - add for new users as needed
# If you've run code before, make a new folder with the date to put data-files into and change path below
# Code won't run if old files present in the working dir
if (file.exists('/Users/wwieder/')){
  dir <- ("/Users/wwieder/Will/git_repos_local/NCAR-NEON/Soil_fluxes")
  setwd(dir)
}

# read in & join  data (this all from HRVF)
tsoi <- read.csv(paste(dir, "/filesToStack00041/stackedFiles/ST_30_minute.csv", 
                       sep = "/"), header = T)

theta <- read.csv(paste(dir, "/filesToStack00094/stackedFiles/SWS_30_minute.csv", 
                        sep = "/"), header = T)

str(tsoi)
tsoi$startDateTime <- ymd_hms(tsoi$startDateTime)
tsoi$endDateTime <- ymd_hms(tsoi$endDateTime)
theta$startDateTime <- ymd_hms(theta$startDateTime)
theta$endDateTime <- ymd_hms(theta$endDateTime)
# join  data
sJoin = intersect(colnames(tsoi), colnames(theta))
sObs <- left_join(x = tsoi, y = theta, by=sJoin)
names(sObs)
str(sObs)
print(unique(sObs$verticalPosition)) #8 depths
print(unique(sObs$horizontalPosition)) # 5 sensors
print(unique(sObs$VSWCFinalQF )) # 5 sensors

# Most basic line chart
# Facet for each vertical position
p1 <- ggplot(sObs %>% filter(finalQF==0),
             aes(x=startDateTime, y=soilTempMean, 
                 color=as.factor(horizontalPosition) )) +
  geom_point(size=0.2, show.legend = FALSE, alpha=0.3 , 
             position=position_jitter()) +
  facet_wrap(~ verticalPosition) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
#  theme(legend.title = element_blank() ) +
  ggtitle('HARV') 


#  ggtitle("Temperature: range 1-10") +
#  theme_ipsum()
p1

p2 <- ggplot(sObs %>% filter(VSWCFinalQF==0),
             aes(x=startDateTime, y=VSWCMean , 
                 color=as.factor(horizontalPosition) )) +
  geom_point(size=0.2, show.legend = FALSE, alpha=0.3 , 
             position=position_jitter()) +
  facet_wrap(~ verticalPosition) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
#  theme(legend.title = element_blank() ) +
  ggtitle('HARV') 
#  theme_ipsum()
p2

{
  pdf(file = "HARV_sensors.pdf",   # The directory you want to save the file in
    width = 6, # The width of the plot in inches
    height = 4) # The height of the plot in inches

  p1
  dev.next()

  p2
  dev.off()
}