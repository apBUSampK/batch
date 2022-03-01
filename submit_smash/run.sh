#!/bin/bash

#hades
#pbeam=1.95
#pbeam=2.31

#cbm
#pbeam=3.3
#pbeam=4.4
#pbeam=6
#pbeam=8
#pbeam=10
pbeam=12

#ags:
#pbeam=2.78
#pbeam=4.85
#pbeam=6.87
#pbeam=8.89

#mpd:
#pbeam=9.81

#star
#pbeam=30.65
#pbeam=69.55
#pbeam=111.13

#na49/61:
#pbeam=13
#pbeam=30
#pbeam=40
#pbeam=158

events_per_file=2000 # set in config file!
jobRange=3-1000
#partition=long
partition=main
#partition=debug
system=auau
#system=pbpb
#system=pau
export config=${PWD}/config.yaml
export remove_logs=no

[ "$system" == "pbpb" ]  && projA=208 && projZ=82&& targetA=208 && targetZ=82
[ "$system" == "auau" ]  && projA=197 && projZ=79&& targetA=197 && targetZ=79
[ "$system" == "pau" ]  && projA=1 && projZ=1 && targetA=197 && targetZ=79

[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00
[ "$partition" == "long" ] && time=1-00:00:00

[ "$events_per_file" == "" ] && echo "Empty events_per_file. Provide it as a 2nd argument" && exit
[ "$jobRange" == "" ] && echo "Empty jobRange in the file sequence. Provide it as a 3rd argument" && exit
[ "$partition" == "" ] && echo "Empty partition. Provide it as a 4th argument (options: main / debug)" && exit

source_dir_orig=/lustre/cbm/users/ogolosov/mc/macros/submit_smash
export smash_dir=/lustre/cbm/users/ogolosov/soft/smash-2.0.1

export root_config=/cvmfs/fairroot.gsi.de/fairsoft/jun19p1/bin/thisroot.sh
outdir="/lustre/cbm/users/$USER/mc/generators/smash-2.0.1/"$system"/pbeam"$pbeam"agev/mbias"
export outdir_root="$outdir/root/"
export source_dir="$outdir/src/"
export log_dir="$outdir/log/"

mkdir -p "$outdir"
mkdir -p $source_dir
mkdir -p $outdir_root

mkdir -p $log_dir

run_gen=$source_dir_orig/run_smash.sh

rsync -v $0 $source_dir
rsync -v $run_gen $source_dir
rsync -v ${config} $source_dir

sbatch -J uqmd_$pbeam --mem=8G -o ${log_dir}/%a_%A.log -p $partition -t $time -a $jobRange -D $outdir -- $run_gen

echo "========================================================"
echo "Output will be written to:"
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo "========================================================"


