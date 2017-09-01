########################################
# General setup

# Directory where sbatch-r.sh, sbatch-rmd.sh, etc. can be found.
SCRIPT_DIR=scripts
#SCRIPT_DIR=.

# Directory to store command results; set to "." to be current directory.
OUTPUT_DIR=output
#OUTPUT_DIR=.

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

######
# Savio configuration.

# This allows us to use environmental variables to override this default.
# e.g. we run in BASH: "export ACCOUNT=co_otheraccount"
ifndef ACCOUNT
	ACCOUNT=co_biostat
endif

# This allows us to use environmental variables to override this default.
ifndef PARTITION
	PARTITION=savio2
endif

# This allows us to override the default QOS by setting an environmental variable.
# e.g. we run in BASH: "export QOS=biostat_normal"
ifndef QOS
	# Choose one QOS and comment out the other, or use environmental variables.
	QOS=biostat_savio2_normal
	#QOS=savio_lowprio
endif

########################################
# Execution engines.

# Sbatch runs a SLURM job, e.g. on Savio or XSEDE.
SBATCH=sbatch -A ${ACCOUNT} -p ${PARTITION} --qos ${QOS}

# Setup R to run commands in the background and keep running after logout.
R=nohup nice -n 19 R CMD BATCH --no-restore --no-save

# TODO: support Sun Grid Engine (SGE) for grizzlybear2.
# Or just convert to batchtools?

########################################
# Tasks that can be run.

# Run an R file via "make analysis"
analysis: somefile.R
ifeq (${JOB_ENGINE},slurm)
	${SBATCH} --nodes 4 --job-name=$< ${SCRIPT_DIR}/sbatch-r.sh --file=$< --dir=${OUTPUT_DIR}
else
	${R} $< ${OUTPUT_DIR}/$<.out &
endif

# Run an Rmd file via "make h2o"
h2o: h2o.Rmd
ifeq (${JOB_ENGINE},slurm)
	${SBATCH} --nodes 4 --job-name=$< ${SCRIPT_DIR}/sbatch-rmd.sh --file=$< --dir=${OUTPUT_DIR}
else
	${R} $< ${OUTPUT_DIR}/$<.out &
endif

# Options customized based on "7. GPU job script" at:
# http://research-it.berkeley.edu/services/high-performance-computing/running-your-jobs
gpu-test: gpu-test.Rmd
	sbatch -A ${ACCOUNT} -p savio2_gpu --qos savio_lowprio --nodes 1 --job-name=$< ${SCRIPT_DIR}/sbatch-rmd.sh --file=$< --dir=${OUTPUT_DIR}

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
