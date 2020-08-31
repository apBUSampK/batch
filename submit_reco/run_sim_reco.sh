#!/bin/bash

taskId=${SLURM_ARRAY_TASK_ID}
taskId5=$(printf "%05d" ${taskId})
plutoFile=${pluto_path}${taskId5}.root
 
input_file=${input_file}${taskId}.root
job_out_dir=${out_dir}/${taskId}

echo input_file=${input_file}

mkdir -p ${job_out_dir}
cd ${job_out_dir}
ln -s ${VMCWORKDIR}/macro/run/.rootrc .


elapsed=$SECONDS

if [ ${run_transport} == 1 ] && [ ! -e transport.log.gz ]; then 
  cp -v ../macro/run_transport.C .
  sed -i -- "s~PLUTOFILE~\"${plutoFile}\"~g" run_transport.C
  echo Execute: ${job_out_dir}/run_transport.C
  root -b -q "run_transport.C (${nEvents}, \"${base_setup}\", \"${taskId}\", \"${input_file}\")" &> transport.log
  #&> /dev/null 
  gzip -f transport.log
  cp -v FairRunInfo_${taskId}.par.root FairRunInfo_${taskId}_transport.par.root
  rm run_transport.C
fi

if [ ${run_digi} == 1 ] && [ ! -e digi.log.gz ]; then 
  cp -v ../macro/run_digi.C .
  sed -i -- "s~TASKID~${taskId}~g" run_digi.C
  echo Execute: ${job_out_dir}/run_digi.C
  root -b -q "${job_out_dir}/run_digi.C (${nEvents}, \"${taskId}\", 1.e7, 1.e4, kTRUE)" &> digi.log
  gzip -f digi.log
  rm run_digi.C
fi

if [ ${run_reco} == 1 ] && [ ! -e reco.log.gz ]; then  
  cp -v ../macro/run_reco_event.C .
  sed -i -- "s~TASKID~${taskId}~g" run_reco_event.C
  echo Execute: ${job_out_dir}/run_reco_event.C
  root -b -q "${job_out_dir}/run_reco_event.C (${nEvents}, \"${taskId}\", \"${base_setup}\")" &> reco.log 
  gzip -f reco.log
  rm run_reco_event.C
fi

if [ ${run_treemaker} == 1 ] && [ -e reco.log.gz ]; then 
  cp -v ../macro/run_treemaker.C .
  sed -i -- "s~TASKID~${taskId}~g" run_treemaker.C
  echo Execute: ${job_out_dir}/run_treemaker.C
  root -b -q "${job_out_dir}/run_treemaker.C (${nEvents}, \"${taskId}\", \"${base_setup}\")" &> tree.log
  gzip -f tree.log
  mv ${taskId}.tree.root ${tree_dir}
  rm run_treemaker.C
fi

rm .rootrc

[ ${delete_sim_files} = 1 ] && [ $(( $taskId % 100 )) -ne 0 ] && rm -r ${job_out_dir} 

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes
