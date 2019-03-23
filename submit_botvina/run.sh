#!/bin/bash

T0=$1
events_per_file=$2
jobRange=$3
partition=$4

#pbeam=2.76
#pbeam=4.82
#pbeam=6.84
#pbeam=8.85
#pbeam=10.85
#pbeam=12.85
#pbeam=3.3
#pbeam=5.36
pbeam=12
events_per_file=1000
jobRange=1-999
split_factor=1
#partition=main
partition=debug
[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00
[ "$partition" == "grid" ] && time=3-00:00:00


# code to calculate T0 for a given energy
# Double_t mp=0.938;
# Double_t pl=P_LAB_TEMPLATE;
# Double_t El=sqrt(pl*pl+mp*mp)
# Double_t pc=sqrt( ( mp*El-mp*mp )/2 )
# Double_t e_cm=sqrt( pc*pc + mp*mp )
# Double_t ss = sqrt( 4*(pc*pc + mp*mp) )
# Double_t T0 = ss*ss/1.87 - 1.87

T0=UNDEFINED
[ "$pbeam" == 2 ] && T0=1.2871343
[ "$pbeam" == 3.3 ] && T0=2.49272
[ "$pbeam" == 4 ] && T0=3.1927007
[ "$pbeam" == 5.36 ] && T0=4.50346
[ "$pbeam" == 6 ] && T0=5.1633725
[ "$pbeam" == 8 ] && T0=7.1516565
[ "$pbeam" == 10 ] && T0=9.1471319
[ "$pbeam" == 12 ] && T0=11.0986
[ "$pbeam" == 13 ] && T0=12.146626
[ "$pbeam" == 30 ] && T0=29.181974

[ "$pbeam" == 2.76 ] && T0=2
[ "$pbeam" == 4.82 ] && T0=4
[ "$pbeam" == 6.84 ] && T0=6
[ "$pbeam" == 8.85 ] && T0=8
[ "$pbeam" == 10.85 ] && T0=10
[ "$pbeam" == 12.85 ] && T0=12

[ "$T0" == "" ] && echo "T0 is undefined. Provide it as a 1st argument" && exit
[ "$events_per_file" == "" ] && echo "Empty events_per_file. Provide it as a 2nd argument" && exit
[ "$jobRange" == "" ] && echo "Empty jobRange in the file sequence. Provide it as a 3rd argument" && exit
[ "$partition" == "" ] && echo "Empty partition. Provide it as a 4th argument (options: main / debug)" && exit

source_dir_orig=/lustre/nyx/cbm/users/ogolosov/mc/macros/submit_botvina
root_config=/lustre/nyx/cbm/users/ogolosov/soft/cbmroot/trunk/build/config.sh

user=$USER  # test it

outdir="/lustre/nyx/cbm/users/$user/mc/generators/dcmqgsm_abotvina/auau/"$pbeam"agev/mbias"
outdir_root="$outdir/root/"
outdir_dat="$outdir/dat/"
outdir_dat_pure="$outdir/dat_pure/"
source_dir="$outdir/src/"
log_dir="$outdir/log/"

mkdir -p "$outdir"
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_dat

mkdir -p $log_dir

rsync -av $source_dir_orig/ $source_dir/
cd $source_dir_orig/dcmqgsmfragments
make -f makehypcoa-b1n
gfortran -o re-cas-smm re-cas-smm.f
#make
cd -

rsync -v $source_dir/input.inp.template $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~TO_TEMPLATE~$T0~g" $source_dir/dcmqgsmfragments/input.inp
sed -i -- "s~NEVENTS_TEMPLATE~$events_per_file~g" $source_dir/dcmqgsmfragments/input.inp

currentDir=`pwd`
echo "current dir:" $currentDir

run_gen="$source_dir/run_gen.sh"
#seed=$(expr $SECONDS / 2)
seed=0

sbatch -J botv_$pbeam -p $partition -t $time -a $jobRange -D $outdir --export=root_config=$root_config,outdir_dat=$outdir_dat,outdir_dat_pure=$outdir_dat_pure,outdir_root=$outdir_root,log_dir=$log_dir,source_dir=$source_dir,seed=$seed,pbeam=$pbeam,events_per_file=$events_per_file,split_factor=$split_factor $run_gen


echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"


