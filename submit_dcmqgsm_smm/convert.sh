#!/bin/bash
 
dir=${1}
datDir=${dir}/dat
rootDir=${dir}/root
nEvents=2000
splitFactor=1

. /cvmfs/fairroot.gsi.de/fairroot/v18.2.1_fairsoft-jun19p1/bin/FairRootConfig.sh
. /lustre/cbm/users/ogolosov/soft/mcini/macro/config.sh

for datFile in ${datDir}/*;do 
  rootFile=$(basename ${datFile})
  rootFile=${rootFile/.dat.gz/}
  fileNumber=${rootFile/dcmqgsm_/}
  rootFile=${rootDir}/${rootFile}
  gunzip ${datFile}
  root -q -l "${MCINI}/macro/convertDCMQGSM_SMM.C(\"${datFile/.gz}\",\"${rootFile}\",${nEvents},${splitFactor})"
  for (( i=0;i<${splitFactor};i++ ));do
    mv -v ${rootFile}_${i}.root ${rootFile/${fileNumber}}$(( ${fileNumber} + ${i} )).root
  done
done

for datFile in ${datDir}/*;do
  gzip ${datFile}
done

echo finish!!! 
