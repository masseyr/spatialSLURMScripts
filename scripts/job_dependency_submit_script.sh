#!/usr/bin/env bash
job_array_id=$(sbatch /scratch/user/prepare_job_array.sh | awk '{ print $4 }')
sbatch --dependency=afterany:$job_array_id /scratch/user/compile_outputs.sh
