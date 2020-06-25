#!/bin/bash

OUTPUT_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Outputs"
PLOT_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Plotss"

Benchmarks=("gcc" "mcf" "zeusmp" "cactusADM" "gobmk" "soplex" "hmmer" "sjeng" "GemsFDTD" "omnetpp"  "astar" "xalancbmk" )
#Benchmarks=("gcc" "mcf" "zeusmp" "cactusADM" "gobmk" "sjeng" "GemsFDTD") # CORRECT BENCHs
dw_confs=("01" "02" "04" "08" "16" "32")

i_bench=$((0))

mkdir -p $PLOT_DIR_BASE
echo "Created directory ${PLOT_DIR_BASE}"

### Plot for every benchmark
for BENCH in "${Benchmarks[@]}"; do
  benchOutDir=${OUTPUT_DIR_BASE}/$BENCH

  ### Create Input Parameters
  for dw in "${dw_confs[@]}"; do
    case $dw in
      01)
        ws_confs="001 002 004 008 016 032 064 096 128 192 256 384"
        ;;
      02)
        ws_confs="002 004 008 016 032 064 096 128 192 256 384"
        ;;
      04)
        ws_confs="004 008 016 032 064 096 128 192 256 384"
        ;;
      08)
        ws_confs="008 016 032 064 096 128 192 256 384"
        ;;
      16)
        ws_confs="016 032 064 096 128 192 256 384"
        ;;
      32)
        ws_confs="032 064 096 128 192 256 384"
        ;;
    esac

    for ws in $ws_confs; do
      INPUTS[$i_bench]+="${benchOutDir}/${BENCH}.DW_${dw}-WS_${ws}.out "
    done
  done

  echo "Plotting $BENCH"
  # echo $i_bench
  # echo ${INPUTS[$i_bench]}

  # '''
  eval "./plot_ipc.py ${INPUTS[$i_bench]}"
  mkdir -p "${PLOT_DIR_BASE}/IPC"
  mv ${BENCH}.png "${PLOT_DIR_BASE}/IPC/${BENCH}_ipc.png"
  # '''

  i_bench=$(($i_bench+1))

done

mv "total_instr_executed.txt" ${PLOT_DIR_BASE}
