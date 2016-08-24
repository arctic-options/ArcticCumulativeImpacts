# Arctic UV data explore

source('../../common.R')


library(ncdf4)


data = stack(file.path(dir_arctic,'stressors/uv/raw/data_for_cusb/uiUVB_All.nc'))

data_nc <- nc_open(file.path(dir_arctic,'stressors/uv/raw/data_for_cusb/uiUVB_All.nc'))

uvb <- ncvar_get(data_nc,varid='uvbIr')

long <- ncvar_get(data_nc,varid='lon')
lat <- ncvar_get(data_nc,varid='lat')
fillvalue <- 1e+32

uvb[uvb==fillvalue]<-NA


mon <- 4
per <- 1
data <- 1

uv <- uvb[,,mon,per,data]


r <-raster(uv,xmn=55,xmx=85,ymn=-180,ymx=170)
r <- flip(t(r),"y")

plot(r)

laeaCRS <- CRS("+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
projection(r) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
out<- projectRaster(r,crs=laeaCRS)

writeRaster(r,filename='stressors/uv/working/uvb_April_Past_MonthlyMean.tif')

#-------------------------------------------------------------

# Looking at past UV across arctic and bsr


mon <- 1:6
per <- 1 #past is period 1
data <- 1

uv <- uvb[,,mon,per,data]

uv_mean = apply(uv,1:2,mean) 


r<-raster(uv_mean,xmn=55,xmx=85,ymn=-180,ymx=170)
r <- flip(t(r),"y")

plot(r)

laeaCRS <- CRS("+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
projection(r) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
past_arctic<- projectRaster(r,crs=laeaCRS);plot(past_arctic)
past_bsr <- crop(past_arctic,bsr);plot(past_bsr)

#-------------------------------------------------------------

# Looking at present UV across arctic and bsr

mon <- 4
per <- 2 #present is period 2
data <- 1

uv <- uvb[,,mon,per,data]


r<-raster(uv,xmn=55,xmx=85,ymn=-180,ymx=170)
r <- flip(t(r),"y")

plot(r)

laeaCRS <- CRS("+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
projection(r) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
pres_arctic<- projectRaster(r,crs=laeaCRS);plot(pres_arctic)
pres_bsr <- crop(pres_arctic,bsr);plot(pres_bsr)

#-------------------------------------------------------------

# Look at change

ch_arctic = pres_arctic - past_arctic
plot(ch_arctic)

ch_bsr = pres_bsr - past_bsr
plot(ch_bsr)
