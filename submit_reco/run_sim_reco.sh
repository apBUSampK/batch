#!/bin/bash

function getJsonVal () { # e.x. 'out_dir=$(dirname $(getJsonVal "['transport']['output']['path']"))'
  python -c "import json,sys;sys.stdout.write(json.dumps(json.load(open('${config}'))$1))"; 
}

function checkJsonKey () { # returns True if key exists, False if not, e.x. 'run_transport=$(checkJsonKey "transport")'
  python -c "import json,sys;print ('$1' in json.load(open('${config}')))"; 
}

config=$1

nEvents=$(getJsonVal "['accessory']['nEvents']")
run_transport=$(getJsonVal "['accessory']['run_transport']")
run_digi=$(getJsonVal "['accessory']['run_digi']")
run_reco=$(getJsonVal "['accessory']['run_reco']")
run_AT=$(getJsonVal "['accessory']['run_AT']")

[ -z ${transport_macro} ] && transport_macro=$(getJsonVal "['accessory']['transport_macro']")
[ -z ${digi_macro} ] && digi_macro=$(getJsonVal "['accessory']['digi_macro']")
[ -z ${reco_macro} ] && reco_macro=$(getJsonVal "['accessory']['reco_macro']")
[ -z ${AT_macro} ] && AT_macro=$(getJsonVal "['accessory']['AT_macro']")

[ ${run_transport} == true ] && root -b -l -q "${transport_macro}(\"${config}\",${nEvents})"

[ ${run_digi} == true ] && root -b -l -q "${digi_macro}(\"${config}\",${nEvents})"

if [ ${run_reco} == true ]; then
  input=$(getJsonVal "['reconstruction']['input']")
  nTimeSlices=$(getJsonVal "['reconstruction']['nTimeSlices']")
  firstTimeSlice=$(getJsonVal "['reconstruction']['firstTimeSlice']")
  outputReco=$(getJsonVal "['reconstruction']['output']['path']")
  overwriteReco=$(getJsonVal "['reconstruction']['output']['overwrite']")
  sEvBuildRaw=$(getJsonVal "['reconstruction']['sEvBuildRaw']")
  paramFile=$(getJsonVal "['reconstruction']['paramFile']")
  useMC=$(getJsonVal "['reconstruction']['useMC']")
  root -b -l -q "${reco_macro}(${input},${nTimeSlices},${firstTimeSlice},${outputReco},${overwriteReco},${sEvBuildRaw},\"${config}\",${paramFile},${useMC})"
fi

if [ ${run_AT} == true ]; then
  traPath=$(getJsonVal "['AT']['traPath']")
  rawPath=$(getJsonVal "['AT']['rawPath']")
  recPath=$(getJsonVal "['AT']['recPath']")
  geoPath=$(getJsonVal "['AT']['geoPath']")
  parPath=$(getJsonVal "['AT']['parPath']")
  unigenFile=$(getJsonVal "['AT']['unigenFile']")
  outputAT=$(getJsonVal "['AT']['output']['path']")
  overwriteAT=$(getJsonVal "['AT']['output']['overwrite']")
  root -b -l -q "${AT_macro}(${traPath},${rawPath},${recPath},${geoPath},${parPath},${unigenFile},${oututAT},${overwriteAT},\"${config}\",${nEvents})"
fi
