#!/bin/bash

outfilenamemask=dcmqgsm
filenum=${SLURM_ARRAY_TASK_ID}
jobDir=${log_dir}/${filenum}

mkdir -p ${jobDir}
cd ${jobDir}
echo "current dir:" $PWD

elapsed=$SECONDS
datfile=${outdir_dat}/${outfilenamemask}_${filenum}.dat.gz
datfile_pure=${outdir_dat_pure}/${outfilenamemask}_pure_${filenum}.dat.gz
rootfile=${outfilenamemask}_$filenum
start_number=$(( ($filenum - 1) * $split_factor ))

echo datfile: ${datfile} 
echo datfile_pure: ${datfile_pure} 
echo rootfile: ${rootfile} 
echo start_number: ${start_number} 

if [ ! -e ${datfile_pure} ];then
  seed=$(perl -e 'print int rand 99999999, "\n";')
  echo SEED: ${seed}
  echo $source_dir/dcmqgsm_smm_stable/input.inp | $source_dir/dcmqgsm_smm_stable/bin/hypcoa-b1n $seed
fi

if [ ! -e ${datfile} ];then
  [ -e outfile.r12 ] || gunzip -cv ${datfile_pure} > outfile.r12
  $source_dir/dcmqgsm_smm_stable/bin/re-cas-smm
fi

[ -e CAS-SMM-evt.out ] || gunzip -cv ${datfile} > CAS-SMM-evt.out 
source $root_config
source $mcini_config
rsync -v $MCINI/macro/convertDCMQGSM_SMM.C $source_dir 
root -l -b -q "$source_dir/convertDCMQGSM_SMM.C (\"CAS-SMM-evt.out\",\"$rootfile\", $events_per_file, $split_factor)"

for (( i=0;i<$split_factor;i++ )); 
do 
  mv $rootfile"_"$i.root $outdir_root/${outfilenamemask}_$(( $start_number + $i )).root;
done

[ -e ${datfile_pure} ] || gzip -cv outfile.r12 > ${datfile_pure}
[ -e ${datfile} ] || gzip -cv CAS-SMM-evt.out > ${datfile}
rm outfile.r12
rm CAS-SMM-evt.out

[ $remove_logs == 1 ] && rm -rf $log_dir/$filenum 

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

