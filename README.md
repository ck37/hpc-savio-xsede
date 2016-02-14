# savio-notes
Notes on using UC Berkeley's Savio cluster for multicore and multi-node parallel R computation via SLURM.

## Check job status
```bash
squeue | grep $USER
```

## How to compile R on Savio

With thanks to Chris Paciorek for help on this.
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

You can then use MacFusion to mount your Savio directory to your mac using ssh. This makes it easy to operate on remote files as though they are on your computer.
