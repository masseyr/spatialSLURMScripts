#!/bin/bash
#SBATCH --job-name=randfrst
#SBATCH --time=5-23:59:59
#SBATCH --ntasks=72
#SBATCH --mem=192000
#SBATCH --output=/scratch/user/support/out/slurm-jobs/py_pickle_mpi_%A.out

# SLURM script to run apython script with MPI using 72 cores

module load intel
module load anaconda
module load gdal

date
echo '-------------------------------------------'

#output folder, dont forget the '/' at the end
pickle_dir='/scratch/user/gdrive/sync/pickled_classifiers/'
samp_file='/scratch/user/gdrive/sync/decid/SAMPLES/samples.csv'

# classifier code name
classifier_code='v8'

# number of iterations
n_iter=50000

#if output folder doesn't exist
mkdir $pickle_dir

#make tiles
mpirun -n 72 python "/home/user/projects/classifier_mpi.py" $samp_file $pickle_dir $code $n_iter

echo '-------------------------------------------'
date
