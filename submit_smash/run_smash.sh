#!/bin/bash

elapsed=$SECONDS

outfilenamemask=smash

filenum=$SLURM_ARRAY_TASK_ID

source $root_config

echo "current dir:" $PWD
config=$(basename ${config})
rootfile=$log_dir/${filenum}/Particles.root
unigenFile=$outdir_root/${outfilenamemask}_$filenum.root

${smash_dir}/build/smash -i src/${config} -o log/${filenum}

which root

[ $remove_logs == "yes" ] && rm -r ${log_dir}/${filenum}

elapsed=$(expr $SECONDS - $elapsed)
echo "Done!"
echo Elapsed time: $(expr $elapsed / 60) minutes
