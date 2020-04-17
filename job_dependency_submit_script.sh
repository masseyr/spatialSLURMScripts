#!/usr/bin/env bash
array_job=$(sbatch /scratch/user/prepare_job_array.sh | awk '{ print $4 }')
sbatch --dependency=afterany:$array_job /scratch/user/compile_outputs.sh
