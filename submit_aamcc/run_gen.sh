#!/bin/bash

filenum=${SLURM_ARRAY_TASK_ID}
(
cd $out_path
# Create input file
cat ./inputfile 1>./inputfile${filenum}
echo "output_${filenum}" >> ./inputfile${filenum}
# Process calculation
${aamcc_path}/GRATE < inputfile${filenum} &> ./log/log_${filenum}
echo "File ${filenum} is afterburned"
rm inputfile${filenum}
)


