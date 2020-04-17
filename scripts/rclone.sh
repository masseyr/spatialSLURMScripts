#!/bin/bash
#SBATCH --job-name=rclone
#SBATCH --time=3:59:59
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12000

# simple slurm script to download files using rclone

module load rclone

date

date

downloaddir='/scratch/user/gdrive/sync/'

if [ ! -d $downloaddir ]; then
	mkdir $downloaddir;
fi

rclone --include "raster_*.tif" copy myRemote:/work/is/fine/ $downloaddir

date
exit 0
