#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4GB
#SBATCH --time=01:00:00
#SBATCH --job-name=Dedalus_slurm_example
#SBATCH --mail-type=END
#SBATCH --mail-user=sd3201@nyu.edu
#SBATCH --output=slurm_%j.out

module purge

cd /scratch/sd3201/dedalus/examples/ivp_2d_shear_flow

# save the revelant slurm parameters and delete the rest
CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
for e in $(env | grep SLURM_ | cut -d= -f1); do unset $e; done

# launch the singularity
singularity \
    exec \
    --overlay /home/sd3201/dedalus3/dedalus3_mpisinglenode.ext3:ro \
    /scratch/work/public/singularity/ubuntu-20.04.4.sif \
    /bin/bash -c "
source /ext3/env.sh
export OMP_NUM_THREADS=1
export NUMEXPR_MAX_THREADS=1
mpiexec -n $CPUS_PER_TASK python3 shear_flow.py
"
