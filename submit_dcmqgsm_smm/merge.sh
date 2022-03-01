#!/bin/bash

#SBATCH -p main
#SBATCH -t 8:00:00
#SBATCH -J merge
#SBATCH -o merge_%A.log

in=${1}_1000
out=${in}_2000

mkdir -p ${out}

. /cvmfs/fairroot.gsi.de/fairsoft/jun19p1/bin/thisroot.sh
. /lustre/cbm/users/ogolosov/soft/mcini/macro/config.sh

for (( i=1,j=1;i<=2500;i++,j+=2 )); 
do 
  hadd ${out}/dcmqgsm_${i}.root ${in}/dcmqgsm_${j}.root ${in}/dcmqgsm_$((${j}+1)).root; 
done

