#Creating deep and surface waters for BSR

#Jamie Afflerbach


#According to Halpern et al. 2008 - Deep waters are areas deeper than 60 m, and shallow waters are only where there are deep waters.

#------------------------------------------------

source('./common.R')

#------------------------------------------------------

# Bring in bathymetry raster


depth = raster(file.path(dir_arctic,'ecosystems/benthic_substrate/raw/topo30.tif'))

extent(depth)<-c(0,360,-90,90)

projection(depth)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

depth = rotate(depth)

d=projectRaster(depth,crs=laeaCRS,progress='text')

# d_bsr = crop(d,bsr,progress='text')%>%
#   mask(.,bsr,progress='text')

#writeRaster(d_bsr,filename='habitats/hard_and_soft/working/bsr_bathymetry.tif',overwrite=T)

d_bsr = raster('habitats/hard_and_soft/working/bsr_bathymetry.tif')


#depth is negative. Using Halpern 2008 definition for shallow, shelf, slope and deep, separate
# the depth raster into these four categories

deep = calc(d_bsr,fun=function(x){ifelse(x<=-60 & x>=-200,1,NA)},progress='text')%>%
  resample(.,bsr_ocean, filename='habitats/ci_model_layers/deep_waters_lzw.tif',overwrite=T) #shallow is 0-60 m

shallow = deep
writeRaster(shallow,filename='habitats/ci_model_layers/surface_waters_lzw.tif',overwrite=T)

