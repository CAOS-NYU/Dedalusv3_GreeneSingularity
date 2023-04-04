

# Using Dedalus on NYU Greene Cluster

[Dedalus](https://dedalus-project.org/) is a flexible differential equations solver using spectral methods. It is MPI-parallelized therefore it can make efficient use to high performance computing resources like the [NYU Greene Clucster](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene?authuser=0). The cluster uses Singularity containers to manage packages. Because of the use of MPI, the Singularity container construction for Dedalus v3 is not trivial, thus making running Dedalus on Greene difficult. This note aims at lowering that barrier. First, we will learn how to use an already-made Singularity container. Then we will walk through how to make a Dedalus v3 Singularity.

Note: The Singularities in this note could only make use of one compute node. However, due to how Dedalus is parallelized, we will need to use MPI. We will update with a version that makes use of multiple compute nodes in the future and a start is [this script](https://raw.githubusercontent.com/DedalusProject/dedalus_conda/master/conda_install_dedalus3.sh) from the official Dedalus website.

Note 2: If anything does not work in this note, or that you have run into trouble, please let me know at my email ryan_sjdu@nyu.edu. I would be happy to help.
 
## Using an already-made singularity
### On the command line, interactively
We first use Dedalus on the command line. On the command line (compared to using JupyterLab) Dedalus can make use of multiple cores to improve speed. Serious simulations should use this method.

Once we are logged into the Greene cluster, `cd` into your scratch directory and request a computing node so that we can run some code for testing (do not run CPU heavy jobs in the log-in node)

    cd scratch/<yourusrnm>
    srun --cpus-per-task=4 --time=4:00:00 --mem=4GB --pty /bin/bash
Once we are in, paste the following commands in to start the already made singularity 

    singularity exec --overlay \
	    /home/sd3201/dedalus3/dedalus3_mpisinglenode.ext3:ro \
	    /scratch/work/public/singularity/ubuntu-22.04.1.sif /bin/bash
	for e in $(env | grep SLURM_ | cut -d= -f1); do unset $e; done
    source /ext3/env.sh
    export OMP_NUM_THREADS=1; export NUMEXPR_MAX_THREADS=1
Some of these command needs explaination. The line `for e in $(env | grep SLURM_ | cut -d= -f1); do unset $e; done` delete all slurm variable. Without this we get an error when using Dedalus.  The last command essentially turns off any shared parallelism. But this is recommended for Dedalus's performance since Dedalus does not use supprt parallelism (see Dedalus documentation on [Disable multithreading](https://dedalus-project.readthedocs.io/en/latest/pages/performance_tips.html#disable-multithreading)). We can check they indeed worked by running `echo $OMP_NUM_THREADS; echo $NUMEXPR_MAX_THREADS` and we should get `1 1`.

Now we can check if we have Dedalus v3 by running

    python3 -m dedalus test
We could now run an example script, e.g.: the [Rayleigh-Benard convection (2D IVP) example](https://dedalus-project.readthedocs.io/en/latest/pages/performance_tips.html#disable-multithreading). We clone this from the [Dedalus GitHub repo](https://github.com/DedalusProject/dedalus), but to avoid downloading a lot of files, we use [sparse checkout](https://stackoverflow.com/a/52269934) (you might need a newer version of git for this to work, see [here](https://stackoverflow.com/questions/72223738/failed-to-initialize-sparse-checkout)).  

    git clone --depth 1 --filter=blob:none --sparse https://github.com/DedalusProject/dedalus.git
    cd dedalus/
    git sparse-checkout set examples
    cd examples/ivp_2d_rayleigh_benard
<!---
We clone this from the [Dedalus GitHub repo](https://github.com/DedalusProject/dedalus)

    git clone https://github.com/DedalusProject/dedalus.git
    cd dedalus/examples/ivp_2d_rayleigh_benard/
 --->
Now we can run them. Note that we requested 4 cores and are using 4 MPI processes, these two numbers about be the same.

    mpiexec -n 4 python3 rayleigh_benard.py
    mpiexec -n 4 python3 plot_snapshots.py snapshots/*.h5
We now see the script outputting time stepping information. And if we look at the CPU usage in the node using `htop -u <yourusrnm>`, you should see near 100% usage on 4 cores. Satisfying.

### Submitting a job using Slurm
To run many serious simulations, one should queue the jobs in Greene by using Slurm scripts. [Here](https://sites.google.com/nyu.edu/nyu-hpc/training-support/tutorials/slurm-tutorial) is the general tutorial for Slurm on Greene. In this section we will run an example Slurm Dedalus job. 

In the repository of this note, there is an example [Slurm script](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/slurm_example.SBATCH) that runs the [Periodic shear flow (2D IVP) exmple](https://dedalus-project.readthedocs.io/en/latest/pages/examples/ivp_2d_shear_flow.html). To use it, we first clone this repo

    cd scratch/<yourusrnm>
    git clone https://github.com/Empyreal092/Dedalusv3_GreeneSingularity.git
    cd Dedalusv3_GreeneSingularity
We can take a look at the script

    cat slurm_example.SBATCH
You need to fill in your NYU ID to use this script. We see that the script contains essentially the same commands used in the interactive command line so nothing mysterious. 

Now we submit the script 

    sbatch slurm_example.SBATCH
and check the queue

    squeue -u <yourusrnm> -o "%.18i %.9P %.34j %.8u %.8T %.10M %.9l %.6D %R"
Now we see it in the queue. You can check the reasons for the wait [here](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/best-practices#h.p_ID_118). After some patience and the job runs (you will receive an email when it is done) we can check the output in the `Dedalusv3_GreeneSingularity` directory. There should be a file named `slurm_<yourjobid>.out` that contains the output that was outputted to the terminal when we run jobs interactively. We can also find the data output in the code folder

    /scratch/<yourusrnm>/dedalus/examples/ivp_2d_shear_flow
    ls snapshots

### JupyterLab using Open OnDemand (OOD)
Sometimes it is conveience to use JupyterLab for code developement. Note that for Dedalus, using JupyterLab means we can use only one core. This is acceptable if the computation is light. We should only request one core because more will be wasteful.

We adapt the instruction on using [Open OnDemand (OOD) with Conda/Singularity](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity) for Greene. Since we have an already made Singularity, we can skip making it. We start from [Configure iPython Kernels](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity#h.25pp9n8colt0). 

We create a kernel named dedalus by copying the template files to your home directory.

    mkdir -p ~/.local/share/jupyter/kernels
    cd ~/.local/share/jupyter/kernels
    cp -R /share/apps/mypy/src/kernel_template ./dedalus3
    cd ./dedalus3
    
    ls
    #kernel.json logo-32x32.png logo-64x64.png python # files in the ~/.local/share/jupyter/kernels directory
To set the conda environment, edit the file named 'python' in `/.local/share/jupyter/kernels/my_env/`. The python file is a wrapper script that the Jupyter notebook will use to launch your Singularity container and attach it to the notebook. At the bottom of the file we have some singularity command. Edit it so that it uses the already made Sinularity with Dedalus and JupyterLab

    singularity exec $nv \
	  --overlay /home/sd3201/dedalus3/dedalus3_jupyterlab.ext3:ro \
	  /scratch/work/public/singularity/cuda11.2.2-cudnn8-devel-ubuntu20.04.sif \
	  /bin/bash -c "source /ext3/env.sh; export OMP_NUM_THREADS=1; export NUMEXPR_MAX_THREADS=1; $cmd $args"
Finally, edit over the default kernel.json file by pasting these lines

    {
	 "argv": [
	  "/home/<yourusrnm>/.local/share/jupyter/kernels/dedalus3/python",
	  "-m",
	  "ipykernel_launcher",
	  "-f",
	  "{connection_file}"
	 ],
	 "display_name": "dedalus3",
	 "language": "python"
	}

After the hard work, we can enjoy Dedalus on OOD. Follow [this tutorial](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity#h.pjqb0en5ivqf). Remember to request only one core because we can only use one!

## Building the Singularity
Under construction...


## Acknowledgment
We thank the NYU HPC team for their help in training and troubleshooting. 
