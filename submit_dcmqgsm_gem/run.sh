#!/bin/bash

#hades
#pbeam=1.95 #auau
#pbeam=2.34 #agag

#cbm
#pbeam=3.3
#pbeam=4
#pbeam=5.36
#pbeam=6
#pbeam=8
#pbeam=10
#export pbeam=12

#ags:
#pbeam=2.78
#pbeam=4.85
#pbeam=6.87
#pbeam=8.89

#bman
pbeam=4.78

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

#system=auau
#system=pbpb
#system=agag
system=xesc

export events_per_file=2
jobRange=1
export split_factor=1
postfix=""
partition=fast
#partition=cpu

[ "$system" == "agag" ] && AP=108 && ZP=47 && AT=108 && ZT=47
[ "$system" == "xesc" ] && AP=131 && ZP=54 && AT=45 && ZT=21
[ "$system" == "xexe" ] && AP=131 && ZP=54 && AT=131 && ZT=54
[ "$system" == "auau" ] && AP=197 && ZP=79 && AT=197 && ZT=79
[ "$system" == "pbpb" ] && AP=208 && ZP=82 && AT=208 && ZT=82

[ "$partition" == "fast" ] && time=1:00:00
[ "$partition" == "cpu" ] && time=1-00:00:00
export remove_logs="no"

T0=$(echo "$pbeam" | awk '{print sqrt($pbeam*$pbeam+0.938*0.938)-0.938}')

source_dir_orig=/home/ovgol/batch/submit_dcmqgsm_gem
#root_config=/lustre/cbm/users/ogolosov/soft/root-5.34.38/bin/thisroot.sh
export root_config=/mnt/pool/nica/7/mam2mih/soft/basov/fairsoft/install/bin/thisroot.sh
export mcini_config=/home/ovgol/soft/mcini/macro/config.sh

user=$USER  # test it

outdir="/mnt/pool/nica/7/ovgol/mc/generators/dcmsmm/${system}/pbeam${pbeam}agev${postfix}/mbias"
export outdir_root="$outdir/root/"
export outdir_dat="$outdir/dat/"
export source_dir="$outdir/src/"
export log_dir="$outdir/log/"

mkdir -p "$outdir"
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_dat
mkdir -p $log_dir

rsync -a $source_dir_orig/ $source_dir/

rsync -v $source_dir/input.inp.template $source_dir/dcmsmm/input.inp
sed -i -- "s~SRC_PATH_TEMPLATE~$source_dir/dcmsmm~g" $source_dir/dcmsmm/input.inp
sed -i -- "s~TO_TEMPLATE~$T0~g" $source_dir/dcmsmm/input.inp
sed -i -- "s~AP_TEMPLATE~$AP~g" $source_dir/dcmsmm/input.inp
sed -i -- "s~AT_TEMPLATE~$AT~g" $source_dir/dcmsmm/input.inp
sed -i -- "s~ZP_TEMPLATE~$ZP~g" $source_dir/dcmsmm/input.inp
sed -i -- "s~ZT_TEMPLATE~$ZT~g" $source_dir/dcmsmm/input.inp
sed -i -- "s~NEVENTS_TEMPLATE~$events_per_file~g" $source_dir/dcmsmm/input.inp

currentDir=`pwd`
echo "current dir:" $currentDir

run_gen="$source_dir/run_gen.sh"

sbatch -J geni_$pbeam -p $partition -t $time -a $jobRange -D $outdir -o $outdir/log/%a_%A.log -- $run_gen


echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"


