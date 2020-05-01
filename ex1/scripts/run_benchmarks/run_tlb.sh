#!/bin/bash

## Modify the following paths appropriately
PARSEC_PATH=/home/manos/adv-comparch/parsec-3.0/
PIN_EXE=/home/manos/adv-comparch/pin-3.13-98189-g60a6ef199-gcc-linux/pin
PIN_TOOL=/home/manos/adv-comparch/advcomparch-2019-2020-ex1-helpcode/pintool/obj-intel64/simulator.so

CMDS_FILE=./cmds_simlarge.txt
mkdir outputsTLB
outDir="./outputsTLB/"
echo "Created directory ${outDir}"

export LD_LIBRARY_PATH=$PARSEC_PATH/pkgs/libs/hooks/inst/amd64-linux.gcc-serial/lib/

## Triples of <cache_size>_<associativity>_<block_size>
CONFS="64_2_4096 64_4_4096
      64_8_4096 64_16_4096 64_32_4096
      64_64_4096 128_4_4096 256_4_4096"
L1size=32
L1assoc=8
L1bsize=64
L2size=1024
L2assoc=8
L2bsize=128
L2prf=0

BENCHMARKS="facesim"

for BENCH in $BENCHMARKS; do
	cmd=$(cat ${CMDS_FILE} | grep "$BENCH")
for conf in $CONFS; do
	## Get parameters
    TLBe=$(echo $conf | cut -d'_' -f1)
    TLBa=$(echo $conf | cut -d'_' -f2)
    TLBp=$(echo $conf | cut -d'_' -f3)

	outFile=$(printf "%s.dcache_cslab.TLB_%04d_%02d_%04d.out" $BENCH ${TLBe} ${TLBa} ${TLBp})
	outFile="$outDir/$outFile"

	pin_cmd="$PIN_EXE -t $PIN_TOOL -o $outFile -L1c ${L1size} -L1a ${L1assoc} -L1b ${L1bsize} -L2c ${L2size} -L2a ${L2assoc} -L2b ${L2bsize} -TLBe ${TLBe} -TLBp ${TLBp} -TLBa ${TLBa} -L2prf ${L2prf} -- $cmd"
	time $pin_cmd
done
done
