# Using Dedalus on multiple nodes <a name="mult_nodes"></a>
Since Dedalus uses MPI, we could use multiple nodes for our computation. In Greene, requesting multiple nodes and lauching python in each nodes is managed by Slurm via `srun`. Therefore, we cannot use multiple nodes for interactive jobs. Therefore, we start with


## In the terminal, using Slurm via `srun` <a name="single_comm_srun"></a>
All the above commands are wrapped up in a script that we can just call. We can take a peak at the script via
```shell
cat /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash
```
Now to run the same Dedalus code, we can just enter this command in the log-in node:
```shell
srun --nodes=1 --tasks-per-node=4 --cpus-per-task=1 --time=2:00:00 --mem=4GB \
  /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python rayleigh_benard.py
```
## Submitting a job using Slurm <a name="single_slurm"></a>
To run many heavy simulations, one should queue the jobs in Greene by using Slurm scripts. [Here](https://sites.google.com/nyu.edu/nyu-hpc/training-support/tutorials/slurm-tutorial) is the general tutorial for Slurm on Greene. In this section, we will run an example Slurm Dedalus job. 

In the repository of this note, there is an example [Slurm script](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/blob/main/slurm_example_singlenode.SBATCH) that runs the [Periodic shear flow (2D IVP) exmple](https://dedalus-project.readthedocs.io/en/latest/pages/examples/ivp_2d_shear_flow.html). To use it, we first clone this repo
```shell
cd $SCRATCH
git clone https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity.git
cd Dedalusv3_GreeneSingularity
```
We can take a look at the script
```shell
cat slurm_example_singlenode.SBATCH
```
You need to fill in your NYU ID to use this script. We see that the script contains the same `srun` commands used in the interactive command line case. Nothing mysterious. 

Now we submit the script 
```shell
sbatch slurm_example.SBATCH
```
and check the queue
```shell
squeue -u ${USER}
```
Now we see it in the queue. We can check the reasons for the wait [here](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/best-practices#h.p_ID_118). After some patience and the job runs (you will receive an email when it is done), we can check the output in the `Dedalusv3_GreeneSingularity` directory. There should be a file named `slurm_<yourjobid>.out` that contains the terminal output. We can also find the data output in the code folder
```shell
$SCRATCH/dedalus/examples/ivp_2d_shear_flow
ls snapshots
```



## On the command line, using Slurm via `srun`<a name="mult_srun"></a>
In a log-in node, run
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

## Submitting a job using Slurm<a name="mult_slurm"></a>
It is straightforward to convert the above command into a slurm script. We provide [an example](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/blob/main/slurm_example_multplnode.SBATCH) in this repo.