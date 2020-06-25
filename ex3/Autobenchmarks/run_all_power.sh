#!/bin/bash

OUTPUT_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Outputs"
POWER_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Power"
MCPAT_PATH="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/sniper-7.3/tools/advcomparch_mcpat.py"

Benchmarks=("gcc" "mcf" "zeusmp" "cactusADM" "gobmk" "soplex" "hmmer" "sjeng" "GemsFDTD" "omnetpp"  "astar" "xalancbmk" )
# Benchmarks=("gcc" "mcf" "zeusmp" "cactusADM" "gobmk" "sjeng" "GemsFDTD") # CORRECT BENCHs
dw_confs=("01" "02" "04" "08" "16" "32")


### Plot for every benchmark
for BENCH in "${Benchmarks[@]}"; do
  benchOutDir=${OUTPUT_DIR_BASE}/$BENCH
  benchPoweDir=${POWER_DIR_BASE}/$BENCH

  echo "Power for $BENCH"
  mkdir -p $benchPoweDir
  echo "Created directory ./$BENCH/"

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
      mkdir -p "${benchPoweDir}/${BENCH}.DW_${dw}-WS_${ws}.out"
      eval "${MCPAT_PATH} -d ${benchOutDir}/${BENCH}.DW_${dw}-WS_${ws}.out -t total -o ${benchPoweDir}/${BENCH}.DW_${dw}-WS_${ws}.out/power > ${benchPoweDir}/${BENCH}.DW_${dw}-WS_${ws}.out/power.total.out"
    done
  done

done
