# Ship density

#Jamie Afflerbach

#------------------------------------------------

library(dplyr)
library(rgdal)
library(raster)

dir_arctic = c('Windows' = '//jupiter.nceas.ucsb.edu/arctic',
                'Linux'   = '/data/shares/arctic')[[ Sys.info()[['sysname']] ]]

setwd(file.path(dir_arctic,'HIACMS/CHI/stressors/shipping'))

pan = readOGR(dsn=file.path(dir_arctic,'HIACMS/CHI/gis/panarctic'),layer='panarctic_plus_bsr_region')
    
#-------------------------------------------------------------
    
# Look at year by year
    

ship_2011 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2011.tif')%>%
              raster::crop(.,pan)%>%
              raster::mask(.,pan,progress='text')
extent(ship_2011)<-ext


ship_2012 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2012.tif')%>%
  raster::crop(.,pan)%>%
  raster::mask(.,pan,progress='text')
extent(ship_2012)<-ext


ship_2013 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2013.tif')%>%
  raster::crop(.,pan,progress='text')%>%
  raster::mask(.,pan,progress='text')
extent(ship_2013)<-ext


ship_2014 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2014.tif')%>%
  raster::crop(.,pan,progress='text')%>%
  raster::mask(.,pan,progress='text')
extent(ship_2014)<-ext


# raw data

all = stack(ship_2011,ship_2012,ship_2013,ship_2014)
names(all)<-c('2011','2012','2013','2014')

plot(all,col=cols,main=c('2011','2012','2013','2014'))

histogram(all)

# log all

all_log = log(all)
names(all_log)<-c('2011','2012','2013','2014')

plot(all_log,col=cols,main=c('2011','2012','2013','2014'))


histogram(all_log)
cellStats(all,stat='range')

# Rescale to a given quantile

quant = quantile(all_log,prob=c(0.99,0.999,0.9999))

#           99%    99.9%    99.99%
#X2011 3.610918 5.605432  7.610063
#X2012 4.189655 6.399999  8.355266
#X2013 4.543295 6.150603  8.498123
#X2014 6.459904 8.687889 10.855841

ref = quantile(all_log,prob=0.999)
    
all_log_resc = calc(all_log,fun=function(x){ifelse(x>ref,1,x/ref)},progress='text')
names(all_log_resc)<-c('2011','2012','2013','2014')

plot(all_log_resc,main = c('2011','2012','2013','2014'))
    
# Final mean layer

#set all NA to 0
all_log_resc[is.na(all_log_resc)]<-0

all_mean = mean(stack(all_log_resc))

plot(all_mean,main='Ship Stressor Layer \nAveraged over all 4 years')
    
# look at distribution of non-zero data

all_dist = all_mean
all_dist[all_dist==0]<-NA

histogram(all_dist)
