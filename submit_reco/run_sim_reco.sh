#!/bin/bash

jobId=${SLURM_ARRAY_JOB_ID}
taskId=${SLURM_ARRAY_TASK_ID}

if [ ${run_transport} == true ]; then
  config=$(ls ${transport_out_dir}/*.json) 
  job_src_dir=$(dirname ${transport_macro})/${jobId}
  job_transport_macro=${job_src_dir}/$(basename ${transport_macro})
  job_config=${job_src_dir}/$(basename ${config})
  mkdir -pv ${job_src_dir}
  mv -v ${transport_macro} ${job_transport_macro}
  mv -v ${config} ${job_config}
  task_dir=${transport_out_dir}/${taskId}
  job_log_dir=${transport_out_dir}/log_${jobId}
  log=${job_log_dir}/${taskId}.tra.log
  mkdir -p ${job_log_dir}
  mkdir -p ${task_dir}
  #cd ${task_dir}
  ln -sf ${VMCWORKDIR}/macro/run/.rootrc .
  root -b -l -q "${job_transport_macro}(\"${job_config}\",${nEvents})" &> ${log}
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
