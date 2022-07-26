#!/bin/bash

outfilenamemask=dcmsmm

filenum=$(($SLURM_ARRAY_TASK_ID))
#filenum=$(printf "%04d" "$SLURM_ARRAY_TASK_ID")

mkdir -p $log_dir/$filenum

cd "log/$filenum/"
echo "current dir:" $PWD

elapsed=$SECONDS
seed=$(perl -e 'print int rand 99999999, "\n";')
datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
rootfile=${outfilenamemask}_$filenum
start_number=$(( $filenum * $split_factor ))

$source_dir/dcmsmm/dcmsmm.exe < $source_dir/dcmsmm/input.inp
mv outfile.r12 $datfile

source $root_config
source $mcini_config
rsync -v $MCINI/macro/convertDCMSMM.C $source_dir 
root -l -b -q "$source_dir/convertDCMSMM.C (\"$datfile\",\"$rootfile\", $events_per_file, $split_factor)" &> dat2root.log

for (( i=0;i<$split_factor;i++ )); 
do 
  mv $rootfile"_"$i.root $outdir_root/${outfilenamemask}_$(( $start_number + $i )).root;
done

[ $remove_logs == "yes" ] && rm $log_dir/$filenum 

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

