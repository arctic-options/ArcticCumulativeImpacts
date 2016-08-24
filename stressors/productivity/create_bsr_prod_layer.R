# clipping productivity to the BSR



#Jamie Afflerbach


source('common.R')


# read in data

prod_global = raster('stressors/productivity/output/raw/five_yr_avg_09-13_interpolate.tif') # five year average productivity projected to LAEA and then interpolated


#Clip to BSR

bsr_prod_crop = crop(prod_global,bsr,progress='text')%>%
                 resample(.,bsr_ocean,method='ngb',progress='text')%>%
                  mask(.,bsr,progress='text',
                       filename='stressors/productivity/output/five_yr_avg_09-13_bsr_laea.tif',overwrite=T)

