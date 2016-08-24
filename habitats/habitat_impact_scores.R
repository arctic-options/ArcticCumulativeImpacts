# Looking at habitats with highest/lowest impacts

habs_ice = list.files('output/habitat_impact_layers',full.names=T, pattern='ice.tif$')%>%
            stack()%>%mask(bsr)

habs_icef = list.files('output/habitat_impact_layers',full.names=T,pattern='ice_free.tif$')%>%
              stack()%>%mask(bsr)

habs = list.files('output/habitat_impact_layers',full.names=T,pattern='annual.tif$')%>%
          stack()%>%mask(bsr)

# area weighted mean impact

# take the mean impact and then divide by total area?

hab_mean <- function(raster){
  
  raster[raster==0]<-NA
  
  mean = cellStats(raster,stat='mean',na.rm=T)
  
  mean
}

df_icef <- data.frame(hab_mean(habs_icef),stringsAsFactors=F)%>%
        mutate(habitat = row.names(.))%>%
               rename(mean = hab_mean.habs_icef.)%>%
        separate(habitat,c("habitat","season"),sep='_ECO_',extra='merge')

df_ice <- data.frame(hab_mean(habs_ice),stringsAsFactors=F)%>%
  mutate(habitat = row.names(.))%>%
  rename(mean = hab_mean.habs_ice.)%>%
  separate(habitat,c("habitat","season"),sep='_ECO_',extra='merge')

df_all <- data.frame(hab_mean(habs),stringsAsFactors=F)%>%
  mutate(habitat = row.names(.))%>%
  rename(mean = hab_mean.habs.)%>%
  separate(habitat,c("habitat","season"),sep='_ECO_',extra='merge')

df <- rbind(df_ice,df_icef,df_all)


ggplot(df,aes(x=reorder(habitat,-mean),y=mean,fill=season))+
  geom_bar(stat='identity',position='dodge')+
  labs(x='Habitat',y='Mean Impact Scores')+
  scale_fill_discrete(name='Season',labels = c('Annual','Ice','Ice-Free'))


