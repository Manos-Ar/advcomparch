#!/bin/bash

# Change to your branch stats outputs
OUTPUTS_DIR=/home/manos/Desktop/plot_stats/outputs_branch_stats/
echo $OUTPUTS_DIR
PLOTS_DIR=stats

echo "Plotting Branch Stats"
mkdir $PLOTS_DIR
echo "Created directory ./${PLOTS_DIR}/"


for BENCHMARK in 403.gcc 429.mcf 434.zeusmp 436.cactusADM 445.gobmk 450.soplex 456.hmmer 458.sjeng 459.GemsFDTD 471.omnetpp 473.astar 483.xalancbmk
do
  echo "${BENCHMARK}"
  eval " ./plot_branch_predictors_stats.py ${OUTPUTS_DIR}${BENCHMARK}.cslab_branch_stats.out
  "
  mv bar.png ./${PLOTS_DIR}/${BENCHMARK}_bar.png
  mv pie.png ./${PLOTS_DIR}/${BENCHMARK}_pie.png
done
