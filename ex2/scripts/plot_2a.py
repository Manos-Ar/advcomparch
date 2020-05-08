#!/usr/bin/env python3

import os
import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

print(str(sys.argv[1]))
print(str(sys.argv[2]))
# print(sys.argv[2])

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
            mpki_axis = []
            while line:
                if line.startswith("Total Instructions"):
                    total_ins = int(line.split()[2])
                    print('Total instructions: ', total_ins)
                if line.startswith("Branch Predictors"):
                    line = fp.readline()
                    tokens = line.split(':')
                    while(len(tokens) > 1):
                        x_axis.append(tokens[0].lstrip())
                        correct, incorrect = map(int, tokens[1].split())
                        total = correct + incorrect
                        mpki = incorrect/(total_ins/1000)
                        mpki_axis.append(mpki)
                        line = fp.readline()
                        tokens = line.split(':')
                line = fp.readline()
            print(benchmark)
            print(x_axis)
            print(mpki_axis)

            fig, ax1 = plt.subplots()
            ax1.grid(True)

            xAx = np.arange(len(x_axis))
            ax1.xaxis.set_ticks(np.arange(0, len(x_axis), 1))
            ax1.set_xticklabels(x_axis, rotation=45)
            #plt.xticks(xAx, x_axis, rotation=45)
            ax1.set_xlim(-0.5, len(x_axis) - 0.5)
            ax1.set_ylim(min(mpki_axis) - 0.05, max(mpki_axis) + 0.05)
            ax1.set_ylabel("$MPKI$")
            line1 = ax1.plot(mpki_axis, label="mpki", color="green",marker='o')

            plt.title(benchmark + " MPKI")
            plt.savefig(os.path.join(TARGET_DIR, benchmark+'.png'), bbox_inches='tight')
