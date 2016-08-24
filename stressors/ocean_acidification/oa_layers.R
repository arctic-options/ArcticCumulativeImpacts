# Creating Pan-Arctic and Bering Sea ocean acidification pressure layers


# Jamie Afflerbach

#-----------------------------------------

#   'oa_dataprep.R' created the following:
#     a. Calculates the historical global mean for the decade 1880-1889 (1 raster layer as output)
#     b. Calculates the annual mean for each of the 10 years in 2005-2014 (10 raster layers as output)

# This script takes prepped Ocean Acidification input raster layers (created by oa_dataprep.R) and does the following:

#     1. Takes each of the 10 raster layers produced in (b) above, and subtracts the historical global mean (produced in step 1) 
#        to create 10 new raster layers (one for each year) with values equal to the change in aragonite saturation state
#     2. RESCALE: For each year between 2005 and 2014, look at the mean annual aragonite saturation state rasters (annualmean_2005-2014). 
#        All values at or below the threshold (<=1) are set to 1 (highest pressure value). All cells with aragonite saturation state values >1 
#        will be scaled based on their change relative to historical levels (calculated in step 2 above). All cells that have a negative change 
#        (indicating a decrease in acidification) are assigned 0    
#     3. Resamples each raster to 1km
#     4. Using ArcGIS through arcpy in python, NA cells are interpolated using nearest neighbor to create final output raster layer

# While this script calculates OA for pan-arctic and, just clips the output layer to the bering strait. There are built in functions
# that allow for the BSR region to be calculated without the pan-arctic calculation.

# NOTE: Interpolation was done in ArcGIS using OA_interpolation.py

#------------------------------------------

# source common file containing dir_arctic directory, libraries, colors for plotting (col=cols) and tmp directory
# for rasters

source('common.R')


# read in data

hist_mean = raster('stressors/ocean_acidification/working/global_oa_1880_1889_arag_mean.tif') # historical decadal mean of aragonite saturation state from 1880-1889

files = list.files('stressors/ocean_acidification/working/annualmean_2005-2014',full.names=TRUE,recursive=TRUE) # list the annual mean raster files for each year in 2005-2014

pan_ocean = raster(file.path(dir_arctic,'gis/ocean_panarctic.tif'))
bsr_ocean = raster(file.path(dir_arctic,'gis/ocean_bsr.tif'))

bsr = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='BSR_region')

#-------------------------------------------------------------------------------------------------


# (Step 1): Clip data to bsr and panarctic

pan_mask = function(file){
  yr = substr(file,51,54) 
  r = raster(file)
  crop = crop(r,pan)
  mask_r = mask(crop,pan,progress='text')
  writeRaster(mask_r,filename=paste0('stressors/ocean_acidification/working/pan-arctic/raw_crop/oa_raw_crop_',yr,sep=''),format='GTiff',overwrite=T) 
}


sapply(files,pan_mask)


# also do the same for historical mean

pan_hist = raster('working/global_oa_1880_1889_arag_mean.tif')%>%
            crop(.,pan)%>%
              mask(.,pan,filename='stressors/ocean_acidification/pan-arctic/raw_crop/hist_mean_1880_1889_crop.tif',overwrite=T,progress='text')

#-------------------------------------------------------------------------------------------------


# (Step 2): function that subtracts annual mean from historical decadal mean and outputs raster to specified folder

pan_annual_change = function(file){
  
  yr = substr(file,33,36)         #use substr to grab the year out of the filename
  out = pan_hist - raster(file)   #subtract current from historical. Although this is counterintuitive, it results in the 
  #correct scaling of values (higher values = more acidification)
  writeRaster(out,filename=paste0('stressors/ocean_acidification/pan-arctic/annualchange_2005-2014/difference_from_hist_mean_',yr,sep=""),format='GTiff',overwrite=T)
  
}

#list files to apply function to
    panfiles = list.files(path = 'stressors/ocean_acidification/pan-arctic/raw_crop',pattern='oa_*',full.names=T)


# apply function across all files using sapply
    sapply(panfiles,pan_annual_change)


# list new files - 'f' at end of variable name indicates files
    pan_change_f = list.files('stressors/ocean_acidification/pan-arctic/annualchange_2005-2014',full.names=TRUE,recursive=TRUE) 



#-------------------------------------------------------------------------------------------------

# Step (3): Rescale values

#     For each year between 2005 and 2014, look at the mean annual aragonite saturation state rasters (annualmean_2005-2014). All values at or below
#     the threshold (<=1) are set to 1 (highest pressure value). All cells with aragonite saturation state values >1, will be scaled based on their change
#     relative to historical levels (calculated in step 2 above). 


pan_rescale_f = function(file){
  
  yr   = substr(file,33,36) #get year of file
  mean = raster(file)       #get annual mean aragonite raster for given year
  diff = raster(pan_change[substr(pan_change,61,64)==yr])  #get the change raster for same year ((current-historical)/historical)
  mean[mean<=1]<-1    #all values at or less than 1 are given a value of 1
  mean[mean>1] = diff[mean>1]  # all cells with values greater than 1 are swapped out with their amount of change 
  mean[mean<0]<-0   #all values less than 0 (indicating a decrease in acidity) are capped at 0
  
  writeRaster(mean,filename=paste0('stressors/ocean_acidification/pan-arctic/annual_oa_rescaled/oa_rescaled_',yr,sep=""),format='GTiff',overwrite=T)
  
}


sapply(panfiles,pan_rescale_f)

pan_rescaled_f = list.files('stressors/ocean_acidification/pan-arctic/annual_oa_rescaled',full.names=T)


#-------------------------------------------------------------------------------------------------

# (Step 3): Resample to 1km

pan_resample = function(file){
  
  yr  = substr(file,43,46)
  r   = raster(file)
  out = raster::resample(r,pan_ocean,method='ngb',progress='text') # resample r to the resolution of 'ocean' (~1km)
  
  writeRaster(out,filename=paste0('stressors/ocean_acidification/pan-arctic/annual_oa_rescaled_1km/annual_oa_rescaled_1km_',yr,sep=''),format='GTiff',overwrite=T)
  
}

sapply(pan_rescaled_f,pan_resample)


#-------------------------------------------------------------------------------------------------

# (Step 4): Interpolate to coast. This was done manually in ArcGIS (Jamie Afflerbach)

#     Interpolation to fill in NA cells with values of the nearest neighbor 
#     is done within the 'OA_interpolation.py' python script, which relies on arcpy (ArcGIS)


pan_int = list.files('stressors/ocean_acidification/pan-arctic/annual_oa_rescaled_1km_int',full.names=T)



#-------------------------------------------------------------------------------------------------


# (Step 5): Clip out ocean

# Each interpolated raster needs to have all land cells clipped out. Using the ocean raster again, mask the interpolated
# rasters to select just those in the oceanic regions.

pan_ocean_clip = function(file){
  
  yr  = substr(file,62,65)
  r   = raster(file)
  out = mask(r,pan_ocean,progress='text')
  
  writeRaster(out,filename=paste0('stressors/ocean_acidification/output/pan-arctic/annual_oa_rescaled_1km_int_clip_',yr,sep=''),format='GTiff',overwrite=T)
  
}

#this clips the raster layers created in the pan_ocean_clip function to the bering strait
bsr_ocean_clip = function(file){
  
  yr  = substr(file,51,54)
  r   = raster(file)
  out = crop(r,bsr)%>%mask(.,bsr_ocean,progress='text')
  
  writeRaster(out,filename=paste0('stressors/ocean_acidification/output/bsr/annual_oa_rescaled_1km_int_clip_',yr,sep=''),format='GTiff',overwrite=T)
  
}


sapply(pan_int,pan_ocean_clip)

pan_oa = list.files(path='pan-arctic/output',pattern='annual_*',full.names=T)
sapply(pan_oa,bsr_ocean_clip)


#-------------------------------------------------------------------------------------------------

# (Step 6): Average last four years to create final output for bsr and panarctic

l = list.files('stressors/ocean_acidification/output/bsr',pattern='annual_oa',full.names=T)

bsr_4yr = stack(l[substr(l,54,57)%in% 2011:2014])%>%
          calc(.,fun=function(x){mean(x,na.rm=T)},progress='text')

plot(bsr_4yr,zlim=c(0,1),col=cols)

writeRaster(bsr_4yr,filename='stressors/ocean_acidification/output/bsr/oa_avg_2011-2014.tif')

k = list.files('pan-arctic/output', pattern='annual_oa_rescaled',full.names=T)

pan_4yr = stack(k[substr(k,51,54) %in% 2011:2014])%>%
  calc(.,fun=function(x){mean(x,na.rm=T)},progress='text')

writeRaster(pan_4yr,filename='stressors/ocean_acidification/output/pan-arctic/oa_2011-2014.tif')
#-------------------------------------------------------------------------------------------------


# (Step 7): Create a raster showing what cells were interpolated - just creating ONE raster. All ten output OA rasters have the same cells interpolated

#original data rescaled and resampled, before interpolation (grab one of the 10 layers for this - doesn't matter)

pan_pre = raster('stressors/ocean_acidification/working/pan-arctic/annual_oa_rescaled_1km/annual_oa_rescaled_1km_2014.tif')

#after interpolation, and after land clipped out

pan_post = raster('stressors/ocean_acidification/output/pan-arctic/annual_oa_rescaled_1km_int_clip_2014.tif')


interp_cells = mask(pan_post,pan_pre,progress='text',inverse=TRUE,filename='stressors/ocean_acidification/output/pan-arctic.oa_interpolated_cells.tif',overwrite=T)
bsr_interp = crop(interp_cells,bsr)%>%mask(.,bsr_ocean,filename='stressors/ocean_acidification/output/bsr/oa_interpolated_cells.tif',overwrite=T)
