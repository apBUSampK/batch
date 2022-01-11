#!/bin/bash

steps="transport digitization reconstruction AT"
source ${cbmRoot}
for step in ${steps}; do
  read_step_info
  if [ ${run} == true ]; then
    export taskId=${SLURM_ARRAY_TASK_ID}
    config=${src_dir}/${config_name}
    macro=${src_dir}/${macro_name}
    out_path=$(getJsonVal "['${step}']['output']['path']")
    log=${out_path}.${step}.log
    out_dir=$(dirname ${out_path})
    mkdir -pv ${out_dir}
    cd ${out_dir}
    ln -sf ${VMCWORKDIR}/macro/run/.rootrc .
    if [ ${step} == reconstruction ]; then
      input=$(getJsonVal "['reconstruction']['input']")
      nTimeSlices=$(getJsonVal "['reconstruction']['nTimeSlices']")
      firstTimeSlice=$(getJsonVal "['reconstruction']['firstTimeSlice']")
      overwrite=$(getJsonVal "['reconstruction']['output']['overwrite']")
      sEvBuildRaw=$(getJsonVal "['reconstruction']['sEvBuildRaw']")
      paramFile=$(getJsonVal "['reconstruction']['paramFile']")
      useMC=$(getJsonVal "['reconstruction']['useMC']")
      root -b -l -q "${macro}(\"${input}\",${nTimeSlices},${firstTimeSlice},\"${out_path}\",\
        ${overwrite},\"${sEvBuildRaw}\",\"${config}\",\"${paramFile}\",${useMC})" &> ${log}
    elif [ ${step} == AT ]; then
      traPath=$(getJsonVal "['AT']['traPath']")
      rawPath=$(getJsonVal "['AT']['rawPath']")
      recPath=$(getJsonVal "['AT']['recPath']")
      geoPath=$(getJsonVal "['AT']['geoPath']")
      parPath=$(getJsonVal "['AT']['parPath']")
      unigenFile=$(getJsonVal "['AT']['unigenFile']")
      overwrite=$(getJsonVal "['AT']['output']['overwrite']")
      root -b -l -q "${macro}(\"${traPath}\",\"${rawPath}\",\"${recPath}\",\"${geoPath}\",\"${parPath}\",\
	\"${unigenFile}\",\"${out_path}\",${overwrite},\"${config}\",${nEvents})" &> ${log}
    else 
      root -b -l -q "${macro}(\"${config}\",${nEvents})" &> ${log}
    fi
    gzip -f ${log}
    rm .rootrc *{moni,Fair,TR,L1,Edep}* 
    cd -
    export taskId=
  fi
done
