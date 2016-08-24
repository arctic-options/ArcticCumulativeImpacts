# Creating the rescaled sst layer for pan-arctic and bsr

source('common.R')

pan_raw = raster(file.path(dir_arctic,'stressors/sst/output/pan_sst_2008_2012-1985_1989.tif'))

histogram(pan_raw)


max_pan = cellStats(pan_raw,stat='max')

pan_rescale = calc(pan_raw,fun=function(x){ifelse(x>0,x/max_pan,0)},progress='text',
                   filename=paste0(file.path(dir_arctic),'/stressors/sst/output/pan_sst_rescaled.tif',sep=""),overwrite=T)

bsr_rescale = crop(pan_rescale,bsr)%>%
                mask(.,bsr,add=T,filename='stressors/sst/output/bsr_sst_rescaled.tif',overwrite=T)