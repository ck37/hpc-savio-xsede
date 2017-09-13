#!/bin/bash
######### Sbatch configuration.
#
# NOTE: we do not specify account, partition, or QOS in this file,
# in order to allow easier customization. Instead those settings
# should be specified in the command line via the calling file.
#
# Job output
#SBATCH --output=slurm.out
#SBATCH --error=slurm.out
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
#### Done configuring sbatch.

# Output to current directory by default. Overriden by --dir option.
dir_output=.

# Don't use spark unless explicitly enabled.
use_spark=0

# Extract command line arguments
for i in "$@"
do
case $i in
    -f=*|--file=*)
    file="${i#*=}"
    ;;
    -d=*|--dir=*)
    dir_output="${i#*=}"
    ;;
    --spark)
    use_spark=1
    ;;
esac
done

# Load R if we are using the built-in R module.
# Comment out if using a custom compiled version of R.
module load r

# Load a newer version of gcc than the default. Needed for C++11.
module load gcc/4.8.5

# Load Java if any R packages need RJava (bartMachine, h2o, etc.)
module load java

# Load a better linear algebra system.
module load lapack

# GPU computation modules. CUDA is 7.5, cudnn is 4.0.
module load cuda cudnn

# Load spark if needed.
if [[ $use_spark == 1 ]]; then
  module load spark

  source /global/home/groups/allhands/bin/spark_helper.sh

  spark-start
fi;

# Add job id to output file in case multiple versions of script are running
# simultaneously.
R CMD BATCH --no-save --no-restore ${file} ${dir_output}/${file}-${SLURM_JOB_ID}.out

if [[ $use_spark == 1 ]]; then
  # Shut down spark cluster.
  spark-stop
fi;
