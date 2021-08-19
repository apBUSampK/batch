#!/bin/bash

file_list=$1
out_file=$2
pbeam=$3
cuts=$4

if [ -z $cuts ];then 
  cuts="default_cbm_cuts"
else 
  [ $cuts == "no" ] && cuts="default_cuts"
  [ $cuts == "alt" ] && cuts="alternative_cbm_cuts"
  [ $cuts == "new" ] && cuts="default_cbm_cuts_new_tof"
fi

echo ${cuts}

. /lustre/cbm/users/ogolosov/soft/root-6.18.04/bin/thisroot.sh
sbatch --mem=16G -p main -t 00:60:00 -J DTQA -o ../../log/%A.log -- /lustre/cbm/users/ogolosov/DataTreeQA/build_cbm/RunDataTreeQA "$file_list" rf $out_file  ../QAConfigurations.root cbm_${pbeam}agev_config $cuts
