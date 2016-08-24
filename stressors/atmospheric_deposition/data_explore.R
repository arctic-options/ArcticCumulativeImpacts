# Exploring atmospheric deposition data


library(raster)
library(rgdal)
library(maps)
library(rasterVis)

dir_arctic = c('Windows' = '//jupiter.nceas.ucsb.edu/arctic/HIACMS/CHI',
               'Linux'   = '/data/shares/arctic/HIACMS/CHI')[[ Sys.info()[['sysname']] ]]

# set tmp directory

tmpdir=file.path(dir_arctic,'home_big/R_raster_tmp')
dir.create(tmpdir, showWarnings=F)
rasterOptions(tmpdir=tmpdir)

#set working directory to atmo deposition
setwd('stressors/atmospheric_deposition')

laeaCRS <- CRS("+init=epsg:3572")

#------------------------------------------

# ORGANIC CARBON

OC = raster(file.path(dir_arctic,'stressors/atmospheric_deposition/raw/F2_depOC.tif'))%>%
        shift(.,x=0,y=90)%>%
          rotate(.)


# Define initial projection for OC
projection(OC) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

out_laea <- projectRaster(OC,crs=laeaCRS)
plot(out_laea)

# look at data values
histogram(OC)

# Max = 20.64
# Min = 0.009955

#------------------------------------------

# ORGANIC PHOSPHATE

OP = raster(file.path(dir_arctic,'stressors/atmospheric_deposition/raw/F4a_OPdep.tif'))%>%
      shift(.,x=0,y=90)%>%
       rotate(.)


# Define initial projection for OC
projection(OP) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

OP_laea <- projectRaster(OP,crs=laeaCRS)
plot(OP_laea)

# look at data values
histogram(OP)


#-----------------------------------------

# ORGANIC NITROGEN

ON = raster(file.path(dir_arctic,'stressors/atmospheric_deposition/raw/F3a_depON.tif'))%>%
      shift(.,x=0,y=90)%>%
        rotate(.)


# Define initial projection for OC
projection(ON) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

ON_laea <- projectRaster(ON,crs=laeaCRS)
plot(ON_laea)

# look at data values
histogram(ON)

#---------------------------------------

# INORGANIC NITROGEN

IN = raster(file.path(dir_arctic,'stressors/atmospheric_deposition/raw/F3b_totdepIN.tif'))%>%
        flip(.,'y')%>%
        shift(.,x=0,y=90)%>%
        rotate(.)

# Define initial projection for OC
projection(IN) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

ON_laea <- projectRaster(ON,crs=laeaCRS)
plot(ON_laea)

# look at data values
histogram(ON)

