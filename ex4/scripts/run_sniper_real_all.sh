#!/bin/bash

## Example of usage: ./run_sniper_real_all.sh
## Modify the following paths appropriately
## CAUTION: use only absolute paths below!!!

BINARY_DIR=/home/manos/Desktop/advcomparch/advanced-ca-Spring-2020-ask4-helpcode
OUTPUT_DIR_BASE=/home/manos/Desktop/advcomparch/askisi4/Outputs/Real

LockMechs=("TAS_TS")

for LOCK_MECH in "${LockMechs[@]}"; do

	# Replace LFLAG value
	sed -i 's/^LFLAG ?=.*/LFLAG ?= -D'${LOCK_MECH}'/' Makefile
	# Replace IMPLFLAG value
	sed -i 's/^IMPLFLAG ?=.*/IMPLFLAG ?= -DREAL/' Makefile

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

	for nthreads in 1 2 4 8; do	# Change nthreads
		for grain_size in 1 10 100; do
			outDir=$(printf "%s.NT_%02d-GS_%03d.out" $LOCK_MECH $nthreads $grain_size)
			outDir=$OUTPUT_DIR/$outDir
			sniper_cmd="$BINARY_DIR/locks $nthreads 100000000 $grain_size > $outDir"	# Change iterations
			echo $sniper_cmd
			/bin/bash -c "$sniper_cmd"
		done
	done

done
