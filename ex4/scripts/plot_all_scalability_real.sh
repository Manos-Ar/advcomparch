#!/bin/bash

OUTPUT_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Outputs/Real"
PLOT_DIR_BASE="/home/manos/Desktop/advcomparch/askisi4/Plots"

LockMechs=("TAS_CAS" "TAS_TS" "TTAS_CAS" "TTAS_TS" "MUTEX")

mkdir -p $PLOT_DIR_BASE
echo "Created directory ${PLOT_DIR_BASE}"

### Plot for every grain size
for grain_size in 1 10 100; do

  # Create the input to give to python plot program
  INPUTS=""

  for LOCK_MECH in "${LockMechs[@]}"; do
    for nthreads in 1 2 4 8; do           # Change nthreads
      NAME=$(printf "%s.NT_%02d-GS_%03d.out" $LOCK_MECH $nthreads $grain_size)
      INPUTS+="${OUTPUT_DIR_BASE}/${LOCK_MECH}/$NAME "
    done
  done
  # echo $INPUTS

  echo "Plotting $grain_size"
  eval "./plot_scalability_real.py 8 ${INPUTS}"     # Change nthreads
  mv ${grain_size}.png "${PLOT_DIR_BASE}/${grain_size}_scalability_real.png"

done
