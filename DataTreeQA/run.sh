#!/bin/bash
file_list=$1
ref_file_list=$2
out_file=$3
config_name=$4
cuts_config=default_cbm_cuts

pbeam=12
pipe_version=3
n_psd_modules=44
hole_size=20
postfix=
#postfix=_test
#postfix=_default
#postfix=_no_mvd
#postfix=_no_target
#postfix=_no_mvd_no_target
#postfix=_test

partition=main
#partition=debug

exe_dir=/lustre/nyx/cbm/users/$USER/DataTreeQA
log_dir=$exe_dir/log
config_file=$exe_dir/macro/QAConfigurations.root
root_config=/lustre/nyx/cbm/users/klochkov/soft/root/root6/v6-12-06-cxx11/install/bin/thisroot.sh

file_list="/lustre/nyx/cbm/users/"$USER"/mc/cbmsim/fileLists/botv_"$pbeam"agev_psd"$n_psd_modules"_d"$hole_size"_p"$pipe_version$postfix
ref_file_list=$file_list"_ref"
out_dir="/lustre/nyx/cbm/users/"$USER"/mc/cbmsim/qa/"$(basename "$file_list")
config_name="cbm_"$pbeam"agev_config"

n_jobs=$(wc -l < $file_list)
n_jobs=$(expr $n_jobs / 20)
n_jobs=10
[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00

echo root_config=$root_config
echo exe_dir=$exe_dir
echo log_dir=$log_dir
echo file_list=$file_list
echo ref_file_list=$ref_file_list
echo out_dir=$out_dir
echo config_file=$config_file
echo config_name=$config_name
echo cuts_config=$cuts_config
echo n_jobs=$n_jobs

mkdir -p $out_dir
mkdir -p $log_dir
split -n l/$n_jobs -d -a 4 --additional-suffix=.list $file_list $out_dir/

sbatch -J DTQA_$pbeam -p $partition -a 0-$(expr $n_jobs - 1) -t $time -o $log_dir/%A_%a.o -e $log_dir/%A_%a.e -D $exe_dir --export=root_config=$root_config,ref_file_list=$ref_file_list,out_dir=$out_dir,config_file=$config_file,config_name=$config_name,cuts_config=$cuts_config,log_dir=$log_dir run_kronos.sh
