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
#pbeam=13
#pbeam=30
#pbeam=40
#pbeam=158

help()
{
	echo "Usage:"
	echo "run.sh [OPTION] [NEVENTS_PER_FILE]"
	echo "Here NEVENTS_PER_FILE is requested events amount per file (per job). Default is 2000"
	echo ""
	echo "Options list:"
	echo "-h		display this help"
	echo "-p [float]	projectile beam momentum in lab frame[(A)Gev]. default: 9.85"
	echo "-f		sets \"partition\" to fast. default: disabled"
	echo "-s [string]	sets the colliding system. default: pbpb"
	echo "-j [int]   	number of jobs for calculation. default: 1"
	echo "-S [string]	suffix to append to the output directory"
	echo "-c [string]	cluster selection. default and currently only: nica"
	echo "-m		enable merging"
}

# Configurable parameters
eos=0
pbeam=9.85
partition=cpu
export cluster=nica
system=pbpb
nJobs=1
export jobShift=0
suffix=
merge=no

export events_per_file=2000

# Internal parameters
script_dir=$(dirname -- $0)
run_gen=run_gen.sh
aamcc_hadd=aamcc_hadd.sh

while getopts ':hp:fs:j:S:c:m' opt; do
	case "$opt" in
		h) help; exit 0 ;;
		p) pbeam=$OPTARG ;;
		f) partition=fast ;;
		s) system=$OPTARG ;;
		j) nJobs=$OPTARG ;;
		S) suffix=$OPTARG ;;
		c) export cluster=$OPTARG ;;
		m) merge=yes ;;
		:) echo "-$OPTARG is used with an argument! Type \"run.sh -h\" for help!"; exit 1 ;;
		?) ;;
		*) echo "-$OPTARG is an invalid option! Type \"run.sh -h\" for help!"; exit 1 ;;
	esac;
done

shift $(($OPTIND - 1))

# Number of jobs
if [[ $nJobs > 0 ]]; then
	jobRange=1-$nJobs
else
	echo "Must have at least one job!"
	exit 1
fi

# Number of events
if [ $1 ]; then
	export events_per_file=$1
fi

AP=-1

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
[ $partition == cpu ] && time=2:00:00


[[ $AP < 0 ]] && echo "There is no such system set" && exit 1

if [ $cluster == nica ];then
  soft_path=/scratch1/ogolosov/soft
  export root_config=/cvmfs/nica.jinr.ru/centos7/fairsoft/may18/bin/thisroot.sh
  export out_path=/scratch1/${USER}
else
  echo "No such cluster!"
  exit 1
fi

export urqmd_src_dir=${soft_path}/misc/urqmd-3.4
export unigen_path=${soft_path}/unigen
export aamcc_path=$out_path/aamcc-build
export mcini_path=${soft_path}/mcini
outdir=$out_path/UrQMD-AMC/v3.4/${system}/pbeam${pbeam}agev_eos${eos}/mbias${suffix}
export outdir_root=$outdir/pre-amc
export outdir_root_aamcc=$outdir/post-amc
export outdir_dat=$outdir/urqmd-dat
export source_dir=$outdir/exe
export log_dir=$outdir/log
export aamcc_log_dir=$outdir_root_aamcc/log

mkdir -p $outdir
mkdir -p $source_dir
mkdir -p $outdir_root
mkdir -p $outdir_dat
mkdir -p $outdir_root_aamcc
mkdir -p $aamcc_log_dir

mkdir -p $log_dir

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


if [ ${cluster} == nica ]; then
  exclude_nodes="ncx[182,211,112,114-117]"
  DEP=$(sbatch --job-name=urqmd_$pbeam -t $time --array=$jobRange -o ${log_dir}/%A_%a.out -e ${log_dir}/%A_%a.err --export=ALL --exclude=${exclude_nodes} --parsable $source_dir/$run_gen)
  if [ ${merge} == yes ]; then
  sbatch --dependency=afterok:${DEP} -t $time -o ${aamcc_log_dir}/logMergeGrid/m_output -e ${aamcc_log_dir}/logMergeGrid/m_error --export=ALL --exclude=${exclude_nodes} $script_dir/$aamcc_hadd 
  fi
else
  echo "No such cluster!F"
  exit 0
fi
squeue --name=urqmd_$pbeam

echo "========================================================"
echo "Output will be written to:"
echo ""
echo "source code: $source_dir"
echo "Temporary dir (do not forget to clean up after the jobs are finished) $log_dir"
echo "root files: $outdir_root"
echo ""
echo "dat files: $outdir_dat"
echo "========================================================"
