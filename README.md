# savio-notes
Notes on using UC Berkeley's Savio cluster for multicore and multi-node parallel R computation via SLURM.

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

## Setup SSH keys for github
I have not been able to get this to work yet.

## How to compile R on Savio

Savio currently only has R 3.1, so we need to compile a new version to get R 3.2. Thanks to Chris Paciorek for help on this.
```bash
module load gcc java
# Intel compiler messes up gcc, so we need to unload it.
module unload intel/2013_sp1.4.211
# Make a source folder for storing packages to compile.
mkdir -p ~/lib/src
cd ~/lib/src
# Get the latest version of R, currently 3.2.3
wget https://cran.cnr.berkeley.edu/src/base/R-3/R-3.2.3.tar.gz
tar zxvf R-3.2.3.tar.gz
cd R-3.2.3
# Install the built package into our lib directory, in the bin subdirectory.
./configure --prefix=$HOME/lib
make
make install
```

You may then want to modify ~/.bash_profile and add ~/lib/bin to your path.

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

You can then use MacFusion's GUI to mount your Savio directory to your mac using ssh. This makes it easy to operate on remote files as though they are on your computer.
