# Land based pollution layers for the arctic

# Jamie Afflerbach

source('~/CumulativeImpacts/common.R')

#------------------------------------------------------------------

# read in data

fert = raster('~/CumulativeImpacts/stressors/land_based/working/fert_arctic.tif')
pest = raster('~/CumulativeImpacts/stressors/land_based/working/pest_arctic.tif')

#---------------------------------------------------------------

# Need to rescale the data, take a look at distribution and quantile

histogram(fert)
histogram(pest)

fert_log = log(fert+1)
pest_log = log(pest+1)

ref_fert = quantile(fert_log,prob=0.9999)
ref_pest = quantile(pest_log,prob=0.9999)

fert_resc = calc(fert_log,fun=function(x){ifelse(x>ref_fert,1,x/ref_fert)},progress='text')
pest_resc = calc(pest_log,fun=function(x){ifelse(x>ref_pest,1,x/ref_pest)},progress='text')


writeRaster(fert_resc,'~/CumulativeImpacts/stressors/land_based/output/fert_arctic_rescaled.tif',overwrite=T)
writeRaster(pest_resc,'~/CumulativeImpacts/stressors/land_based/output/pest_arctic_rescaled.tif',overwrite=T)
