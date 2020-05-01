#!/bin/bash

## Instructions
## - Place this script in a directory where plot scripts are and have an outputs/ directory
## with all the results from the 10 benchmarks.
## - Change the name to: plot_all_caches.sh
## - Run command on terminal: chmod +x plot_all_caches.sh
## - Now run the script with the following parameters: L1, L2, TLB, PRF like: ./plot_all_caches.sh L1

mkdir benchmarks

if [ "${1}" = "L1" ]
then
  echo "Plotting L1"
  mkdir ./benchmarks/plotsL1
  echo "Created directory ./plotsL1/"
  for BENCHMARK in blackscholes bodytrack canneal facesim ferret fluidanimate freqmine rtview streamcluster swaptions
  do
    eval "./plot_l1.sh \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0032_04_064.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0032_08_032.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0032_08_064.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0032_08_128.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0064_04_064.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0064_08_032.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0064_08_064.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0064_08_128.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0128_08_032.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0128_08_064.out \
    outputsL1/${BENCHMARK}.dcache_cslab.L1_0128_08_128.out"
    mv L1.png ./benchmarks/plotsL1/L1_${BENCHMARK}.png
  done

elif [ "${1}" = "L2" ]
then
  echo "Plotting L2"
  mkdir ./benchmarks/plotsL2
  echo "Created directory ./plotsL2/"
  for BENCHMARK in blackscholes bodytrack canneal facesim ferret fluidanimate freqmine rtview streamcluster swaptions
  do
    eval "./plot_l2.sh \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_0512_08_064.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_0512_08_128.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_0512_08_256.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_1024_08_064.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_1024_08_128.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_1024_08_256.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_1024_16_064.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_1024_16_128.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_1024_16_256.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_2048_16_064.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_2048_16_128.out \
    outputsL2/${BENCHMARK}.dcache_cslab.L2_2048_16_256.out"
    mv L2.png ./benchmarks/plotsL2/L2_${BENCHMARK}.png
  done


elif [ "${1}" = "TLB" ]
then
  echo "Plotting TLB"
  mkdir ./benchmarks/plotsTLB
  echo "Created directory ./plotsTLB/"
  for BENCHMARK in blackscholes bodytrack canneal facesim ferret fluidanimate freqmine rtview streamcluster swaptions
  do
    eval "./plot_tlb.sh \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0008_04_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0016_04_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0032_04_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_01_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_02_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_04_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_08_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_16_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_32_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0064_64_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0128_04_4096.out \
    outputsTLB/${BENCHMARK}.dcache_cslab.TLB_0256_04_4096.out"
    mv TLB.png ./benchmarks/plotsTLB/TLB_${BENCHMARK}.png
  done


elif [ "${1}" = "PRF" ]
then
  echo "Plotting PRF"
  mkdir ./benchmarks/plotsPRF
  echo "Created directory ./plotsPRF/"
  for BENCHMARK in blackscholes bodytrack canneal facesim ferret fluidanimate freqmine rtview streamcluster swaptions
  do
    eval "./plot_prf.sh \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_01.out \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_02.out \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_04.out \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_08.out \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_16.out \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_32.out \
    outputsPRF/${BENCHMARK}.dcache_cslab.PRF_64.out"
    mv PRF.png ./benchmarks/plotsPRF/PRF_${BENCHMARK}.png
  done

else
  echo "Please choose a parameter from these: L1, L2, TLB, PRF"
fi
