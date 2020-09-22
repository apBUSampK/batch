#!/bin/bash

#SBATCH -J compress
#SBATCH -p long
#SBATCH -t 24:00:00

folder=$1
echo folder=$folder
cd $folder

date
echo archiving src folder
\time -f "%E" tar -cjf src.tgz src
chmod 600 src.tgz
rm -rf src

echo zipping dat files
date
for f in dat/urqmd_*.dat;
do 
  gzip -f $f;
done
date

echo tarring dat folder
\time -f "%E" tar -cf dat.tar dat

echo removing log folder
\time -f "%E" rm -fr log

echo removing dat folder
\time -f "%E" rm -fr dat

date
echo finish!
