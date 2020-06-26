#!/bin/bash

path=$1
min=$2
max=$3
step=$4

echo path: $path
echo range: $min-$max
echo step: $step

echo ================================================
for (( i=$min;i<=$max;i++ )) do
  if (( $i % $step != 0 )) 
  then
#    rm -r $path/$i
    rm -r $path/$i/transport.log
  fi
done
