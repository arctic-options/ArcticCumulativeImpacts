#Creating hard and soft substrate rasters for BSR

#Jamie Afflerbach

#------------------------------------------------

source('./common.R')

#look at habitat labels
hab = readOGR(dsn=file.path(dir_arctic,'../ArcticData/Bering_Chukchi/Audobon'),layer='MarineSurficialSediments')%>%
        spTransform(.,crs(bsr_ocean))

plot(hab,add=T)

#bring in lookup table for CHI habitat names
lookup = read.csv('habitats/hard_and_soft/hab_crosswalk.csv')

hab@data = hab@data%>%
            mutate(CHI_label = lookup$CHI[match(Label,lookup$Audobon)],
                   CHI_label_no = ifelse(CHI_label=='Hard',1,2))

#------------------------------------------------------
# Bring in bathymetry raster
laeaCRS <- CRS("+init=epsg:3572")

depth = raster(file.path(dir_arctic,'ecosystems/benthic_substrate/raw/topo30.tif'))

extent(depth)<-c(0,360,-90,90)

projection(depth)<-"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

depth = rotate(depth)

d=projectRaster(depth,crs=laeaCRS,progress='text')

d_bsr = crop(d,bsr,progress='text')%>%
          mask(.,bsr,progress='text')

writeRaster(d_bsr,filename='habitats/hard_and_soft/working/bsr_bathymetry.tif',overwrite=T)

d_bsr = raster('habitats/hard_and_soft/working/bsr_bathymetry.tif')


#depth is negative. Using Halpern 2008 definition for shallow, shelf, slope and deep, separate
# the depth raster into these four categories

shall = calc(d_bsr,fun=function(x){ifelse(x<=0 & x>=-60,x,NA)},progress='text')%>%
          resample(.,bsr_ocean,filename='habitats/hard_and_soft/working/bsr_depth_shallow.tif',overwrite=T) #shallow is 0-60 m
shelf = calc(d_bsr,fun=function(x){ifelse(x<=-60 & x>=-200,x,NA)},progress='text')%>%
          resample(.,bsr_ocean,filename='habitats/hard_and_soft/working/bsr_depth_shelf.tif',overwrite=T) #shelf is 60-200 m

#not in our area:
slope = calc(d_bsr,fun=function(x){ifelse(x<=-200 & x>=-2000,x,NA)},progress='text') #only one cell as far as I can see
deep  = calc(d_bsr,fun=function(x){ifelse(x<=-2000,x,NA)},progress='text') #none

# The bering straight only has shallow and shelf benthic regions (as expected)

#------------------------------------------------------

# Create soft/hard shallow and shelf layers

#rasterize

hab_ras = rasterize(hab,bsr_ocean,field='CHI_label_no')%>%
            mask(.,bsr,progress='text',filename='habitats/hard_and_soft/working/hab_ras.tif',overwrite=T)

#1 = hard and 2 equals soft
    hard = hab_ras
    hard[hard!=1]<-NA

    shal_hard  = mask(hard,shall,progress='text',
                      filename='habitats/hard_and_soft/working/bsr_hard_shallow.tif',overwrite=T)
    shelf_hard = mask(hard,shelf,progress='text',
                      filename='habitats/hard_and_soft/working/bsr_hard_shelf.tif',overwrite=T)

# soft

    soft = hab_ras
    soft[soft!=2]<-NA

    shal_soft = calc(soft,fun=function(x){x/2})%>%
                mask(.,shall,progress='text',filename='habitats/hard_and_soft/working/bsr_soft_shallow.tif',overwrite=T)
    shelf_soft = calc(soft,fun=function(x){x/2})%>%
                 mask(.,shelf,progress='text',filename='habitats/hard_and_soft/working/bsr_soft_shelf.tif',overwrite=T)

#---------------------------------------------------------------------

# Bring in global rasters of these 4 layers and supplement the rest of the BSR region with global values

hard_shal_global = raster(file.path(dir_arctic,'ecosystems/benthic_substrate/global_habitats/rocky_reef_lzw.tif'))%>%
                    crop(.,extent(-18040095,18040134,6000000,10000000))%>%
                     projectRaster(.,crs=laeaCRS,progress='text')%>%
                      mask(.,pan,progress='text',filename='habitats/hard_and_soft/working/global_rocky_reef_pan.tif',overwrite=T)%>%
                       crop(.,bsr)%>%
                         resample(.,bsr_ocean)%>%
                          mask(.,shall,filename='habitats/hard_and_soft/working/global_rocky_reef_bsr.tif',overwrite=T)

hard_shelf_global = raster(file.path(dir_arctic,'ecosystems/benthic_substrate/global_habitats/hard_shelf_lzw.tif'))%>%
                     crop(.,extent(-18040095,18040134,6000000,10000000))%>%
                      projectRaster(.,crs=laeaCRS,progress='text')%>%
                       mask(.,pan,progress='text',filename='habitats/hard_and_soft/working/global_hard_shelf_pan.tif',overwrite=T)

# There is no global hard shelf data in the BSR region. Deleting the 'global_hard_shelf_bsr.tif' from the server (8/3/2015-JA)
                                          
soft_shal_global = raster(file.path(dir_arctic,'ecosystems/benthic_substrate/global_habitats/s_t_s_bottom_lzw.tif'))%>%
                    crop(.,extent(-18040095,18040134,6000000,10000000))%>%
                     projectRaster(.,crs=laeaCRS,progress='text')%>%
                      mask(.,pan,progress='text',filename='habitats/hard_and_soft/working/global_s_t_s_bottom_pan.tif', overwrite=T)%>%
                        crop(.,bsr)%>%
                        resample(.,bsr_ocean,filename='habitats/hard_and_soft/working/global_s_t_s_bottom_bsr.tif',overwrite=T)

soft_shelf_global = raster(file.path(dir_arctic,'ecosystems/benthic_substrate/global_habitats/soft_shelf_lzw.tif'))%>%
                     crop(.,extent(-18040095,18040134,6000000,10000000))%>%
                      projectRaster(.,crs=laeaCRS,progress='text')%>%
                       mask(.,pan,progress='text',filename='habitats/hard_and_soft/working/global_soft_shelf_pan.tif',overwrite=T)%>%
                        crop(.,bsr)%>%
                          resample(.,bsr_ocean,filename='habitats/hard_and_soft/working/global_soft_shelf_bsr.tif',overwrite=T)


#-------------------------------------------------------

# use global layers to add data where there isn't any...using hab_ras

extent(hard_shal_global)<-extent(hab_ras)


# (1) Hard shallow
plot(hard_shal_global)
# This global raster layer does not have hard shallow habitat outside of the extent of our habitat raster for the BSR region.
# Therefore we will just go with the raster shal_hard for BSR

writeRaster(shal_hard,filename='habitats/hard_and_soft/output/bsr_hard_shallow.tif',overwrite=T)

# (2) Hard shelf - there is none from the global data so we are using shelf_hard for BSR

writeRaster(shelf_hard,filename='habitats/hard_and_soft/output/bsr_hard_shelf.tif',overwrite=T)

# (3) Soft Shallow

      bsr_s_shal = raster('habitats/hard_and_soft/working/global_s_t_s_bottom_bsr.tif')%>%
                    mask(.,hab_ras,inverse=T,progress='text')

      m = merge(shal_soft,bsr_s_shal,progress='text')%>%mask(.,bsr)
      m[!is.na(m)]<-1
      writeRaster(m,filename='habitats/hard_and_soft/output/bsr_soft_shallow.tif',overwrite=T) 

#(4) Soft Shelf

      bsr_s_shelf = raster('habitats/hard_and_soft/working/global_soft_shelf_bsr.tif')%>%
        mask(.,hab_ras,inverse=T,progress='text')
      
      p = merge(shelf_soft, bsr_s_shelf,progress='text')%>%mask(.,bsr)
      p[!is.na(p)]<-1
      writeRaster(p,filename='habitats/hard_and_soft/output/bsr_soft_shelf.tif',overwrite=T)


#plotting


par(mfrow=c(2,2),mar = c(1,2,2,1) + 0.4)
plot(shal_hard,col='red',main='BSR Hard Shallow',legend=F)
plot(bsr,add=T)
plot(shelf_hard,col='green',main='BSR Hard Shelf',legend=F)
plot(bsr,add=T)
plot(m,col='purple',main='BSR Soft Shallow',legend=F)
plot(bsr,add=T)
plot(p,col='orange',main='BSR Shelf Shallow',legend=F)
plot(bsr,add=T)

