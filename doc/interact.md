# Using Dedalus interactively
This section descibes some ways you can use Dedalus on Greene interactively. We will go into using is in the terminal, and then get into using it on Jupyter. 

## In the terminal
We first use Dedalus in the terminal. In the terminal (compared to using JupyterLab) Dedalus can use multiple cores (but still on a single node[^1]) to improve speed. 
You should use this method is you need to interact with (e.g., debudding) a code that require heavier computation.

Once we are logged into the Greene cluster, `cd` into your scratch directory and request a computing node so that we can run some code for testing (do not run CPU heavy jobs in the log-in node)
```shell
cd $SCRATCH
srun --nodes=1 --tasks-per-node=4 --cpus-per-task=1 --time=2:00:00 --mem=4GB --pty /bin/bash
```
Once we are in, paste the following commands to start the already-made singularity 
```shell
singularity exec \
  --overlay /scratch/work/public/singularity/dedalus-3.0.0a0-openmpi-4.1.2-ubuntu-22.04.1.sqf:ro \
  /scratch/work/public/singularity/ubuntu-22.04.1.sif /bin/bash
unset -f which
source /ext3/env.sh
export OMP_NUM_THREADS=1; export NUMEXPR_MAX_THREADS=1
```
:::{note}
The last command essentially turns off any shared parallelism. This is recommended for Dedalus's performance since Dedalus does not use hybrid parallelism (see Dedalus documentation on [Disable multithreading](https://dedalus-project.readthedocs.io/en/latest/pages/performance_tips.html#disable-multithreading)). We can check they indeed worked by running `echo $OMP_NUM_THREADS; echo $NUMEXPR_MAX_THREADS` and we should get `1 1`.
:::

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
We now see the script outputting time-stepping information. And if we look at the CPU usage in the node using `htop -u ${USER}`, we should see near 100% usage on 4 cores. Satisfying.

:::{admonition} How about `dedalus test`?
:class: note, dropdown
We did not use the Dedalus provided test `python3 -m dedalus test`. This is intentional. The test function does not work consistently with our setup. But obviously, we have a working Singularity given that we can run Dedalus examples.
:::


## JupyterLab using Open OnDemand (OOD)
Sometimes it is convenient to use JupyterLab for code development. Note that for Dedalus, running it in JupyterLab means we can use only one core. This is acceptable if the computation is light. We should only request one core because more will be wasteful. 
:::{admonition} `mipexec` in Jupyter
:class: note, dropdown
You can run `mipexec` in Jupyter but I think then one should just use the in terminal method.
:::

The instruction on using Open OnDemand (OOD) with Conda/Singularity for Greene is available [here](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity). Since we have an already-made Singularity, we can skip most of the steps.

We create a kernel named `dedalus3` by copying my files to your home directory.
```shell
mkdir -p ~/.local/share/jupyter/kernels
cd ~/.local/share/jupyter/kernels
cp -R /scratch/work/sd3201/dedalus3/dedalus3 ./dedalus3
cd ./dedalus3

ls
#kernel.json logo-32x32.png logo-64x64.png python 
#files in the ~/.local/share/jupyter/kernels directory
```
After this, we can enjoy Dedalus in Jupyter on OOD by following [this tutorial](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/open-ondemand-ood-with-condasingularity#h.pjqb0en5ivqf). 
:::{warning}
Remember to request only one core because we can only use one!
:::

To learn about the details of the files you copied, you could read the `python` and `kernel.json` files. The Singularity used is mine. For instructions on how to make your own, see {ref}`the section on buiding your own Singularity<make_sing>`.


[^1]: A node is a single machine. They are usually named for example as `cs001`, which contains 48 CPU cores.