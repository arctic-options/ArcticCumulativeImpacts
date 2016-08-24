#Exploring mercury deposition data

source('common.R')

r <- raster(file.path(dir_arctic,'stressors/atmospheric_deposition/raw/GEOS-Chem_Mercury/mmtf_GEOSCHEM-v902_BASE_vmrhg0aq_Surface_2013_Monthly.nc'),stopIfNotEqualSpaced=FALSE)


"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0" 
laeaCRS <- CRS("+init=epsg:3572")


nc = open.ncdf(file.path(dir_arctic,'stressors/atmospheric_deposition/raw/GEOS-Chem_Mercury/mmtf_GEOSCHEM-v902_BASE_vmrhg0aq_Surface_2013_Monthly.nc'))

data = get.var.ncdf(nc,varid='vmrhg0aq')

long <- get.var.ncdf(nc,varid='lon_bnds') #dim = 144

# latitude values are stored in the variable 'TLAT'

lat <- get.var.ncdf(nc,varid='lat_bnds') #dim = 91



data[data==1e+20]<-NA


m = data[,,1]
m_mean = apply(m,c(1,2),mean)

#create an array with long, lat, aragonite mean data
A <- array(c(lat,long,m_mean),dim=c(144,91,3))
B <- apply(A, 3, cbind)

#lon=x, lat=y
x = B[,1]
y = B[,2]


C = as.data.frame(B)
names(df)<-c('x','y','value')


e <- extent(df[,1:2])
r <- raster(e,ncol=91,nrow=144) #create empty raster with e extent

out <- rasterize(C[,1:2],r,C[,3],fun=function(x,...)mean(x),progress='text') # i had to create a mean function here for "multiple points in a cell"
extent(out)<-c(-180,180,-90,90) #data extent is 0,360,-80, 90 (the -80 is not a typo)
out <- rotate(out) #shifts data from 0-360 to -180-180

