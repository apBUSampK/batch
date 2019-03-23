#!/bin/bash

filenum=$(($SLURM_ARRAY_TASK_ID))
filenum=$(printf "%04d" "$filenum")

job_file_list=$out_dir"/"$filenum".list"
out_file=$out_dir"/"$filenum".root"
log_file=$out_dir"/"$filenum".log"

echo current_dir=$PWD
echo root_config=$root_config
echo job_file_list=$job_file_list
echo ref_file_list=$ref_file_list
echo out_file=$out_file
echo config_file=$config_file
echo config_name=$config_name
echo cuts_config=$cuts_config
echo log_file=$log_file

source $root_config

echo RUNNING:
echo build/RunDataTreeQA $job_file_list $ref_file_list $out_file $config_file $config_name $cuts_config

build/RunDataTreeQA $job_file_list $ref_file_list $out_file $config_file $config_name $cuts_config &> $log_file

rm job_file_list

echo "DONE"
