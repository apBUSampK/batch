#!/bin/bash

elapsed=$SECONDS

outfilenamemask=urqmd

filenum=$SLURM_ARRAY_TASK_ID

[ $cluster == nica ] && filenum=$((${jobShift}+${SGE_TASK_ID}))
jobDir=${log_dir}/${filenum}

source $root_config
cd $unigen_path
source $unigen_path/config/unigenlogin.sh
#source $mcini_path/macro/config.sh

mkdir -pv ${jobDir}
cd ${jobDir}
echo "current dir:" $PWD
ln -s ${source_dir}/urqmd.x86_64 .
ln -s ${source_dir}/inputfile .

seed=$(perl -e 'print int rand 99999999, "\n";')
#seed=$filenum
sed -i -- "s~seed~$seed~g" inputfile

datfile=$outdir_dat/${outfilenamemask}_$filenum.dat
rootfile=$outdir_root/${outfilenamemask}_$filenum.root

if [ ! -e $datfile.gz ]; then
  ${source_dir}/runqmd.bash
  mv test.f14 $datfile
#  mv test.f20 $datfile
else
  gunzip $datfile.gz
fi

which root

# Convert UrQMD to mcini
echo $LD_LIBRARY_PATH
$unigen_path/bin/urqmd2u $datfile $rootfile $events_per_file
#root $source_dir/convertUrQMD.C"(\"$datfile\",\"$rootfile\")"
gzip -f $datfile

# AfterBurn UrQMD files in AAMCC
cd $outdir_root_aamcc
# Create input file
AAMCCinputString1="1\n1\n"
AAMCCinputString2="4\nurqmd_aamcc_"
echo -e $AAMCCinputString1$rootfile$AAMCCinputString2$filenum > .inFile
# Process afterburning
${aamcc_path}/GRATE < .inFile 1> $outdir_root_aamcc/log
echo "${filenum} file is afterburned"

[ $remove_logs == "yes" ] && rm -r ${log_dir}/${filenum}

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes
