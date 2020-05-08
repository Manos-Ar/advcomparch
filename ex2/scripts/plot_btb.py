#!/usr/bin/env python3

import os
import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


TARGET_DIR = sys.argv[1]
try:
    os.mkdir(TARGET_DIR)
except FileExistsError:
    print('Directory', TARGET_DIR, 'exists.')
    ans = input('Do you want to overwrite?[Y/n] ')
    if not ans.startswith('y') and not ans.startswith('Y'):
        quit()
print('Directory created')

with os.scandir(sys.argv[2]) as it:
    for entry in it:
        if entry.is_file():
            print(entry.name)
            name = entry.name.split('.')
            benchmark = name[0] + '.' + name[1]
            fp = open(entry)
            line = fp.readline()
            x_axis = []
            direction_mpki_axis = []
            target_mpki_axis = []
            while line:
                if line.startswith("Total Instructions"):
                    total_ins = int(line.split()[2])
                    print('Total instructions: ', total_ins)
                if line.startswith("BTB"):
                    line = fp.readline()
                    tokens = line.split(':')
                    while(len(tokens) > 1):
                        x_axis.append(tokens[0].lstrip())
                        correct, incorrect, correct_target = map(int, tokens[1].split())
                        total = correct + incorrect
                        direction_mpki = incorrect/(total_ins/1000)
                        direction_mpki_axis.append(direction_mpki)
                        target_mpki = (correct-correct_target)/(total_ins/1000)
                        target_mpki_axis.append(target_mpki)
                        line = fp.readline()
                        tokens = line.split(':')
                line = fp.readline()
            print(benchmark)
            print(x_axis)
            print(target_mpki_axis)

            fig, ax1 = plt.subplots()
            ax1.grid(True)

            xAx = np.arange(len(x_axis))
            ax1.xaxis.set_ticks(np.arange(0, len(x_axis), 1))
            ax1.set_xticklabels(x_axis, rotation=45)
            #plt.xticks(xAx, x_axis, rotation=45)
            ax1.set_xlim(-0.5, len(x_axis) - 0.5)
            ax1.set_ylim(min(direction_mpki_axis) - 0.05, max(direction_mpki_axis) + 0.05)
            ax1.set_ylabel("$Direction$ $MPKI$")
            line1 = ax1.plot(direction_mpki_axis, label="direction_mpki", color="green",marker='o')

            ax2 = ax1.twinx()
            ax2.xaxis.set_ticks(np.arange(0, len(x_axis), 1))
            ax2.set_xticklabels(x_axis, rotation=45)
            #plt.xticks(xAx, x_axis, rotation=45)
            ax2.set_xlim(-0.5, len(x_axis) - 0.5)
            ax2.set_ylim(min(target_mpki_axis) - 0.05, max(target_mpki_axis) + 0.05)
            ax2.set_ylabel("$Target$ $MPKI$")
            line2 = ax2.plot(target_mpki_axis, label="target_mpki", color="blue",marker='^')

            lns = line1 + line2
            labs = [l.get_label() for l in lns]

            plt.title(benchmark + " BTB")
            lgd = plt.legend(lns, labs)
            lgd.draw_frame(False)
            plt.savefig(os.path.join(TARGET_DIR, benchmark+'.png'), bbox_inches='tight')
