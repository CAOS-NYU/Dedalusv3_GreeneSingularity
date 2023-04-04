#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=02:00:00
#SBATCH --job-name=Dedalus_slurm_example
#SBATCH --mail-type=END
#SBATCH --mail-user=<yourusrnm>@nyu.edu
#SBATCH --output=slurm_%j.out

module purge

cd /scratch/<yourusrnm>/dedalus/examples/ivp_2d_shear_flow
srun /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python shear_flow.py 