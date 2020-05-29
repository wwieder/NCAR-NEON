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
site = 'NIWO'
# read in & join  data (this all from site)
tsoi <- read.csv(paste0(dir, "/filesToStack00041/stackedFiles/ST_",site,"_30_minute.csv"), 
                        header = T)

theta <- read.csv(paste0(dir, "/filesToStack00094/stackedFiles/SWS_",site,"_30_minute.csv"), 
                 header = T)

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
  ylim(-15, 30) + #one plot sensor has errors  
  ggtitle(site) 
p1

p2 <- ggplot(sObs %>% filter(VSWCFinalQF==0),
             aes(x=startDateTime, y=VSWCMean , 
                 color=as.factor(horizontalPosition) )) +
  geom_point(size=0.2, show.legend = FALSE, alpha=0.3 , 
             position=position_jitter()) +
  facet_wrap(~ verticalPosition) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ylim(0, 0.5) + #one plot sensor has errors  
  ggtitle(site) 
p2

# look at just one depth
p3 <- ggplot(sObs %>% filter(VSWCFinalQF==0) %>% 
               filter(verticalPosition==503),
             aes(x=startDateTime, y=VSWCMean , 
                 color=as.factor(horizontalPosition) )) +
  geom_point(size=0.5, show.legend = FALSE, alpha=0.3 , 
             position=position_jitter()) +
  ylim(0, 0.4) + #one plot sensor has errors  
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ggtitle(paste(site, ' verticalPosition=503') ) 
p3

pdf(file = paste0(site,"_sensors.pdf"), width = 6, height = 4) 
p1
dev.next()
p2
dev.next()
p3
dev.off()

print(sObs$startDateTime)
p4 <- ggplot(sObs %>% filter(finalQF==0) %>% 
               filter(verticalPosition==502) %>%
               filter(startDateTime>= as.Date("2019-01-01")) %>%
               filter(startDateTime< as.Date("2020-01-01")),
             aes(x=startDateTime, y=soilTempMean , 
                 color=as.factor(horizontalPosition) )) +
  geom_point(size=0.5, show.legend = FALSE, alpha=0.3 , 
             position=position_jitter()) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ggtitle(paste(site, ' verticalPosition=502') ) 

p4
