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

# By default assume we're running an R file.
make_rmd=0

# Extract command line arguments
for i in "$@"
do
case $i in
    -f=*|--file=*)
    file="${i#*=}"

    # If the filename ends in .Rmd turn on Rmd handling.
    if [ ${file: -4} == ".Rmd" ]; then
      echo "Detected Rmd file."
      make_rmd=1
      file_raw="${i#*=}"
      shopt -s extglob    # Turn on extended pattern support
      # Remove .Rmd if it's included in the filename, for use later.
      file=${file_raw%.Rmd}
    fi
    ;;
    -d=*|--dir=*)
    dir_output="${i#*=}"
    ;;
    --spark)
    use_spark=1
    ;;
    # TODO: support manually turning on Rmd processing.
esac
done

# Load R if we are using the built-in R module.
# Comment out if using a custom compiled version of R.
module load r
# comet version (3.4.0):
# module load R

# Load a newer version of gcc than the default. Needed for C++11.
module load gcc/4.8.5
# comet version (4.9)
# module load gnu

# Load Java if any R packages need RJava (bartMachine, h2o, etc.)
module load java

# Load a better linear algebra system.
module load lapack

# GPU computation modules. CUDA is 7.5, cudnn is 4.0.
module load cuda cudnn

# Load spark if needed.
# See https://github.com/berkeley-scf/spark-cloudwg-2015/blob/master/example-savio.sh
# and http://research-it.berkeley.edu/services/high-performance-computing/frequently-asked-questions#q-how-can-i-run-spark-jobs-
if [ $use_spark == 1 ]; then

  # NOTE: this requires the java module.
  # NOTE: this module should have been loaded prior to calling this sbatch.
  # I.e. run on login node, not within the SLURM call.
  # module load spark

  source /global/home/groups/allhands/bin/spark_helper.sh

  # This will start 1 worker per available node in $SLURM_NODELIST.
  # Logs etc. will be in /global/scratch/$USER/spark/bash.<number>/log/
  spark-start

fi;

# Echo remaining commands to stdout
set -x

if [ $make_rmd == 1 ]; then
  # knitr does not support subdirectories - need to use cd.
  cd $dir_output

  # This assumes we are in a subdirectory; remove "../" if not.
  # TODO: detect automatically if dir_output changed directories or not.
  Rscript -e "knitr::knit('../$file.Rmd', '$file.md')" 2>&1

  # Check if the markdown file was generated.
  if [ -f "$file.md" ]; then
    # Convert markdown to html
    # Alternatively could use pandoc on the command line.
    Rscript -e "markdown::markdownToHTML('$file.md', '$file.html')"
  else
    echo "Error: Markdown file $file.md does not exist. Can't create html file."
  fi
else
  # Add job id to output file in case multiple versions of script are running
  # simultaneously.
  R CMD BATCH --no-save --no-restore ${file} ${dir_output}/${file}-${SLURM_JOB_ID}.out
fi;

if [ $use_spark == 1 ]; then
  # Shut down spark cluster.
  spark-stop
fi;
