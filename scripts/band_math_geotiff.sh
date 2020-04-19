#!/bin/bash
#SBATCH --job-name=gdal_calc
#SBATCH --time=8:59:59
#SBATCH --cpus-per-task=1
#SBATCH --mem=6000
#SBATCH --array=1-500
#SBATCH --partition=all
#SBATCH --output=/home/user/slurm-jobs/band_math_%A_%a.out

# SLURM script to do a band math calculation on geotiff files using GDAL

module load gdal
module load anaconda

# input folder that contains tif files, dont forget the '/' at the end
datadir='/scratch/user/gdrive/sync/tiles_2010/'

# output folder, dont forget the '/' at the end
outfolder='/scratch/user/gdrive/sync/tiles_2010_calc/'

# if output folder doesn't exist
mkdir $outfolder

FILELIST=(${datadir}*.tif)

# for this element in job array, pick filename based on task ID
f=${FILELIST[$SLURM_ARRAY_TASK_ID]}

bname=$(basename $f);
extension="${bname##*.}";
filename="${bname%.*}";

tempf=$outfolder""$filename"_temp."$extension;
outf=$outfolder""$filename"_byte."$extension;

if [ -f $outf ] ; then
   rm -f $outf;
fi;

echo $f
echo $outf

# convert data type to float32
gdal_translate -of GTiff -ot Float32 -a_nodata 0.0 $f $tempf

# band math calculation
gdal_calc.py -A $tempf --outfile=$outf --calc="(A*100)*(A>=0) + (A*0)*(A<0)" --NoDataValue=0 --type='Byte'

# remove temp file
rm $tempf

exit 0
