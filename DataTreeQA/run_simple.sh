#!/bin/bash

#SBATCH -p main
#SBATCH -t 00:60:00
#SBATCH -J DTQA
#SBATCH -o ../../log/%A.log
#SBATCH --mem=16G

file_list=$1
out_file=$2
pbeam=$3
cuts=$4

if [ -z $cuts ];then 
  cuts="default_cbm_cuts"
else 
  [ $cuts == "no" ] && cuts="default_cuts"
  [ $cuts == "alt" ] && cuts="alternative_cbm_cuts"
fi

. /lustre/cbm/users/ogolosov/soft/root-6.18.04/bin/thisroot.sh
../../build_cbm/RunDataTreeQA "$file_list" rf $out_file  ../QAConfigurations.root cbm_${pbeam}agev_config $cuts
