
There was no data for Russian fisheries in the Bering Strait so unfortunately we are unable to update the fishing data in Russian waters, except for Halibut which is internationally managed by the IPHC which provides data for the region.

Following the same methods from Halpern et al. (2008), all fishing layers were standardized by updated primary productivity data from VGPM - described in 

###Data Layers and associated scripts


**Demersal destructive and pelagic high bycatch fishing layers were updated with** `comm_fis_pressures_layers.R`
- Both of these types of fishing do not take place in US waters.


**Pelagic low bycatch**
  
  The data is kept the same from Halpern 2013 for pelagic low bycatch in Russian waters. In US waters, the salmon fishery that takes place in the BSR falls into this category. The script `pel_lb_salmon_data_layer.R` creates this layer using data from [Alaska Commercial Fisheries Entry (CFEC)](http://www.cfec.state.ak.us/bit/mnusalm.htm). Raw data located in `inputs/BIT.csv`

**Demersal non destructive low bycatch**
  
  This data is kept the same from Halpern 2013 for Russian waters. In US waters, the crab fishery that takes place in the BSR falls into this category. The script `dem_nd_lb_crab_data_layer.R` creates this layer using data from the [CFEC](http://www.cfec.state.ak.us/bit/mnucrab.htm). Data is also found in `inputs/BIT.csv`

**Demersal nondestructive high bycatch**
  
  The regional halibut fishery falls into this category as the gear used are bottom long-lines. There is not much data on the bycatch of this fishery.

The [International Pacific Halibut Commission](http://www.iphc.int/) manages this fishery and keeps data for each of its [regulatory regions](http://alaskafisheries.noaa.gov/maps/iphc/areas.htm). Tom Kong from IPHC provided me with data restricted to regions 4D and 4E between the 62 and 66 parallels. Catch data was averaged for the years 2008-2013 and applied to the region.

The halibut data is the only fishing data for the US region. Fishing data in Russian waters was kept from the 2013 CHI project was not updated with the halibut data under the assumption that the FAO data used to update this data incorporates the halibut fishery statistics. 

**Pelagic high bycatch**
  
  This type of fishing does not take place in this region.
