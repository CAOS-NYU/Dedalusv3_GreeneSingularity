
# Using Dedalus on the NYU Greene Cluster

[Dedalus](https://dedalus-project.org/) is a flexible differential equations solver using spectral methods. It is MPI-parallelized and therefore can make efficient use of high performance computing resources like the [NYU Greene Cluster](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene?authuser=0). The cluster uses Singularity containers to manage packages and Slurm for job scheduling. Constructing a Singularity container for Dedalus v3 that interacts with these well is not trivial, thus making running Dedalus on Greene difficult. Luckily, the NYU HPC staff has made a Singularity for Dedalus. This note details how to use the Singularity, on single node, on multiple nodes, and in JupyterLab. At the end we will also biefly comment on how to build on the exsting Singularity by add more packages, and how to build the Singularity.

Note: If anything does not work in this note, or that you have run into trouble, please let me know at my email ryan_sjdu@nyu.edu. I would be happy to help.


## Table of contents
1. [Using Dedalus on a single node](#single_node)
	1. [On the command line, interactively](#single_comm_int)
	2. [On the command line, using Slurm via srun](#single_comm_srun)
	3. [JupyterLab using Open OnDemand (OOD)](#single_jupy)
2. [Using Dedalus on multiple nodes](#mult_nodes)
    1. [On the command line, using Slurm via srun](#mult_srun)
    2. [Submitting a job using Slurm](#mult_slurm)
3. [Testing performance](#testing_perf)
4. [Editing and making the Singularity](#edit_make)
	1. [Adding more packeges to the existing Singularity](#add_package)
	2. [Buidling the Singularity itself](#bulding_sing)
5. [Acknowledgment](#acknowledgment)

 
## Using Dedalus on a single node <a name="single_node"></a>
### On the command line, interactively <a name="single_comm_int"></a>
We first use Dedalus on the command line. On the command line (compared to using JupyterLab) Dedalus can use multiple cores (but still on a single node) to improve speed. Simulations that involves heavy computation should use this method.

Once we are logged into the Greene cluster, `cd` into your scratch directory and request a computing node so that we can run some code for testing (do not run CPU heavy jobs in the log-in node)
```shell
cd $SCRATCH
srun --nodes=1 --tasks-per-node=4 --cpus-per-task=1 --time=2:00:00 --mem=4GB --pty /bin/bash
```
Once we are in, paste the following commands to start the already made singularity 
```shell
singularity exec \
  --overlay /scratch/work/public/singularity/dedalus-3.0.0a0-openmpi-4.1.2-ubuntu-22.04.1.sqf:ro \
  /scratch/work/public/singularity/ubuntu-22.04.1.sif /bin/bash
unset -f which
source /ext3/env.sh
export OMP_NUM_THREADS=1; export NUMEXPR_MAX_THREADS=1
```
The last command essentially turns off any shared parallelism. But this is recommended for Dedalus's performance since Dedalus does not use hybrid parallelism (see Dedalus documentation on [Disable multithreading](https://dedalus-project.readthedocs.io/en/latest/pages/performance_tips.html#disable-multithreading)). We can check they indeed worked by running `echo $OMP_NUM_THREADS; echo $NUMEXPR_MAX_THREADS` and we should get `1 1`.

We could now run an example script, e.g.: the [Rayleigh-Benard convection (2D IVP) example](https://dedalus-project.readthedocs.io/en/latest/pages/examples/ivp_2d_rayleigh_benard.html). We clone this from the [Dedalus GitHub repo](https://github.com/DedalusProject/dedalus). To avoid downloading a lot of files, we use [sparse checkout](https://stackoverflow.com/a/52269934).  
```shell
git clone --depth 1 --filter=blob:none --sparse https://github.com/DedalusProject/dedalus.git
cd dedalus/
git sparse-checkout set examples
cd examples/ivp_2d_rayleigh_benard
```
Now we can run the example. Note that we requested 4 cores and are using 4 MPI processes, these two numbers should be the same.
```shell
mpiexec -n 4 python3 rayleigh_benard.py
mpiexec -n 4 python3 plot_snapshots.py snapshots/*.h5
```
We now see the script outputting time stepping information. And if we look at the CPU usage in the node using `htop -u ${USER}`, we should see near 100% usage on 4 cores. Satisfying.

Note that we did not use the Dedalus provided test `python3 -m dedalus test`. This is intentional. The test function does not work consistently with our set-up. But obviously we have a working Singularity given that we can run Dedalus examples.

### On the command line, using Slurm via `srun` <a name="single_comm_srun"></a>
All the above commands are wrapped up in a script that we can just call. We can take a peak at the script via
```shell
cat /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash
```
Now to run the same Dedalus code, we can just enter this commend in the log-in node:
```shell
srun --nodes=1 --tasks-per-node=4 --cpus-per-task=1 --time=2:00:00 --mem=4GB \
  /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python rayleigh_benard.py
```
### Submitting a job using Slurm <a name="single_slurm"></a>
To run many heavy simulations, one should queue the jobs in Greene by using Slurm scripts. [Here](https://sites.google.com/nyu.edu/nyu-hpc/training-support/tutorials/slurm-tutorial) is the general tutorial for Slurm on Greene. In this section we will run an example Slurm Dedalus job. 

In the repository of this note, there is an example [Slurm script](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/blob/main/slurm_example_singlenode.SBATCH) that runs the [Periodic shear flow (2D IVP) exmple](https://dedalus-project.readthedocs.io/en/latest/pages/examples/ivp_2d_shear_flow.html). To use it, we first clone this repo
```shell
cd $SCRATCH
https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity.git
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
squeue -u ${USER} -o "%.18i %.9P %.34j %.8u %.8T %.10M %.9l %.6D %R"
```
Now we see it in the queue. We can check the reasons for the wait [here](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/best-practices#h.p_ID_118). After some patience and the job runs (you will receive an email when it is done), we can check the output in the `Dedalusv3_GreeneSingularity` directory. There should be a file named `slurm_<yourjobid>.out` that contains the terminal output. We can also find the data output in the code folder
```shell
$SCRATCH/dedalus/examples/ivp_2d_shear_flow
ls snapshots
```
### JupyterLab using Open OnDemand (OOD) <a name="single_jupy"></a>
Sometimes it is conveient to use JupyterLab for code developement. Note that for Dedalus, using JupyterLab means we can use only one core. This is acceptable if the computation is light. We should only request one core because more will be wasteful.

We adapt the instruction on using [Open OnDemand (OOD) with Conda/Singularity](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity) for Greene. Since we have an already-made Singularity, we can skip making it. We start from [Configure iPython Kernels](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity#h.25pp9n8colt0). 

We create a kernel named dedalus by copying the template files to your home directory.
```shell
mkdir -p ~/.local/share/jupyter/kernels
cd ~/.local/share/jupyter/kernels
cp -R /share/apps/mypy/src/kernel_template ./dedalus3
cd ./dedalus3

ls
#kernel.json logo-32x32.png logo-64x64.png python #files in the ~/.local/share/jupyter/kernels directory
```
To set the conda environment, edit the file named `python`. The python file is a wrapper script that the Jupyter notebook will use to launch the Singularity container and attach it to the notebook. At the bottom of the file we have some singularity command. Edit it so that it uses the already made Sinularity with Dedalus and JupyterLab
```shell
singularity exec $nv \
  --overlay /home/sd3201/dedalus3/dedalus_ryansingularity.sqf:ro \
  /scratch/work/public/singularity/cuda11.2.2-cudnn8-devel-ubuntu20.04.sif \
  /bin/bash -c "source /ext3/env.sh; export OMP_NUM_THREADS=1; export NUMEXPR_MAX_THREADS=1; $cmd $args"
```
Finally, edit over the default `kernel.json` file by pasting these lines
```json
{
 "argv": [
  "/home/<yourusername>/.local/share/jupyter/kernels/dedalus3/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "dedalus3",
 "language": "python"
}
```
After the hard work, we can enjoy Dedalus on OOD by following [this tutorial](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity#h.pjqb0en5ivqf). Remember to request only one core because we can only use one!

## Using Dedalus on multiple nodes <a name="mult_nodes"></a>
Since Dedalus uses MPI, we could use multiple nodes for our computation. In Greene, requesting multiple nodes and lauching python in each nodes is managed by Slurm via `srun`. Therefore, we cannot use multiple nodes for interactive jobs. Therefore, we start with

### On the command line, using Slurm via `srun`<a name="mult_srun"></a>
In a log-in node, run
```shell
srun --nodes=4 --tasks-per-node=4 --cpus-per-task=1 --time=2:00:00 --mem=4GB \
  /scratch/work/public/singularity/run-dedalus-3.0.0a0.bash python rayleigh_benard.py
```
Because we have to [disable multithreading](https://dedalus-project.readthedocs.io/en/latest/pages/performance_tips.html#disable-multithreading), we should keep `--cpus-per-task=1`. 

After some wait for the job to start, we should see the code running. We can see four nodes used via
```shell
squeue -u $USER -o "%.18i %.9P %.34j %.8u %.8T %.10M %.9l %.6D %R"
```
In each node, there are four CPU cores used, all near 100%. Nice.

### Submitting a job using Slurm<a name="mult_slurm"></a>
It is straightforward to convert the above command into a slurm script. We provide [an example](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/blob/main/slurm_example_multplnode.SBATCH) in this repo.

## Testing performance<a name="testing_perf"></a>
Please see the [drag_race](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/tree/main/drag_race) folder for some performance tests of Dedalus on Greene. The tests shows our set-ups are working well.

## Editing and making the Singularity<a name="edit_make"></a>
### Adding more packeges to the existing Singularity<a name="add_package"></a>
There are always more packages that we want and need. We could modify the existing Singularity and add more packages. We will add [cmocean](https://matplotlib.org/cmocean), a beautiful colormap package to the existing Singularity. 

Make a copy of the existing Singularity so that we can modify it
```shell
cp /scratch/work/public/singularity/dedalus-3.0.0a0-openmpi-4.1.2-ubuntu-22.04.1.sqf \
  add_cmocean.sqf
```
 Then we can launch it without the `-ro` flag so we can edit it
```shell
singularity exec \
  --overlay add_cmocean.sqf \
  /scratch/work/public/singularity/ubuntu-22.04.1.sif /bin/bash

source /ext3/env.sh
```
Now install the cmocean package
```shell
pip install cmocean
```
To test that we indeed have the package, run
```shell
python -c "import cmocean; print(cmocean.__version__)"
```
It should give us the current version of cmocean.

The version I use will be available at `/home/sd3201/dedalus3/dedalus_ryansingularity.sqf`, with which you could replace `/scratch/work/public/singularity/dedalus-3.0.0a0-openmpi-4.1.2-ubuntu-22.04.1.sqf` in this note, if you want to use mine version. Keen-eyed reader might have already realized the Singularity used for the JupyterLab is my version.

### Buidling the Singularity itself<a name="bulding_sing"></a>
Under construction... 

Shenglong Wang from the NYU HPC team made the Dedalus Singularity. In short, accroding to Shenglong, the basic installation is based on Singularity image `/scratch/work/public/singularity/ubuntu-22.04.1.sif`, which OpenMPI 4.1.2 is builtin. We setup all packages with the builtin OpenMPi 4.1.2. After that, replace with the Greene OpenMPI 4.1.2 built with Infiniband and Slurm enabled.

## Acknowledgment<a name="acknowledgment"></a>
The Singularity files in this note are made by Shenglong Wang on the NYU HPC team. We thank the NYU HPC team for their help in training and troubleshooting. 
