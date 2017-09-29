########################################
# General setup

# Directory where sbatch-r-rmd.sh, etc. can be found.
#SCRIPT_DIR=scripts
SCRIPT_DIR=.

# Directory to store command results; set to "." to be current directory.
#OUTPUT_DIR=output
OUTPUT_DIR=.

# How do we want to run tasks? Can be slurm or bash currently.
# Use SLURM if possible, otherwise use bash.
# Can override if desired: "export JOB_ENGINE=shell"
ifndef JOB_ENGINE
  # Detect if we can use slurm, otherwise use shell.
  ifeq (, $(shell which sbatch))
		JOB_ENGINE=shell
	else
		JOB_ENGINE=slurm
	endif
	# TODO: check for SGE.
endif

########################################
# Savio configuration.

# This allows us to use environmental variables to override this default.
# e.g. we run in BASH: "export SBATCH_ACCOUNT=co_otheraccount"
ifndef SBATCH_ACCOUNT
	SBATCH_ACCOUNT=co_biostat
endif

# This allows us to use environmental variables to override this default.
ifndef SBATCH_PARTITION
	SBATCH_PARTITION=savio2
	# Comet standard partition:
	# SBATCH_PARTITION=compute
	# Bridges regular node:
	# SBATCH_PARTITION=rm
endif

# This allows us to override the default QOS by setting an environmental variable.
# e.g. we run in BASH: "export SBATCH_QOS=biostat_normal"
ifndef SBATCH_QOS
	# Choose one QOS and comment out the other, or use environmental variables.
	SBATCH_QOS=biostat_savio2_normal
	#SBATCH_QOS=savio_lowprio
endif

########################################
# Execution engines.

# Sbatch runs a SLURM job, e.g. on Savio or XSEDE.
SBATCH=sbatch -A ${SBATCH_ACCOUNT} -p ${SBATCH_PARTITION} --qos ${SBATCH_QOS}

# Setup R to run commands in the background and keep running after logout.
R=nohup nice -n 19 R CMD BATCH --no-restore --no-save

# TODO: support Sun Grid Engine (SGE) for grizzlybear2.
# Or just convert to batchtools?

########################################
# Misc

# Location of the sbatch script for R or Rmd files.
SBATCH_R_RMD=${SCRIPT_DIR}/sbatch-r-rmd.sh

########################################
# Tasks that can be run.
# Precendence: command line argument > env variable > batch script option.

# Specify -t hh:mm:ss to customize the max runtime requested in sbatch.

# Run an R file via "make analysis"
analysis: somefile.R
ifeq (${JOB_ENGINE},slurm)
	${SBATCH} --nodes 4 --job-name=$< ${SBATCH_R_RMD} --file=$< --dir=${OUTPUT_DIR}
else
	${R} $< ${OUTPUT_DIR}/$<.out &
endif

# Run the example future-batchtools.r script, which uses batchtools.slurm.tmpl
batchtools: future-batchtools.R
	${R} $< &

# Run an Rmd file via "make h2o"
h2o: h2o-slurm-multinode.Rmd
ifeq (${JOB_ENGINE},slurm)
	${SBATCH} --nodes 4 --job-name=$< ${SBATCH_R_RMD} --file=$< --dir=${OUTPUT_DIR}
else
	#${R} $< ${OUTPUT_DIR}/$<.out &
	nohup nice -n 19 Rscript -e "rmarkdown::render('$<')" > ${OUTPUT_DIR}/$<.out 2>&1 &
endif

# Options customized based on "7. GPU job script" at:
# http://research-it.berkeley.edu/services/high-performance-computing/running-your-jobs
gpu-test: gpu-test.Rmd
	sbatch -A ${ACCOUNT} -p savio2_gpu --qos savio_lowprio --nodes 1 --job-name=$< ${SBATCH_R_RMD} --file=$< --dir=${OUTPUT_DIR}

# Launch a bash session on 2 compute nodes for up to 12 hours via "make bash".
bash:
	srun -A ${ACCOUNT} -p ${PARTITION}  -N 2 -t 12:00:00 --pty bash

####
# Add other rules here.
####

# Clean up any logs or temporary files via "make clean"
# Next line ensures that this rule works even if there's a file named "clean".
.PHONY : clean
clean:
	rm -f *.Rout
	rm -f slurm*.out
	rm -f install*.out
	rm -f cache/*
