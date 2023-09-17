#!/bin/bash

#SBATCH --nodes=3
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=02:00:00
#SBATCH --job-name=dragrace_multpl_3by2
#SBATCH --mail-type=END
#SBATCH --mail-user=sd3201@nyu.edu
#SBATCH --output=dragrace_multpl_3by2_result.out

module purge

cd /scratch/sd3201/Dedalusv3_GreeneSingularity/drag_race
srun /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python rayleigh_benard.py 