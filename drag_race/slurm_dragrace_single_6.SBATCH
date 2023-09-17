#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=02:00:00
#SBATCH --job-name=dragrace_single_6
#SBATCH --mail-type=END
#SBATCH --mail-user=sd3201@nyu.edu
#SBATCH --output=dragrace_single_6_result.out

module purge

cd /scratch/sd3201/Dedalusv3_GreeneSingularity/drag_race
srun /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python rayleigh_benard.py 