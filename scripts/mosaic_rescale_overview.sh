#!/bin/bash
#SBATCH --job-name=mosaic
#SBATCH --time=18:59:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=64000
#SBATCH --partition=all
#SBATCH --output=/home/user/slurm-jobs/mosaic_2000_tif_%j.out

# SLURM script for mosaicing, rescale, and adding overviews

module load gdal
module load anaconda

date
echo 'Begin!~~~~~~~~~~'

# file folder
datadir='/scratch/user/gdrive/rasters/'

# find files with a particular string
files=(${datadir}*_2000_*.tif)
echo 'Found '${#files[*]}' files'

# specify output file names
mosaic=$datadir'raster_2000_mosaic.tif'
temp=$datadir'raster_2000_mosaic_temp.tif'
compmosaic=$datadir'raster_2000_mosaic_compressed.tif'

echo '********************************************************************************************'

echo 'Data folder: '$datadir
echo 'Mosaic: '$mosaic
echo 'Compressed mosaic: '$compmosaic

echo '********************************************************************************************'

# make mosaic at spatial resolution: 30m or 0.00027 degrees
# data type: Byte, background value: 0, file format: Geotiff
gdal_merge.py -init 0 -n 0 -o $mosaic -of GTiff -ps 0.00027 0.00027 -ot Float32 ${files[*]}

# take care of negative values or values greater than max
gdal_calc.py -A $mosaic --outfile=$temp --calc="(A*100)*(A>=0) + (A*0)*(A<0)" --type=Byte --NoDataValue=0

# compress large tif file using LZW compression
# use BIGTIFF=YES for large files
gdal_translate -of GTiff -co COMPRESS=LZW -co BIGTIFF=YES $temp $compmosaic 

# make overview (pyramid) file: gdaladdo -> gdal add overview
# this is useful if at any point ArcGIS is going to be used with this data
# this makes pyramids and will save that step with ArcGIS
gdaladdo -ro $compmosaic 2 4 8 16 32 64 128 256 --config COMPRESS_OVERVIEW LZW --config BIGTIFF_OVERVIEW YES

# output file basename 
outfile_=${compmosaic##*/}

# add suffix
outfile=$datadir${outfile_%.tif}'_250m.tif'

# reproject to a different spatial resolution
gdalwarp -ot Byte -tr 0.002083333 0.002083333 -t_srs 'EPSG:4326' -r bilinear -co COMPRESS=LZW -co BIGTIFF=YES  $compmosaic $outfile

# add overviews 
gdaladdo -ro $outfile 2 4 8 16 32 64 128 256 --config COMPRESS_OVERVIEW LZW

# remove temperory files
rm $mosaic
rm $temp
