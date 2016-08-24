# compare_uv_anomalies.py
# =======================================
#
# Calculate difference between uv anomaly layers in two time periods.
# (difference raster = raster2 - raster1)
# Also log-transform and normalize the raw difference raster.
#
# (Tested w/ ArcGIS 10.1)
# June-July 2013, John Potapenko (john@scigeo.org)
#
#===============================================================================

#----------------------------------
# user-parameters:
#----------------------------------

# input and output directories
uv_anomaly_input_dir = "R:\\users\\potapenko\\DATA STORAGE\\uv\\uv_baseline_anomaly"
uv_anomaly_output_dir = "R:\\users\\potapenko\\DATA STORAGE\\uv\\uv_baseline_anomaly"

# anomaly input rasters (from input directory above)
anomaly_rast1_raw="toms_ep_uv_anomaly_1997m01-2001m12_raw.tif"
anomaly_rast2_raw="omi_aura_uv_anomaly_2008m01-2012m12_raw.tif"

# output raster names
anomaly_rast1_trans="toms_ep_uv_anomaly_1997m01-2001m12_trans.tif"
anomaly_rast2_trans="omi_aura_uv_anomaly_2008m01-2012m12_trans.tif"

difference_rast_raw_output='uv_anomaly_difference_2008m01-2012m12_minus_1997m01-2001m12_raw.tif'
difference_rast_trans_output='uv_anomaly_difference_2008m01-2012m12_minus_1997m01-2001m12_trans.tif'

#----------------------------------
# functions:
#----------------------------------

# transform_raster: log-transform and normalize input raster
#                   and save with output raster name
#
# For each raster, compute the log10(pixel_value+1) and normalize result
# by highest value, giving values in range from 0 to 1.
# (The high value of 1 is guaranteed, but the low zero may not be reached
#  if the lowest original value is not zero.)
#
# If values are negative and positive, the negative and positive pixel values
# are computed as log10(absolute_value(pixel_value)+1) 
# and normalized out of the highest absolute pixel value.
# (Thus results will be on the scale from -1 to 1,
#  although need not span that entire range.)

def transform_raster(input_raster,output_raster):
  arcpy.CalculateStatistics_management(input_raster)
  max_val=float(str(arcpy.GetRasterProperties_management(input_raster,"MAXIMUM")))
  min_val=float(str(arcpy.GetRasterProperties_management(input_raster,"MINIMUM")))
  if min_val >0:
    outRast=Log10(arcpy.Raster(input_raster)+1)/Log10(max_val+1)
  else:
    max_val=max(abs(min_val),abs(max_val))
    outRast=Con(arcpy.Raster(input_raster)>0,1,-1)*Log10(Abs(arcpy.Raster(input_raster))+1)/Log10(max_val+1)
  outRast.save(output_raster)

#----------------------------------
# main:
#----------------------------------

import os, sys, arcpy
from arcpy.sa import *
arcpy.CheckOutExtension("spatial")

arcpy.env.overwriteOutput=True

# calculate transformed anomaly rasters
transform_raster(os.path.join(uv_anomaly_input_dir,anomaly_rast1_raw),\
                 os.path.join(uv_anomaly_output_dir,anomaly_rast1_trans))
transform_raster(os.path.join(uv_anomaly_input_dir,anomaly_rast2_raw),\
                 os.path.join(uv_anomaly_output_dir,anomaly_rast2_trans))

# calculate difference raster
difference_rast=\
    arcpy.Raster(os.path.join(uv_anomaly_input_dir,anomaly_rast2_raw))-\
    arcpy.Raster(os.path.join(uv_anomaly_input_dir,anomaly_rast1_raw))
difference_rast.save(os.path.join(uv_anomaly_output_dir,difference_rast_raw_output))

# calculate transformed difference raster

transform_raster(os.path.join(uv_anomaly_output_dir,difference_rast_raw_output),\
                 os.path.join(uv_anomaly_output_dir,difference_rast_trans_output))
