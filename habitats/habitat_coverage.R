#Percent coverage of habitats


# There are 472044 cells in the bsr region


habs = list.files('habitats/ci_model_layers',full.names = T,pattern='.tif$')

df = data.frame()


for (i in 1:10){
  
  h = raster(habs[i])
  
  layer = substr(basename(habs[i]), 1, nchar(basename(habs[i]))-4)
  
  perc = (cellStats(h,stat='sum')/472044)*100
  
  d = data.frame(layer,perc)
  
  df = rbind(df,d)
  
}

names(df)<- c('Habitat','Percent Coverage (%)')
