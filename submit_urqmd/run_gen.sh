#!/bin/bash

elapsed=$SECONDS
echo $outdir_root

outfilenamemask=urqmd

filenum=$(($SLURM_ARRAY_TASK_ID))

mkdir -p $log_dir/$filenum

source $root_config
cd $unigen_path
source $unigen_path/config/unigenlogin.sh

cd "$log_dir/$filenum/"
echo "current dir:" $PWD
ln -s ${source_dir}/urqmd-3.4/urqmd.x86_64 .
ln -s ${source_dir}/inputfile .

seed=$(perl -e 'print int rand 99999999, "\n";')
sed -i -- "s~seed~$seed~g" inputfile

datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
rootfile=$outdir_root/${outfilenamemask}_$filenum.root

${source_dir}/urqmd-3.4/runqmd.bash
mv test.f14 $datfile

which root

echo $events_per_file events

$unigen_path/bin/urqmd2u $datfile $rootfile $events_per_file
gzip -f $datfile

[ $remove_logs == "yes" ] && rm -r ${log_dir}/${filenum}

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

