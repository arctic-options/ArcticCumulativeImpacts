# Updating beach

# Jamie Afflerbach

source('common.R')

# Bring in global beach

beach_gl = raster('habitats/beach_lzw.tif')

#clip to bsr

beach_gl = crop(beach_gl,bsr)%>%
              mask(.,bsr,progress='text')%>%
  resample(.,bsr_ocean,method='ngb')

# bring in beach from AK shorezone

#coastal classes shapefile has all classes - we will need to select beach from this
coast_sz = readOGR(dsn=file.path(dir_arctic,'ecosystems/coastal/ShoreZone_AK'),layer='CoastalClass_AK_ShoreZone')

#transform
coast_sz_laea=spTransform(coast_sz,laeaCRS,progress='text')


head(coast_sz@data)

#clip coast_sz to BSR

bsr_rec = readOGR(dsn=file.path(dir_arctic,'gis/bsr'),layer='BSR_rectangle')

coast_bsr = crop(coast_sz_laea,bsr_rec,progress='text')

# bring in older ESI data and rasterize for beach

    nw_ak = readOGR(dsn=file.path(dir_arctic,'ecosystems/coastal/NOAA ESI/NWArctic_2002_Shapefiles/AVPROJ/shape'),layer='esil')
    
    projection(nw_ak)<-"+proj=longlat +ellps=clrk66 +datum=NAD27 +no_defs <>"
    
    nw_ak_laea = spTransform(nw_ak,laeaCRS)

  #Using the 2009 Halpern cal current CHI analysis, the following ESI codes were used for beach:

    b = c('3A|4|5|6A')

    nw_ak_bsr = crop(nw_ak_laea,bsr_rec)
    nw_ak_bsr@data$ESI <- as.character(nw_ak_bsr@data$ESI)
    nw_ak_bsr[grep(b,nw_ak_bsr@data$ESI),"habitat"]<-'beach' #
    nw_ak_beach = nw_ak_bsr[nw_ak_bsr$habitat=='beach',]
    
  #rasterize to correct res
    
    nw_ak_beach_ras = rasterize(nw_ak_beach,bsr_ocean,progress='text')
    nw_ak_beach_ras[nw_ak_beach_ras>0]<-1 

    
    
#--------------------------------------------

    c = c('3A','4','5','6A')
    
# Bring in newer data and rasterize for beach
beach_aksz_bsr = coast_bsr[coast_bsr@data$ESI %in% c,]

# rasterize beach

beach_ras = rasterize(beach_aksz_bsr,bsr_ocean,progress='text')
#set values of beach_ras to 1

beach_ras[beach_ras>0]<-1


# Need to make 3 separate rasters for st lawrence island and kotzebue sound (and a piece of k sound)

#draw extent around st lawrence island and save it for cropping

stl_ext <- drawExtent(show=TRUE,col='red')
#class       : Extent 
#xmin        : -1106856 
#xmax        : -924987.5 
#ymin        : -2835333 
#ymax        : -2685292 

stl_aksz = crop(beach_ras,stl_ext)
#stl_gl   = crop(beach_gl,stl_ext)

#kotzebue extent
k_ext <- drawExtent(show=TRUE,col='red')
#class       : Extent 
#xmin        : -837084.6 
#xmax        : -444552.7 
#ymin        : -2571624 
#ymax        : -2266995  
k_aksz = crop(beach_ras,k_ext)

#second portion of kotzebue sound
k2_ext <- drawExtent(show=TRUE,col='red')
#class       : Extent 
#xmin        : -635514.1 
#xmax        : -443037.1 
#ymin        : -2617091 
#ymax        : -2570109  
k2_aksz = crop(beach_ras,k2_ext)

#-------------------------------------

#Now we have three sections of beach raster from the newest coastal data. We need to merge these with the older data
#from ESI database

#draw extent around the southern half of nw_ak_int_ras that needs to be kept. 
#need two extents
int_ext<-drawExtent(show=TRUE,col='red')
#       class       : Extent 
#       xmin        : -833978.7 
#       xmax        : -633807.4 
#       ymin        : -2899115 
#       ymax        : -2568220 
nw_1<-crop(nw_ak_beach_ras,int_ext)

int_ext2 <- drawExtent(show=TRUE,col='red')
#       class       : Extent 
#       xmin        : -654233 
#       xmax        : -445891.4 
#       ymin        : -2909328 
#       ymax        : -2707114 


nw_2<-crop(nw_ak_beach_ras,int_ext2)

#mask beach_gl to select hte southern most part of the coast that has not been mapped

crop_1 = drawExtent(show=TRUE,col='red')
# xmin        : -896779.9 
# xmax        : -720493.2 
# ymin        : -2943241 
# ymax        : -2860917 

beach_gl_1 = crop(beach_gl,crop_1)

#Crop the russian side
rus_ext <- drawExtent(show=TRUE,col='red')

rus = crop(beach_gl,rus_ext)

#final beach layer
all = merge(stl_aksz,k_aksz,k2_aksz,beach_gl_1,nw_1,nw_2,rus)%>%
  crop(.,bsr_ocean)%>%
  extend(.,bsr_ocean) #add additional rows of NA to match bsr_ocean


writeRaster(all,filename='habitats/coastal/beach.tif',overwrite=T)
