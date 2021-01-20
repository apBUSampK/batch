#!/bin/bash

#hades
#pbeam=1.95 #auau
#pbeam=2.34 #agag

#cbm
pbeam=2.3
#pbeam=3.3
#pbeam=5.36
#pbeam=6
#pbeam=8
#pbeam=10
#pbeam=12
#pbeam=30

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

#system=pau
system=auau
#system=pbpb
#system=agag

export events_per_file=2
jobRange=1 #-5000
export split_factor=1
postfix=""
partition=debug
#partition=main
#partition=long

[ "$system" == "agag" ] && AP=108 && ZP=47 && AT=108 && ZT=47
[ "$system" == "auau" ] && AP=197 && ZP=79 && AT=197 && ZT=79
[ "$system" == "pbpb" ] && AP=208 && ZP=82 && AT=208 && ZT=82
[ "$system" == "pau" ] && AP=1 && ZP=1 && AT=197 && ZT=79

[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00
[ "$partition" == "long" ] && time=1-00:00:00

export remove_logs= #"yes"

T0=$(echo "$pbeam" | awk '{print sqrt($pbeam*$pbeam+0.938*0.938)-0.938}')

model_source=/lustre/cbm/users/ogolosov/mc/macros/submit_dcmqgsm_smm/dcmqgsm_smm_stable
export root_config=/cvmfs/fairroot.gsi.de/fairsoft/jun19p1/bin/thisroot.sh
export mcini_config=/lustre/cbm/users/ogolosov/soft/mcini/macro/config.sh

outdir="/lustre/cbm/users/${USER}/mc/generators/dcmqgsm_smm/${system}/pbeam${pbeam}agev${postfix}/mbias"
export outdir_root="$outdir/root/"
export outdir_dat="$outdir/dat/"
export outdir_dat_pure="$outdir/dat_pure/"
export source_dir="$outdir/src/"
export log_dir="$outdir/log/"

mkdir -p "$outdir"
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_dat
mkdir -p $outdir_dat_pure
mkdir -p $log_dir

script_path=$(dirname ${0})
run_gen=${script_path}/run_gen.sh
rsync -a --exclude=src ${model_source} $source_dir/
rsync -v ${script_path}/input.inp.template $source_dir/dcmqgsm_smm_stable/input.inp 
rsync -v $0 $source_dir 
rsync -v $run_gen $source_dir 
run_gen=${source_dir}/$(basename ${run_gen})

sed -i -- "s~SRC_PATH_TEMPLATE~$source_dir/dcmqgsm_smm_stable~g" $source_dir/dcmqgsm_smm_stable/input.inp
sed -i -- "s~TO_TEMPLATE~$T0~g" $source_dir/dcmqgsm_smm_stable/input.inp
sed -i -- "s~AP_TEMPLATE~$AP~g" $source_dir/dcmqgsm_smm_stable/input.inp
sed -i -- "s~AT_TEMPLATE~$AT~g" $source_dir/dcmqgsm_smm_stable/input.inp
sed -i -- "s~ZP_TEMPLATE~$ZP~g" $source_dir/dcmqgsm_smm_stable/input.inp
sed -i -- "s~ZT_TEMPLATE~$ZT~g" $source_dir/dcmqgsm_smm_stable/input.inp
sed -i -- "s~NEVENTS_TEMPLATE~$events_per_file~g" $source_dir/dcmqgsm_smm_stable/input.inp

currentDir=`pwd`
echo "current dir:" $currentDir

sbatch -J dcm_$pbeam -p $partition -t $time -a $jobRange -o ${log_dir}/%a_%A.log -D $outdir -- $run_gen

echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"


