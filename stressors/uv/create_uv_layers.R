# UV Pressures Layer

#JAfflerbach

source('../common.R')

#read in UV data

uv_current = raster(file.path(dir_arctic,'stressors/uv/raw/uv_omi_aura_2013_2014/uv_baseline_anomaly/omi_aura_uv_anomaly_2010m01-2014m12_raw.tif'))
uv_past    = raster(file.path(dir_arctic,'stressors/uv/raw/uv_omi_aura_2013_2014/uv_baseline_anomaly/toms_ep_uv_anomaly_1997m01-2001m12_raw.tif'))
data       = raster(file.path(dir_arctic,'stressors/uv/raw/uv_omi_aura_2013_2014/uv_baseline_anomaly/uv_anomaly_difference_2010m01-2014m12_minus_1997m01-2001m12_raw.tif'))


# Reproject to mollweide

projection(data) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"    #define initial projection. Helps avoid errors when reprojecting to mollweide
laeaCRS <- CRS("+init=epsg:3572")

diff_laea <- projectRaster(data, crs=laeaCRS,progress='text',filename='working/uv_anomaly_diff_laea.tif',overwrite=T)


#set all negative values to 0

diff_laea[diff_laea<0]<-0

#---------------------------------------

# Crop to pan boundaries

pan_diff = crop(diff_laea,pan)

#---------------------------------------

# Resample to 1km 

pan_resamp  <- resample(pan_diff,pan_ocean,progress='text',method='ngb')%>%
                mask(.,pan,filename='working/uv_anomaly_diff_1km_pan.tif',overwrite=T)



#---------------------------------------

histogram(pan_resamp)


#---------------------------------------


#rescale

#set ref to max value

ref = cellStats(pan_resamp,stat='max')

pan_resc = calc(pan_resamp,fun=function(x){x/ref},filename='output/uv_anomaly_diff_1km_resc_pan.tif',overwrite=T)

#---------------------------------------
# Clip to BSR


bsr_uv = crop(pan_resc,bsr)%>%mask(.,bsr_ocean,filename='output/bsr_uv_anomaly_diff_1km_resc.tif',overwrite=T)




