#!/bin/bash

source $root_config

filenum=$(($SLURM_ARRAY_TASK_ID))
filenum4=$(printf "%04d" "$SLURM_ARRAY_TASK_ID")
plutoFile=/lustre/nyx/cbm/prod/gen/pluto/auau/cktA/8gev/omega/epem/pluto.auau.8gev.omega.epem.$filenum4.root
 
input_file=""$input_dir"/"$mc_generator_file_name"_"$filenum.root""
job_out_dir=$out_dir/$filenum

echo mc_generator_file_name=$mc_generator_file_name
echo input_file=$input_file

mkdir -p $job_out_dir
cd $job_out_dir
cp ../macro/run_transport.C .
ln -s $VMCWORKDIR/macro/run/.rootrc .
ln -s ../macro/redefineDecays.C .

sed -i -- "s~PLUTOFILE~\"$plutoFile\"~g" run_transport.C

elapsed=$SECONDS

echo "Execute: $PWD/run_transport.C"
[ -e $filenum.tra.root ] || root -b -q "run_transport.C ($nEvents, \"$cbm_setup\", \"$filenum\", \"$input_file\")" &> transport.log
#&> /dev/null 
gzip -f transport.log

echo "Execute: $VMCWORKDIR/macro/run/run_digi.C"
[ -e digi.log.gz ] || root -b -q "$VMCWORKDIR/macro/run/run_digi.C ($nEvents, \"$filenum\", 1.e7, 1.e4, kTRUE)" &> digi.log
gzip -f digi.log

echo "Execute: $VMCWORKDIR/macro/run/run_reco_event.C"
[ -e reco.log.gz ] || root -b -q "$out_dir/macro/run_reco_event.C ($nEvents, \"$filenum\", \"$cbm_setup\")" &> reco.log 
gzip -f reco.log

echo "Execute: $VMCWORKDIR/analysis/flow/DataTreeCbmInterface/macro/run_treemaker.C"
[ -e reco.log.gz ] && root -l -b -q "$out_dir/macro/run_treemaker.C ($nEvents, \"$filenum\", \"$cbm_setup\")" &> tree.log
gzip -f tree.log

mv $filenum.tree.root $tree_dir
rm .rootrc
rm redefineDecays.C

[ "$delete_sim_files" = "yes" ] && [ $(( $filenum % 100 )) -ne 0 ] && rm -r $job_out_dir 

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes
