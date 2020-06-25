#!/bin/bash

## Example of usage: ./run_sniper.sh gcc
## Modify the following paths appropriately
## CAUTION: use only absolute paths below!!!
SNIPER_EXE=/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/sniper-7.3/run-sniper
SPEC_PINBALLS_DIR=/home/manos/Downloads/cpu2006_pinballs
SNIPER_CONFIG=gainestown
OUTPUT_DIR_BASE="/home/manos/Documents/Advanced_Computer_Architecture_8th-semester/Exercise_3/Outputs"

Benchmarks=("gcc" "mcf" "zeusmp" "cactusADM" "gobmk" "soplex" "hmmer" "sjeng" "GemsFDTD" "omnetpp"  "astar" "xalancbmk" )

for BENCH in "${Benchmarks[@]}"; do
		benchOutDir=${OUTPUT_DIR_BASE}/$BENCH
		mkdir -p $benchOutDir


	for dw in 1 2 4 8 16 32; do
		case $dw in
			1)
				ws_confs="1 2 4 8 16 32 64 96 128 192 256 384"
				;;
			2)
				ws_confs="2 4 8 16 32 64 96 128 192 256 384"
				;;
			4)
				ws_confs="4 8 16 32 64 96 128 192 256 384"
				;;
			8)
				ws_confs="8 16 32 64 96 128 192 256 384"
				;;
			16)
				ws_confs="16 32 64 96 128 192 256 384"
				;;
			32)
				ws_confs="32 64 96 128 192 256 384"
				;;
		esac

		for ws in $ws_confs; do
			outDir=$(printf "%s.DW_%02d-WS_%03d.out" $BENCH $dw $ws)
			outDir="${benchOutDir}/${outDir}"

			pinball="$(ls $SPEC_PINBALLS_DIR/$BENCH/pinball_short.pp/*.address)"
			sniper_cmd="${SNIPER_EXE} -c ${SNIPER_CONFIG} -d ${outDir} -g --perf_model/core/interval_timer/dispatch_width=$dw -g --perf_model/core/interval_timer/window_size=$ws --pinballs=${pinball}"
			echo \"$sniper_cmd\"
			/bin/bash -c "$sniper_cmd"
		done
	done
	echo

done
