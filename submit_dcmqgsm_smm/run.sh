#!/bin/bash

#hades
#pbeam=1.95 #T0=1.23
#pbeam=2.34 #T0=1.58

#cbm
#pbeam=2.3
#pbeam=3.3
#pbeam=5.36
#pbeam=6
#pbeam=8
#pbeam=10
#pbeam=12
#pbeam=30

#bman
pbeam=4
#pbeam=4.85

#hz
#pbeam=11.6

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
#pbeam=41
#pbeam=159

#lhc
#pbeam=13433000 # 5.02 TeV

#system=pau
#system=auau
#system=auag
#system=aubr
system=arpb
#system=pbpb
#system=agag
#system=xecs
#system=xexe

export events_per_file=1000
jobRange=1-1000
export jobShift=0
export split_factor=1
export allowPosPzTargetSpect=false
postfix=
partition=fast
#partition=cpu

[ "$system" == "agag" ] && AP=108 && ZP=47 && AT=108 && ZT=47
[ "$system" == "xecs" ] && AP=131 && ZP=54 && AT=133 && ZT=55
[ "$system" == "xexe" ] && AP=131 && ZP=54 && AT=131 && ZT=54
[ "$system" == "auau" ] && AP=197 && ZP=79 && AT=197 && ZT=79
[ "$system" == "auag" ] && AP=197 && ZP=79 && AT=108 && ZT=47
[ "$system" == "aubr" ] && AP=197 && ZP=79 && AT=80 && ZT=37
[ "$system" == "pbpb" ] && AP=208 && ZP=82 && AT=208 && ZT=82
[ "$system" == "arpb" ] && AP=40 && ZP=18 && AT=208 && ZT=82
[ "$system" == "pau"  ] && AP=1 && ZP=1 && AT=197 && ZT=79

export swapProjTarg=false
[ $AP -gt $AT ] && export swapProjTarg=true 

[ "$partition" == "fast" ] && time=1:00:00
[ "$partition" == "cpu" ] && time=1-00:00:00

export remove_logs="yes"

T0=$(echo "$pbeam" | awk '{print sqrt($pbeam*$pbeam+0.938*0.938)-0.938}')

model_source=/home/ovgol/soft/dcmqgsm_smm
export root_config=/mnt/pool/nica/7/mam2mih/soft/basov/fairsoft/install/bin/thisroot.sh
export mcini_config=/home/ovgol/soft/mcini/macro/config.sh

outdir="/mnt/pool/nica/7/ovgol/mc/generators/dcmqgsm_smm/${system}/pbeam${pbeam}agev${postfix}/mbias"
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
rsync -ap --exclude=src ${model_source} $source_dir/
rsync -vp ${script_path}/input.inp.template $source_dir/dcmqgsm_smm/input.inp 
rsync -vp $0 $source_dir 
rsync -vp $run_gen $source_dir 
source $mcini_config
rsync -vp $MCINI/macro/convertDCMQGSM_SMM.C $source_dir 
run_gen=${source_dir}/$(basename ${run_gen})

sed -i -- "s~SRC_PATH_TEMPLATE~$source_dir/dcmqgsm_smm~g" $source_dir/dcmqgsm_smm/input.inp
sed -i -- "s~TO_TEMPLATE~$T0~g" $source_dir/dcmqgsm_smm/input.inp
sed -i -- "s~AP_TEMPLATE~$AP~g" $source_dir/dcmqgsm_smm/input.inp
sed -i -- "s~AT_TEMPLATE~$AT~g" $source_dir/dcmqgsm_smm/input.inp
sed -i -- "s~ZP_TEMPLATE~$ZP~g" $source_dir/dcmqgsm_smm/input.inp
sed -i -- "s~ZT_TEMPLATE~$ZT~g" $source_dir/dcmqgsm_smm/input.inp
sed -i -- "s~NEVENTS_TEMPLATE~$events_per_file~g" $source_dir/dcmqgsm_smm/input.inp

currentDir=`pwd`
echo "current dir:" $currentDir
echo "run_gen:" $run_gen

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


