# Compile R on Savio

Compiling R from scratch takes a fair amount of work so I've put these instructions in a separate file. I followed the [writeup by Paul John](http://pj.freefaculty.org/blog/?p=315) but tweaked them to be more concise and general. These steps are specifically for Berkeley's Savio supercluster but should work in similar systems. Thank you to Chris Paciorek for help with this.

## Basic setup

```bash
# Load modules that we need.
module load java mkl texlive texinfo

# Make a source folder for storing packages to compile.
mkdir -p ~/lib/src
cd ~/lib/src
# Set target directory
export TARGET_DIR=$HOME/lib

# Setup compilation directories
export PATH=$TARGET_DIR/bin:$PATH
export LD_LIBRARY_PATH=$TARGET_DIR/lib:$LD_LIBRARY_PATH
export CFLAGS="-I$TARGET_DIR/include"
export LDFLAGS="-L$TARGET_DIR/lib"
```

## Install zlib
```bash
wget http://zlib.net/zlib1211.zip
unzip zlib*.zip
cd zlib-1.2.11
./configure --prefix=$TARGET_DIR
make && make install && cd ..
```

## Install bzip2
```bash
wget http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
tar zxvf bzip2*.gz
cd bzip2-1.0.6
make -f Makefile-libbz2_so && make clean && make
make install PREFIX=$TARGET_DIR && cd ..
```

## Install xz
```bash
wget http://tukaani.org/xz/xz-5.2.3.tar.gz
tar zxvf xz*.tar.gz
cd xz-5.2.3
./configure --prefix=$TARGET_DIR
make && make install && cd ..
```

## Install pcre
```bash
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.zip
unzip pcre*.zip
cd pcre-8.40
./configure --enable-utf8 --prefix=$TARGET_DIR
make -j3 && make install && cd ..
```

## Install libcurl
```bash
wget https://curl.haxx.se/download/curl-7.54.0.zip
unzip curl*.zip
cd curl-7.54.0
./configure --prefix=$TARGET_DIR
make -j3 && make install && cd ..
```

## Finally, we download and install R

```bash
# Get the latest version of R, currently 3.5.3
wget https://cran.rstudio.com/src/base/R-3/R-3.5.3.tar.gz
tar zxvf R-*.tar.gz
cd R-*

# Setup BLAS to use Intel's math kernel library.
MKL="-Wl,--no-as-needed -lmkl_gf_lp64 -Wl,--start-group -lmkl_gnu_thread  -lmkl_core  -Wl,--end-group -fopenmp  -ldl -lpthread -lm"

# Install the built package into our lib directory, in the bin subdirectory.
# Note: on "External Libaries:" line should see "BLAS(MKL), LAPACK(in blas)".
./configure --prefix=$TARGET_DIR --with-blas="$MKL" --with-lapack --enable-memory-profiling
make -j4 && make install

# Triple-check that MKL was linked successfully - should see 3 MKL shared objects listed.
ldd bin/exec/R | grep mkl

# Add $TARGET_DIR/bin to your path if you haven't already.
echo -e "# Add local bin dir for R etc. $(date +%F)\nexport PATH=$TARGET_DIR/bin:\$PATH" >> ~/.bash_profile

# Reload your .bash_profile with the revised path
source ~/.bash_profile
# Check that your system can find R.
which R
# Also load R to confirm that it works.
R
# If this doesn't find the new R then something is wrong.

# Setup R for java usage.
R CMD javareconf
```
