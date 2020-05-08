
Outdir="/home/manos/Desktop/plots"
mkdir $Outdir

Inputs="/home/manos/Desktop/outputs/outputs_branch_"
echo $Inputs

Benchmarks=("403.gcc" "429.mcf" "434.zeusmp" "436.cactusADM" "445.gobmk" "450.soplex" "456.hmmer" "458.sjeng" "459.GemsFDTD" "471.omnetpp"  "473.astar" "483.xalancbmk" )

if [[ (${1} == bar_stats) || (${1} == pie_stats)]]
then
  echo "Plotting ${1}"
  Outfile=$Outdir"/stats"
  mkdir $Outfile
  Outfile=$Outfile"/"${1}
  mkdir $Outfile
  echo $Outfile
  echo "Created directory $Outfile"
  for BENCH in "${Benchmarks[@]}";
  do
    eval "./plot_${1}.py \
    $Inputs"stats"/${BENCH}.cslab_branch_stats.out"
    mv stats.png $Outfile"/"${1}_${BENCH}.png
  done
elif [[ (${1} ==  all)]] #|| (${1} == 2b) || (${1} == btb) || (${1} == 2a_mean) || (${1} == 2b_mean) || (${1} == btb_mean) || (${1} == ras) || (${1} == ras_mean) || (${1} == 4.5)]];
then
    Predictors=("2a" "2b" "btb" "ras")
    for pre in "${Predictors[@]}";
    do
      echo $pre
      eval ./plot_${pre}.py $Outdir"/"${pre} $Inputs${pre}
      echo $pre"_mean"
      eval ./plot_${pre}"_mean.py" $Outdir"/"${pre} $Inputs${pre}
    done
    eval ./plot_4.5.py $Outdir"/4.5" $Inputs"static" $Inputs"2b" $Inputs"ras" $Inputs"local_global" $Inputs"tournament"
    eval ./plot_4.5_mean.py $Outdir"/4.5" $Inputs"static" $Inputs"2b" $Inputs"ras" $Inputs"local_global" $Inputs"tournament"

    eval ./plot_4.5_b.py $Outdir"/4.5_dynamic"  $Inputs"2b" $Inputs"ras" $Inputs"local_global" $Inputs"tournament"
    eval ./plot_4.5_b_mean.py $Outdir"/4.5_dynamic"  $Inputs"2b" $Inputs"ras" $Inputs"local_global" $Inputs"tournament"
else
  echo "Please choose a parameter from these: branch_stats, all"
fi
