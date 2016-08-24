# SST stressor layer data prep for arctic options

# Jamie Afflerbach

#------------------------------------------------

# source common file containing dir_arctic directory, libraries, colors for plotting (col=cols) and tmp directory
# for rasters

    source('common.R')

# this data is copied from neptune after creating the SST pressure layer for OHI 2015. These are the annual
# positive anomalies per year

l   <- list.files(file.path(dir_arctic,'stressors/sst/raw'),pattern='annual_pos_anomalies',full.names=TRUE)

# Get 5 year aggregates

yrs_1985_1989 <- stack(l[1:5])%>%sum(.) # This is the time period we are using for historical comparison

#define arctic projection
laeaCRS <- CRS("+init=epsg:3572")

#calculate

i = 2008
  
  yrs <- c(i,i+1,i+2,i+3,i+4)
  s   <- stack(l[substr(l,74,77)%in%yrs])%>%sum(.)
  
  diff = s - yrs_1985_1989
  
  projection(diff) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
  
  out_pan = crop(diff,extent(-180,180,50,90),progress='text')%>%
             projectRaster(.,crs=laeaCRS,progress='text')%>%
              mask(.,pan,progress='text')%>%
              resample(.,pan_ocean,method='ngb',progress='text',
                    filename=paste0(file.path(dir_arctic),'/stressors/sst/output/pan_sst_',min(yrs),'_',max(yrs),'-1985_1989.tif',sep=""),overwrite=T)
  
  
  out_bsr = mask(out_pan,bsr,progress='text')%>%
              crop(.,bsr,
                 filename=paste0(file.path(dir_arctic),'/stressors/sst/output/bsr_sst_',min(yrs),'_',max(yrs),'-1985_1989.tif',sep=""),overwrite=T)
  

