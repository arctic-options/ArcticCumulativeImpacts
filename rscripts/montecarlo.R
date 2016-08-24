#Monte Carlo Simulation

# This script takes the weight matrix and randomly samples to create 500

library(dplyr)

weights = read.csv('weights/weights.csv')[2:13,2:12]%>% 
  `colnames<-`(c('','RR_ECO','HS_ECO','SBSB_ECO','SSHELF_ECO',
                 'SW_ECO','DW_ECO', 'BCH_ECO', 'SM_ECO','RI_ECO','IM_ECO'))%>%
  `row.names<-`(.[,1])%>%
        select(RR_ECO:IM_ECO)%>%
          as.matrix()

