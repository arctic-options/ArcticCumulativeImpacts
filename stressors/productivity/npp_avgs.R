# Exploring primary productivity data

# Jamie Afflerbach

# Created 2.17.2015

#Updated 2/25/2015

library(raster)
library(rasterVis)
library(RColorBrewer)

cols = rev(colorRampPalette(brewer.pal(11, 'Spectral'))(255)) # rainbow color scheme

dir_arctic = c('Windows' = '//jupiter.nceas.ucsb.edu/arctic',
               'Linux'   = '/data/shares/arctic')[[ Sys.info()[['sysname']] ]]

# set tmp directory
tmpdir=file.path(dir_arctic,'home_big/R_raster_tmp')
dir.create(tmpdir, showWarnings=F)
rasterOptions(tmpdir=tmpdir)

# set working directory

setwd(file.path(dir_arctic, 'HIACMS/CHI/stressors/productivity'))




# get files for a year

yr = 2013

files <- list.files(path='working/rasterized_rawdata',pattern=paste(yr,"\\.tif$",sep=''),full.names=TRUE,recursive=TRUE)


# get the average 

r <- stack(files)

avg = calc(r,fun=mean,progress='text',na.rm=T)

plot(avg,col=cols,main='Mean Primary Productivity (2002)\n(mg C/m2/day)')

histogram(avg)

writeRaster(avg,file=paste('output/raw/',yr,'_annual_avg_raw.tif',sep=''),overwrite=T) #use when getting average from raw data
#writeRaster(avg,file=paste('output/log/',yr,'_annual_avg_log.tif',sep='')) #use when getting average from log10 transformed data


#--------------------------------------

# look at 3 year averages for raw data


files = list.files(path='output/raw',full.names=TRUE,recursive=TRUE)[6:8]

s = stack(files)

three_yr_avg = calc(s,fun=mean,na.rm=T)

plot(three_yr_avg,col=cols,main='Mean Primary Productivity (2011-2013)\n(mg C/m2/day)')

histogram(three_yr_avg)

writeRaster(three_yr_avg,filename='output/raw/three_yr_avg_2011_2012_2013.tif')

#-----------------------------------

# Average 5 years

files = list.files(path='output/raw',full.names=TRUE,recursive=TRUE)[4:8]

s = stack(files)

five_yr_avg = calc(s,fun=mean,na.rm=T)

plot(five_yr_avg,col=cols,main='Mean Primary Productivity (2009-2013)\n(mg C/m2/day)')

histogram(five_yr_avg)

writeRaster(five_yr_avg,filename='output/raw/five_yr_avg_2009-2013.tif')


