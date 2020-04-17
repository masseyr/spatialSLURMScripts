#!/bin/bash
#SBATCH --job-name=mosaic_m
#SBATCH --time=18:59:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=64000
#SBATCH --partition=all
#SBATCH --output=/home/rm885/slurm-jobs/mosaic_multiple_%j.out

# SLURM script to mosaic files with multiple search strings in name

module load gdal
module load anaconda

date
echo 'Begin!~~~~~~~~~~'

datadir='/scratch/user/gdrive/sync/zonal_tiles/'

# list of input filess
files=(${datadir}zone_1_tile*.tif ${datadir}zone_2_tile*.tif ${datadir}zone_3_tile*.tif)

echo 'Found '${#files[*]}' files'

mosaicsmall=$datadir'all_zone_mosaic_small.tif'
mosaic=$datadir'all_zone_mosaic.tif'
temp=$datadir'all_zone_mosaic_temp.tif'
compmosaic=$datadir'all_zone_mosaic_compressed.tif'

echo '********************************************************************************************'

echo 'Data folder: '$datadir
echo 'Mosaic: '$mosaic
echo 'Compressed mosaic: '$compmosaic

echo '********************************************************************************************'

# make mosaic, spatial resolution: 30m, data type: Byte
# background value: 0, file format: Geotiff
gdal_merge.py -init 0 -n 0 -o $mosaicsmall -co BIGTIFF=YES -of GTiff -ps 0.0084 0.0084 -ot Float32 ${files[*]}
gdal_merge.py -init 0 -n 0 -o $mosaic -co BIGTIFF=YES -of GTiff -ps 0.00027 0.00027 -ot Float32 ${files[*]}

# band math to take care of outliers
gdal_calc.py -A $mosaic --outfile=$temp --calc="(A*1)*(A>=0) + (A*0)*(A<0)"  --co='BIGTIFF=YES' --type=Byte --NoDataValue=0

# compress large tif file using LZW compression
# use BIGTIFF=YES for large files
gdal_translate -of GTiff -co COMPRESS=LZW -co BIGTIFF=YES $temp $compmosaic 

# make overview (pyramid) file: gdaladdo -> gdal add overview
# this is useful if at any point ArcGIS is going to be used with this data
# this makes pyramids and will save that step with ArcGIS
gdaladdo -ro $compmosaic 2 4 8 16 32 64 128 256 --config COMPRESS_OVERVIEW LZW --config BIGTIFF_OVERVIEW YES

# outfile basename
outfile_=${compmosaic##*/}

# coarse resolution mosaic
outfile=$datadir${outfile_%.tif}'_250m.tif'

# compress
gdalwarp -ot Byte -tr 0.002083333 0.002083333 -t_srs 'EPSG:4326' -r bilinear -co COMPRESS=LZW -co BIGTIFF=YES  $compmosaic $outfile

# add overview
gdaladdo -ro $outfile 2 4 8 16 32 64 128 256 --config COMPRESS_OVERVIEW LZW

# remove temperory files
rm $mosaic
rm $temp
