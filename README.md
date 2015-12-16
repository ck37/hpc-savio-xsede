# savio-r
Multicore and multi-node parallel R computation via SLURM on the Savio cluster at UC Berkeley


## Check job status
squeue | grep $USER

## How to compile R on Savio

```bash
module load gcc java
module unload intel/2013_sp1.4.211
mkdir -p ~/lib/src
cd ~/lib/src
wget https://cran.cnr.berkeley.edu/src/base/R-3/R-3.2.3.tar.gz
tar zxvf R-3.2.3.tar.gz
cd R-3.2.3
./configure --prefix=$HOME/lib
make
make install
```

You may then want to modify ~/.bash_profile and add ~/lib/bin to your path.
