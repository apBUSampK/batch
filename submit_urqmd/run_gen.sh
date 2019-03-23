#!/bin/bash


echo $outdir_root

outfilenamemask=urqmd

filenum=$(($SLURM_ARRAY_TASK_ID))

mkdir -p $log_dir/$filenum

source $root_config
source $unigen_path/config/unigenlogin.bash

rsync $source_dir/src/* $log_dir/$filenum/

cd "$log_dir/$filenum/"

elapsed=$SECONDS

seed=$(expr $seed + $filenum)
sed -i -- "s~seed~$seed~g" inputfile


currentDir=`pwd`
echo "current dir:" $currentDir

datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
rootfile=$outdir_root/${outfilenamemask}_$filenum.root

./runqmd.bash
mv test.f14 $datfile

which root

#source /etc/profile.d/modules.sh
#alias module='module -u exp'
#unset MODULEPATH
#if [[ $MODULESHOME && -d /cvmfs/it.gsi.de/modules ]]; then
# module use /cvmfs/it.gsi.de/modules
#fi
#module load gcc/6.4.0

echo $events_per_file events

$unigen_path/bin/urqmd2u $datfile $rootfile $events_per_file

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

