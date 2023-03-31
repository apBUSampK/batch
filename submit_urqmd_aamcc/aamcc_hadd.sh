#!/bin/bash

source $root_config
hadd -j -f $outdir_root_aamcc/aamccUrQMDhadd.root $outdir_root_aamcc/urqmd_aamcc_*_mcini_.root >& $outdir_root_aamcc/log_merge.txt