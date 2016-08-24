# Create shipping layer for pan-arctic and bering-strait region
#--------------------------------------------------------------

#source common file (directory and libraries)
source('common.R')

#pan-arctic boundary (including bsr region)
pan       <- readOGR(dsn=file.path(dir_arctic,'HIACMS/CHI/gis/panarctic'),layer='panarctic_plus_bsr_region')
pan_ocean <- raster(file.path(dir_arctic,'HIACMS/CHI/gis/ocean_panarctic.tif'))


#-------------------------------------------------------------

# Grab data from all years

ship_2011 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2011.tif')%>%
             crop(.,pan,progress='text')%>%
              mask(.,pan,progress='text',filename='working/shipping_panarctic_2011.tif')
  
    ext <-extent(ship_2011) #set extent so all four shipping layers are in the same extent


ship_2012 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2012.tif')%>%
             crop(.,pan,progress='text')%>%
              mask(.,pan,progress='text',filename='tmp/shipping_panarctic_2012.tif')

  extent(ship_2012)<-ext


ship_2013 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2013.tif')%>%
             crop(.,pan,progress='text')%>%
              mask(.,pan,progress='text',filename='tmp/shipping_panarctic_2013.tif')

  extent(ship_2013)<-ext


ship_2014 = raster('HIACMS/CHI/stressors/shipping/shipping_rasters/full_shipping_2014.tif')%>%
             crop(.,pan,progress='text')%>%
              mask(.,pan,progress='text',filename='tmp/shipping_panarctic_2014.tif')

  extent(ship_2014)<-ext
  
#--------------------------------------------------------------------
  
# raw data
  
all = stack(ship_2011,ship_2012,ship_2013,ship_2014)
names(all)<-c('2011','2012','2013','2014')
  
#plot(all,col=cols,main=c('2011','2012','2013','2014'))
  
#histogram(all)
  
# log all
  
all_log = log(all)
names(all_log)<-c('2011','2012','2013','2014')
  
#plot(all_log,col=cols,main=c('2011','2012','2013','2014'))
  
  
# Rescale to a given quantile (99.99)

ref = quantile(all_log,prob=0.9999)
  
all_log_resc = calc(all_log,fun=function(x){ifelse(x>ref,1,x/ref)},progress='text')
names(all_log_resc)<-c('2011','2012','2013','2014')
  
plot(all_log_resc,main = c('2011','2012','2013','2014'))
  

#set all NA to 0
all_log_resc[is.na(all_log_resc)]<-0

all_mean = mean(stack(all_log_resc))

plot(all_mean,main='Ship Stressor Layer \nAveraged over all 4 years')

# Resample to same resolution as pan_ocean (which is 934x934 rather than 1000x1000...maybe we should fix this elsewhere)

all_mean_res = resample(all_mean,pan_ocean,progress='text',method='ngb')

writeRaster(all_mean_res,filename='output/panarctic_shipping_stressor_layer.tif',overwrite=T)

#----------------------------------------------------------------------------

# Clip to bering Strait

bsr = readOGR(dsn=file.path(dir_arctic,'HIACMS/CHI/gis/bsr'),layer='BSR_region')

bsr_ship <- mask(all_mean_res,bsr)%>%crop(.,bsr,filename='output/bsr_shipping_stressor_layer.tif',overwrite=T)
  