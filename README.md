# savio-notes
Notes on using UC Berkeley's Savio cluster for multicore and multinode parallel R computation via SLURM.

## Files in this repository

* [h2o-slurm-multinode.Rmd]() - example of how to start a multinode h2o cluster using R
* [sbatch-rmd.sh]() - generalized slurm job script that runs an Rmd and converts to html
* [sbatch-r.sh]() - generalized slurm job script that run an R file
* [Makefile]() - generalized Makefile to customize slurm parameters and submit jobs
* [compile-R-3.3.md]() - compiling R on Savio


## Key resources

* Research IT's [Savio user guide](http://research-it.berkeley.edu/services/high-performance-computing/user-guide)
* Chris Paciorek's [Savio 2016 Biostats repository](https://github.com/berkeley-scf/savio-biostat-2016)
* Chris Paciorek's [parallel distributed repository](https://github.com/berkeley-scf/tutorial-parallel-distributed)

## Run an interactive job

Opens a bash shell with access to 1 node for 30 minutes, via the D-Lab condo:
```bash
srun -A co_dlab -p savio  -N 1 -t 30:0 --pty bash
```
After 30 minutes have elapsed the system will terminate the bash shell and send you back to the login node. Or run the "exit" command to stop early, per usual.

Do the same thing, but with 2 nodes and for 5 hours, then check that it works:
```bash
srun -A co_dlab -p savio  -N 2 -t 300:0 --pty bash
echo $SLURM_NODELIST    # Should list two computer hostnames
```

## Run a batch job

Run myjob.sh, which defines the parameters of the SLURM job (see Chris P's biostats repo above).
```bash
sbatch myjob.sh
```

## Check job status
```bash
squeue | grep $USER
```

## Set R mirror
Create ~/.Rprofile and put this in the first line:
```r
options(repos=structure(c(CRAN="http://cran.cnr.berkeley.edu/")))
```
Then when you install packages you won't have to select a mirror every time.

## Remote mount Savio via SSH

* Install osxfuse, sshfs, and Macfusion

This can be done easily with [Homebrew](http://brew.sh/):
```bash
brew cask install osxfuse sshfs macfusion
```

Modify macfusion to use the new ssh ([directions from here](https://github.com/osxfuse/osxfuse/wiki/SSHFS#macfusion)):
```bash
cd /Applications/Macfusion.app/Contents/PlugIns/sshfs.mfplugin/Contents/Resources
mv -f sshfs-static.orig sshfs-static
```

You can then use MacFusion's GUI to mount your Savio directory to your mac using ssh. This makes it easy to operate on remote files as though they are on your computer, e.g. opening R scripts in RStudio to edit. Make sure to use "dtn.brc.berkeley.edu" as the host rather than "hpc.brc.berkeley.edu", as DTN is intended for remote mount operations and HPC won't allow it.

## Setup SSH keys for github
(To be added)
