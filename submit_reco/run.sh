#!/bin/bash

function getJsonVal () {
  python -c "import json,sys;sys.stdout.write(json.dumps(json.load(open('${config}'))$1))";
} # e.x. 'out_dir=$(dirname $(getJsonVal "['transport']['output']['path']"))'

function checkJsonKey () {
  python -c "import json,sys;print ('$1' in json.load(open('${config}')))";
} # returns True if key exists, False if not, e.x. 'run_transport=$(checkJsonKey "transport")'

config=$1

nEvents=$(getJsonVal "['nEvents']")
run_transport=$(getJsonVal "['run_transport']")
run_digitization=$(getJsonVal "['run_digi']")
run_reconstruction=$(getJsonVal "['run_reco']")
run_AT=$(getJsonVal "['run_AT']")

steps=(transport digitization reconstruction AT)
for step in $(steps[*]); do
  run_transport=$(getJsonVal "['run_transport']")
  if [ run_${step} == true ]; then
    out_dir=$(dirname $(getJsonVal "['${step}']['output']['path']"))
    ${step}_macro=$(getJsonVal "['accessory']['${step}_macro']")
    mkdir -p ${out_dir}
    rsync -v ${step}_macro ${out_dir}
    export ${step}_macro=$(basename ${step}_macro)
  fi
done
