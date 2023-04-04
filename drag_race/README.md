# Drag Racing Dedalus on Different Machines
To make sure we set up Dedalus correctly on Greene, we run some Dedalus codes on some different environments to compare them. 

Note: This note is incomplete. We would like to do a proper scaling study on larger (3D) problems [this one](https://github.com/DedalusProject/dedalus_scaling). But for now the results show Dedalus is working on Greene and the more ambitious goal is for the future.

## The 2D Rayleigh-Benard convection code
We run the [2D Rayleigh-Benard convection code](https://github.com/DedalusProject/dedalus/blob/master/examples/ivp_2d_rayleigh_benard/rayleigh_benard.py). 

### On my laptop
We use a laptop with Intel(R) Core(TM) i9-10885H which has 
16 threads. We run the code in a conda environment which was set up following the [official recommended method](https://dedalus-project.readthedocs.io/en/latest/pages/installation.html#full-stack-conda-installation-recommended). We use the command

    mpiexec -n 16 python3 rayleigh_benard.py
At the end of the simulation, we have the timing

    2023-04-04 16:36:31,993 solvers 0/16 INFO :: Setup time (init - iter 0): 2.076 sec
    2023-04-04 16:36:31,993 solvers 0/16 INFO :: Warmup time (iter 0-10): 2.611 sec
    2023-04-04 16:36:31,993 solvers 0/16 INFO :: Run time (iter 10-end): 168.1 sec
    2023-04-04 16:36:31,993 solvers 0/16 INFO :: CPU time (iter 10-end): 0.7472 cpu-hr
    2023-04-04 16:36:31,993 solvers 0/16 INFO :: Speed: 1.772e+05 mode-stages/cpu-sec

### On Greene using a single node
We run the same code on Greene using 16 cores on the same node. We use the sbatch script [`slurm_dragrace_single_16.SBATCH`](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/slurm_dragrace_single_16.SBATCH). We have the timing result:

    2023-04-04 17:12:57,277 solvers 0/16 INFO :: Setup time (init - iter 0): 1.972 sec
    2023-04-04 17:12:57,277 solvers 0/16 INFO :: Warmup time (iter 0-10): 1.447 sec
    2023-04-04 17:12:57,277 solvers 0/16 INFO :: Run time (iter 10-end): 33.06 sec
    2023-04-04 17:12:57,277 solvers 0/16 INFO :: CPU time (iter 10-end): 0.1469 cpu-hr
    2023-04-04 17:12:57,277 solvers 0/16 INFO :: Speed: 9.012e+05 mode-stages/cpu-sec
Greene is much faster than my laptop. This is a surprise to be sure, but a welcome one. 

### On Greene using multiple nodes
For the sake of fareness, we run the code on Greene still using 16 codes, but on 4 nodes with 4 cores each. We use the sbatch script [`slurm_dragrace_multpl_4by4.SBATCH`](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/slurm_dragrace_multpl_4by4.SBATCH). We have the timing result:
    2023-04-04 17:11:54,562 solvers 0/16 INFO :: Setup time (init - iter 0): 1.155 sec
    2023-04-04 17:11:54,562 solvers 0/16 INFO :: Warmup time (iter 0-10): 0.3413 sec
    2023-04-04 17:11:54,562 solvers 0/16 INFO :: Run time (iter 10-end): 33.98 sec
    2023-04-04 17:11:54,563 solvers 0/16 INFO :: CPU time (iter 10-end): 0.151 cpu-hr
    2023-04-04 17:11:54,563 solvers 0/16 INFO :: Speed: 8.766e+05 mode-stages/cpu-sec

We see that the multiple nodes sey-up is just as fast as the single node case. This means we are not bottlenecked by network communication on Greene.
