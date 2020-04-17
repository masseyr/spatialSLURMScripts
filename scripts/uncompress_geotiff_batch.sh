#!/bin/bash
#SBATCH --job-name=gdal_tif
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=12000
#SBATCH --partition=all
#SBATCH --output=/home/rm885/slurm-jobs/gdal_tif_slurm_%j.out

#This is a SLURM script to uncompress GEE output tif files

module load gdal
module load anaconda

#input folder that contains tif files, dont forget the '/' at the end
datadir='/scratch/user/gdrive/sync/compressed/'
files=(${datadir}*.tif)

#output folder, dont forget the '/' at the end
outfolder='/scratch/user/gdrive/sync/decid/uncompressed/'

#if output folder doesn't exist
mkdir $outfolder

#make filelist array
declare -a FILELIST
for f in $files*; do
   f=$(echo "$f");
   echo $f;
   bname=$(basename $f);
   extension="${bname##*.}";
   filename="${bname%.*}";
   outf=$outfolder""$filename"_uncomp."$extension;
   if [ -f $outf ] ; then
      rm -f $outf;
   fi;
   gdal_translate -of GTiff -ot BYTE -co TILED=YES -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -co INTERLEAVE=PIXEL -co COMPRESS=NONE $f $outf;
done

date
