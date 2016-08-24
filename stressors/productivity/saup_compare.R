# compare productivity 

# get original updated (catch/prod)*sauppctchang, clip to BSR, 


library(rgdal)
library(raster)
library(maptools)
library(dplyr)


dir_arctic = c('Windows' = '//jupiter.nceas.ucsb.edu/arctic',
               'Linux'   = '/data/shares/arctic')[[ Sys.info()[['sysname']] ]]

# set tmp directory

tmpdir=file.path(dir_arctic,'home_big/R_raster_tmp')
dir.create(tmpdir, showWarnings=F)
rasterOptions(tmpdir=tmpdir)


files = list.files(file.path(dir_arctic,'HIACMS/CHI/stressors/productivity/output/raw'),full.name=T)

# productivity multiplier, teased out from dividing catch/fish_prod from N:/git-annex/Global/SAUP_FishCatchByGearType_Halpern2008/data
mult = raster(file.path(dir_arctic,'HIACMS/CHI/stressors/productivity/saup_comparison/prod_multiplier_resamp.tif'))

diff=function(file){
  r<-raster(file)
  yr = substr(file,74,77)
  diff = r-mult
  histogram(diff)
  writeRaster(diff,filename=paste('saup_comparison/diff_from_saup_prod_multiplier_',yr,sep=''),format='GTiff',overwrite=T)
}

sapply(files,diff)



# run the same function for 3 year averages

t_yr_files = list.files(file.path(dir_arctic,'HIACMS/CHI/stressors/productivity/output/raw'),full.name=T)[12:16]


diff_t=function(file){
  r<-raster(file)
  yr = substr(file,86,100)
  diff = r-mult
  histogram(diff)
  writeRaster(diff,filename=paste('saup_comparison/diff_from_saup_prod_multiplier_',yr,sep=''),format='GTiff',overwrite=T)
}

sapply(t_yr_files,diff_t)


# run the same function for 5 year averages

f_yr_files = list.files(file.path(dir_arctic,'HIACMS/CHI/stressors/productivity/output/raw'),full.name=T)[9:11]

diff_f=function(file){
  r<-raster(file)
  yr = substr(file,86,94)
  diff = r-mult
  histogram(diff)
  writeRaster(diff,filename=paste('saup_comparison/diff_from_saup_prod_multiplier_',yr,sep=''),format='GTiff',overwrite=T)
}

sapply(f_yr_files,diff_f)



## Get the average difference for each of the files

f = list.files(file.path(dir_arctic,'HIACMS/CHI/stressors/productivity/saup_comparison'),full.names=T,pattern='diff')

s = stack(f)

avg = mean(s)

freq = freq(s,digits=2,progress='text')

