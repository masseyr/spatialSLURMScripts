#!/bin/bash
#SBATCH --job-name=gee_upld
#SBATCH --time=30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4000
#SBATCH --partition=all
#SBATCH --output=/scratch/user/support/out/slurm-jobs/rclone_gee_upload_%j.out

# This SLURM script is used to upload a geotiff file to Google Earth Engine (GEE)

date

# use preconfigured rclone remotes for upload/download 
rclone copy "/scratch/user/gdrive/sync/processing_output/mosaic_2010.tif" my_GCS_remote:GCS_bucket/storage_folder

# use gsutil to set permission as public
gsutil acl ch -u AllUsers:R gs://GCS_bucket/storage_folder/mosaic_2010.tif

# upload to GEE
earthengine upload image --asset_id=users/user/myFiles/mosaic_2010 gs://GCS_bucket/storage_folder/mosaic_2010.tif

# set permission in GEE
earthengine acl set public users/user/myFiles/mosaic_2010

date
