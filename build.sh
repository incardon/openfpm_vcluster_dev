#! /bin/bash

# Make a directory in /tmp/openfpm_data

echo "$PATH"
echo "Directory: $1"
echo "Machine: $2"
echo "Branch: $3"

mkdir /tmp/openfpm_vcluster
mv * .[^.]* /tmp/openfpm_vcluster
mv /tmp/openfpm_vcluster openfpm_vcluster

mkdir openfpm_vcluster/src/config

git clone git@git.mpi-cbg.de:/openfpm/openfpm_devices.git openfpm_devices
git clone git@git.mpi-cbg.de:/openfpm/openfpm_data.git openfpm_data
cd openfpm_data
git checkout 6c2a5911ac16f93ab0ae1e7ac14723c952aa5c16
cd ..
cd openfpm_devices
git checkout 46e4994c5dff879a71e6ae090c50b2f23235d435
cd ..

cd "$1/openfpm_vcluster"

source $HOME/openfpm_vars_$3

if [ "$2" == "gin" ]; then
 echo "Compiling on gin\n"
 module load gcc/4.9.2
 module load openmpi/1.8.1

elif [ "$2" == "wetcluster" ]; then
 echo "Compiling on wetcluster"

## produce the module path

 export MODULEPATH="/sw/apps/modules/modulefiles:$MODULEPATH"

 script="module load gcc/4.9.2\n 
module load openmpi/1.8.1\n
module load boost/1.54.0\n
compile_options='--with-boost=/sw/apps/boost/1.54.0/'\n
\n
sh ./autogen.sh\n
sh ./configure \"\$compile_options\"  CXX=mpic++\n
make\n
if [ \"\$?\" = "0" ]; then exit 1 ; fi\n
exit(0)\n"

 echo $script | sed -r 's/\\n/\n/g' > compile_script

 bsub -o output_compile.%J -K -n 1 -J compile sh ./compile_script

elif [ "$2" == "taurus" ]; then
 echo "Compiling on taurus"

 echo "$PATH"
 module load gcc/5.3.0
 module load boost/1.60.0
 module load openmpi/1.10.2-gnu
 module unload bullxmpi

 sh ./autogen.sh
 sh ./configure  CXX=mpic++
 make
 if [ $? -ne 0 ]; then exit 1 ; fi

### to exclude --exclude=taurusi[6300-6400],taurusi[5400-5500]

else

 source $HOME/.bashrc
 echo "$PATH"
 echo "Compiling general"
 sh ./autogen.sh
 sh ./configure  CXX=mpic++
 make
 if [ $? -ne 0 ]; then exit 1 ; fi

fi

