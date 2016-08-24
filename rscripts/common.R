# source file for Aurora server directory and common libraries

library(raster)
library(rasterVis)
library(stringr)
library(rgdal)
library(ggplot2)
library(RColorBrewer)
library(reshape2)
library(tidyr)
library(dplyr)

dir_arctic = c('Windows' = 'XX_add_windows_dir',
               'Linux'   = 'XX_add_linux_dir')[[ Sys.info()[['sysname']] ]]


#projection
laeaCRS <- CRS("+init=epsg:3572")

# set tmp directory

tmpdir='~/big/R_raster_tmp'
dir.create(tmpdir, showWarnings=F)
rasterOptions(tmpdir=tmpdir)

#set extent

ext <- extent(-1578729, -460158, -2954428,-2093773)

#set colors for plotting

cols      = rev(colorRampPalette(brewer.pal(9, 'Spectral'))(255)) # rainbow color scheme
red_cols  = colorRampPalette(brewer.pal(9, 'YlOrRd'))(255) # red color scheme
blue_cols = colorRampPalette(brewer.pal(9, 'Blues'))(255)  # blue color scheme
blue_red_cols = colorRampPalette(rev(brewer.pal(9,'RdBu')))(255)
blueTheme <- rasterTheme(region=rev(brewer.pal('Blues',n=9)))
BuRdTheme <- rasterTheme(region=rev(brewer.pal('RdBu',n=9)))
myTheme <- rasterTheme(region = rev(brewer.pal('Spectral', n = 11)))
greyTheme <- rasterTheme(region = brewer.pal('Greys',n=9))
YlOrRdTheme <- rasterTheme(region = brewer.pal('YlOrRd',n=5))
PRGnTheme <- rasterTheme(region=brewer.pal('PRGn',n=9))
BrBGTheme <- rasterTheme(region=brewer.pal('BrBG',n=9))


#bsr and pan shapefiles
bsr = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='BSR_region',verbose = FALSE)
bsrpoly = SpatialPolygons(bsr@polygons,proj4string = crs(bsr)) #for plotting on levelplots

pan = readOGR(dsn=file.path(dir_arctic,'gis/panarctic'),layer='panarctic_plus_bsr_region',verbose = FALSE)
#bsr and pan rasters at 1km
pan_ocean = raster(file.path(dir_arctic,'gis/ocean_panarctic.tif'))
bsr_ocean = raster(file.path(dir_arctic,'gis/ocean_bsr.tif'))

#russia eez
rus_eez = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='RUS_EEZ',verbose=F)
ruspoly = SpatialPolygons(rus_eez@polygons,proj4string = crs(bsr))
rus_ras = rasterize(rus_eez,bsr_ocean)%>%`extent<-`(ext)


#us eez
us_eez <- readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='USA_EEZ',verbose=F)
uspoly= SpatialPolygons(us_eez@polygons,proj4string = crs(bsr))
us_ras = rasterize(us_eez,bsr_ocean)%>%`extent<-`(ext)

#eliminate scientific notation
options(scipen=999)