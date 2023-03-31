#!/bin/bash

#hades
#pbeam=1.95
#pbeam=2.3

#cbm
#pbeam=3.3
#pbeam=4.4
#pbeam=6
#pbeam=8
#pbeam=10
#pbeam=12

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
pbeam=13
#pbeam=30
#pbeam=40
#pbeam=158

# Equation of state
eos=0
# Number of events
export events_per_file=100 # set double to get desired amount after removing empty events
# Number of jobs
jobRange=1-2
export jobShift=0
#partition=cpu
partition=fast
# Colliding system
#system=auau
system=pbpb
#system=pau
postfix=

# "yes" to remove
export remove_logs=no 

[ $system == agag ] && AP=108 && ZP=47 && AT=108 && ZT=47
[ $system == xecs ] && AP=131 && ZP=54 && AT=133 && ZT=55
[ $system == xexe ] && AP=131 && ZP=54 && AT=131 && ZT=54
[ $system == auau ] && AP=197 && ZP=79 && AT=197 && ZT=79
[ $system == auag ] && AP=197 && ZP=79 && AT=108 && ZT=47
[ $system == aubr ] && AP=197 && ZP=79 && AT=80 && ZT=37
[ $system == pbpb ] && AP=208 && ZP=82 && AT=208 && ZT=82
[ $system == arpb ] && AP=40 && ZP=18 && AT=208 && ZT=82
[ $system == pau  ] && AP=1 && ZP=1 && AT=197 && ZT=79

[ $partition == fast ] && time=1:00:00
[ $partition == cpu ] && time=2-00:00:0

export cluster=nica

if [ $cluster == nica ];then
  soft_path=/scratch1/ogolosov/soft
  export root_config=/cvmfs/nica.jinr.ru/centos7/fairsoft/may18/bin/thisroot.sh
  export out_path=/scratch1/${USER}
else
  echo "Cluster is not specified"
  exit 0
fi

urqmd_src_dir=${soft_path}/misc/urqmd-3.4
export unigen_path=${soft_path}/unigen
export aamcc_path=$out_path/AAMCCwork/AAMCC/build
export mcini_path=${soft_path}/mcini
outdir=$out_path/UrQMDwork/urqmd3.4_aamcc/${system}/pbeam${pbeam}agev_eos${eos}/mbias${postfix}
export outdir_root=$outdir/root
export outdir_root_aamcc=$outdir/aamcc
export outdir_dat=$outdir/dat
export source_dir=$outdir/src
export log_dir=$outdir/log

mkdir -p $outdir
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_root_aamcc
mkdir -p $outdir_dat

mkdir -p $log_dir

script_dir=$(dirname -- $0)
run_gen=run_gen.sh
aamcc_hadd=aamcc_hadd.sh

rsync -v $0 $source_dir
rsync -v $script_dir/$run_gen $source_dir
rsync -v $script_dir/inputfile.template $source_dir/inputfile
rsync -v $urqmd_src_dir/urqmd.x86_64 $source_dir
rsync -v $urqmd_src_dir/runqmd.bash $source_dir
#rsync -v $mcini_path/macro/convertUrQMD.C $source_dir

sed -i -- "s~AT~$AT~g" $source_dir/inputfile
sed -i -- "s~ZT~$ZT~g" $source_dir/inputfile
sed -i -- "s~AP~$AP~g" $source_dir/inputfile
sed -i -- "s~ZP~$ZP~g" $source_dir/inputfile
sed -i -- "s~EOS~$eos~g" $source_dir/inputfile
sed -i -- "s~nEvents~$events_per_file~g" $source_dir/inputfile
sed -i -- "s~plab~$pbeam~g" $source_dir/inputfile

currentDir=`pwd`
echo "current dir:" $currentDir

if [ ${cluster} == nica ]; then
  exclude_nodes="ncx182.jinr.ru|ncx211.jinr.ru|ncx112.jinr.ru|ncx114.jinr.ru|ncx115.jinr.ru|ncx116.jinr.ru|ncx117.jinr.ru"
  qsub -N urqmd_$pbeam -l s_rt=$time -l h_rt=$time -t $jobRange -o ${log_dir} -e ${log_dir} -V -l "h=!(${exclude_nodes})" $source_dir/$run_gen
  qsub -hold_jid urqmd_$pbeam -l s_rt=$time -l h_rt=$time -o ${outdir_root_aamcc}/logMergeGrid -e ${outdir_root_aamcc}/logMergeGrid -V -l "h=!(${exclude_nodes})" $script_dir/$aamcc_hadd
else
  echo "NICA cluster is not defined"
  exit 0
fi

qstat | tail -n 1 | awk '{print $1}'

echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"


