#!/bin/bash

## Example of usage: ./run_sniper_all.sh
## Modify the following paths appropriately
## CAUTION: use only absolute paths below!!!

SNIPER_EXE=/home/manos/sniper-7.3/run-sniper
SNIPER_CONFIG=/home/manos/Desktop/advcomparch/advanced-ca-Spring-2020-ask4-helpcode/ask4.cfg
BINARY_DIR=/home/manos/Desktop/advcomparch/advanced-ca-Spring-2020-ask4-helpcode
OUTPUT_DIR_BASE=/home/manos/Desktop/advcomparch/askisi4/Outputs/Cache

LockMechs=("TAS_CAS" "TAS_TS" "TTAS_CAS" "TTAS_TS" "MUTEX")
Topologies=("share_all" "share_L3" "share_nothing")

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

	for TOPOLOGY in "${Topologies[@]}"; do
		case $TOPOLOGY in
			"share_all")
				l2sharedcores=4
				l3sharedcores=4

				;;
			"share_L3")
				l2sharedcores=1
				l3sharedcores=4

				;;
			"share_nothing")
				l2sharedcores=1
				l3sharedcores=1

				;;
		esac

		outDir=$(printf "%s.NT_4-GS_1-%s.out" $LOCK_MECH $TOPOLOGY)
		outDir=$OUTPUT_DIR/$outDir
		sniper_cmd="$SNIPER_EXE -c $SNIPER_CONFIG -d $outDir -n 4 --roi \
		-g --perf_model/l1_icache/shared_cores=1 \
		-g --perf_model/l1_dcache/shared_cores=1 \
		-g --perf_model/l2_cache/shared_cores=$l2sharedcores \
		-g --perf_model/l3_cache/shared_cores=$l3sharedcores \
		-- $BINARY_DIR/locks 4 1000 1"
		echo $sniper_cmd
		mkdir $outDir
		/bin/bash -c "$sniper_cmd"

	done

done
