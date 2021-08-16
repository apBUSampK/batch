#!/bin/bash

jobId=${SLURM_ARRAY_JOB_ID}
taskId=${SLURM_ARRAY_TASK_ID}

if [ ${run_transport} == true ]; then
  transport_config=transport_${config}
  cp -v ${transport_out_dir}/${config} ${transport_src_dir}/${transport_config}
  task_dir=${transport_out_dir}/${taskId}
  job_log_dir=${transport_out_dir}/log_${jobId}
  log=${job_log_dir}/${taskId}.tra.log
  mkdir -pv ${job_log_dir}
  mkdir -pv ${task_dir}
  cd ${task_dir}
  ln -sf ${VMCWORKDIR}/macro/run/.rootrc .
  echo root -b -l -q "${job_transport_macro}(\"${job_config}\",${nEvents})" &> ${log}
  gzip -f ${log} 
  rm .rootrc
fi


#if [ ${run_reconstruction} == true ]; then
#  input=$(getJsonVal "['reconstruction']['input']")
#  nTimeSlices=$(getJsonVal "['reconstruction']['nTimeSlices']")
#  firstTimeSlice=$(getJsonVal "['reconstruction']['firstTimeSlice']")
#  outputReco=$(getJsonVal "['reconstruction']['output']['path']")
#  overwriteReco=$(getJsonVal "['reconstruction']['output']['overwrite']")
#  sEvBuildRaw=$(getJsonVal "['reconstruction']['sEvBuildRaw']")
#  paramFile=$(getJsonVal "['reconstruction']['paramFile']")
#  useMC=$(getJsonVal "['reconstruction']['useMC']")
#  root -b -l -q "${reco_macro}(${input},${nTimeSlices},${firstTimeSlice},${outputReco},${overwriteReco},${sEvBuildRaw},\"${config}\",${paramFile},${useMC})"
#fi
#
#if [ ${run_AT} == true ]; then
#  traPath=$(getJsonVal "['AT']['traPath']")
#  rawPath=$(getJsonVal "['AT']['rawPath']")
#  recPath=$(getJsonVal "['AT']['recPath']")
#  geoPath=$(getJsonVal "['AT']['geoPath']")
#  parPath=$(getJsonVal "['AT']['parPath']")
#  unigenFile=$(getJsonVal "['AT']['unigenFile']")
#  outputAT=$(getJsonVal "['AT']['output']['path']")
#  overwriteAT=$(getJsonVal "['AT']['output']['overwrite']")
#  root -b -l -q "${AT_macro}(${traPath},${rawPath},${recPath},${geoPath},${parPath},${unigenFile},${oututAT},${overwriteAT},\"${config}\",${nEvents})"
#fi
