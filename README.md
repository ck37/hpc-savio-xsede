# savio-notes
Notes on using UC Berkeley's Savio cluster for multicore and multinode parallel R computation via SLURM.

## Files in this repository

* [h2o-slurm-multinode.Rmd](h2o-slurm-multinode.Rmd) - example of how to start a multinode h2o cluster using R
* [sbatch-rmd.sh](sbatch-rmd.sh) - generalized slurm job script that runs any Rmd file and generates html
* [sbatch-r.sh](sbatch-r.sh) - generalized slurm job script that runs any R file
* [Makefile](Makefile) - generalized Makefile to customize slurm parameters and submit jobs
* [compile-R-3.3.md](compile-R-3.3.md) - compiling R on Savio


## Key resources

* Research IT's [Savio user guide](http://research-it.berkeley.edu/services/high-performance-computing/user-guide)
* Chris Paciorek's [Savio 2016 Biostats repository](https://github.com/berkeley-scf/savio-biostat-2016)
* Chris Paciorek's [parallel distributed repository](https://github.com/berkeley-scf/tutorial-parallel-distributed)

## Run an interactive job

Opens a bash shell with access to 1 node for 30 minutes, via the D-Lab condo:
```bash
srun -A co_biostat -p savio2 -N 1 -t 30:0 --pty bash
```
After 30 minutes have elapsed the system will terminate the bash shell and send you back to the login node. Or run the "exit" command to stop early, per usual.

Do the same thing, but with 2 nodes and for 5 hours, then check that it works:
```bash
srun -A co_biostat -p savio2  -N 2 -t 300:0 --pty bash
echo $SLURM_NODELIST    # Should list two computer hostnames
```

## Run a batch job

Run myjob.sh, which defines the parameters of the SLURM job (see Chris P's biostats repo above).
```bash
sbatch myjob.sh
```

## Check job status
```bash
squeue -u $USER
```

## Set R mirror
Create ~/.Rprofile and put this in the first line:
```r
options(repos=structure(c(CRAN="http://cran.cnr.berkeley.edu/")))
```
Then when you install packages you won't have to select a mirror every time.

## Memory management

Run (without the angle brackets):
```bash
wwall -j <JOBID>
```
This will show you current CPU and memory usage for a given job. The OS uses about 6 GB of RAM itself, so if you subtract that from the total memory used and then divide by the number of cores, you will have an estimate of memory usage per core. This can be helpful when understanding the performance characteristics of an analysis running sequentially or in parallel.

After a job has completed (or been terminated/cancelled), you can review the maximum memory used via the sacct command.

```bash
sacct -j <JOBID> --format=JobID,JobName,MaxRSS,Elapsed
```
MaxRSS will show the maximum amount of memory that the job used in kilobytes, so divide by 1024^2 to get gigabytes.

## Customized squeue output

I find that a customized output for squeue gives clearer information, so I've added an `sq` alias to my ~/.bashrc file:
```bash
alias sq='squeue -u ${USER} -o "%.7i %.12P %.13j %.10q %.10M %.6D %R"'
```
This provides longer strings for the partition and account, adds in the QOS, automatically restricts to jobs submitted by the current user, and removes some unnecessary columns.

## Tmux and long-running scripts

Login nodes will kill long-running processes after a certain amount of time - something like 2-3 days. So using screen-saving program like tmux does not work on a login node directly. However, the data transfer node (dtn.brc.berkeley.edu) does not seem to restrict how long a process can run. Therefore to use tmux, ssh-agent, or related long-running processes, ssh to dtn, start up the processes, then from within dtn ssh into a login node to submit jobs. (Thanks to Aaron Culich for relaying me this tip.)

Example (starting from personal computer):
```bash
ssh username@dtn.brc.berkeley.edu
# Start tmux
module load tmux
tmux a
# Load ssh-agent
eval $(ssh-agent -s)
# Add github key
ssh-add ~/.ssh/savio_id_rsa
# Connect to a login node to submit jobs.
ssh ln001
```

## Remote mount Savio via SSH

Note: as of January 2017 this does not seem to work anymore. To be explored more.

* Install osxfuse, sshfs, and Macfusion

This can be done easily with [Homebrew](http://brew.sh/):
```bash
brew cask install osxfuse sshfs
```

Currently (Nov. 16) Homebrew does not have the latest version of Macfusion, so that needs to be installed from https://github.com/ElDeveloper/macfusion2.

You can then use MacFusion's GUI to mount your Savio directory to your mac using ssh. This makes it easy to operate on remote files as though they are on your computer, e.g. opening R scripts in RStudio to edit. Make sure to use "dtn.brc.berkeley.edu" as the host rather than "hpc.brc.berkeley.edu", as DTN is intended for remote mount operations and HPC won't allow it.

## Setup SSH keys for github
(To be added)
