#!/bin/bash

(
. $out_path/makeup.sh
source $root_config
cd $outdir_root_aamcc
find ./ -maxdepth 1 -regex "\./urqmd_aamcc_[123456789]+\.root" -exec hadd -j -f aamccUrQMDhadd.root \{\} >& $aamcc_log_dir/logMergeScript +
)
