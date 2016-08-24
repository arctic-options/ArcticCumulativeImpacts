#!/usr/bin/python

import gdal, struct, osr, numpy, csv, sys, time, math, os, glob, re, calendar
from gdalconst import *
import datetime
from osgeo import gdal  
from osgeo.gdalnumeric import *  
from osgeo.gdalconst import *
import operator

#==================================================================================
# create_monthly_uv_rasters.py:
#------------------------------
#
# Calculates monthly mean and standard deviation UV irradiance rasters.
#
# June-July 2013, John Potapenko (john@scigeo.org)
#
#==================================================================================
# user input parameters:
#-----------------------

# uv_rast_input: input of original uv satellite raster files
# format:
#   <satellite prefix name>:
#   {<directory name>,<raster file type>,<raster name prefix>,
#    <year start>,<month start>,<year end>,<month end>}
uv_rast_input={
 'toms_ep':{
 'dir': '/media/nix/nceas_ohi/impact_layers_redo/uv/uv_og/uv_toms_ep_1996_2005/tif_from_hdf/',
 'file_type': '.tif',
 'raster_prefix': 'TOMS-EP_L3-TOMSEPL3_',
 'year_start': 1997,
 'month_start': 1,
 'year_end': 2001,
 'month_end': 12},
 'omi_aura':{
 'dir':'/media/nix/nceas_ohi/impact_layers_redo/uv/uv_og/uv_omi_aura_2004_2013/tif_from_nc/',
 'file_type':'.tif',
 'raster_prefix':'OMI-Aura_L3-OMUVBd_',
 'year_start': 2008,
 'month_start': 1,
 'year_end': 2012,
 'month_end': 12}}

# where output mean/std dev rasters will be stored
uv_rast_output_dir='/media/nix/nceas_ohi/impact_layers_redo/uv/uv_monthly_mean/'

#==================================================================================

### preliminaries

# start timer
start_time=time.time()

# create output directory if it doesn't exist
if not os.path.isdir(uv_rast_output_dir):
  os.mkdir(uv_rast_output_dir)

### read in rasters

for sat_name in uv_rast_input:
  print 'Running satellite: ',sat_name
  for year in range(uv_rast_input[sat_name]['year_start'],uv_rast_input[sat_name]['year_end']+1):
    for month in range(uv_rast_input[sat_name]['month_start'],uv_rast_input[sat_name]['month_end']+1):
      num_days=calendar.monthrange(year,month)[1]

      uv_rast_list=[]

      for day in range(1,num_days+1):
        uv_rast_input_file_search=glob.glob(os.path.join(uv_rast_input[sat_name]['dir'],uv_rast_input[sat_name]['raster_prefix']+str(year)+'m'+str(month).zfill(2)+str(day).zfill(2)+'*'+uv_rast_input[sat_name]['file_type']))
        if not uv_rast_input_file_search:
          print 'skipping year: ',year,', month: ',month,', day: ',day
          continue
        
        uv_rast_input_file=uv_rast_input_file_search[0]
        #print 'Reading file: ',print uv_rast_input_file

        uv_rast=gdal.Open(uv_rast_input_file, GA_ReadOnly)
        if uv_rast is None:
          print 'Error: could not open raster file: ', uv_rast_input_file
          sys.exit(1)
        uv_rast_list.append(uv_rast)

      ### stack rasters into array

      first_raster=True
      for uv_rast in uv_rast_list:
        uv_rast_data=BandReadAsArray(uv_rast.GetRasterBand(1))
        uv_rast_data=numpy.ma.masked_where(uv_rast_data==uv_rast.GetRasterBand(1).GetNoDataValue(),uv_rast_data)
        if first_raster==True:
          uv_rast_data_array=uv_rast_data
          uv_rast_sample=uv_rast
          first_raster=False
        else:
          uv_rast_data_array=numpy.ma.dstack((uv_rast_data_array,uv_rast_data))

      ### compute mean raster
      mean_rast=numpy.ma.mean(uv_rast_data_array,2)
      mean_rast[mean_rast.mask]=uv_rast_sample.GetRasterBand(1).GetNoDataValue()

      ### save mean raster
      driver = gdal.GetDriverByName("GTiff")
      rast_out = driver.Create(os.path.join(uv_rast_output_dir,sat_name+'_uv_mean_'+str(year)+'_'+str(month).zfill(2)+'.tif'), uv_rast_sample.RasterXSize, uv_rast_sample.RasterYSize, 1, uv_rast_sample.GetRasterBand(1).DataType,['TFW=YES'])
      rast_out.SetGeoTransform(uv_rast_sample.GetGeoTransform())
      rast_out.SetProjection(uv_rast_sample.GetProjection())
      band_out=rast_out.GetRasterBand(1)
      band_out.SetNoDataValue(uv_rast_sample.GetRasterBand(1).GetNoDataValue())
      BandWriteArray(band_out, mean_rast)
      stats = band_out.GetStatistics(0, 1)  
      rast_out=None

      ### compute std dev raster
      stddev_rast=numpy.ma.std(uv_rast_data_array,axis=2,ddof=1)
      stddev_rast[stddev_rast.mask]=uv_rast_sample.GetRasterBand(1).GetNoDataValue()

      ### save std dev raster
      driver = gdal.GetDriverByName("GTiff")
      rast_out = driver.Create(os.path.join(uv_rast_output_dir,sat_name+'_uv_stddev_'+str(year)+'_'+str(month).zfill(2)+'.tif'), uv_rast_sample.RasterXSize, uv_rast_sample.RasterYSize, 1, uv_rast_sample.GetRasterBand(1).DataType,['TFW=YES'])
      rast_out.SetGeoTransform(uv_rast_sample.GetGeoTransform())
      rast_out.SetProjection(uv_rast_sample.GetProjection())
      band_out=rast_out.GetRasterBand(1)
      band_out.SetNoDataValue(uv_rast_sample.GetRasterBand(1).GetNoDataValue())
      BandWriteArray(band_out, stddev_rast)
      stats = band_out.GetStatistics(0, 1)
      rast_out=None

      ### close up rasters
      for uv_rast in uv_rast_list:
        uv_rast=None

print 'Script finished in %f minutes.' % ((time.time()-start_time)/60)
