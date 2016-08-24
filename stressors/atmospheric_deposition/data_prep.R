# Atmospheric deposition

#----------------------------------------------------------------------

# source common file containing dir_arctic directory, libraries, colors for plotting (col=cols) and tmp directory
# for rasters

      source('common.R')

#atmospheric deposition path
atm_depo = file.path(dir_arctic,'stressors/atmospheric_deposition')



# read in ocean rasters and boundaries for arctic and bsr

pan_ocean = raster(file.path(dir_arctic,'gis/ocean_panarctic.tif'))
bsr_ocean = raster(file.path(dir_arctic,'gis/ocean_bsr.tif'))
ocean     = raster(file.path(dir_arctic,'gis/ocean_laea.tif'))


# Bring in panarctic and BSR region shapefile

pan = readOGR(dsn=file.path(dir_arctic,'gis/panarctic'),layer='panarctic_plus_bsr_region')
bsr = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='BSR_region')


laeaCRS <- CRS("+init=epsg:3572")

#----------------------------------------------------------------------

# GLOBAL ATMOSPHERIC DEPOSITION DATA

# Organic Nitrogen

      ON = raster(file.path(atm_depo,'raw/F3a_depON.tif'))%>%flip(.,'y')
      extent(ON)<-c(-180,180,-90,90)
      projection(ON)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
      ON_laea = projectRaster(ON,crs=laeaCRS,progress='text')%>%
                 resample(.,ocean,progress='text',method='ngb')%>%
                  mask(.,ocean,progress='text')
      
      writeRaster(ON_laea,filename=file.path(atm_depo,'working/ON_laea_1km.tif'))
      
      histogram(ON)

#     Global values range from 0.0004 to 1.97 g N/m2/year

#-----------
      
# Organic Phosphate      

      OP = raster(file.path(atm_depo,'raw/F4a_OPdep.tif'))%>%flip(.,'y')
      extent(OP)<-c(-180,180,-90,90)
      projection(OP)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
      OP_laea = projectRaster(OP,crs=laeaCRS)%>%
                 resample(OP_laea,ocean,progress='text',method='ngb')%>%
                  mask(.,ocean,progress='text')
      
      writeRaster(OP_laea,filename=file.path(atm_depo,'working/OP_laea_1km.tif'))
  
      histogram(OP)  
      
      # Global values range from 0.000009 to 0.007 g Phosphate/m2/year

#-----------

# Organic Carbon
      
      
      OC = raster(file.path(atm_depo,'raw/F2_depOC.tif'))%>%flip(.,'y')
      extent(OC) <- c(-180,180,-90,90)
      projection(OC)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
      OC_laea = projectRaster(OC,crs=laeaCRS)%>%
                 resample(OC_laea,ocean,progress='text',method='ngb')%>%
                  mask(.,ocean,progress='text')
      
      writeRaster(OC_laea,filename=file.path(atm_depo,'working/OC_laea_1km.tif'),overwrite=T)

      histogram(OC)
      
      #Global values range from 0.016 to 20.64 g C/m2/yr
      
#-----------

#  Inorganic nitrogen

      IN = raster(file.path(atm_depo,'raw/F3b_totdepIN.tif'))%>%flip(.,'y')
      extent(IN) <- c(-180,180,-90,90)
      projection(IN)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
      IN_laea = projectRaster(IN,crs=laeaCRS)%>%
                 resample(.,ocean,progress='text',method='ngb')%>%
                  mask(.,ocean,progress='text')
      
      writeRaster(IN_laea,filename=file.path(atm_depo,'working/IN_laea_1km.tif'),overwrite=T)
      
      histogram(IN)

      #Global values range from -0.012 to 1.78 g inorganic nitrogen/m2/year
      

#----------------------------------------------------------------------

# Clip to pan-arctic and rescale

# Organic Nitrogen

pan_ON = crop(ON_laea,pan)%>%
          resample(.,pan_ocean,progress='text',method='ngb')%>%
           mask(.,pan_ocean,filename='stressors/atmospheric_deposition/working/ON_panarctic_laea_1km.tif')

histogram(pan_ON)

# Range of values in the arctic: 0.00324 to 0.6. Global values range from 0.0004 to 1.97

  max_ON = cellStats(pan_ON,stat='max')

  pan_ON_max = calc(pan_ON,fun=function(x){x/max_ON})

  quant_ON = quantile(pan_ON,prob=0.9999)

  pan_ON_quant = calc(pan_ON,fun=function(x){ifelse(x>quant_ON,1,x/quant_ON)})

# Organic Phosphorous plots
pan_OP = crop(OP_laea,pan)%>%
          resample(.,pan_ocean,progress='text',method='ngb')%>%
           mask(.,pan_ocean,filename='stressors/atmospheric_deposition/working/OP_panarctic_laea_1km.tif')

histogram(pan_OP)

#max_OP = cellStats(pan_OP,stat='max')

#pan_OP_max = calc(pan_OP,fun=function(x){x/max_OP})

quant_OP = quantile(pan_OP,prob=0.9999)

pan_OP_quant = calc(pan_OP,fun=function(x){ifelse(x>quant_OP,1,x/quant_OP)})

# Organic Carbon Plots

pan_OC = crop(OC_laea,pan)%>%
          resample(.,pan_ocean,progress='text')%>%
            mask(.,pan_ocean,filename='stressors/atmospheric_deposition/working/OC_panarctic_laea_1km.tif')

histogram(pan_OC)

#max_OC = cellStats(pan_OC,stat='max')

#pan_OC_max = calc(pan_OC,fun=function(x){x/max_OC})
  
quant_OC = quantile(pan_OC,prob=0.9999)

pan_OC_quant = calc(pan_OC,fun=function(x){ifelse(x>quant_OC,1,x/quant_OC)})

histogram(pan_OC_quant)

# Inorganic Nitrogen


pan_IN = crop(IN_laea,pan)%>%
  resample(.,pan_ocean,progress='text')%>%
  mask(.,pan_ocean,filename='stressors/atmospheric_deposition/working/IN_panarctic_laea_1km.tif')

#------------------------------------------------------------------

# Clip to BSR

bsr_OC = mask(pan_OC,bsr,progress='text')%>%
          crop(.,bsr,filename='stressors/atmospheric_deposition/working/bsr_OC_raw.tif')


bsr_OP = mask(pan_OP,bsr,progress='text')%>%
          crop(.,bsr,filename='stressors/atmospheric_deposition/working/bsr_OP_raw.tif')


bsr_ON = mask(pan_ON,bsr,progress='text')%>%
          crop(.,bsr,filename='stressors/atmospheric_deposition/working/bsr_ON_raw.tif')


bsr_IN = mask(pan_IN,bsr,progress='text')%>%
          crop(.,bsr,filename='stressors/atmospheric_deposition/working/bsr_IN_raw.tif')
#------------------------------------------------------------------

# Need to rescale from 0-1 (JA 7/30/15)

# plot all (global, pan, and bsr) with cell ranges

par(mar = c(1, 0.1, 2, 6), mfrow = c(4,3)) 

plot(ON,main='Organic Nitrogen (g N/m2/yr)',col=cols,axes=FALSE,box=FALSE)
plot(pan_ON,col=cols,axes=FALSE,box=FALSE)
plot(bsr_ON,col=cols,axes=FALSE,box=FALSE)
plot(OP, main='Organic Phosphate (g P/m2/yr)',col=cols,axes=FALSE,box=FALSE)
plot(pan_OP,col=cols,axes=FALSE,box=FALSE)
plot(bsr_OP,col=cols,axes=FALSE,box=FALSE)
plot(OC,main='Organic Carbon (g C/m2/yr)',col=cols,axes=FALSE,box=FALSE)
plot(pan_OC,col=cols,axes=FALSE,box=FALSE)
plot(bsr_OC,col=cols,axes=FALSE,box=FALSE)
plot(IN, main='Inorganic Nitrogen (g N/m2/yr)',col=cols,axes=FALSE,box=FALSE)
plot(pan_IN,col=cols,axes=FALSE,box=FALSE)
plot(bsr_IN,col=cols,axes=FALSE,box=FALSE)

