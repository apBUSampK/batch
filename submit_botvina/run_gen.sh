#!/bin/bash

#SBATCH -o log/%A_%a.log.out
#SBATCH -e log/%A_%a.log.err

echo $outdir_root

outfilenamemask=dcmqgsm

filenum=$(($SLURM_ARRAY_TASK_ID))
#filenum=$(printf "%04d" "$SLURM_ARRAY_TASK_ID")

mkdir -p $log_dir/$filenum

source $root_config

rsync $source_dir/dcmqgsmfragments/* $log_dir/$filenum/

cd "log/$filenum/"

elapsed=$SECONDS

seed=$(expr $seed + $filenum)

#./hypcoa-b1n.exe $seed < inputfilename.txt
#./re-cas-smm  > re-cas-smm.out

#output/hypcoa-b1n $seed < inputfilename.txt
#output/re-cas-smm  > re-cas-smm.out

currentDir=`pwd`
echo "current dir:" $currentDir

datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
datfile_pure=$outdir_dat_pure/${outfilenamemask}_pure_$filenum.dat
rootfile=${outfilenamemask}_$filenum
start_number=$(( $filenum * $split_factor ))

mv CAS-SMM-evt.out $datfile
mv outfile.r12 $datfile_pure

root -l -b -q 'dat2root.C ("'$datfile'","'$rootfile'",'$pbeam','$events_per_file','$split_factor')' &> dat2root.log

for (( i=0;i<$split_factor;i++ )); 
do 
  mv $rootfile"_"$i.root $outdir_root/${outfilenamemask}_$(( $start_number + $i )).root;
done

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes

