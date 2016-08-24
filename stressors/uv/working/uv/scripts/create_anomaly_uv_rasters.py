#!/usr/bin/python

import gdal, struct, osr, numpy, csv, sys, time, math, os, glob, re
from gdalconst import *
import datetime
from osgeo import gdal  
from osgeo.gdalnumeric import *  
from osgeo.gdalconst import *
import operator

#==================================================================================
# create_anomaly_uv_rasters.py:
#------------------------------
#
# This script calculates the baseline mean raster ("climatological" mean)
# and standard deviation from the baseline mean for each satellite by taking
# the mean of monthly uv irradiance rasters.
# Then it computes the number of anomalies greater than 1+ standard deviations
# above the baseline mean for each satellite's time period.
#
# Run after 'create_monthly_uv_rasters.py'.
#
# June-July 2013, John Potapenko (john@scigeo.org)
#
#==================================================================================
# user input parameters:
#-----------------------

# uv_rast_input: input of monthly mean uv satellite raster files
# format:
#   <satellite prefix name>:
#   {<directory name>,<raster file type>,<raster name prefix>,
#    <year start>,<month start>,<year end>,<month end>}
uv_rast_input={
 'toms_ep':{
 'dir': '/media/nix/nceas_ohi/impact_layers_redo/uv/uv_monthly_mean/',
 'file_type': '.tif',
 'raster_prefix': 'toms_ep_uv_mean_',
 'year_start': 1997,
 'month_start': 1,
 'year_end': 2001,
 'month_end': 12},
 'omi_aura':{
 'dir': '/media/nix/nceas_ohi/impact_layers_redo/uv/uv_monthly_mean/',
 'file_type':'.tif',
 'raster_prefix':'omi_aura_uv_mean_',
 'year_start': 2008,
 'month_start': 1,
 'year_end': 2012,
 'month_end': 12}}

# where output rasters will be stored
uv_rast_output_dir='/media/nix/nceas_ohi/impact_layers_redo/uv/uv_baseline_anomaly'

#==================================================================================

### preliminaries

# start timer
start_time=time.time()

# create output directory if it doesn't exist
if not os.path.isdir(uv_rast_output_dir):
  os.mkdir(uv_rast_output_dir)

### read in rasters

uv_rast_list={}
for sat_name in uv_rast_input:
  uv_rast_list[sat_name]={}
  for year in range(uv_rast_input[sat_name]['year_start'],uv_rast_input[sat_name]['year_end']+1):
    uv_rast_list[sat_name][year]={}
    for month in range(uv_rast_input[sat_name]['month_start'],uv_rast_input[sat_name]['month_end']+1):
      uv_rast_input_file_search=glob.glob(os.path.join(uv_rast_input[sat_name]['dir'],uv_rast_input[sat_name]['raster_prefix']+str(year)+'_'+str(month).zfill(2)+'*'+uv_rast_input[sat_name]['file_type']))
      if not uv_rast_input_file_search:
        print 'skipping year: ',year,', month: ',month
        continue
      
      uv_rast_input_file=uv_rast_input_file_search[0]
      #print 'Reading file: ',print uv_rast_input_file

      uv_rast=gdal.Open(uv_rast_input_file, GA_ReadOnly)
      if uv_rast is None:
        print 'Error: could not open raster file: ', uv_rast_input_file
        sys.exit(1)
      uv_rast_list[sat_name][year][month]=uv_rast

### stack rasters into array

uv_rast_data_array={}
uv_rast_sample={}
for sat_name in uv_rast_input:
  # flag for first raster
  first_raster=True
  for year in range(uv_rast_input[sat_name]['year_start'],uv_rast_input[sat_name]['year_end']+1):
    for month in range(uv_rast_input[sat_name]['month_start'],uv_rast_input[sat_name]['month_end']+1):
      uv_rast=uv_rast_list[sat_name][year][month]
      uv_rast_data=BandReadAsArray(uv_rast.GetRasterBand(1))
      uv_rast_data=numpy.ma.masked_where(uv_rast_data==uv_rast.GetRasterBand(1).GetNoDataValue(),uv_rast_data)
      if first_raster==True:
        uv_rast_data_array[sat_name]=uv_rast_data
        uv_rast_sample[sat_name]=uv_rast
        first_raster=False
      else:
        uv_rast_data_array[sat_name]=numpy.ma.dstack((uv_rast_data_array[sat_name],uv_rast_data))

### calculate and save baseline mean and standard deviation rasters for all satellites
uv_baseline_mean_rast={}
uv_baseline_stddev_rast={}

for sat_name in uv_rast_input:
  ### compute baseline mean raster
  uv_baseline_mean_rast[sat_name]=numpy.ma.mean(uv_rast_data_array[sat_name],2)
  uv_baseline_mean_rast[sat_name][uv_baseline_mean_rast[sat_name].mask]=uv_rast_sample[sat_name].GetRasterBand(1).GetNoDataValue()

  ### save baseline mean raster
  driver = gdal.GetDriverByName("GTiff")
  rast_out = driver.Create(os.path.join(uv_rast_output_dir,sat_name+'_uv_baseline_mean_'+\
  str(uv_rast_input[sat_name]['year_start'])+'m'+\
  str(uv_rast_input[sat_name]['month_start']).zfill(2)+'-'+\
  str(uv_rast_input[sat_name]['year_end'])+'m'+\
  str(uv_rast_input[sat_name]['month_end']).zfill(2)+'.tif'),+\
  uv_rast_sample[sat_name].RasterXSize, uv_rast_sample[sat_name].RasterYSize, 1, uv_rast_sample[sat_name].GetRasterBand(1).DataType,['TFW=YES'])
  rast_out.SetGeoTransform(uv_rast_sample[sat_name].GetGeoTransform())
  rast_out.SetProjection(uv_rast_sample[sat_name].GetProjection())
  band_out=rast_out.GetRasterBand(1)
  band_out.SetNoDataValue(uv_rast_sample[sat_name].GetRasterBand(1).GetNoDataValue())
  BandWriteArray(band_out, uv_baseline_mean_rast[sat_name])
  stats = band_out.GetStatistics(0, 1)  
  rast_out=None

  ### compute baseline std dev raster
  uv_baseline_stddev_rast[sat_name]=numpy.ma.std(uv_rast_data_array[sat_name],axis=2,ddof=1)
  uv_baseline_stddev_rast[sat_name][uv_baseline_stddev_rast[sat_name].mask]=uv_rast_sample[sat_name].GetRasterBand(1).GetNoDataValue()

  ### save baseline std dev raster
  driver = gdal.GetDriverByName("GTiff")
  rast_out = driver.Create(os.path.join(uv_rast_output_dir,sat_name+'_uv_baseline_stddev_'+\
  str(uv_rast_input[sat_name]['year_start'])+'m'+\
  str(uv_rast_input[sat_name]['month_start']).zfill(2)+'-'+\
  str(uv_rast_input[sat_name]['year_end'])+'m'+\
  str(uv_rast_input[sat_name]['month_end']).zfill(2)+'.tif'),+\
  uv_rast_sample[sat_name].RasterXSize, uv_rast_sample[sat_name].RasterYSize, 1, uv_rast_sample[sat_name].GetRasterBand(1).DataType,['TFW=YES'])
  rast_out.SetGeoTransform(uv_rast_sample[sat_name].GetGeoTransform())
  rast_out.SetProjection(uv_rast_sample[sat_name].GetProjection())
  band_out=rast_out.GetRasterBand(1)
  band_out.SetNoDataValue(uv_rast_sample[sat_name].GetRasterBand(1).GetNoDataValue())
  BandWriteArray(band_out, uv_baseline_stddev_rast[sat_name])
  stats = band_out.GetStatistics(0, 1)
  rast_out=None

### calculate anomaly rasters (>= 1+ std dev above the baseline mean)
uv_anomaly_threshold_rast={}
uv_anomaly_count_rast={}

for sat_name in uv_rast_input:
  uv_anomaly_threshold_rast[sat_name]=uv_baseline_mean_rast[sat_name]+uv_baseline_stddev_rast[sat_name]
  first_raster=True
  for rast_num in range(0,numpy.shape(uv_rast_data_array[sat_name])[2]):
    uv_rast_monthly_mean=uv_rast_data_array[sat_name][:,:,rast_num]
    uv_rast_over_threshold_idx=numpy.ma.where(uv_rast_monthly_mean>=uv_anomaly_threshold_rast[sat_name])
    uv_rast_under_threshold_idx=numpy.ma.where(uv_rast_monthly_mean<uv_anomaly_threshold_rast[sat_name])
    uv_rast_monthly_mean[uv_rast_over_threshold_idx]=1
    uv_rast_monthly_mean[uv_rast_under_threshold_idx]=0
    if first_raster==True:
      uv_anomaly_count_rast[sat_name]=uv_rast_monthly_mean
      first_raster=False
    else:
      uv_anomaly_count_rast[sat_name]=numpy.ma.dstack((uv_anomaly_count_rast[sat_name],uv_rast_monthly_mean))

### sum and save number of anomalies for each satellite
for sat_name in uv_rast_input:
  uv_anomaly_count_sum_rast=numpy.ma.sum(uv_anomaly_count_rast[sat_name],2)
  uv_anomaly_count_sum_rast[uv_anomaly_count_sum_rast.mask]=uv_rast_sample[sat_name].GetRasterBand(1).GetNoDataValue()
  driver = gdal.GetDriverByName("GTiff")
  rast_out = driver.Create(os.path.join(uv_rast_output_dir,sat_name+'_uv_anomaly_'+\
  str(uv_rast_input[sat_name]['year_start'])+'m'+\
  str(uv_rast_input[sat_name]['month_start']).zfill(2)+'-'+\
  str(uv_rast_input[sat_name]['year_end'])+'m'+\
  str(uv_rast_input[sat_name]['month_end']).zfill(2)+'_raw.tif'),+\
  uv_rast_sample[sat_name].RasterXSize, uv_rast_sample[sat_name].RasterYSize, 1, uv_rast_sample[sat_name].GetRasterBand(1).DataType,['TFW=YES'])
  rast_out.SetGeoTransform(uv_rast_sample[sat_name].GetGeoTransform())
  rast_out.SetProjection(uv_rast_sample[sat_name].GetProjection())
  band_out=rast_out.GetRasterBand(1)
  band_out.SetNoDataValue(uv_rast_sample[sat_name].GetRasterBand(1).GetNoDataValue())
  BandWriteArray(band_out, uv_anomaly_count_sum_rast)
  stats = band_out.GetStatistics(0, 1)
  rast_out=None
    
### close up rasters
for uv_rast in uv_rast_list:
  uv_rast=None

print 'Script finished in %f minutes.' % ((time.time()-start_time)/60)
