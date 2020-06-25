#!/bin/bash

OUTPUT_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Outputs/Cache"
PLOT_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Plots"

LockMechs=("TAS_CAS" "TAS_TS" "TTAS_CAS" "TTAS_TS" "MUTEX")
Topologies=("share_all" "share_L3" "share_nothing")

mkdir -p $PLOT_DIR_BASE
echo "Created directory ${PLOT_DIR_BASE}"

# Create the input to give to python plot program
INPUTS=""

for LOCK_MECH in "${LockMechs[@]}"; do

	for TOPOLOGY in "${Topologies[@]}"; do
		NAME=$(printf "%s.NT_4-GS_1-%s.out" $LOCK_MECH $TOPOLOGY)
		INPUTS+="${OUTPUT_DIR_BASE}/${LOCK_MECH}/$NAME "
	done
done

# echo $INPUTS
echo "Plotting"
eval "./plot_scalability_cache.py ${INPUTS}"
mv topologies.png "${PLOT_DIR_BASE}/topologies_scalability.png"
