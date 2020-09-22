#!/bin/bash

#hades
#pbeam=1.95 #auau
#pbeam=2.34 #agag

#cbm
pbeam=3.3
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

events_per_file=2000
jobRange=1-5000
split_factor=1
postfix=""
#partition=debug
partition=main
#partition=long

[ "$system" == "agag" ] && AP=108 && ZP=47 && AT=108 && ZT=47
[ "$system" == "auau" ] && AP=197 && ZP=79 && AT=197 && ZT=79
[ "$system" == "pbpb" ] && AP=208 && ZP=82 && AT=208 && ZT=82
[ "$system" == "pau" ] && AP=1 && ZP=1 && AT=197 && ZT=79

[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00
[ "$partition" == "long" ] && time=1-00:00:00

remove_logs="yes"

T0=$(echo "$pbeam" | awk '{print sqrt($pbeam*$pbeam+0.938*0.938)-0.938}')

source_dir_orig=/lustre/cbm/users/ogolosov/mc/macros/submit_dcmqgsm_smm
root_config=/cvmfs/fairroot.gsi.de/fairsoft/jun19p1/bin/thisroot.sh
mcini_config=/lustre/cbm/users/ogolosov/soft/mcini/macro/config.sh

outdir="/lustre/cbm/users/${USER}/mc/generators/dcmqgsm_smm/${system}/pbeam${pbeam}agev${postfix}/mbias"
outdir_root="$outdir/root/"
outdir_dat="$outdir/dat/"
outdir_dat_pure="$outdir/dat_pure/"
source_dir="$outdir/src/"
log_dir="$outdir/log/"

mkdir -p "$outdir"
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_dat
mkdir -p $outdir_dat_pure
mkdir -p $log_dir

run_gen=$source_dir_orig/run_gen.sh
rsync -a $source_dir_orig/dcmqgsmfragments $source_dir/
rsync -v $source_dir_orig/input.inp.template $source_dir 
rsync -v $0 $source_dir 
rsync -v $run_gen $source_dir 

mv -v $source_dir/input.inp.template $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~SRC_PATH_TEMPLATE~$source_dir/dcmqgsmfragments~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~TO_TEMPLATE~$T0~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~AP_TEMPLATE~$AP~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~AT_TEMPLATE~$AT~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~ZP_TEMPLATE~$ZP~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~ZT_TEMPLATE~$ZT~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~NEVENTS_TEMPLATE~$events_per_file~g" $source_dir/dcmqgsmfragments/input.inp

currentDir=`pwd`
echo "current dir:" $currentDir

seed=0

sbatch -J dcm_$pbeam -p $partition -t $time -a $jobRange -D $outdir --export=root_config=$root_config,mcini_config=$mcini_config,outdir_dat=$outdir_dat,outdir_dat_pure=$outdir_dat_pure,outdir_root=$outdir_root,log_dir=$log_dir,source_dir=$source_dir,seed=$seed,pbeam=$pbeam,events_per_file=$events_per_file,split_factor=$split_factor,remove_logs=$remove_logs $run_gen


echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"


