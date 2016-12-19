#######################
# Setup

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
ifndef QOS
	# Choose one QOS and comment out the other, or use environmental variables.
	#QOS=biostat_savio2_normal
	QOS=savio_lowprio
endif

SBATCH=sbatch -A ${ACCOUNT} -p ${PARTITION} --qos ${QOS}

######
# Makefile configuration.

# These can be subdirectories if desired, e.g. ./scripts and ./output
SCRIPT_DIR=.
OUTPUT_DIR=.

# Run an R file via "make analysis"
analysis: somefile.R
	${SBATCH} --nodes 4 --job-name=$< ${SCRIPT_DIR}/sbatch-r.sh --file=$< --dir=${OUTPUT_DIR}

# Run an RMD file via "make h2o"
h2o: h2o.Rmd
	${SBATCH} --nodes 4 --job-name=$< ${SCRIPT_DIR}/sbatch-rmd.sh --file=$< --dir=${OUTPUT_DIR}

# Launch an interactive bash shell on 2 compute nodes via "make bash"
bash:
	srun -A ${ACCOUNT} -p ${PARTITION}  -N 2 -t 5:00:00 --pty bash

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
