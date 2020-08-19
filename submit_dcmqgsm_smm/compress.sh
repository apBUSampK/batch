#!/bin/bash

#SBATCH -J compress
#SBATCH -p long
#SBATCH -t 24:00:00

folder=$1
echo folder=$folder
cd $folder

date
echo archiving src folder
\time -f "%E" tar -I pbz2 -cf src.tpbz2 src
chmod 600 src.tpbz2
rm -rf src

echo archiving dat_pure folder
\time -f "%E" tar -I pbz2 -cf dat_pure.tpbz2 dat_pure

echo removing dat_pure folder
\time -f "%E" rm -fr dat_pure

echo removing dat folder
\time -f "%E" rm -fr dat

echo removing log folder
\time -f "%E" rm -fr log

date
echo finish!
