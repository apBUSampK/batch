#!/bin/bash

steps="transport digitization reconstruction AT"
source ${cbmRoot}
for step in ${steps}; do
  readStepInfo
  if [ ${run} == true ]; then
    export taskId=${SLURM_ARRAY_TASK_ID}
    plutoShift=$(getJsonVal "['accessory']['transport']['plutoShift']")
    export plutoFileId=$(printf %05d $((${taskId}-${plutoShift})))
    config=${srcDir}/${configName}
    macro=${srcDir}/${macroName}
    outFile=$(getJsonVal "['${step}']['output']['path']")
    log=${outFile}.${step}.log
    outDir=$(dirname ${outFile})
    
    mkdir -pv ${outDir}
    cd ${outDir}
    ln -sfv ${VMCWORKDIR}/macro/run/.rootrc ${outDir} 
    if [ ${step} == reconstruction ]; then
      rawFile=$(getJsonVal "['reconstruction']['rawFile']")
      nTimeSlices=$(getJsonVal "['reconstruction']['nTimeSlices']")
      firstTimeSlice=$(getJsonVal "['reconstruction']['firstTimeSlice']")
      sEvBuildRaw=$(getJsonVal "['reconstruction']['sEvBuildRaw']")
      traFile=$(getJsonVal "['reconstruction']['traFile']")
      useMC=$(getJsonVal "['reconstruction']['useMC']")
      root -b -l -q "${macro}(\"${rawFile}\",${nTimeSlices},${firstTimeSlice},\"${outFile}\",\
        ${overwrite},\"${sEvBuildRaw}\",\"${config}\",\"${traFile}\",${useMC})" &> ${log}
    elif [ ${step} == AT ]; then
      traFile=$(getJsonVal "['AT']['traFile']")
      rawFile=$(getJsonVal "['AT']['rawFile']")
      recFile=$(getJsonVal "['AT']['recFile']")
      unigenFile=$(getJsonVal "['AT']['unigenFile']")
      root -b -l -q "${macro}(\"${traFile}\",\"${rawFile}\",\"${recFile}\",\
	\"${unigenFile}\",\"${outFile}\",${overwrite},\"${config}\")" &> ${log}
    else 
      if [ ${step} == digitization ]; then
        input=$(getJsonVal "['transport']['output']['path']")
        if [ ! -e ${outFile}.par.root ] || [ ${overwrite} == true ]; then
          cp -v ${input}.par.root ${outDir}
        fi
      fi 
      root -b -l -q "${macro}(\"${config}\",${nEvents})" &> ${log}
    fi
    gzip -f ${log}
    rm .rootrc *{core,moni,Fair,TR,L1,Edep}* 
    cd -
    export taskId=
  fi
done
