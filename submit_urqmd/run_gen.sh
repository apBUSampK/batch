#!/bin/bash


echo $outdir_root

outfilenamemask=urqmd

filenum=$(($SLURM_ARRAY_TASK_ID))

mkdir -p $log_dir/$filenum

source $root_config
source $unigen_path/config/unigenlogin.bash

rsync $source_dir/src/* $log_dir/$filenum/

cd "$log_dir/$filenum/"
echo "current dir:" $PDW

elapsed=$SECONDS

seed=$(expr $seed + $filenum)
sed -i -- "s~seed~$seed~g" inputfile

datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
rootfile=$outdir_root/${outfilenamemask}_$filenum.root

./runqmd.bash
mv test.f14 $datfile

which root

echo $events_per_file events

$unigen_path/bin/urqmd2u $datfile $rootfile $events_per_file

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

