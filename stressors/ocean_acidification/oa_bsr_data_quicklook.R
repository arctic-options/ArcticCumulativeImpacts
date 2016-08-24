# looking at BSR OA raw values to compare to literature values.

source('common.R')

pan_oa = list.files('stressors/ocean_acidification/working/pan-arctic/raw_crop',pattern='oa_',full.names = T)

bsr = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='BSR_region')

s = stack()

for (i in 1:length(pan_oa)){
  
  r <- raster(pan_oa[i])
  
  out = crop(r,bsr,progress='text')
  
  s = stack(s,out)
  
  
}

avg = calc(s,fun=function(x){mean(x,na.rm=T)})

#Mathis et al (2015) looks specifically at pacific-arctic region for OA but unfortunately doesn't look at the russian side of the strait.
# Their model and data seem to say that present day omega aragonite is between 1.2 and 1.5 in our region. Looking at the average of OA
# from this global dataset, our data seems to agree with this value. Therefore I still think it is ok to use this dataset but a more region specific
# one would be preferred.

