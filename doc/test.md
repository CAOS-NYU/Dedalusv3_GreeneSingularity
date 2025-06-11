# Testing performance<a name="testing_perf"></a>
To make sure we set up Dedalus correctly on Greene, we run some Dedalus codes on some different environments to compare them. The tests shows our set-ups are working well. You can find the .out files in the [`drag_race`](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/tree/main/drag_race) folder.

:::{note}
Note: This note is incomplete. We would like to do a proper scaling study on larger (3D) problems like [this one](https://github.com/DedalusProject/dedalus_scaling). But for now the results show Dedalus is working on Greene and the more ambitious goal is for the future.
:::

## The 2D Rayleigh-Benard convection code
We run the [2D Rayleigh-Benard convection code](https://github.com/DedalusProject/dedalus/blob/master/examples/ivp_2d_rayleigh_benard/rayleigh_benard.py). 

### On my laptop
We use a laptop with Intel(R) Core(TM) i9-10885H which has 
8 cores. We run the code in a conda environment which was set up following the [official recommended method](https://dedalus-project.readthedocs.io/en/latest/pages/installation.html#full-stack-conda-installation-recommended). We use the command

    mpiexec -n 6 python3 rayleigh_benard.py
At the end of the simulation, we have the timing

	2023-09-17 09:19:07,403 solvers 0/6 INFO :: Setup time (init - iter 0): 2.122 sec
	2023-09-17 09:19:07,403 solvers 0/6 INFO :: Warmup time (iter 0-10): 1.074 sec
	2023-09-17 09:19:07,403 solvers 0/6 INFO :: Run time (iter 10-end): 109.5 sec
	2023-09-17 09:19:07,403 solvers 0/6 INFO :: CPU time (iter 10-end): 0.1825 cpu-hr
	2023-09-17 09:19:07,403 solvers 0/6 INFO :: Speed: 7.256e+05 mode-stages/cpu-sec

### On Greene using a single node
We run the same code on Greene using 6 cores on the same node. We use the sbatch script [`slurm_dragrace_single_6.SBATCH`](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/slurm_dragrace_single_6.SBATCH). We have the timing result:

	2023-09-17 17:07:45,810 solvers 0/6 INFO :: Setup time (init - iter 0): 1.869 sec
	2023-09-17 17:07:45,810 solvers 0/6 INFO :: Warmup time (iter 0-10): 0.4294 sec
	2023-09-17 17:07:45,810 solvers 0/6 INFO :: Run time (iter 10-end): 69.57 sec
	2023-09-17 17:07:45,810 solvers 0/6 INFO :: CPU time (iter 10-end): 0.116 cpu-hr
	2023-09-17 17:07:45,810 solvers 0/6 INFO :: Speed: 1.142e+06 mode-stages/cpu-sec
Greene is a bit faster than my laptop. Good!

### On Greene using multiple nodes
For the sake of fairness, we run the code on Greene still using 6 cores, but on 3 nodes with 2 cores each. We use the sbatch script [`slurm_dragrace_multpl_3by2.SBATCH`](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/slurm_dragrace_multpl_3by2.SBATCH). We have the timing result:

	2023-09-17 17:04:41,077 solvers 0/6 INFO :: Setup time (init - iter 0): 1.909 sec
	2023-09-17 17:04:41,077 solvers 0/6 INFO :: Warmup time (iter 0-10): 0.4599 sec
	2023-09-17 17:04:41,077 solvers 0/6 INFO :: Run time (iter 10-end): 61.87 sec
	2023-09-17 17:04:41,077 solvers 0/6 INFO :: CPU time (iter 10-end): 0.1031 cpu-hr
	2023-09-17 17:04:41,077 solvers 0/6 INFO :: Speed: 1.284e+06 mode-stages/cpu-sec

We see that the multiple nodes set-up is just as fast as the single node case. This means we are not bottlenecked by network communication on Greene. Great!

## The 2D Periodic shear flow code
We run a modified version of [2D Periodic shear flow code code](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/shear_flow.py) with higher resolution so that the computation is more demanding. We do all simulations in Greene.

### Using a single node
We run the code on Greene using 32 cores on the same node. We use the sbatch script [`slurm_dragrace_single_32.SBATCH`](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/slurm_dragrace_single_32.SBATCH). We have the timing result:

    2023-04-05 00:03:55,536 solvers 0/32 INFO :: Setup time (init - iter 0): 2.231 sec
    2023-04-05 00:03:55,536 solvers 0/32 INFO :: Warmup time (iter 0-10): 1.022 sec
    2023-04-05 00:03:55,536 solvers 0/32 INFO :: Run time (iter 10-end): 1503 sec
    2023-04-05 00:03:55,536 solvers 0/32 INFO :: CPU time (iter 10-end): 13.36 cpu-hr
    2023-04-05 00:03:55,536 solvers 0/32 INFO :: Speed: 2.757e+06 mode-stages/cpu-sec

### Using multiple nodes
We compare this to running the code still using 32 cores, but on 4 nodes with 8 cores each, a more realistic set-up. We use the sbatch script [`slurm_dragrace_multpl_4by8.SBATCH`](https://github.com/Empyreal092/Dedalusv3_GreeneSingularity/blob/main/drag_race/slurm_dragrace_multpl_4by8.SBATCH). We have the timing result:

    2023-04-04 23:32:56,148 solvers 0/32 INFO :: Setup time (init - iter 0): 3.942 sec
    2023-04-04 23:32:56,148 solvers 0/32 INFO :: Warmup time (iter 0-10): 0.9534 sec
    2023-04-04 23:32:56,148 solvers 0/32 INFO :: Run time (iter 10-end): 1450 sec
    2023-04-04 23:32:56,148 solvers 0/32 INFO :: CPU time (iter 10-end): 12.89 cpu-hr
    2023-04-04 23:32:56,148 solvers 0/32 INFO :: Speed: 2.857e+06 mode-stages/cpu-sec

The multiple nodes set-up is just as fast as the single node case (even a bit faster!). 

### Scaling up the cores number
Finally we run a simulation using more cores (128) than there are on a single node (48). We are now using the full power of distributed MPI set-up. We run the code with 128 cores with 8 nodes and 16 cores each. We get the timing

    2023-04-04 18:28:18,257 solvers 0/128 INFO :: Setup time (init - iter 0): 4.052 sec
    2023-04-04 18:28:18,257 solvers 0/128 INFO :: Warmup time (iter 0-10): 1.452 sec
    2023-04-04 18:28:18,257 solvers 0/128 INFO :: Run time (iter 10-end): 452.1 sec
    2023-04-04 18:28:18,257 solvers 0/128 INFO :: CPU time (iter 10-end): 16.08 cpu-hr
    2023-04-04 18:28:18,257 solvers 0/128 INFO :: Speed: 2.291e+06 mode-stages/cpu-sec
This is almost 4 times the speed up from the 32 cores version. It is within reason to call this scaling strong.
