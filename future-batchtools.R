library(future.batchtools)
plan(batchtools_slurm)

# Demo code via https://github.com/HenrikBengtsson/future.batchtools/tree/develop

# This will submit an sbatch job.
x %<-% { Sys.sleep(5); 3.14 }

# This will also submit an sbatch job.
y %<-% { Sys.sleep(5); 2.71 }

x
y