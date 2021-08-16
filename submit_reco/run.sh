#!/bin/bash

function getJsonVal () {
  val=$(python -c "import json;print(json.dumps(json.load(open('${config}'))$1))";)
  eval echo ${val}
} # e.x. 'out_path=$(getJsonVal "['transport']['output']['path']")'

#function checkJsonKey () {
#  python -c "import json,sys;print ('$1' in json.load(open('${config}')))";
#} # returns True if key exists, False if not, e.x. 'run_transport=$(checkJsonKey "transport")'

batch=false

submit_script=${0}
config=${1}
jobName=$(getJsonVal "['accessory']['jobName']")
jobRange=$(getJsonVal "['accessory']['jobRange']")
logDir=$(getJsonVal "['accessory']['logDir']")
jobScript=$(getJsonVal "['accessory']['jobScript']")
cbmRoot=$(getJsonVal "['accessory']['cbmRoot']")
source ${cbmRoot}

steps=(transport digitization reconstruction AT)
declare -A run_steps
declare -A step_out_dirs
declare -A step_macros
for step in ${steps[*]}; do
  run_step=$(getJsonVal "['accessory']['${step}']['run']")
  if [ ${run_step} == true ]; then
    step_out_dir=$(dirname $(getJsonVal "['${step}']['output']['path']"))
    step_macro=$(getJsonVal "['accessory']['${step}']['macro']")
    step_src_dir=${step_out_dir}/macro
    mkdir -pv ${step_out_dir}
    mkdir -pv ${step_src_dir}
    cp -v ${step_macro} ${step_src_dir}
    cp -v ${config} ${step_src_dir}
    cp -v ${submit_script} ${step_src_dir}
    cp -v ${jobScript} ${step_src_dir}
    run_steps[${step}]=${run_step}
    step_out_dirs[${step}]=${step_out_dir}
    step_macros[${step}]=${step_src_dir}/$(basename ${step_macro})
  fi
done

export submit_script=$(basename ${submit_script})
export jobScript=$(basename ${jobScript})
export config=$(basename ${config})

export run_transport=${run_steps[transport]}
export transport_out_dir=${step_out_dirs[transport]}
export transport_macro=${step_macros[transport]}

export run_digitization=${run_steps[digitization]}
export digitization_out_dir=${step_out_dirs[digitization]}
export digitization_macro=${step_macros[digitization]}
 
export run_reconstruction=${run_steps[reconstruction]}
export reconstruction_out_dir=${step_out_dirs[reconstruction]}
export reconstruction_macro=${step_macros[reconstruction]}

export run_AT=${run_steps[AT]}
export AT_out_dir=${step_out_dirs[AT]}
export AT_macro=${step_macros[AT]}

export nEvents=$(getJsonVal "['accessory']['nEvents']")

if [ ${batch} == true ];then
  mkdir -pv ${logDir}
  sbatch -J ${jobName} -o ${logDir}/%A_%a.log -a ${jobRange} --export=ALL -- ${jobSript}
else
  export SLURM_ARRAY_JOB_ID=jobId
  export SLURM_ARRAY_TASK_ID=taskId
  ./${jobScript}
fi
