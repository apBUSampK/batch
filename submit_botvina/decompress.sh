#!/bin/bash

#SBATCH -J decompress
#SBATCH -p long
#SBATCH -t 24:00:00

folder=$1
echo folder=$folder
cd $folder

date
echo decompressing src folder
\time -f "%E" tar -xjvf dat_pure.tpbz2

date
echo finish!
