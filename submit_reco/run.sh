#!/bin/bash

#pbeam=3.3
#pbeam=5.36
pbeam=12
#pbeam=40
#pbeam=158

batch=1
export nEvents=1000
jobRange=1-50
export run_transport=1
export run_digi=1
export run_reco=1
export run_treemaker=1
export run_at_maker=1
postfix= #_test
release=apr20
build=fr_18.2.1_fs_jun19p1

#partition=debug
#partition=main
partition=long
 
geant_version=4

main_input=dcmqgsm_smm
#main_input=phsd
#main_input=dcmqgsm_smm_pluto
#main_input=urqmd
#main_input=pluto
#main_input=eDelta

centrality=mbias 
#centrality=centr_0_10

#emb_input=pluto
#bg_input=eDelta

export pluto_signal=w # 1-1000 # 1-500
#export pluto_signal=wdalitz # 1001-2000 # 501-1000
#export pluto_signal=etap # 2001-3000 # 1001-1500
#export pluto_signal=phi # 3001-4000 # 1501-2000
#export pluto_signal=rho0 # 4001-5000 # 2001-2500
#export pluto_signal=inmed_had_epem # 5001-7500 # 2501-3750
#export pluto_signal=qgp_epem # 7501-10000 # 3751-5000

export offset=0

embed_pluto_during_transport=1

system=auau

urqmd_eos=0

export base_setup=sis100_electron
#export base_setup=sis100_electron_sts_long

#field_scale=0.56 # optional, otherwise set to pbeam/12
#mvd=0 #optional
#psd=0 #optional
targetThickness=25 # mkm - optional 

# PSD tag - optional
#psdTag=v18f # 44 modules 6 cm hole
#psdTag=v18g # 44 modules no hole
#psdTag=v18h # 52 modules
#psdTag=v18i # ideal 20 cm hole
#psdTag=v18j # ideal 6 cm hole
#psdTag=v18k # ideal no hole
#psdTag=v18l # 46 modules
#psdTag=v18e_p3.3_45 # 44 modules 20 cm hole (45% field at 3.3 agev)
#psdTag=v18e_p3.3_56 # 44 modules 20 cm hole (56% field at 3.3 agev)
psdTag=v18e_z_10.5 # 44 modules 20 cm hole (10.5 m from target)
#psdTag=v18e_p3.3_45_z_10.5 # 44 modules 20 cm hole (10.5 m from target, 45% field at 3.3 agev)
#psdTag=v18e_p3.3_56_z_10.5 # 44 modules 20 cm hole (10.5 m from target, 56% field at 3.3 agev)

# PIPE tag - optional
#pipeTag=v18a
#pipeTag=v18b
#pipeTag=v18c

# TOF tag - optional
tofTag=v16d_1e_z_6.9

# Physics list - optional
#physicsList=FTFP_BERT_EMV
#physicsList=QGSP_BERT
#physicsList=QGSP_BERT_EMV
#physicsList=QGSP_BIC
#physicsList=QGSP_FTFP_BERT_EMV
#physicsList=QGSP_INCLXX

export delete_sim_files=0

cbmroot_config=/lustre/cbm/users/ogolosov/soft/cbmroot/${release}/${build}/bin/CbmRootConfig.sh
export cbmroot_with_AT_config=/lustre/cbm/users/ogolosov/soft/cbmroot/trunk/fr_18.2.1_fs_jun19p1/install/bin/CbmRootConfig.sh
source_dir=/lustre/cbm/users/${USER}/mc/macros/submit_reco/
user_mc_dir=/lustre/cbm/users/${USER}/mc

batch_script=${source_dir}/run_sim_reco.sh

[ ${partition} == debug ] && time=0:20:00
[ ${partition} == main ] && time=8:00:00
[ ${partition} == long ] && time=1-00:00:00

#change geometry if needed
setup=${base_setup}
[ ! -z ${targetThickness} ] && setup=${setup}_target_${targetThickness}_mkm
if [ ! -z ${tofTag} ];then
  setup=${setup}_tof_${tofTag}
  set_tof="CbmSetup::Instance()->SetModule(ECbmModuleId::kTof, \"${tofTag}\");\n  "
fi
if [ ! -z ${psdTag} ];then
  setup=${setup}_psd_${psdTag}
  set_psd="CbmSetup::Instance()->SetModule(ECbmModuleId::kPsd, \"${psdTag}\");\n  "
fi
if [ ! -z ${pipeTag} ];then
  setup=${setup}_pipe_${pipeTag}
set_pipe="CbmSetup::Instance()->SetModule(ECbmModuleId::kPipe, \"${pipeTag}\");\n  "
fi
if [ ! -z ${mvd} ] && [ ${mvd} == 0 ];then
  setup=${setup}_no_mvd
  set_mvd="CbmSetup::Instance()->RemoveModule(ECbmModuleId::kMvd);\n  "
fi
if [ ! -z ${psd} ] && [ ${psd} == 0 ];then
  setup=${setup}_no_psd
  set_psd="CbmSetup::Instance()->RemoveModule(ECbmModuleId::kPsd);\n  "
fi
[ -z ${field_scale} ] && field_scale=$(echo "${pbeam}" | awk '{print $pbeam/12}') 
[ ${field_scale} != 1 ] && postfix=${postfix}_MF_$(echo "${field_scale}" | awk '{print $field_scale*100}')
set_scaling="CbmSetup::Instance()->SetFieldScale(${field_scale});"
set_setup="${set_mvd}${set_tof}${set_psd}${set_pipe}${set_scaling}"

#construct input and folder names
main_input_version=""
eos=""
[ ${main_input} == urqmd ] && main_input_version=v3.4 && eos=_eos${urqmd_eos} && main_input_file_name=urqmd
[ ${main_input} == phsd ] && main_input_version=40csr && eos=_qgp_w && main_input_file_name=phsd
[ ${main_input} == dcmqgsm_smm ] && main_input_file_name=dcmqgsm

export inputFile=/lustre/cbm/users/ogolosov/mc/generators/${main_input}/${main_input_version}/${system}/pbeam${pbeam}agev${eos}/${centrality}/root/${main_input_file_name}

export plutoPath=/lustre/cbm/users/ogolosov/mc/generators/pluto/${system}/pbeam${pbeam}agev/${pluto_signal}/${pluto_signal}
[ ${main_input} == pluto ] && export inputFile=${plutoPath}
[ ${embed_pluto_during_transport} == 1 ] && main_input=${main_input}_pluto_${pluto_signal}

pre_out_dir=${user_mc_dir}/cbmsim/${release}_${build}
post_out_dir=${system}/${pbeam}agev/${centrality}/${setup}${postfix}/TGeant${geant_version}
[ ! -z ${physicsList} ] && post_out_dir=${post_out_dir}_${physicsList}
export main_input_dir=${pre_out_dir}/${main_input}/${post_out_dir}
export emb_input_dir=${pre_out_dir}/${emb_input}/${post_out_dir}
export bg_input_dir=${pre_out_dir}/${bg_input}/${post_out_dir}
suppl_inputs=( ${emb_input} ${bg_input} )
input=${main_input}
for i in ${suppl_inputs[@]};do input=${input}_${i};done
export out_dir=${pre_out_dir}/${input}/${post_out_dir}
export tree_dir=${out_dir}/tree
export atree_dir=${out_dir}/atree
log_dir=${out_dir}/log

echo cbmroot_config: ${cbmroot_config}
echo inputFile: ${inputFile}
echo emb_input_dir: ${emb_input_dir}
echo bg_input_dir: ${bg_input_dir}
echo source_dir: ${source_dir}
echo out_dir: ${out_dir}
echo log_dir: ${log_dir}
echo pbeam: ${pbeam}
echo holeDiameter: ${holeDiameter}
echo nPSDmodules: ${nPSDmodules}
echo psdTag: ${psdTag}
echo pipeVersion: ${pipeVersion}
echo pipeTag: ${pipeTag}
echo Setup: ${base_setup}
echo Setup change: ${set_setup}
echo geant_version: ${geant_version}
echo postfix: ${postfix}
echo partition: ${partition}
echo time: ${time}
echo nEvents: ${nEvents}
echo jobRange: ${jobRange}
echo run_transport: ${run_transport}
echo run_digi: ${run_digi}
echo run_reco: ${run_reco}
echo run_treemaker: ${run_treemaker}

#create needed folders
mkdir -p ${out_dir}
mkdir -p ${out_dir}/macro
mkdir -p ${log_dir}
source ${cbmroot_config}

#make local copies of macros and scripts
rsync -v $0 ${out_dir}/macro
rsync -v ${batch_script} ${out_dir}/macro

if [ ${run_transport} == 1 ] || [ ${run_treemaker} == 1 ];then
  #make local copy of transport macro
  rsync -v ${VMCWORKDIR}/macro/run/run_transport.C ${out_dir}/macro
  
  #set target and beam properties
  Ztarget=0. && Zbeam=-1.
  [ ${base_setup} == sis100_electron_sts_long ] && Ztarget=-4. && Zbeam=-5.
  sed -i -- "s~run.SetTarget(\"Gold\", 0.025, 2.5);~run.SetTarget(\"Gold\", $(printf "0.%04d" ${targetThickness}), 2.5, 0., 0., ${Ztarget});~g" ${out_dir}/macro/run_transport.C
  sed -i -- "s~run.SetBeamPosition(0., 0., 0.1, 0.1);~run.SetBeamPosition(0., 0., 0.1, 0.1, ${Zbeam});~g" ${out_dir}/macro/run_transport.C
  #change geometry setup
  sed -i -- "s~run.Run(nEvents);~${set_setup}\n  run.Run(nEvents);~g" ${out_dir}/macro/run_transport.C
  #for some reason geo files do not survive but are needed for the converter
  cd ${out_dir}/macro
  root -b -q "run_transport.C (0, \"${base_setup}\")" &> transport.log
  cd -
  #set geant version
  sed -i -- "s~run.Run(nEvents);~run.SetEngine(kGeant${geant_version});\n  run.Run(nEvents);\n~g" ${out_dir}/macro/run_transport.C
  #change Geant4 physics list
  g4settings="CbmGeant4Settings* g4Settings = new CbmGeant4Settings();\n  g4Settings->SetG4RunConfig(\"geomRoot\",\"${physicsList}+optical\",\"stepLimiter\");\n  run.SetGeant4Settings(g4Settings);\n"
  [ ! -z ${physicsList} ] && sed -i -- "s~run.SetEngine(kGeant4);~${g4settings}  run.SetEngine(kGeant4);~g" ${out_dir}/macro/run_transport.C
  #change generator type if pluto is the main input
  [ ${main_input} == pluto ] && sed -i -- 's~run.AddInput(inFile);~run.AddInput(inFile, kPluto);~g' ${out_dir}/macro/run_transport.C
  #change generator type if eDelta is the main input
  if [ ${main_input} == eDelta ];then
    nIons=1
    sed -i -- "s~run.AddInput(inFile);~run.AddInput(new FairIonGenerator(79, 197, 79, ${nIons}, 0., 0., ${pbeam}, 0., 0., ${Zbeam}));~g" ${out_dir}/macro/run_transport.C
  fi
  #seed the random number generator
  seed=0 # may be constant or e.g. TASKID
  sed -i -- "s~run.Run(nEvents);~gRandom->SetSeed(${seed});\n  run.Run(nEvents);~g" ${out_dir}/macro/run_transport.C
  #add pluto file
  if [ ${embed_pluto_during_transport} == 1 ]
  then
    pluto_PID=''
    [ ${pluto_signal} == inmed_had_epem ] && pluto_PID='pluto_gen->SetManualPDG(99009011);'
    [ ${pluto_signal} == qgp_epem ] && pluto_PID='pluto_gen->SetManualPDG(99009111);'
    pluto_input="CbmPlutoGenerator *pluto_gen= new CbmPlutoGenerator(PLUTOFILE);\n  ${pluto_PID}\n  run.AddInput(pluto_gen);"
    sed -i -- "s~run.AddInput(inFile);~${pluto_input}\n  run.AddInput(inFile);~g" ${out_dir}/macro/run_transport.C
  fi
fi

if [ ${run_digi} == 1 ];then 
  #make local copy of digitization macro
  rsync -v ${VMCWORKDIR}/macro/run/run_digi.C ${out_dir}/macro
  #embed anything on digitization stage
  path_to_emb_file=${emb_input_dir}/TASKID/TASKID.tra.root
  [ ! -z ${emb_input} ] && sed -i -- "s~run.AddInput(inFile, eventRate);~run.AddInput(inFile, eventRate);\n  run.EmbedInput(1, \"${path_to_emb_file}\", 0, ECbmTreeAccess::kRegular);~g" ${out_dir}/macro/run_digi.C
  #simulate background in MVD
  if [ ! -z ${bg_input} ];then 
    nEventsDelta=$(expr ${nEvents} \* 10)
    nEventsBg=${nEvents}
    nPileUpBg=0
    nPileUpDelta=50
    verbosity=0
    deltaFile=${bg_input_dir}/TASKID/TASKID.tra.root
    setup_mvd_digitizer="CbmMvdDigitizer* mvdDigi = new CbmMvdDigitizer (\"MVDDigitiser\", 0, ${verbosity});\n  mvdDigi->SetBgFileName(inFile);\n  mvdDigi->SetBgBufferSize(${nEventsBg});\n  mvdDigi->SetDeltaName(\"${deltaFile}\");\n  mvdDigi->SetDeltaBufferSize(${nEventsDelta});\n  mvdDigi->SetPileUp(${nPileUpBg});\n  mvdDigi->SetDeltaEvents(${nPileUpDelta});\n  run.SetDigitizer(ECbmModuleId::kMvd, mvdDigi);\n"
    sed -i -- "s~run.Run(nEvents);~${setup_mvd_digitizer}  run.Run(nEvents);~g" ${out_dir}/macro/run_digi.C
  fi
  #set paths to transport and parameter files produced in case of embedding on digitization stage
  if [ ! -z ${emb_input} ] || [ ! -z ${bg_input} ];then
    sed -i -- "s~dataSet + \".tra.root\"~\"${main_input_dir}/TASKID/TASKID.tra.root\"~g" ${out_dir}/macro/run_digi.C
    sed -i -- "s~dataSet + \".par.root\"~\"${main_input_dir}/TASKID/TASKID.par.root\"~g" ${out_dir}/macro/run_digi.C
  fi
fi

if [ ${run_reco} == 1 ];then 
  #make local copy of reconstruction macro
  rsync -v ${VMCWORKDIR}/macro/run/run_reco_event.C ${out_dir}/macro
  #change geometry setup
  sed -i -- "s~// CbmSetup::Instance()->SetActive(ESystemId, Bool_t)~${set_setup}~g" $out_dir/macro/run_reco_event.C
  #set paths to transport and parameter files produced in case of embedding on digitization stage
  if [ ! -z ${emb_input} ] || [ ! -z ${bg_input} ];then
    sed -i -- "s~dataset + \".tra.root\"~\"${main_input_dir}/TASKID/TASKID.tra.root\"~g" ${out_dir}/macro/run_reco_event.C
    sed -i -- "s~dataset + \".par.root\"~\"${main_input_dir}/TASKID/TASKID.par.root\"~g" ${out_dir}/macro/run_reco_event.C
  fi
fi

if [ ${run_treemaker} == 1 ];then 
  mkdir -p ${tree_dir}
  #make local copy of converter macro
  rsync -v ${VMCWORKDIR}/macro/run/run_treemaker.C ${out_dir}/macro
  #change geometry setup
  sed -i -- "s~// CbmSetup::Instance()->SetActive(ESystemId, Bool_t)~${set_setup}~g" $out_dir/macro/run_treemaker.C
  #set paths to transport, geometry and parameter files produced in case of embedding on digitization stage
  if [ ! -z ${emb_input} ] || [ ! -z ${bg_input} ];then
    sed -i -- "s~dataSet + \".tra.root\"~\"${main_input_dir}/TASKID/TASKID.tra.root\"~g" ${out_dir}/macro/run_treemaker.C
    sed -i -- "s~dataSet + \".par.root\"~\"${main_input_dir}/TASKID/TASKID.par.root\"~g" ${out_dir}/macro/run_treemaker.C
  fi
  sed -i -- "s~dataSet + \".geo.root\"~\"${main_input_dir}/macro/test.geo.root\"~g" ${out_dir}/macro/run_treemaker.C
fi

if [ ${run_at_maker} == 1 ];then 
  mkdir -p ${atree_dir}
  . ${cbmroot_with_AT_config} 
  #make local copy of converter macro
  rsync -v ${source_dir}/defineDileptons.C ${out_dir}/macro
  rsync -v ${VMCWORKDIR}/macro/analysis_tree/run_analysis_tree_maker.C ${out_dir}/macro
  #change collision info
  sed -i -- "s~12.~${pbeam}.~g" ${out_dir}/macro/run_analysis_tree_maker.C
  #sed -i -- "s~Au+Au~${system}~g" $out_dir/macro/run_analysis_tree_maker.C
  #change geometry setup
  sed -i -- "s~CbmSetup* setup = CbmSetup::Instance();~CbmSetup* setup = CbmSetup::Instance();\n${set_setup}~g" $out_dir/macro/run_analysis_tree_maker.C
  sed -i -- "s~run->Init();~run->Init();\n  gROOT->ProcessLine(\".x ../macro/defineDileptons.C\");~g" $out_dir/macro/run_analysis_tree_maker.C
  #set paths to transport, geometry and parameter files produced in case of embedding on digitization stage
  if [ ! -z ${emb_input} ] || [ ! -z ${bg_input} ];then
    sed -i -- "s~dataSet + \".tra.root\"~\"${main_input_dir}/TASKID/TASKID.tra.root\"~g" ${out_dir}/macro/run_analysis_tree_maker.C
    sed -i -- "s~dataSet + \".par.root\"~\"${main_input_dir}/TASKID/TASKID.par.root\"~g" ${out_dir}/macro/run_analysis_tree_maker.C
  fi
  sed -i -- "s~dataSet + \".geo.root\"~\"${main_input_dir}/macro/test.geo.root\"~g" ${out_dir}/macro/run_analysis_tree_maker.C
  . ${cbmroot_config} 
fi

job_name=sim_${pbeam}

if [ ${batch} == 0 ];then
  export SLURM_ARRAY_TASK_ID=${jobRange}
  . ${batch_script} &
fi
[ ${batch} == 1 ] && sbatch -A cbm --mem=12G -J ${job_name} -a ${jobRange} -p ${partition} -t ${time} -o ${log_dir}/%a_%A.log -- ${batch_script}
