import arcpy
import os
import arcpy.sa
arcpy.CheckOutExtension("spatial")

arcpy.env.overwriteOutput = True


# think of as the input directory
feature_dir = r'C:\Users\Afflerbach\Documents\GitHub\arctic-options\CumulativeImpacts\stressors\sealevel' #feature directory is where Arc considers the 'home' for this script
# the r above means treat the following as a raw string (don't escape the backslashes)
output_raster_dir = feature_dir

arcpy.env.workspace = feature_dir


if not os.path.exists(output_raster_dir):
    os.mkdir(output_raster_dir) #if output folder doesn't already exist, create it!

raster_in = r"working\arctic_slr_laea.tif"
basename = os.path.splitext(raster_in)[0]
outname = os.path.join(output_raster_dir, basename+"_int.tif") 
#get the basename of the input without extention

arcpy.env.compression="LZW"
input_raster_1000_int=arcpy.sa.Int(arcpy.sa.Raster(raster_in)*1000)
input_raster_1000_int_nonull=arcpy.sa.Con(arcpy.sa.IsNull(input_raster_1000_int),0,input_raster_1000_int)
input_raster_1000_int_nonull_nibble=arcpy.sa.Nibble(input_raster_1000_int_nonull,input_raster_1000_int,"DATA_ONLY")
input_raster_1000_int_nonull_nibble_float=input_raster_1000_int_nonull_nibble/1000.0
arcpy.CopyRaster_management(input_raster_1000_int_nonull_nibble_float,outname)
