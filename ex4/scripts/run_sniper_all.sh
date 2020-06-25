#!/bin/bash

## Example of usage: ./run_sniper_all.sh
## Modify the following paths appropriately
## CAUTION: use only absolute paths below!!!

SNIPER_EXE=/home/manos/Desktop/advcomparch/askisi3/sniper-7.3/run-sniper
SNIPER_CONFIG=/home/manos/Desktop/advcomparch/askisi4/advanced-ca-Spring-2020-ask4-helpcode/ask4.cfg
BINARY_DIR=//home/manos/Desktop/advcomparch/askisi4/advanced-ca-Spring-2020-ask4-helpcode
OUTPUT_DIR_BASE=/home/manos/Desktop/advcomparch/askisi4/Outputs

LockMechs=("TAS_CAS" "TAS_TS" "TTAS_CAS" "TTAS_TS" "MUTEX")

for LOCK_MECH in "${LockMechs[@]}"; do

	# Replace LFLAG value
	sed -i 's/^LFLAG ?=.*/LFLAG ?= -D'${LOCK_MECH}'/' Makefile
	# Replace IMPLFLAG value
	sed -i 's/^IMPLFLAG ?=.*/IMPLFLAG ?= -DSNIPER/' Makefile

	make clean; make;
	# sleep 1

	OUTPUT_DIR=$OUTPUT_DIR_BASE/$LOCK_MECH
	mkdir $OUTPUT_DIR || {
		read -p "Directory $OUTPUT_DIR exists. Do you want to overwrite?[Y/n] " response
		if [ "${response:0:1}" != 'y' ] && [ "${response:0:1}" != 'Y' ]
		then
			exit
		fi
	}

	for nthreads in 1 2 4 8 16; do
		case $nthreads in
			1)
				l2sharedcores=1
				l3sharedcores=1
				;;
			2)
				l2sharedcores=2
				l3sharedcores=2
				;;
			4)
				l2sharedcores=4
				l3sharedcores=4
				;;
			8)
				l2sharedcores=4
				l3sharedcores=8
				;;
			16)
				l2sharedcores=1
				l3sharedcores=8
				;;
		esac

		for grain_size in 1 10 100; do
			outDir=$(printf "%s.NT_%02d-GS_%03d.out" $LOCK_MECH $nthreads $grain_size)
			outDir=$OUTPUT_DIR/$outDir
			sniper_cmd="$SNIPER_EXE -c $SNIPER_CONFIG -d $outDir -n $nthreads --roi -g --perf_model/l2_cache/shared_cores=$l2sharedcores -g --perf_model/l3_cache/shared_cores=$l3sharedcores -- $BINARY_DIR/locks $nthreads 1000 $grain_size"
			echo $sniper_cmd
			/bin/bash -c "$sniper_cmd"
		done
	done

done
