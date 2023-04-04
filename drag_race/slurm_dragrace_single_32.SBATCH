#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=16GB
#SBATCH --time=2-00:00:00
#SBATCH --job-name=dragrace_single_32
#SBATCH --mail-type=END
#SBATCH --mail-user=sd3201@nyu.edu
#SBATCH --output=dragrace_single_32_result.out

module purge

cd /scratch/sd3201/Dedalusv3_GreeneSingularity/drag_race
srun /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python shear_flow.py 