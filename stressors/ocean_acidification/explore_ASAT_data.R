# Exploring data from Steiner et al (2014) Future ocean acidification in 
# the Canada Basin and surrounding Arctic Ocean from CMIP5 earth system models

# Data is in NetCDF form and has aragonite saturation state for the arctic ocean
# for the time periods: (1) 1986-2005 and (2) 2066-2085

source('common.R')

# read in files (all .nc)
l = list.files(file.path(dir_arctic,'stressors/ocean_acidification/raw/ASAT'),full.names = T,pattern='historical')

r = stack(l[1])

# for each model (there are only 5 provided in the dataset, Nadja could not provide data on MIROC)
# take the average across all 12 months then take the average across all models

# 
s = stack(l[4])%>%
      calc(.,fun=function(x){mean(x,na.rm=T)})%>%
        rotate(.)%>%
        projectRaster(.,crs=laeaCRS,progress='text')%>%
          crop(.,pan)%>%
            resample(.,pan_ocean,method='ngb')%>%
              mask(.,pan)

writeRaster(s,filename='stressors/ocean_acidification/working/ASAT/IPSL-CM5A-LR_avg_pan.tif')

#-------------------------------

# Bring in each raster 

all = list.files('stressors/ocean_acidification/working/ASAT',full.names=T)

#take the average across the rasters
s = stack(all)%>%
      calc(.,fun=function(x){mean(x,na.rm=T)})


writeRaster(s,filename='stressors/ocean_acidification/working/ASAT/pan_arctic-5model_avg.tif')

#------------------------------

# look at BSR

bsr = s%>%
        crop(bsr)%>%
          mask(bsr)
#----------------------------

# Bring in current pan-arctic OA and bsr OA


# need to do decadal average and resample to compare...
old = list.files('stressors/ocean_acidification/working/annualmean_2005-2014',full.names = T)

t = stack(old)%>%
    calc(.,fun=function(x){mean(x,na.rm=T)})%>%
      crop(pan)%>%
        resample(pan_ocean,method='ngb')%>%
          mask(pan)
#------------------------------

# Comparing pan-arctic averages

par(mfrow=c(1,2))
plot(s,main='Arctic specific dataset',col=cols,zlim=c(0,2.5),axes=F)
plot(t,main='Global OA dataset',col=cols,zlim=c(0,2.5),axes=F)
dev.off()

#difference

diff = s-t
plot(diff,col=cols,main='Difference (Arctic - Global)')
#----------------------------

# Look at BSR

bsr_old = t%>%crop(bsr)%>%mask(bsr)
bsr_new = s%>%crop(bsr)%>%mask(bsr)
par(mfrow=c(1,2))
plot(bsr_old,main='Global',col=cols,axes=F,zlim=c(1.1,1.65))
plot(bsr_new,main='Arctic',col=cols,axes=F,zlim=c(1.1,1.65))
dev.off()

#difference
bsr_diff = bsr_new-bsr_old
plot(bsr_diff,col=cols,main='Difference (Arctic - Global)',axes=F)












