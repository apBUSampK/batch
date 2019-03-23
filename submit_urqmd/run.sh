#!/bin/bash

events_per_file=$1
jobRange=$2
partition=$3

#pbeam=3.3
#pbeam=5.36
pbeam=12
events_per_file=2000 # set double to get desired amount after removing empty events
jobRange=0-999
partition=long
#partition=main
#partition=debug
[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00
[ "$partition" == "long" ] && time=1-00:00:00

[ "$events_per_file" == "" ] && echo "Empty events_per_file. Provide it as a 2nd argument" && exit
[ "$jobRange" == "" ] && echo "Empty jobRange in the file sequence. Provide it as a 3rd argument" && exit
[ "$partition" == "" ] && echo "Empty partition. Provide it as a 4th argument (options: main / debug)" && exit

source_dir_orig=/lustre/nyx/cbm/users/ogolosov/mc/macros/submit_urqmd

user=$USER  # test it

root_config=/lustre/nyx/cbm/users/ogolosov/soft/root-6.14.08_std11/bin/thisroot.sh
#root_config=/lustre/nyx/cbm/users/ogolosov/soft/cbmroot/trunk/build/config.sh
unigen_path=/lustre/nyx/cbm/users/ogolosov/soft/unigen_2.0
outdir="/lustre/nyx/cbm/users/$user/mc/generators/urqmd/v3.4/auau/"$pbeam"agev/mbias"
outdir_root="$outdir/root/"
outdir_dat="$outdir/dat/"
source_dir="$outdir/src/"
log_dir="$outdir/log/"

mkdir -p "$outdir"
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_dat

mkdir -p $log_dir

rsync -av $source_dir_orig/ $source_dir/

cp $source_dir/src/inputfile.template $source_dir/src/inputfile

targetA=197
targetZ=79

projA=197
projZ=79

sed -i -- "s~targetA~$targetA~g" $source_dir/src/inputfile
sed -i -- "s~targetZ~$targetZ~g" $source_dir/src/inputfile
sed -i -- "s~projA~$projA~g" $source_dir/src/inputfile
sed -i -- "s~projZ~$projZ~g" $source_dir/src/inputfile
sed -i -- "s~nEvents~$events_per_file~g" $source_dir/src/inputfile
sed -i -- "s~plab~$pbeam~g" $source_dir/src/inputfile

currentDir=`pwd`
echo "current dir:" $currentDir

run_gen="$source_dir/run_gen.sh"
#seed=$(expr $SECONDS / 2)
seed=0

sbatch -J uqmd_$pbeam --mem=8G -o $log_dir/%a_%A.o -e $log_dir/%a_%A.e -p $partition -t $time -a $jobRange -D $outdir --export=root_config=$root_config,unigen_path=$unigen_path,outdir_dat=$outdir_dat,outdir_root=$outdir_root,log_dir=$log_dir,source_dir=$source_dir,seed=$seed,pbeam=$pbeam,events_per_file=$events_per_file $run_gen


echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"


