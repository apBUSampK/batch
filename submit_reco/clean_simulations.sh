#!/bin/bash

#SBATCH -J clean
#SBATCH -p main
#SBATCH -t 8:00:00
#SBATCH --mem=16G
#SBATCH -o cleanSim_%A.log

folder=$1
cd $folder
firstNumber=$(ls|head -n 1)
echo folder=${folder}
echo firstNumber=${firstNumber}

date
. /lustre/cbm/users/ogolosov/soft/cbmroot/apr20/fr_18.2.1_fs_jun19p1/bin/CbmRootConfig.sh

qa_folder=param_and_QA
mkdir -p ${qa_folder}
hadd -j ${qa_folder}/KFPF_QA.root */*.KFQA.root
hadd -j ${qa_folder}/KFPF_MC_QA.root */*.KFQA_MC.root
hadd -j ${qa_folder}/CbmKFTrackQA.root */CbmKFTrackQA.root
mv -v ${firstNumber}/TRhistos.root ${qa_folder}
mv -v ${firstNumber}/${firstNumber}.KFeff.txt ${qa_folder}
mv -v ${firstNumber}/${firstNumber}.KFeff_MC.txt ${qa_folder}
mv -v ${firstNumber}/${firstNumber}.event.raw.moni.root ${qa_folder}
mv -v ${firstNumber}/${firstNumber}.rec.monitor.root ${qa_folder}
mv -v ${firstNumber}/FairRunInfo* ${qa_folder}
mv -v macro/test.geo.root ${qa_folder}
mv -v macro/gphysi.dat ${qa_folder}

echo taring logs...
for f in *; do
  if [ -e ${f}/transport.log.gz ]; then
    echo ${f}
    mv ${f}/transport.log.gz ${f}/${f}.transport.log.gz
    mv ${f}/digi.log.gz ${f}/${f}.digi.log.gz
    mv ${f}/reco.log.gz ${f}/${f}.reco.log.gz
    mv ${f}/tree.log.gz ${f}/${f}.tree.log.gz
  fi
done
tar cf logs.tar */*log.gz --remove-files
zip -n root ${qa_folder} ${qa_folder}/*
rm -rf ${qa_folder}

echo removing...
rm macro/transport.log
rm macro/test*
rm */*.KFQA.root
rm */*.KFQA_MC.root
rm */CbmKFTrackQA.root
rm */*.KFeff.txt
rm */*.KFeff_MC.txt
rm */TRhistos.root
rm */*.event.raw.moni.root
rm */*.rec.monitor.root
rm */FairRunInfo*
rm */*.par
rm */EdepHistos.root
rm */L1_histo.root
rm */TRhistos.root
rm */*.geo.root
rm -r log
tar cvf macro.tar macro/ --remove-files

date
echo finish!
