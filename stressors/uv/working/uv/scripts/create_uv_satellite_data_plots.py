#!/usr/bin/python

import gdal, struct, osr, numpy, csv, sys, time, math, os, glob, re
from gdalconst import *
from pylab import *
import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

#==================================================================================
# create_uv_satellite_data_plots.py:
#-----------------------------------
#
# Create a plot of daily global UV irradiance for the TOMS/EP and OMI/AURA satellites.
# Note: requires matplotlib (tested with version 1.2.1).
#
# June-July 2013, John Potapenko (john@scigeo.org)
#
#==================================================================================
# user input parameters:
#-----------------------

# uv_rast_input: input of original uv satellite raster files
# [<satellite prefix name>,<directory name>,<wildcard of raster files>,<raster name prefix>] 
uv_rast_input_toms_ep=['toms_ep','/media/nix/nceas_ohi/impact_layers_redo/uv/uv_og/uv_toms_ep_1996_2005/tif_from_hdf/','*.tif','TOMS-EP_L3-TOMSEPL3']
uv_rast_input_omi_aura=['omi_aura','/media/nix/nceas_ohi/impact_layers_redo/uv/uv_og/uv_omi_aura_2004_2013/tif_from_nc/','*.tif','OMI-Aura_L3-OMUVBd']
#==================================================================================

# start timer
start_time=time.time()

### open input rasters for reading
for uv_rast_input in [uv_rast_input_toms_ep,uv_rast_input_omi_aura]:
  mean_uv_list=[]
  date_list=[]
  uv_rast_input_dir=uv_rast_input[1]
  uv_rast_input_files=uv_rast_input[2]
  uv_rast_input_file_name_start=uv_rast_input[3]
  uv_rast_input_file_paths=sorted(glob.glob(os.path.join(uv_rast_input_dir,uv_rast_input_files)))
  for uv_rast_input_file in uv_rast_input_file_paths:
    uv_rast_name_search=re.search(r'.*'+uv_rast_input_file_name_start+'_(?P<uv_rast_name>[^_]*)_v.*',uv_rast_input_file)
    uv_rast_name=uv_rast_name_search.group('uv_rast_name')

    date_search=re.search(r'(?P<year>[0-9][0-9][0-9][0-9])m(?P<month>[0-9][0-9])(?P<day>[0-9][0-9]).*',uv_rast_name)
    year=int(date_search.group('year'))
    month=int(date_search.group('month'))
    day=int(date_search.group('day'))

    date_list.append(datetime.date(year,month,day))

    uv_rast=gdal.Open(uv_rast_input_file, GA_ReadOnly)
    if uv_rast is None:
      print 'Error: could not open raster file: ', uv_rast_input_file
      sys.exit(1)

    ### get raster information

    band = uv_rast.GetRasterBand(1)
    stats = band.GetStatistics(0, 1)  
    mean_value = stats[2]
    mean_uv_list.append(float(mean_value))

    ### close up rasters
    uv_rast=None

  if uv_rast_input[0]=='toms_ep':
    mean_uv_list_toms_ep=mean_uv_list
    date_list_toms_ep=date_list
  elif uv_rast_input[0]=='omi_aura':
    mean_uv_list_omi_aura=mean_uv_list
    date_list_omi_aura=date_list

fig = plt.figure()
ax = fig.add_subplot(111)

ax.plot(date_list_toms_ep, mean_uv_list_toms_ep,'r.')
ax.plot(date_list_omi_aura, mean_uv_list_omi_aura,'b.')
datemin = datetime.date(date_list_toms_ep[0].year, 1, 1)
datemax = datetime.date(date_list_omi_aura[len(date_list_omi_aura)-1].year+1, 1, 1)

years    = mdates.YearLocator()
months   = mdates.MonthLocator()
yearsFmt = mdates.DateFormatter('%Y')

# format the ticks
ax.xaxis.set_major_locator(years)
ax.xaxis.set_major_formatter(yearsFmt)
ax.xaxis.set_minor_locator(months)

ax.set_xlim(datemin, datemax)

# format the coords message box
ax.format_xdata = mdates.DateFormatter('%Y-%m-%d')
ax.grid(True)

fig.autofmt_xdate()
plt.title('Mean global UV irradiance collected by the TOMS/EP and OMI/AURA satellites')
plt.xlabel('days [1996-2013]')
plt.ylabel('Local Noon Erythemal UV Irradiance (mW/m^2)')
ax.legend(['TOMS/EP','OMI/AURA'],loc=1)
plt.show()
fig.savefig('mean_global_uv_irradiance_satellite_comparison_plot.png')

print 'Script finished in %f minutes.' % ((time.time()-start_time)/60)
