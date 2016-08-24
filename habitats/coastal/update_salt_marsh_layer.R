# Updating salt marsh layer


# Jamie Afflerbach

source('common.R')

# Bring in global salt marsh
sm_gl = raster('habitats/salt_marsh_lzw.tif')

#clip to bsr_rec
bsr_rec = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='BSR_rectangle')

sm_gl = crop(sm_gl,bsr_rec)%>%
          mask(.,bsr_rec,progress='text')%>%
            resample(.,bsr_ocean,method='ngb')

#---------------------------------------------

# bring in beach from AK shorezone

    #coastal classes shapefile has all classes - we will need to select beach from this
    coast_sz = readOGR(dsn=file.path(dir_arctic,'ecosystems/coastal/ShoreZone_AK'),layer='CoastalClass_AK_ShoreZone')
    
    #transform
    
    coast_sz = spTransform(coast_sz,laeaCRS)
    
    head(coast_sz@data)
    
    #clip coast_sz to BSR
    
    coast_bsr = crop(coast_sz,bsr_rec)
    
    
    #Based off ESI selections for Halpern (2009) cal current CHI ecosystems, the following ESI codes are assigned to salt marshes
    
    #10A used for salt marshes
    
    sm_aksz_bsr = coast_bsr[coast_bsr@data$ESI =='10A',]
    
    # rasterize beach
    
    
    sm_ras = rasterize(sm_aksz_bsr,bsr_ocean,progress='text')
    #set values of beach_ras to 1
    
    sm_ras[sm_ras>0]<-1
    
    
    # Need to make 3 separate rasters for st lawrence island and kotzebue sound (and a piece of k sound)
    
    #draw extent around st lawrence island and save it for cropping
    
    plot(sm_ras,col='black')
    plot(coast_bsr,add=T,col='red')
    
    stl_ext <- drawExtent(show=TRUE,col='red')
    #class       : Extent 
    #xmin        : -1106856 
    #xmax        : -924987.5 
    #ymin        : -2835333 
    #ymax        : -2685292 
    
    stl_aksz = crop(sm_ras,stl_ext)
    #stl_gl   = crop(beach_bsr,stl_ext)
    
    #kotzebue extent
    k_ext <- drawExtent(show=TRUE,col='red')
    #class       : Extent 
    #xmin        : -837084.6 
    #xmax        : -444552.7 
    #ymin        : -2571624 
    #ymax        : -2266995  
    k_aksz = crop(sm_ras,k_ext)
    
    #second portion of kotzebue sound
    k2_ext <- drawExtent(show=TRUE,col='red')
    #class       : Extent 
    #xmin        : -635514.1 
    #xmax        : -443037.1 
    #ymin        : -2617091 
    #ymax        : -2570109  
    k2_aksz = crop(sm_ras,k2_ext)

    
#------------------------------------------------
    
# now bring in older data for the rest of the alaskan coast
    
    nw_ak = readOGR(dsn=file.path(dir_arctic,'ecosystems/coastal/NOAA ESI/NWArctic_2002_Shapefiles/AVPROJ/shape'),layer='esil')
    
    projection(nw_ak)<-"+proj=longlat +ellps=clrk66 +datum=NAD27 +no_defs <>"
    
    nw_ak_laea = spTransform(nw_ak,laeaCRS)
  
    plot(nw_ak_laea,col='black')
    
    nw_ak_bsr = crop(nw_ak_laea,bsr_rec)
    nw_ak_bsr@data$ESI <- as.character(nw_ak_bsr@data$ESI)
    nw_ak_bsr[grep("10A",nw_ak_bsr@data$ESI),"habitat"]<-'saltmarsh' #
    nw_ak_sm = nw_ak_bsr[nw_ak_bsr$habitat=='saltmarsh',]
    
    #rasterize to correct res
    
    nw_ak_sm_ras = rasterize(nw_ak_sm,bsr_ocean,progress='text')
    nw_ak_sm_ras[nw_ak_sm_ras>0]<-1 
    
    #crop to extent outside of recent AK shorezone mapping range
    plot(sm_ras,col='black')
    plot(nw_ak_sm_ras,col='red',add=T)
    
    #draw extent around the southern half of nw_ak_int_ras that needs to be kept. 
    #need two extents
    int_ext <- drawExtent(show=TRUE,col='red')
    #       class       : Extent 
    #       xmin        : -833978.7 
    #       xmax        : -633807.4 
    #       ymin        : -2899115 
    #       ymax        : -2568220 
    nw_ak_1<-crop(nw_ak_sm_ras,int_ext)
    
    int_ext2 <- drawExtent(show=TRUE,col='red')
    #       class       : Extent 
    #       xmin        : -654233 
    #       xmax        : -445891.4 
    #       ymin        : -2909328 
    #       ymax        : -2707114 
    nw_ak_2<-crop(nw_ak_sm_ras,int_ext2)
    
    #mask ri_bsr to select southern part that the two recent datasets don't cover
    
    plot(nw_ak_laea)
    plot(sm_gl,col='red',add=T)
    
    #crop global intertidal mud layer
    crop_1 = drawExtent(show=TRUE,col='red')
    #       class       : Extent 
    #       xmin        : -808251.6 
    #       xmax        : -647206.5 
    #       ymin        : -2910041 
    #       ymax        : -2851355 
    
    sm_gl_1 = crop(sm_gl,crop_1)
    
    #Crop the russian side
    plot(sm_gl,col='black')
    rus_ext <- drawExtent(show=TRUE,col='red')
    class       : Extent 
    xmin        : -1666720 
    xmax        : -844314.7 
    ymin        : -2659644 
    ymax        : -2112734 
    
    rus = crop(sm_gl,rus_ext)
    
#-------------------------------------
    
#final salt marsh layer
  all = merge(rus,stl_aksz,k_aksz,k2_aksz,nw_ak_1,nw_ak_2,sm_gl_1)%>%
          crop(.,bsr_ocean)%>%
            extend(.,bsr_ocean) #add additional rows of NA to match bsr_ocean
          
    
    
  writeRaster(all,filename='habitats/coastal/salt_marsh.tif',overwrite=T)

