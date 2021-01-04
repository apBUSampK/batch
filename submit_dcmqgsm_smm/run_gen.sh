#!/bin/bash

outfilenamemask=dcmqgsm
filenum=${SLURM_ARRAY_TASK_ID}
jobDir=${log_dir}/${filenum}

mkdir -p ${jobDir}
cd ${jobDir}
echo "current dir:" $PWD

elapsed=$SECONDS
seed=$(perl -e 'print int rand 99999999, "\n";')
datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
datfile_pure=$outdir_dat_pure/${outfilenamemask}_pure_$filenum.dat
rootfile=${outfilenamemask}_$filenum
start_number=$(( $filenum * $split_factor ))

mv $datfile_pure outfile.r12
echo $source_dir/dcmqgsmfragments/input.inp | $source_dir/dcmqgsmfragments/bin/hypcoa-b1n $seed
$source_dir/dcmqgsmfragments/bin/re-cas-smm
 
mv CAS-SMM-evt.out $datfile
mv outfile.r12 $datfile_pure

source $root_config
source $mcini_config
rsync -v $MCINI/macro/convertDCMQGSM_SMM.C $source_dir 
root -l -b -q "$source_dir/convertDCMQGSM_SMM.C (\"$datfile\",\"$rootfile\", $events_per_file, $split_factor)"

for (( i=0;i<$split_factor;i++ )); 
do 
  mv $rootfile"_"$i.root $outdir_root/${outfilenamemask}_$(( $start_number + $i )).root;
done

gzip -f $datfile
gzip -f $datfile_pure

[ $remove_logs == 1 ] && rm -rf $log_dir/$filenum 

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

