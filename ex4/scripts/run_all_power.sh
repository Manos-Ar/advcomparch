#!/bin/bash

OUTPUT_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Outputs"
PLOT_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Plots"
POWER_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Outputs"
MCPAT_PATH="/home/manos/sniper-7.3/tools/advcomparch_mcpat.py"

LockMechs=("TAS_CAS" "TAS_TS" "TTAS_CAS" "TTAS_TS" "MUTEX")

for LOCK_MECH in "${LockMechs[@]}"; do
  benchOutDir=${OUTPUT_DIR_BASE}/$LOCK_MECH
  benchPoweDir=${POWER_DIR_BASE}/$LOCK_MECH
  benchPlotDir=${PLOT_DIR_BASE}

  echo "Power for $LOCK_MECH"
  mkdir -p $benchPoweDir
  echo "Created directory ./$LOCK_MECH/"

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
			PoweDir=$benchPoweDir/$outDir
			mkdir -p "${PoweDir}"
			eval "${MCPAT_PATH} -d ${benchOutDir}/${outDir} -t total -o ${PoweDir}/power > ${PoweDir}/power.total.out"
		done
	done

done
