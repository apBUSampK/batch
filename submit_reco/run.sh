#run_simulations=$1
#pbeam=$2
#holeDiameter=$3
#nPSDmodules=$4
#pipeVersion=$5
#partition=$6 # main debug
#nEvents=$7
#jobRange=$8
#mc_generator=$9

#pbeam=3.3
#pbeam=5.36
pbeam=12
holeDiameter=20
nPSDmodules=44 # 44 or 46 or 52
pipeVersion=0
magnetTag="v15a" # v15a or v18a
fieldTag="v12b" # v12b or v18a
use_pluto="yes"
nEvents=1000
jobRange=1-2
postfix=_default_old

#partition=debug
#partition=main
partition=long

#mc_generator=dcmqgsm_abotvina
mc_generator=urqmd
geant_version=TGeant3 # TGeant3 or TGeant4
stepLimiter=1.e7

delete_sim_files="no"

[ "$partition" == "debug" ] && time=0:20:00
[ "$partition" == "main" ] && time=8:00:00
[ "$partition" == "long" ] && time=1-00:00:00

SYSTEM="auau"
CENTRALITY="mbias" 

cbm_setup="sis100_electron"

#root_config="/lustre/nyx/cbm/users/ogolosov/soft/cbmroot/trunk_14034/build/config.sh"
root_config="/lustre/nyx/cbm/users/ogolosov/soft/cbmroot/oct18/build/config.sh"

echo "run_simulations=$run_simulations (use RUN to actually submit jobs)"
echo "pbeam=$pbeam"
echo "holeDiameter=$holeDiameter"
echo "nPSDmodules=$nPSDmodules"
echo "pipeVersion=$pipeVersion"
echo "postfix=$postfix"
echo "partition=$partition"
echo "time=$time"
echo "nEvents=$nEvents"
echo "jobRange=$jobRange"
echo "Setup: $cbm_setup"
echo "geant_version=$geant_version"


mc_generator_version=""
[ "$mc_generator" == "urqmd" ] && mc_generator_version="/v3.4"
[ "$mc_generator" == "dcmqgsm_abotvina" ] && mc_generator_file_name="dcmqgsm"
[ "$mc_generator" == "urqmd" ] && mc_generator_file_name="urqmd"

user_mc_dir="/lustre/nyx/cbm/users/$USER/mc"
input_dir="/lustre/nyx/cbm/users/ogolosov/mc/generators/$mc_generator$mc_generator_version/$SYSTEM/${pbeam}agev/$CENTRALITY/root"
source_dir="$user_mc_dir/macros/submit_reco/"
out_dir="$user_mc_dir/cbmsim/$mc_generator/$SYSTEM/${pbeam}agev/$CENTRALITY/psd${nPSDmodules}_hole${holeDiameter}_pipe${pipeVersion}$postfix/$geant_version"
tree_dir=$out_dir/tree
log_dir="$out_dir/log"

echo "root_config: $root_config"
echo "input_dir: $input_dir"
echo "source_dir: $source_dir"
echo "out_dir: $out_dir"
echo "log_dir: $log_dir"

mkdir -p $log_dir
mkdir -p $out_dir
mkdir -p $out_dir/macro
mkdir -p $tree_dir

job_name="sim_${pbeam}"

[ $nPSDmodules == 44 ] && [ $holeDiameter == 20 ] && psdTag=v18e
[ $nPSDmodules == 44 ] && [ $holeDiameter == 6 ] && psdTag=v18f
[ $nPSDmodules == 44 ] && [ $holeDiameter == 0 ] && psdTag=v18g
[ $nPSDmodules == 52 ] && psdTag=v18h
[ $nPSDmodules == 1 ] && [ $holeDiameter == 20 ] && psdTag=v18i
[ $nPSDmodules == 1 ] && [ $holeDiameter == 6 ] && psdTag=v18j
[ $nPSDmodules == 1 ] && [ $holeDiameter == 0 ] && psdTag=v18k
[ $nPSDmodules == 46 ] && psdTag=v18l

[ $pipeVersion == 0 ] && pipeTag=v16b_1e
[ $pipeVersion == 1 ] && pipeTag=v18a
[ $pipeVersion == 2 ] && pipeTag=v18b
[ $pipeVersion == 3 ] && pipeTag=v18c

echo "psdTag: $psdTag"
echo "pipeTag: $pipeTag"

set_scaling="CbmSetup::Instance()->SetFieldScale(${pbeam} / 12.);"
set_psd="CbmSetup::Instance()->SetModule(kPsd, \"$psdTag\");"
set_pipe="CbmSetup::Instance()->SetModule(kPipe, \"$pipeTag\");"
set_magnet="CbmSetup::Instance()->SetModule(kMagnet, \"$magnetTag\");"
set_field="CbmSetup::Instance()->SetField(\"$fieldTag\", 1., 0., 0., 40.);"
set_setup="$set_psd\n  $set_pipe\n  $set_magnet\n  $set_field\n  $set_scaling\n"
set_pluto="CbmPlutoGenerator* plutoGen = new CbmPlutoGenerator(PLUTOFILE);\n  primGen->AddGenerator(plutoGen);"
redefine_decays="gROOT->LoadMacro(\"redefineDecays.C\");\n  gROOT->ProcessLine(\"redefineDecays()\");"

source $root_config
rsync -v $VMCWORKDIR/macro/run/run_transport.C $out_dir/macro
rsync -v redefineDecays.C $out_dir/macro
sed -i -- "s~TGeant3~$geant_version~g" $out_dir/macro/run_transport.C
sed -i -- "s~// CbmSetup::Instance()->SetActive(ESystemId, Bool_t)~$set_setup~g" $out_dir/macro/run_transport.C
sed -i -- "s~run->Init();~run->Init();\n  TVirtualMC::GetMC()->SetMaxNStep($stepLimiter);\n~g" $out_dir/macro/run_transport.C
[ "$mc_generator" == "urqmd" ] || sed -i -- "s~primGen->SetEventPlane~//primGen->SetEventPlane~g" $out_dir/macro/run_transport.C
[ "$use_pluto" == "yes" ] && sed -i -- "s~run->SetGenerator(primGen);~$set_pluto\n  run->SetGenerator(primGen);~g" $out_dir/macro/run_transport.C
[ "$use_pluto" == "yes" ] && sed -i -- "s~run->Init();~run->Init(); \n  $redefine_decays~g" $out_dir/macro/run_transport.C

rsync -v $VMCWORKDIR/macro/run/run_reco_event.C $out_dir/macro
sed -i -- "s~// CbmSetup::Instance()->SetActive(ESystemId, Bool_t)~$set_setup~g" $out_dir/macro/run_reco_event.C

rsync -v $VMCWORKDIR/analysis/flow/DataTreeCbmInterface/macro/run_treemaker.C $out_dir/macro
sed -i -- "s~// CbmSetup::Instance()->SetActive(ESystemId, Bool_t)~$set_setup~g" $out_dir/macro/run_treemaker.C

run_sim_reco="run_sim_reco.sh"

sbatch -J $job_name --mem=8G -p $partition -t $time -a $jobRange -o $log_dir/%A_%a.o -e $log_dir/%A_%a.e --export=input_dir=$input_dir,out_dir=$out_dir,source_dir=$source_dir,tree_dir=$tree_dir,root_config=$root_config,mc_generator_file_name=$mc_generator_file_name,pbeam=$pbeam,cbm_setup=$cbm_setup,geant_version=$geant_version,nEvents=$nEvents,delete_sim_files=$delete_sim_files $run_sim_reco
