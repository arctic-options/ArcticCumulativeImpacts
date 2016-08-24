#UPDATE 3/9/2015 - no longer need this script since I confirmed there is no federally regulated commercial fishing in our region.

# Contact at NOAA is Josh Keaton


# Get average catch per gear per federal fishing area



#Jamie Afflerbach
library(reshape2)
library(ggplot2)
library(scales)
library(magrittr)
library(plyr)
library(dplyr)
library(rgdal)
library(rgeos)
library(maptools)


#Read in data

catch_514 = read.csv('A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/inputs/LANDINGS_REGION_514.csv',stringsAsFactors=F)%>%
  mutate(ROUND_WEIGHT_MTONS = as.numeric(sub(",","",ROUND_WEIGHT_MTONS,fixed=TRUE))) #there are commas in the data which force those values to be read as characters.

catch_524 = read.csv('A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/inputs/LANDINGS_REGION_524.csv',stringsAsFactors=F)%>%
  mutate(ROUND_WEIGHT_MTONS = as.numeric(sub(",","",ROUND_WEIGHT_MTONS,fixed=TRUE))) #there are commas in the data which force those values to be read as characters.

head(catch_514)
head(catch_524)

#shapefile for NOAA reporting areas

areas = readOGR(dsn='A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/working',layer='NMFS_reporting_areas_ROI')

#define gears into CHI categories

gear_def = read.csv('A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/inputs/gear_defs.csv')


# Get average catch per gear type over all years (2008-2013)

avg_514 = catch_514%>%
           filter(AKFIN_YEAR>2008)%>%
            mutate(gear_cat = gear_def$gear_cat[match(FMP_GEAR,gear_def$FMP_GEAR)])%>%
            group_by(gear_cat,AKFIN_YEAR)%>%
             summarize(tot_catch = sum(ROUND_WEIGHT_MTONS))%>% #first sum all catch per gear within each year
            group_by(gear_cat)%>%
             summarize(avg_catch = mean(tot_catch))%>% #then take the mean across all 5 years
            as.data.frame()

rownames(avg_514)<-avg_514[,1]

avg_514 = avg_514%>%
            select(avg_catch)%>%
          t()%>%
            as.data.frame()%>%
            mutate(area=514)




avg_524 = catch_524%>%
           filter(AKFIN_YEAR>2008)%>%
            mutate(gear_cat = gear_def$gear_cat[match(FMP_GEAR,gear_def$FMP_GEAR)])%>%
             group_by(gear_cat,AKFIN_YEAR)%>%
              summarize(tot_catch = sum(ROUND_WEIGHT_MTONS))%>% #first sum all catch per gear within each year
             group_by(gear_cat)%>%
              summarize(avg_catch = mean(tot_catch))%>% #then take the mean across all 5 years
            as.data.frame()


rownames(avg_524)<-avg_524[,1]

avg_524 = avg_524%>%
           select(avg_catch)%>%
          t()%>%
          as.data.frame()%>%
            mutate(area=524)

avg_400 = data.frame(NA,NA,NA,NA,400)
colnames(avg_400)<-c('dem_nd_hbc','pel_hbc','pel_lowbc','unknown','area')

catch_per_area = rbind.fill(avg_514,avg_524,avg_400) #rbind.fill allows rows to be combined with missing columsn. NAs are added where there is missing data
#write.csv(catch_per_area,file='NMFS_area_avg_catch.csv')

# Add catch to shapefile

NMFS_areas_catch = merge(areas,catch_per_area,by.x='REP_AREA',by.y='area')

NMFS_areas_catch@data = NMFS_areas_catch@data%>%
                mutate(dem_nd_hbc_rate = dem_nd_hbc/Area,
                       pel_hbc_rate = pel_hbc/Area,
                       pel_lowbc_rate = pel_lowbc/Area,
                       unknown_rate = unknown/Area)



#write shapefile
writeOGR(NMFS_areas_catch,dsn="A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/working",layer='NMFS_areas_catch',driver="ESRI Shapefile")


#----------------------------------

# Create layers by gear category

#----------------------------------

# Demersal, non destructive, high bycatch in US waters (i.e. Pot gear in Alaska waters)

dem_nd_hbc_us = NMFS_areas_catch

dem_nd_hbc_us@data = dem_nd_hbc_us@data%>%
              select(REP_AREA,Area,dem_nd_hbc,dem_nd_hbc_rate)

writeOGR(dem_nd_hbc_us,dsn="A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/working",layer='dem_nd_hbc_US',driver="ESRI Shapefile")


# Pelagic, high bycatch in US waters (long line and midwater trawl, aka HAL and TRW abbreviation in FMP gear)

pel_hbc_us = NMFS_areas_catch

pel_hbc_us@data = pel_hbc_us@data%>%
  select(REP_AREA,Area,pel_hbc,pel_hbc_rate)

writeOGR(pel_hbc_us,dsn="A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/working",layer='pel_hbc_us',driver="ESRI Shapefile")


#Pelagic low bycatch in US waters (JIG)

pel_lowbc_us = NMFS_areas_catch

pel_lowbc_us@data = pel_lowbc_us@data%>%
  select(REP_AREA,Area,pel_lowbc,pel_lowbc_rate)

writeOGR(pel_lowbc_us,dsn="A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/working",layer='pel_lowbc_us',driver="ESRI Shapefile")
