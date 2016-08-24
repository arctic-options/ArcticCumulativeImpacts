library(dplyr)
library(hash)

calc_mean_and_ci <- function(mean_file, display_name){
  mc<-read.csv(mean_file)
  hist(mc$Mean, main=paste("Means for ",display_name))
  mean_of_original_analysis<-mc %>% filter(Run == -1) 
  ttest<-t.test(mc$Mean, mu=mean_of_original_analysis$Mean)
  print(ttest)
  
  mean_of_original_analysis<-mc %>% filter(Run == -1) 
  df<-data.frame(name=display_name, orig_mean=mean_of_original_analysis$Mean, 
                 ci_low=ttest$conf.int[1], ci_high=ttest$conf.int[2])
  df
}

build_percents <- function(mean_cat_file, display_name){
  mc<-read.csv(mean_cat_file)
  #df<-data.frame("vlow", "low", "med", "high", "vhigh")
  df<-NULL
  for(i in 1:nrow(mc)){
    row=mc[i,]
    cntr=row$Run
    tot = row$Total
    zeros = row$Zeros
    tot_non_zeros = tot - zeros
    
    vlow_perc = (row$Very.Low/tot_non_zeros)*100.0
    low_perc = (row$Low/tot_non_zeros)*100.0
    med_perc = (row$Medium/tot_non_zeros)*100.0
    high_perc = (row$High/tot_non_zeros)*100.0
    vhigh_perc = (row$Very.High/tot_non_zeros)*100.0
    
    if(is.null(df)){
      df<-data.frame(run=cntr,vlow=vlow_perc, low=low_perc, med=med_perc, high=high_perc, vhigh=vhigh_perc)
    } else{
      new_df<-data.frame(run=cntr,vlow=vlow_perc, low=low_perc, med=med_perc, high=high_perc, vhigh=vhigh_perc)
      df<-rbind(df, new_df)
    }
  }
  df
}

calc_all_cat_percents <- function(mean_cat_file, display_name){
  df<-build_percents(mean_cat_file, display_name)
  mval<-df %>% filter(run == -1) 
  
  vlow_mean<-mval$vlow
  vlow_ttest<-t.test(df$vlow)
  
  low_mean<-mval$low
  low_ttest<-t.test(df$low)
  
  med_mean<-mval$med
  med_ttest<-t.test(df$med)
  
  high_mean<-mval$high
  high_ttest<-t.test(df$high)
  
  vhigh_mean<-mval$vhigh
  vhigh_ttest<-t.test(df$vhigh)
  names<-c(paste(display_name,"ci low"), paste(display_name, "mean"), paste(display_name,"ci high"))
  
  vlow<-c(vlow_ttest$conf.int[1],vlow_mean, vlow_ttest$conf.int[2])
  low<-c(low_ttest$conf.int[1], low_mean, low_ttest$conf.int[2])
  med<-c(med_ttest$conf.int[1],med_mean, med_ttest$conf.int[2])
  high<-c(high_ttest$conf.int[1],high_mean,high_ttest$conf.int[2])
  vhigh<-c(vhigh_ttest$conf.int[1],vhigh_mean, vhigh_ttest$conf.int[2])
  
  mean_df<-data.frame(name=names, Very.Low=vlow,Low=low, Medium=med,
                      High=high, Very.High=vhigh)
  mean_df
}

calc_cat_percents <- function(mean_cat_file, display_name){
  mc<-read.csv(mean_cat_file)
  orig_row<-mc %>% filter(Run == -1) 
  tot = orig_row$Total
  zeros = orig_row$Zeros
  tot_non_zeros = tot - zeros
  vlow_perc = (orig_row$Very.Low/tot_non_zeros)*100.0
  low_perc = (orig_row$Low/tot_non_zeros)*100.0
  med_perc = (orig_row$Medium/tot_non_zeros)*100.0
  high_perc = (orig_row$High/tot_non_zeros)*100.0
  vhigh_perc = (orig_row$Very.High/tot_non_zeros)*100.0
  
  df<-data.frame(name=display_name,vlow=vlow_perc,low=low_perc,med=med_perc,high=high_perc,vhigh=vhigh_perc)
  df
}

calc_cat_means <- function(mean_cat_file, display_name){
  mc<-read.csv(mean_cat_file)
  orig_row<-mc %>% filter(Run == -1) 
  
  vlow_ttest<-t.test(mc$Very.Low)
  vlow_orig<-orig_row$Very.Low
  
  low_ttest<-t.test(mc$Low)
  low_orig<-orig_row$Low
  
  med_ttest<-t.test(mc$Medium)
  med_orig<-orig_row$Medium
  
  high_ttest<-t.test(mc$High)
  high_orig<-orig_row$High
  
  vhigh_ttest<-t.test(mc$Very.High)
  vhigh_orig<-orig_row$Very.High
  
  df<-data.frame(name=display_name,vlow_orig=vlow_orig,vlow_ci_low=vlow_ttest$conf.int[1],vlow_ci_high=vlow_ttest$conf.int[2],
                 low_orig=low_orig,low_ci_low=low_ttest$conf.int[1],low_ci_high=low_ttest$conf.int[2],
                 med_orig=med_orig,med_ci_low=med_ttest$conf.int[1],med_ci_high=med_ttest$conf.int[2],
                 high_orig=high_orig,high_ci_low=high_ttest$conf.int[1],high_ci_high=high_ttest$conf.int[2],
                 vhigh_orig=vhigh_orig,vhigh_ci_low=vhigh_ttest$conf.int[1],vhigh_ci_high=vhigh_ttest$conf.int[2])
  df
}

par(mar = rep(2,4))
par(mfrow=c(1,3)) 

regions <- hash()
.set( regions, all="", us="us_", russia="russia_" )

for(key in keys(regions)){
  prefix<-regions[[key]]
  outname <- paste("monte_carlo/out_",key,"_monte_carlo_means.csv",sep="")
  print(paste("prefix:", prefix, "output file:", outname))
  
  annual_name<-paste("monte_carlo/",prefix,"annual_mc.csv",sep="")
  means_df<-calc_mean_and_ci(annual_name, "annual")
  
  winter_name<-paste("monte_carlo/",prefix,"ice_season_mc.csv",sep="")
  winter<-calc_mean_and_ci(winter_name, "winter")
  means_df<-rbind(means_df, winter)
  
  summer_name<-paste("monte_carlo/",prefix,"icefree_season_mc.csv",sep="")
  summer<-calc_mean_and_ci(summer_name, "summer")
  means_df<-rbind(means_df, summer)
  
  write.csv(means_df,outname)
}



if(FALSE){
  percs_df<-calc_cat_percents('monte_carlo/annual_mc_cats.csv', "annual")
  winter_percs<-calc_cat_percents('monte_carlo/ice_season_mc_cats.csv', "winter")
  percs_df<-rbind(perc_df, winter_percs)
  summer_percs<-calc_cat_percents('monte_carlo/icefree_season_mc_cats.csv', "summer")
  percs_df<-rbind(percs_df, summer_percs)
  write.csv(percs_df,file='monte_carlo/monte_carlo_category_percents.csv')
  
  cats_df<-calc_all_cat_percents('monte_carlo/annual_mc_cats.csv', "annual")
  winter_cats<-calc_all_cat_percents('monte_carlo/ice_season_mc_cats.csv', "winter")
  cats_df<-rbind(cats_df, winter_cats)
  summer_cats<-calc_all_cat_percents('monte_carlo/icefree_season_mc_cats.csv', "summer")
  cats_df<-rbind(cats_df, summer_cats)
  write.csv(cats_df,file='monte_carlo/monte_carlo_category_means.csv')
  
  #cats_df<-calc_cat_means('monte_carlo/annual_mc_cats.csv', "annual")
  #winter_cats<-calc_cat_means('monte_carlo/ice_season_mc_cats.csv', "winter")
  #cats_df<-rbind(cats_df, winter_cats)
  
  #summer_cats<-calc_cat_means('monte_carlo/icefree_season_mc_cats.csv', "summer")
  #cats_df<-rbind(cats_df, summer_cats)
  #write.csv(cats_df,file='monte_carlo/monte_carlo_category_means.csv')
}


#cats_df<-calc_cat_means('monte_carlo/annual_mc_cats.csv', "annual")
#winter_cats<-calc_cat_means('monte_carlo/ice_season_mc_cats.csv', "winter")
#cats_df<-rbind(cats_df, winter_cats)

#summer_cats<-calc_cat_means('monte_carlo/icefree_season_mc_cats.csv', "summer")
#cats_df<-rbind(cats_df, summer_cats)
#write.csv(cats_df,file='monte_carlo/monte_carlo_category_means.csv')
