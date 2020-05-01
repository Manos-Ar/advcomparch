#!/bin/bash

## Instructions
## - Place this script in a directory where plot scripts are and have an outputs/ directory
## with all the results from the 10 benchmarks.
## - Change the name to: plot_all_caches_all_confs.sh
## - Run command on terminal: chmod +x plot_all_caches_all_confs.sh
## - Now run the script with the following parameters: L1, L2, TLB, PRF like: ./plot_all_caches_all_confs.sh L1

CACHE=${1}


if [ "${1}" = "L1" ]
then
  echo "Plotting all Benchmarks for L1"
  mkdir cycles_change
  echo "Created directory ./plotsL1/"
  for CONFS in 0032_04_064 0032_08_032 0032_08_064 0032_08_128 0064_04_064 0064_08_032 0064_08_064 0064_08_128 0128_08_032 0128_08_064 0128_08_128
  do
    INPUTS+="outputs${CACHE}/blackscholes.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/bodytrack.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/canneal.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/facesim.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/ferret.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/fluidanimate.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/freqmine.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/rtview.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/streamcluster.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/swaptions.dcache_cslab.${CACHE}_${CONFS}.out "
  done

  eval "./plot_l1.py ${INPUTS}"
  mv L1.png ./cycles_change/L1_cycle_change.png

elif [ "${1}" = "L2" ]
then
  echo "Plotting all Benchmarks for L2"
  mkdir cycles_change
  echo "Created directory ./plotsL2/"
  for CONFS in 0512_08_064 0512_08_128 0512_08_256 1024_08_064 1024_08_128 1024_08_256 1024_16_064 1024_16_128 1024_16_256 2048_16_064 2048_16_128 2048_16_256
  do
    INPUTS+="outputs${CACHE}/blackscholes.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/bodytrack.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/canneal.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/facesim.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/ferret.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/fluidanimate.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/freqmine.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/rtview.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/streamcluster.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/swaptions.dcache_cslab.${CACHE}_${CONFS}.out "
  done

  eval "./plot_l2.py ${INPUTS}"
  mv L2.png ./cycles_change/L2_cycle_change.png


elif [ "${1}" = "TLB" ]
then
  echo "Plotting all Benchmarks for TLB"
  mkdir cycles_change
  echo "Created directory ./plotsTLB/"
  for CONFS in 0008_04_4096 0016_04_4096 0032_04_4096 0064_01_4096 0064_02_4096 0064_04_4096 0064_08_4096 0064_16_4096 0064_32_4096 0064_64_4096 0128_04_4096 0256_04_4096
  do
    INPUTS+="outputs${CACHE}/blackscholes.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/bodytrack.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/canneal.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/facesim.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/ferret.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/fluidanimate.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/freqmine.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/rtview.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/streamcluster.dcache_cslab.${CACHE}_${CONFS}.out \
    outputs${CACHE}/swaptions.dcache_cslab.${CACHE}_${CONFS}.out "
  done

  eval "./plot_tlb.py ${INPUTS}"
  mv TLB.png ./cycles_change/TLB_cycle_change.png
fi
