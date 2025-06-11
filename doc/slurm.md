# Running a Dedalus code using Slurm
For serious simulations, one has submit it as a job, using the slurm management system. This allows us to use MPI to run on multiple nodes. Remember, we cannot use multiple nodes for interactive jobs.

## In the terminal, using Slurm via `srun`
All the necessary commands are wrapped up in a script. We can take a peak at the script via
```shell
cat /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash
```
````{dropdown} <code>run-dedalus-3.0.0a0.bash</code>
```shell
#!/bin/bash

args=''
for i in "$@"; do
  i="${i//\\/\\\\}"
  args="${args} \"${i//\"/\\\"}\""
done

if [[ "${args}" == "" ]]; then args="/bin/bash"; fi

if [[ "${SINGLE_NODE}" != "YES" ]]; then
  if [[ -e /scratch/work/public/singularity/greene-ib-slurm-bind.sh ]]; then
    source /scratch/work/public/singularity/greene-ib-slurm-bind.sh
  fi
  openmpi_overlay="--overlay /scratch/work/public/singularity/openmpi-4.1.2-ubuntu-22.04.1.sqf:ro"
  source_openmpi="source /ext3/apps/openmpi/4.1.2/env.sh"
fi

if [[ "${OMP_NUM_THREADS}" == "" ]]; then export OMP_NUM_THREADS=1; fi
if [[ "${NUMEXPR_MAX_THREADS}" == "" ]]; then export NUMEXPR_MAX_THREADS=1; fi

/share/apps/singularity/bin/singularity exec ${openmpi_overlay} \
--overlay /scratch/work/public/singularity/dedalus-3.0.0a0-openmpi-4.1.2-ubuntu-22.04.1.sqf:ro \
/scratch/work/public/singularity/ubuntu-22.04.1.sif \
/bin/bash -c "
unset -f which
${source_openmpi}
if [[ -e /ext3/env.sh ]]; then source /ext3/env.sh; fi
${args}
"
```
````

Now to run the Rayleigh Benard Dedalus code, we can just enter this command in the log-in node:
```shell
srun --nodes=4 --tasks-per-node=4 --cpus-per-task=1 --time=2:00:00 --mem=4GB \
  /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python rayleigh_benard.py
```
Because we have to [disable multithreading](https://dedalus-project.readthedocs.io/en/latest/pages/performance_tips.html#disable-multithreading), we should keep `--cpus-per-task=1`. 

After some wait for the job to start, we should see the code running. We can see four nodes used via
```shell
squeue -u $USER
```
In each node, there are four CPU cores used, all near 100%. Nice.

## Submitting a job using Slurm
To run many heavy simulations, one could queue the jobs in Greene by using Slurm scripts. [Here](https://sites.google.com/nyu.edu/nyu-hpc/training-support/tutorials/slurm-tutorial) is the general tutorial for Slurm on Greene. In this section, we will run an example Slurm Dedalus job. 

In the repository of this note, there is an example [Slurm script](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/blob/main/slurm_example.SBATCH) that runs the [Periodic shear flow (2D IVP) exmple](https://dedalus-project.readthedocs.io/en/latest/pages/examples/ivp_2d_shear_flow.html). To use it, we first clone this repo
```shell
cd $SCRATCH
git clone https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity.git
cd Dedalusv3_GreeneSingularity
```
We can take a look at the script
```shell
cat slurm_example.SBATCH
```

````{dropdown} <code>slurm_example.SBATCH</code>
```shell
#!/bin/bash

#SBATCH --nodes=4
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
```
````
We see that the script contains the same `srun` commands used in the interactive command line case. Nothing mysterious. 
:::{warning}
You need to fill in your NYU ID to use this script. 
:::

After you filled your NYU ID into the script, now submit the script 
```shell
sbatch slurm_example.SBATCH
```
and check the queue
```shell
squeue -u $USER
```
Now we see it in the queue. 
:::{tip}
You can check the reasons for the wait [here](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/best-practices#h.p_ID_118).
:::
After some patience and the job runs (you will receive an email when it is done), we can check the output in the `Dedalusv3_GreeneSingularity` directory. There should be a file named `slurm_<yourjobid>.out` that contains the terminal output. We can also find the data output in the code folder
```shell
$SCRATCH/dedalus/examples/ivp_2d_shear_flow
ls snapshots
```