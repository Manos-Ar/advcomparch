#!/usr/bin/env python3

import os
import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats.mstats import gmean

TARGET_DIR = "/home/manos/Desktop/ras"
'''
try:
    os.mkdir(TARGET_DIR)
except FileExistsError:
    print('Directory', TARGET_DIR, 'exists.')
    ans = input('Do you want to overwrite?[Y/n] ')
    if not ans.startswith('y') and not ans.startswith('Y'):
        quit()
print('Directory created')
'''

first = True
total = {}
x_axis = []
mpki_axis = []

with os.scandir("/home/manos/Desktop/outputs/outputs_branch_ras") as it:
    for entry in it:
        if entry.is_file():
            fp = open(entry)
            line = fp.readline()
            while line:
                if line.startswith("Total Instructions"):
                    total_ins = int(line.split()[2])
                    print('Total instructions: ', total_ins)
                if line.startswith("RAS"):
                    line = fp.readline()
                    tokens = line.split(':')
                    while(len(tokens) > 1):
                        predictor = tokens[0].lstrip()
                        correct, incorrect = map(int, tokens[1].split())
                        mpki = incorrect/(correct+incorrect)*100
                        if first:
                            total[predictor] = [mpki]
                        else:
                            total[predictor].append(mpki)
                        line = fp.readline()
                        tokens = line.split(':')
                line = fp.readline()
            first = False

for key, value in total.items():
    print(key, value)
    value = gmean(value)
    print(key, value)
    x_axis.append(key)
    mpki_axis.append(value)
    print(x_axis)
    print(mpki_axis)

fig, ax1 = plt.subplots()
ax1.grid(True)

xAx = np.arange(len(x_axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_axis), 1))
ax1.set_xticklabels(x_axis, rotation=45)
ax1.set_xlim(-0.5, len(x_axis) - 0.5)
ax1.set_ylim(min(mpki_axis) - 0.05, max(mpki_axis) + 0.05)
ax1.set_ylabel("$Miss Ratio$")
line1 = ax1.plot(mpki_axis, label="mpki", color="green",marker='o')

plt.title("Miss ratio (%)")
plt.savefig(os.path.join(TARGET_DIR, 'total.png'), bbox_inches='tight')
