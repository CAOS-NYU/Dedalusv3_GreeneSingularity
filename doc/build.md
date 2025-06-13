(make_sing)=
# Building the Singularity
All previous sections of the note use [Dedalus version 3.0.0](https://github.com/DedalusProject/dedalus/releases/tag/v3.0.0). This is when we made the old singularity. It works well unless you need the newest feature of Dedalus. 
However, we see the value of having a way to build a new singularity in case one want to add more packages. This has been surprisingly difficult at this time. 

It is easier to work with this earlier version (see details below). The newer version ([v3.0.3](https://github.com/DedalusProject/dedalus/releases/tag/v3.0.3) at the time of writing) uses requires MPI-4, which is hard to make work with the current version of NYU Greene cluster. Therefore, treat the below instructions with a grain of salt. Contact NYU HPC stuff if it does not work.

Finally, NYU HPC stuff states
> This issue is expected to be resolved with the next-generation HPC cluster.

Hopefully this can be simplified down the line.

## Building
We will build the Singularity by first following the [standard steps](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda). For installing Dedalus, we will be [building from source](https://dedalus-project.readthedocs.io/en/latest/pages/installation.html#building-from-source). First run
```shell
mkdir $SCRATCH/dedalus_sing
cd $SCRATCH/dedalus_sing

cp -rp /scratch/work/public/overlay-fs-ext3/overlay-5GB-200K.ext3.gz .
gunzip overlay-5GB-200K.ext3.gz
```
Then launch the Singularity
```shell
singularity exec \
    --overlay /scratch/work/public/singularity/openmpi-5.0.6-ubuntu-24.04.1.sqf:ro \
    --overlay overlay-5GB-200K.ext3 \
    /scratch/work/public/singularity/ubuntu-24.04.1.sif \
    /bin/bash -c "source /ext3/apps/openmpi/5.0.6/env.sh"
```
Inside the Singularity, install miniconda
```shell
bash /share/apps/utils/singularity-conda/setup-conda.bash
source /ext3/env.sh
```
Then clone the Dedalus source code 
```shell
cd /ext3
git clone https://github.com/DedalusProject/dedalus.git
cd /ext3/dedalus
```
and build and install Dedalus
```shell
CC=mpicc python3 -m pip install --no-cache .
```

At this stage, we can add more packages to the Singularity. For example, we could add [cmocean](https://matplotlib.org/cmocean), a beautiful colormap package to the existing Singularity. 
```shell
pip install cmocean
```
To test that we indeed have the package, run
```shell
source /ext3/env.sh
python -c "import cmocean; print(cmocean.__version__); print(cmocean.__file__)"
#v3.0.3
#/ext3/miniconda3/lib/python3.10/site-packages/cmocean/__init__.py
#your package should be here, not .local
```
Now you have your own Dedalus Singularity that you can edit. If you want to share your Singularity, run inside the Singularity
```shell
mksquashfs /ext3 dedalus_readonly.sqf -keep-as-directory
```
to make a read-only version. 
:::{warning}
You should not let others read your `ext3` file: read access means write access for `ext3` files!
:::

<!-- The version I use will be available at `/scratch/work/sd3201/dedalus3/dedalus_ryansingularity.sqf`, if you want to use my version. A keen reader might have already realized the Singularity used for the JupyterLab is my version. -->

## Using this Singularity
This new Singularity requires some different commands to use, compared to the previous instructions. 

Using interactive mode in the terminal seems to have an issue with efficiency. It cannot make use of multiple cores on a single node to the maximum. 

JupyterLab should work fine (I did not test this). You just need to hook up your Singularity to OOD.

To use Slrum, see the script
```shell
/scratch/work/public/singularity/run-dedalus-3.0.3.bash
```
To use this script, run
```shell
srun --mpi=pmix --nodes=1 --tasks-per-node=4 --mem=4GB /scratch/work/public/singularity/run-dedalus-3.0.3.bash python rayleigh_benard.py
```
You should replace the corresponding line in the `.SBATCH` file.

To use your own overlay file, you can modify the line 
```shell
--overlay /scratch/work/public/singularity/dedalus-3.0.3-openmpi-5.0.6-ubuntu-24.04.1.sqf:ro \
```
in `run-dedalus-3.0.3.bash` to point to your overlay file.