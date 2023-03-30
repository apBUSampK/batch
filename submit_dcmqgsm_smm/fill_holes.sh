#!/bin/bash

path=$1
min=$2
max=$3
prefix=dcmqgsm_

cd $path
ls root/${prefix}* > unsorted
sed -i -- s~root/$prefix~~g unsorted
sed -i -- s~\.root~~g unsorted
sort -n unsorted > sorted
[ -z $min ] && min=$(head -n1 sorted)
[ -z $max ] && max=$(tail -n1 sorted)
last=$(tail -n1 sorted)
for (( i=${min};i<${max};i++ ));do
  [ $i == $last ] && break
  if [ ! -e root/${prefix}${i}.root ];then
    #echo ${last} to ${i}
    mv -v root/${prefix}${last}.root root/${prefix}${i}.root
    mv -v dat/${prefix}${last}.dat.gz dat/${prefix}${i}.dat.gz
    mv -v dat_pure/${prefix}pure_${last}.dat.gz dat_pure/${prefix}pure_${i}.dat.gz
    sed -i '$ d' sorted
    last=$(tail -n1 sorted)
  fi
done
rm unsorted sorted
