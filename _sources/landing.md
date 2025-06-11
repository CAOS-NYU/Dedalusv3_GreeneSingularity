# Using Dedalus on the NYU Greene Cluster

[Dedalus](https://dedalus-project.org/) is a flexible differential equations solver using spectral methods. It is MPI-parallelized and therefore can make efficient use of high performance computing resources like the [NYU Greene Cluster](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene?authuser=0). The cluster uses Singularity containers to manage packages and Slurm for job scheduling. It is tricky to construct and use a Singularity container for Dedalus v3 that interacts with these well. Luckily, the NYU HPC staff has figured out much of the details. This note describes how to use the Singularity, on single node, on multiple nodes, and in JupyterLab. At the end we will also biefly comment on how to build the Singularity so that you can build your customized version.

:::{note}
As I have graduated, I have less attention to maintain this guide. As Dedalus as well as Greene evolve, things are bound to break. You can [open an issue](https://github.com/CAOS-NYU/Dedalusv3_GreeneSingularity/issues/new). The NYU HPC team is amazing at troubleshooting. If there are parts of the guide that are out of date, please consider contributing.
:::

## Table of content
```{tableofcontents}
```

## Acknowledgment<a name="acknowledgment"></a>
The Singularity files in this note are made by Shenglong Wang on the NYU HPC team. We thank the NYU HPC team for their help in training and troubleshooting. 