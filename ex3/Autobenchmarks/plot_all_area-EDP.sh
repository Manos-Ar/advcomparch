#!/bin/bash

POWER_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Outputs"
PLOT_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Plots"

Benchmarks=("gcc" "mcf" "zeusmp" "cactusADM" "gobmk" "sjeng" "GemsFDTD") # CORRECT BENCHs
# Benchmarks=("gcc") # Only one is sufficient
dw_confs=("01" "02" "04" "08" "16" "32")

i_bench=$((0))

mkdir -p $PLOT_DIR_BASE
echo "Created directory ${PLOT_DIR_BASE}"

### Plot for every benchmark
for BENCH in "${Benchmarks[@]}"; do
  benchPoweDir=${POWER_DIR_BASE}/$BENCH

  ### Create Input Parameters
  for dw in "${dw_confs[@]}"; do
    case $dw in
      01)
        # ws_confs="001 002 004 008 016 032 064 096 128 192 256 384"
        ws_confs="016 032 064 096 128 192 256 384"
        ;;
      02)
        # ws_confs="002 004 008 016 032 064 096 128 192 256 384"
        ws_confs="016 032 064 096 128 192 256 384"
        ;;
      04)
        # ws_confs="004 008 016 032 064 096 128 192 256 384"
        ws_confs="016 032 064 096 128 192 256 384"
        ;;
      08)
        # ws_confs="008 016 032 064 096 128 192 256 384"
        ws_confs="016 032 064 096 128 192 256 384"
        ;;
      16)
        # ws_confs="016 032 064 096 128 192 256 384"
        ws_confs="016 032 064 096 128 192 256 384"
        ;;
      32)
        # ws_confs="032 064 096 128 192 256 384"
        ws_confs="032 064 096 128 192 256 384"
        ;;
    esac

    for ws in $ws_confs; do
      INPUTS[$i_bench]+="${benchPoweDir}/${BENCH}.DW_${dw}-WS_${ws}.out "
    done
  done

  echo "Plotting $BENCH"
  # echo $i_bench
  # echo ${INPUTS[$i_bench]}

  eval "./plot_area.py ${INPUTS[$i_bench]}"
  mkdir -p "${PLOT_DIR_BASE}/Area"
  mv "${BENCH}_area.png" "${PLOT_DIR_BASE}/Area/${BENCH}_area.png"

  eval "./plot_EDP.py ${INPUTS[$i_bench]}"
  mkdir -p "${PLOT_DIR_BASE}/EDP"
  mv "${BENCH}_EDP.png" "${PLOT_DIR_BASE}/EDP/${BENCH}_EDP.png"


  i_bench=$(($i_bench+1))

done
