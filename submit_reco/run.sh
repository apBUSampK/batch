#pbeam=3.3
#pbeam=5.36
pbeam=12
#pbeam=40
#pbeam=158
batch=1
export nEvents=1
jobRange=1-1
export run_transport=1
export run_digi=1
export run_reco=1
export run_treemaker=1
holeDiameter=20 # 0 or 6 or 20
nPSDmodules=44 # 44 or 46 or 52
#pipeVersion=0
#mvd=0
#psd=0
targetThickness=25 # mkm 
#postfix=_test
release=apr20
build=fr_18.2.1_fs_jun19p1

#partition=debug
partition=main
#partition=long
 
geant_version=4
physicsList=FTFP_BERT_EMV
main_input=dcmqgsm_smm
#main_input=dcmqgsm_smm_pluto
#main_input=urqmd
#main_input=pluto
#main_input=eDelta
#emb_input=pluto
#bg_input=eDelta
export pluto_signal=w
#export pluto_signal=wdalitz
#export pluto_signal=phi
#export pluto_signal=etaP
#export pluto_signal=rho0
#export pluto_signal=inmed_had_epem_12gev
#export pluto_signal=qgp_epem_12gev
urqmd_eos=0
embed_pluto_during_transport=1

export delete_sim_files=0

[ ${partition} == debug ] && time=0:20:00
[ ${partition} == main ] && time=8:00:00
[ ${partition} == long ] && time=1-00:00:00

system=auau
centrality=mbias 

export base_setup=sis100_electron
#export base_setup=sis100_electron_sts_long


cbmroot_config=/lustre/cbm/users/ogolosov/soft/cbmroot/${release}/${build}/config.sh

#choose psd tag
[ $nPSDmodules == 44 ] && [ $holeDiameter == 20 ] && psdTag=v18e
[ $nPSDmodules == 44 ] && [ $holeDiameter == 6 ] && psdTag=v18f
[ $nPSDmodules == 44 ] && [ $holeDiameter == 0 ] && psdTag=v18g
[ $nPSDmodules == 52 ] && holeDiameter=20 && psdTag=v18h
[ $nPSDmodules == 1 ] && [ $holeDiameter == 20 ] && psdTag=v18i
[ $nPSDmodules == 1 ] && [ $holeDiameter == 6 ] && psdTag=v18j
[ $nPSDmodules == 1 ] && [ $holeDiameter == 0 ] && psdTag=v18k
[ $nPSDmodules == 46 ] && holeDiameter=20 && psdTag=v18l
#choose pipe tag
#[ $pipeVersion == 0 ] && pipeTag=v16b_1e
#[ $pipeVersion == 1 ] && pipeTag=v18a
#[ $pipeVersion == 2 ] && pipeTag=v18b
#[ $pipeVersion == 3 ] && pipeTag=v18c

#change geometry if needed
setup=${base_setup}
[ ${targetThickness} != "" ] && setup=${setup}_target_${targetThickness}_mkm
if [ ${psdTag} != v18e ];then
  setup=${setup}_psd_${psdTag}
  set_psd="CbmSetup::Instance()->SetModule(ECbmModuleId::kPsd, \"${psdTag}\");\n  "
fi
#if [ ${pipeTag} != v16b_1e ];then
#  setup=${setup}_pipe_${pipeTag}
#set_pipe="CbmSetup::Instance()->SetModule(ECbmModuleId::kPipe, \"${pipeTag}\");\n  "
#fi
if [ ${mvd} == 0 ];then
  setup=${setup}_no_mvd
  set_mvd="CbmSetup::Instance()->RemoveModule(ECbmModuleId::kMvd);\n  "
fi
if [ ${psd} == 0 ];then
  setup=${setup}_no_psd
  set_psd="CbmSetup::Instance()->RemoveModule(ECbmModuleId::kPsd);\n  "
fi
[ ${physicsList} != "" ] && setup=${setup}_${physicsList}
#[ ${main_input} == eDelta ] && set_psd="CbmSetup::Instance()->RemoveModule(ECbmModuleId::kMvd);\n  " #prevent psd response to beam nuclei
set_scaling="CbmSetup::Instance()->SetFieldScale(${pbeam} / 12.);"
set_setup="${set_mvd}${set_psd}${set_pipe}${set_scaling}"

#construct input and folder names
main_input_version=""
eos=""
[ ${main_input} == urqmd ] && main_input_version='/v3.4' && eos=_eos${urqmd_eos} && main_input_file_name=urqmd
[ ${main_input} == dcmqgsm_smm ] && main_input_file_name=dcmqgsm
if [ ${main_input} == pluto ] && main_input_file_name=${pluto_signal}


user_mc_dir=/lustre/cbm/users/${USER}/mc
export input_file=/lustre/cbm/users/ogolosov/mc/generators/${main_input}${main_input_version}/${system}/pbeam${pbeam}agev${eos}/${centrality}/root/${main_input_file_name}_

[ ${embed_pluto_during_transport} == 1 ] && main_input=${main_input}_pluto

export source_dir=${user_mc_dir}/macros/submit_reco/
pre_out_dir=${user_mc_dir}/cbmsim/${release}_${build}
post_out_dir=${system}/${pbeam}agev/${centrality}/${setup}${postfix}/TGeant${geant_version}
export main_input_dir=${pre_out_dir}/${main_input}/${post_out_dir}
export emb_input_dir=${pre_out_dir}/${emb_input}/${post_out_dir}
export bg_input_dir=${pre_out_dir}/${bg_input}/${post_out_dir}
suppl_inputs=( ${emb_input} ${bg_input} )
input=${main_input}
for i in ${suppl_inputs[@]};do input=${input}_${i};done
export out_dir=${pre_out_dir}/${input}/${post_out_dir}
export tree_dir=${out_dir}/tree
log_dir=${out_dir}/log

echo cbmroot_config: ${cbmroot_config}
echo input_file: ${input_file}
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
mkdir -p ${tree_dir}
source ${cbmroot_config}

#make local copies of macros and scripts
rsync -v run.sh ${out_dir}/macro
rsync -v run_sim_reco.sh ${out_dir}/macro


if [ ${run_transport} == 1 ] || [ ${run_treemaker} == 1 ];then
  #make local copy of transport macro
  rsync -v ${VMCWORKDIR}/macro/run/run_transport.C ${out_dir}/macro
  
  #shift target and beam in case of sis100_electron_sts_long setup
  if [ ${base_setup} == sis100_electron_sts_long ]
  then
    sed -i -- 's~run.SetTarget("Gold", 0.025, 2.5);~run.SetTarget("Gold", 0.025, 2.5, 0., 0., -4.);~g' ${out_dir}/macro/run_transport.C
    sed -i -- 's~run.SetBeamPosition(0., 0., 0.1, 0.1);~run.SetBeamPosition(0., 0., 0.1, 0.1, -4.);~g' ${out_dir}/macro/run_transport.C
  fi
  #change target thickness
  [ ${targetThickness} != "" ] && sed -i -- "s~run.SetTarget(\"Gold\", 0.025~run.SetTarget(\"Gold\", $(printf "0.%04d" ${targetThickness})~g" ${out_dir}/macro/run_transport.C
  #change geometry setup
  sed -i -- "s~run.Run(nEvents);~${set_setup}\n  run.Run(nEvents);~g" ${out_dir}/macro/run_transport.C
  #for some reason geo files do not survive but are needed for the converter
  cd ${out_dir}/macro
  root -b -q "run_transport.C (0, \"${base_setup}\")" &> transport.log
  cd -
  #set geant version
  sed -i -- "s~run.Run(nEvents);~run.SetEngine(kGeant${geant_version});\n  run.Run(nEvents);\n~g" ${out_dir}/macro/run_transport.C
  #change Geant4 physics list
  g4settings="CbmGeant4Settings* g4Settings = new CbmGeant4Settings();\n  g4Settings->SetG4RunConfig(\"geomRoot\",\"${physicsList}+optical\",\"stepLimiter\");\n  g4Settings->AddG4Command(\"/mcVerbose/all 2\");\n  run.SetGeant4Settings(g4Settings);\n"
  [ ${physicsList} != "" ] && sed -i -- "s~run.SetEngine(kGeant4);~${g4settings}  run.SetEngine(kGeant4);~g" ${out_dir}/macro/run_transport.C
  #change generator type if pluto is the main input
  [ ${main_input} == pluto ] && sed -i -- 's~run.AddInput(inFile);~run.AddInput(inFile,kPluto);~g' ${out_dir}/macro/run_transport.C
  #change generator type if eDelta is the main input
  if [ ${main_input} == eDelta ];then
    nIons=1
    [ ${base_setup} == sis100_electron_sts_long ] && Ztarget=-5. || Ztarget=-1.
    sed -i -- "s~run.AddInput(inFile);~run.AddInput(new FairIonGenerator(79, 197, 79, ${nIons}, 0., 0., ${pbeam}, 0., 0., ${Ztarget}));~g" ${out_dir}/macro/run_transport.C
  fi
  #seed the random number generator
  seed=0 # may be constant or e.g. TASKID
  sed -i -- "s~run.Run(nEvents);~gRandom->SetSeed(${seed});\n  run.Run(nEvents);~g" ${out_dir}/macro/run_transport.C
  #embed pluto on transport stage
  if [ ${embed_pluto_during_transport} == 1 ];then
    registerDileptons='FairRunSim::Instance()->AddNewParticle(new FairParticle(99009911,"dielectron",kPTUndefined,2*TDatabasePDG::Instance()->GetParticle(11)->Mass(),0.,0.,"dilepton", 0., 1, 1, 0, 1, 1, 0, 0, 1, true));\n  FairRunSim::Instance()->AddNewParticle(new FairParticle(99009913,"dimuon",kPTUndefined,2*TDatabasePDG::Instance()->GetParticle(13)->Mass(),0.,0.,"dilepton", 0., 1, 1, 0, 1, 1, 0, 0, 1, true));'
    sed -i -- "s~run.AddInput(inFile);~run.AddInput(inFile);\n  run.AddInput(PLUTOFILE, kPluto);~g" ${out_dir}/macro/run_transport.C
    sed -i -- "s~run.Run(nEvents);~${registerDileptons}\n  run.Run(nEvents);~g" ${out_dir}/macro/run_transport.C
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
  sed -i -- "s~// CbmSetup::Instance()->SetActive(EsystemId, Bool_t)~${set_setup}~g" $out_dir/macro/run_reco_event.C
  #set paths to transport and parameter files produced in case of embedding on digitization stage
  if [ ! -z ${emb_input} ] || [ ! -z ${bg_input} ];then
    sed -i -- "s~dataset + \".tra.root\"~\"${main_input_dir}/TASKID/TASKID.tra.root\"~g" ${out_dir}/macro/run_reco_event.C
    sed -i -- "s~dataset + \".par.root\"~\"${main_input_dir}/TASKID/TASKID.par.root\"~g" ${out_dir}/macro/run_reco_event.C
  fi
fi

if [ ${run_treemaker} == 1 ];then 
  #make local copy of converter macro
  rsync -v ${VMCWORKDIR}/analysis/PWGC2F/flow/DataTreeCbmInterface/macro/run_treemaker.C ${out_dir}/macro
  #change geometry setup
  sed -i -- "s~// CbmSetup::Instance()->SetActive(EsystemId, Bool_t)~${set_setup}~g" $out_dir/macro/run_treemaker.C
  #set paths to transport, geometry and parameter files produced in case of embedding on digitization stage
  if [ ! -z ${emb_input} ] || [ ! -z ${bg_input} ];then
    sed -i -- "s~dataSet + \".tra.root\"~\"${main_input_dir}/TASKID/TASKID.tra.root\"~g" ${out_dir}/macro/run_treemaker.C
    sed -i -- "s~dataSet + \".par.root\"~\"${main_input_dir}/TASKID/TASKID.par.root\"~g" ${out_dir}/macro/run_treemaker.C
  fi
  sed -i -- "s~dataSet + \".geo.root\"~\"${main_input_dir}/macro/test.geo.root\"~g" ${out_dir}/macro/run_treemaker.C
fi

#report changes in cbmroot
#svn diff ${VMCWORKDIR} > ${out_dir}/macro/cbmroot.diff

job_name=sim_${pbeam}

if [ ${batch} == 0 ];then
  export SLURM_ARRAY_TASK_ID=${jobRange}
  . run_sim_reco.sh &
fi
[ ${batch} == 1 ] && sbatch --mem=8G -J ${job_name} -a ${jobRange} -p ${partition} -t ${time} -o ${log_dir}/%a_%A.o -e ${log_dir}/%a_%A.e run_sim_reco.sh
