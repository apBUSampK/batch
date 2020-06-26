#!/bin/bash
file_list=$1
out_dir=$2
config_name=$3
njobs=$4
cuts_config=$5

partition=main
#partition=debug

exe_dir=/lustre/nyx/cbm/users/$USER/DataTreeQA
log_dir=$exe_dir/log
config_file=$exe_dir/macro/QAConfigurations.root
root_config=/lustre/cbm/users/ogolosov/soft/root-6.18.04/bin/thisroot.sh

ref_file_list=$file_list"_ref"
[ $config_name == "cbm3.3" ] && config_name="cbm_3.3agev_config"
[ $config_name == "cbm5.36" ] && config_name="cbm_5.36agev_config"
[ $config_name == "cbm12" ] && config_name="cbm_12agev_config"
[ $cuts_config == "alt" ] && cuts_config="alternative_cbm_cuts"
[ $cuts_config == "nocuts" ] && cuts_config="default_cuts"

n_jobs=$(wc -l < $file_list)
n_jobs=$(expr $n_jobs / 100)
n_jobs=$njobs
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

rm -fr $out_dir
mkdir -p $out_dir
mkdir -p $log_dir
split -n l/$n_jobs -d -a 4 --additional-suffix=.list $file_list $out_dir/

sbatch -J DTQA_$pbeam --mem=8G -p $partition -a 0-$(expr $n_jobs - 1) -t $time -o $out_dir/%a_%A.o -e $out_dir/%a_%A.e -D $exe_dir --export=root_config=$root_config,ref_file_list=$ref_file_list,out_dir=$out_dir,config_file=$config_file,config_name=$config_name,cuts_config=$cuts_config,log_dir=$log_dir run_kronos.sh
