#!/bin/bash

#
#SBATCH -D /mnt/pool/nica/7/ovgol/mc/generators/smash
#SBATCH -J smash
#SBATCH -p cpu
#SBATCH --time=24:00:00
#SBATCH -a 101-1000
#
#SBATCH -o /mnt/pool/nica/7/ovgol/mc/generators/smash/log/%A_%a.log
#

export JOB_ID=$SLURM_ARRAY_JOB_ID
export TASK_ID=$SLURM_ARRAY_TASK_ID

#Energy in cms
#ecm=2.4
#Number of events
nev=2000

export JOB_NUMBER_ID=${JOB_ID}
export JOB_TASK_ID=${TASK_ID}

export START_POSITION=$PWD

export MAIN_DIR=/mnt/pool/nica/7/ovgol/mc/generators/smash

#Input file
export INPUTFILE=/home/ovgol/batch/submit_smash/config.yaml
export SHORTNAME=`basename $INPUTFILE`
export SHORTNAME1=${SHORTNAME#config_}
export LABEL=${SHORTNAME1%.yaml}

export COMMIT=${LABEL}/${JOB_ID}

export OUT=$MAIN_DIR/OUT/$COMMIT
export OUT_LOG=$OUT/log
export OUT_CFG=${OUT}/config
export OUT_FILE=$OUT/files
export OUT_MCINI=${OUT_FILE}/mcini
export OUT_MCPICO=${OUT_FILE}/mcpico
#export OUT_PART=${OUT_FILE}/particles
export LOG=${OUT_LOG}/JOB_${LABEL}_${JOB_ID}_${TASK_ID}.log
export CFG=${OUT_CFG}/config_${LABEL}.${JOB_ID}_${TASK_ID}.yaml

mkdir -p $OUT_LOG
mkdir -p $OUT_CFG
mkdir -p $OUT_FILE
mkdir -p $OUT_MCINI
mkdir -p $OUT_MCPICO
#mkdir -p $OUT_PART

touch $LOG
touch $CFG

_log() {

local format='+%Y/%m/%d-%H:%M:%S'
echo [`date $format`] "$@"

}

source /mnt/pool/rhic/4/parfenovpeter/Soft/Basov/ROOT/install/bin/thisroot.sh

export SMASH_DIR=/home/ovgol/soft/smash-2.2/build
export SMASH_BIN=${SMASH_DIR}/smash

export MCINI_DIR=/home/ovgol/soft/mcini
export CONVERTER1_MACRO=${MCINI_DIR}/macro/convertSmashParticles.C # Convert from SMASH ROOT file (final state only) to mcini

export TMPALL=$MAIN_DIR/TMP
export TMPDIR=$TMPALL/TMP_${JOB_NUMBER_ID}_${JOB_TASK_ID}
export TMPDIR_OUT=$TMPDIR/OUT

mkdir -p $TMPDIR_OUT

cd $TMPDIR

cp $INPUTFILE ${TMPDIR}/config.yaml

#sed -e "s|energyincms|$ecm|" -i ./config.yaml
sed -e "s|numberofevents|$nev|" -i ./config.yaml
sed -e "s|randomrandom|`shuf -i 1-1000000 -n 1`|" -i ./config.yaml


_log ${TMPDIR}

_log ${INPUTFILE}

_log `ls ${TMPDIR}`

_log ${ROOTSYS_cvmfs}

_log ${ROOTSYS}

_log ${LD_LIBRARY_PATH}

_log ${PATH}

cat config.yaml >> $LOG
cat config.yaml >> $CFG

_log -------

_log "Running SMASH..."
$SMASH_BIN -i ${TMPDIR}/config.yaml -o ${TMPDIR_OUT}/ -p ${SMASH_DIR}/../input/light_nuclei/particles.txt -d ${SMASH_DIR}/../input/light_nuclei/decaymodes.txt &>>$LOG

_log -------

cd $TMPDIR
_log `ls $TMPDIR`

_log -------

_log Converting output file to mcini and mcpico formats
. ${MCINI_DIR}/macro/config.sh &>> $LOG
root -l -b -q $CONVERTER1_MACRO'("'${TMPDIR_OUT}/Particles.root'","'${OUT_MCINI}/smash_${LABEL}_${JOB_ID}_${TASK_ID}.mcini.root'")' &>> $LOG

_log Cleaning temporary directory...
rm -rf $TMPDIR

cd $START_POSITION
_log "Job is done!" &>> $LOG
