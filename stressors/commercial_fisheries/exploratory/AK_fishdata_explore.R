#UPDATE 3/9/2015 - no longer need this script since I confirmed there is no federally regulated commercial fishing in our region.

# Contact at NOAA is Josh Keaton


# Exploring Alaska Fisheries Data from AKFIN (Rob Ames at PSFMC - sent on 12/4/2014)

#12.5.2014

#Jamie Afflerbach
library(reshape2)
library(ggplot2)
library(scales)
library(magrittr)
library(dplyr)


#Read in data

catch_514 = read.csv('A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/inputs/LANDINGS_REGION_514.csv',stringsAsFactors=F)%>%
             mutate(ROUND_WEIGHT_MTONS = as.numeric(sub(",","",ROUND_WEIGHT_MTONS,fixed=TRUE))) #there are commas in the data which force those values to be read as characters.

catch_524 = read.csv('A:/HIACMS/CHI/bering-strait/stressors/commerical fisheries/inputs/LANDINGS_REGION_524.csv',stringsAsFactors=F)%>%
             mutate(ROUND_WEIGHT_MTONS = as.numeric(sub(",","",ROUND_WEIGHT_MTONS,fixed=TRUE))) #there are commas in the data which force those values to be read as characters.

head(catch_514)
head(catch_524)


#get data in format to plot
dat_514 = catch_514%>%
           group_by(FMP_GEAR,AKFIN_YEAR)%>%
            summarise(CATCH = sum(ROUND_WEIGHT_MTONS))

#plot
ggplot(dat_514,aes(x=AKFIN_YEAR,y=CATCH,fill=FMP_GEAR))+geom_bar(stat='identity') 

#get data in format to plot
dat_524 = catch_524%>%
           group_by(FMP_GEAR,AKFIN_YEAR)%>%
            summarise(CATCH = sum(ROUND_WEIGHT_MTONS))

#plot
ggplot(dat_524,aes(x=AKFIN_YEAR,y=CATCH,fill=FMP_GEAR))+geom_bar(stat='identity') 

# look at catch per species
sp_514 = catch_514%>%
        group_by(SPECIES,AKFIN_YEAR)%>%
        summarise(CATCH = sum(ROUND_WEIGHT_MTONS))
          
ggplot(sp_514,aes(x=AKFIN_YEAR,y=CATCH,fill=SPECIES))+geom_bar(stat='identity')  +scale_y_continuous(labels=comma)

sp_524 = catch_524%>%
          group_by(SPECIES,AKFIN_YEAR)%>%
           summarise(CATCH = sum(ROUND_WEIGHT_MTONS))

ggplot(sp_524,aes(x=AKFIN_YEAR,y=CATCH,fill=SPECIES))+geom_bar(stat='identity')  +scale_y_continuous(labels=comma)


# Get average catch per gear type over all years (2008-2013)

avg_514 = catch_514%>%
            filter(AKFIN_YEAR>2008)%>%
             group_by(FMP_GEAR)%>%
              summarize(avg_catch = mean(ROUND_WEIGHT_MTONS))


avg_524 = catch_524%>%
           filter(AKFIN_YEAR>2008)%>%
            group_by(FMP_GEAR)%>%
             summarize(avg_catch = mean(ROUND_WEIGHT_MTONS))
