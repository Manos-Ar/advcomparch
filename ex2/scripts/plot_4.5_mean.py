#!/usr/bin/env python3

import os
import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats.mstats import gmean


TARGET_DIR = sys.argv[1]


# try:
# 	os.mkdir(TARGET_DIR)
# except FileExistsError:
# 	print('Directory', TARGET_DIR, 'exists.')
# 	ans = input('Do you want to overwrite?[Y/n] ')
# 	if not ans.startswith('y') and not ans.startswith('Y'):
# 		quit()
# print('Directory created')
x_axis = []
# Benchmarks = []
a = {}
mpki_axis = {}

with os.scandir(sys.argv[2]) as it:
	Benchmarks = []
	for entry in it:
		if entry.is_file():
			# print(entry.name)
			bench = entry.name.split('.')
			benchmark = bench[0] + '.' + bench[1]
			Benchmarks.append(benchmark)
			fp = open(entry)
			line = fp.readline()
			while line:
				if line.startswith("Total Instructions"):
					total_ins = int(line.split()[2])
					# print('Total instructions: ', total_ins)
				if line.startswith("Branch Predictors:"):
					line = fp.readline()
					tokens = line.split(':')
					while(len(tokens) > 1):
						name = tokens[0].lstrip()
						correct, incorrect = map(int, tokens[1].split())
						mpki = incorrect/(total_ins/1000)
						if mpki_axis.get(name)==None:
							mpki_axis[name] = dict({benchmark:mpki})

							x_axis.append(name)
						else :
							mpki_axis[name].update(dict({benchmark:mpki}))

						line = fp.readline()
						tokens = line.split(':')
				line = fp.readline()
print(x_axis)
#
# print(mpki_axis.items())
# print(len(mpki_axis[x_axis[0]]))
# print(len(mpki_axis[x_axis[1]]))
print(Benchmarks)
#
with os.scandir(sys.argv[3]) as it:
	Benchmarks = []
	for entry in it:
		if entry.is_file():
			# print(entry.name)
			fp = open(entry)
			bench = entry.name.split('.')
			benchmark = bench[0] + '.' + bench[1]
			Benchmarks.append(benchmark)
			line = fp.readline()
			while line:
				if line.startswith("Total Instructions"):
					total_ins = int(line.split()[2])
					# print('Total instructions: ', total_ins)
				if line.startswith("Branch Predictors:"):
					line = fp.readline()
					tokens = line.split(':')
					while(len(tokens) > 1):
						name = tokens[0].lstrip()

						if name=="Nbit-16K-2":
							correct, incorrect = map(int, tokens[1].split())
							mpki = incorrect/(total_ins/1000)
							if mpki_axis.get(name)==None:
								mpki_axis[name] = dict({benchmark:mpki})
								x_axis.append(name)

							else :
								mpki_axis[name].update(dict({benchmark:mpki}))
							break
						line = fp.readline()
						tokens = line.split(':')
				line = fp.readline()
print(x_axis)
# # print(mpki_axis[x_axis[2]])
# # print(len(mpki_axis[x_axis[2]]))
print(Benchmarks)
# print(mpki_axis.get("Nbit-16K-2"))

#
with os.scandir(sys.argv[4]) as it:
	Benchmarks = []
	for entry in it:
		if entry.is_file():
			# print(entry.name)
			fp = open(entry)
			bench = entry.name.split('.')
			benchmark = bench[0] + '.' + bench[1]
			Benchmarks.append(benchmark)
			line = fp.readline()
			while line:
				if line.startswith("Total Instructions"):
					total_ins = int(line.split()[2])
					# print('Total instructions: ', total_ins)
				if line.startswith("Branch Predictors:"):
					line = fp.readline()
					tokens = line.split(':')
					while(len(tokens) > 1):
						name = tokens[0].lstrip()
						correct, incorrect = map(int, tokens[1].split())
						mpki = incorrect/(total_ins/1000)
						if mpki_axis.get(name)==None:
							mpki_axis[name] = dict({benchmark:mpki})
							x_axis.append(name)

						else :
							mpki_axis[name].update(dict({benchmark:mpki}))

						line = fp.readline()
						tokens = line.split(':')
				line = fp.readline()
x_axis[3] = 'Alpha-21264'
print(x_axis)
print(Benchmarks)
mpki_axis["Alpha-21264"] = mpki_axis.pop("Alpha")
# # del mpki_axis["Alpha"]

# print(mpki_axis.get("Alpha-21264"))
# print(mpki_axis.get("Pentium-M"))
# # print(mpki_axis[x_axis[3]])
# # print(mpki_axis[x_axis[4]])
# # print(len(mpki_axis[x_axis[3]]))
# # print(len(mpki_axis[x_axis[4]]))


with os.scandir(sys.argv[5]) as it:
	Benchmarks = []
	for entry in it:
		if entry.is_file():
			# print(entry.name)
			fp = open(entry)
			line = fp.readline()
			bench = entry.name.split('.')
			benchmark = bench[0] + '.' + bench[1]
			Benchmarks.append(benchmark)
			while line:
				if line.startswith("Total Instructions"):
					total_ins = int(line.split()[2])
					# print('Total instructions: ', total_ins)
				if line.startswith("Branch Predictors:"):
					line = fp.readline()
					tokens = line.split(':')
					while(len(tokens) > 1):
						name = tokens[0].lstrip()
						name_array = name.split('-')

						correct, incorrect = map(int, tokens[1].split())
						mpki = incorrect/(total_ins/1000)
						if name_array[0] == "LocalTwoLevel" :
							bht = list(str(name_array[1]))[0]+'K'
							bht_bit = name_array[2]+"bit"
							predictor = "Local-8K-2cntr-"+bht+'-'+bht_bit
							if mpki_axis.get(predictor)==None:
								mpki_axis[predictor] = dict({benchmark:mpki})
								x_axis.append(predictor)

							else :
								mpki_axis[predictor].update(dict({benchmark:mpki}))
						elif name_array[0] == "GlobalTwoLevel" :
							cntr = name_array[1]
							pht = str(int(32/int(cntr)))+'K'
							bhr = name_array[2]+"bhr"
							predictor = "Global-"+pht+'-'+cntr+"cntr-"+bhr
							if mpki_axis.get(predictor)==None:
								mpki_axis[predictor] = dict({benchmark:mpki})
								x_axis.append(predictor)

							else :
								mpki_axis[predictor].update(dict({benchmark:mpki}))
						line = fp.readline()
						tokens = line.split(':')
				line = fp.readline()
x = x_axis[3]
del x_axis[3]
x_axis.append(x)


with os.scandir(sys.argv[6]) as it:
	Benchmarks = []
	for entry in it:
		if entry.is_file():
			# print(entry.name)
			fp = open(entry)
			bench = entry.name.split('.')
			benchmark = bench[0] + '.' + bench[1]
			Benchmarks.append(benchmark)
			line = fp.readline()
			while line:
				if line.startswith("Total Instructions"):
					total_ins = int(line.split()[2])
					# print('Total instructions: ', total_ins)
				if line.startswith("Branch Predictors:"):
					line = fp.readline()
					tokens = line.split(':')
					while(len(tokens) > 1):
						name = tokens[0].lstrip()
						correct, incorrect = map(int, tokens[1].split())
						mpki = incorrect/(total_ins/1000)
						if mpki_axis.get(name)==None:
							mpki_axis[name] = dict({benchmark:mpki})
							x_axis.append(name)
						else :
							mpki_axis[name].update(dict({benchmark:mpki}))

						line = fp.readline()
						tokens = line.split(':')
				line = fp.readline()

#
print(mpki_axis.items())
print(x_axis)
print(Benchmarks)
# for pre in range(4,10)
# print(mpki_axis[x_axis[4]])
# print(mpki_axis[x_axis[5]])
# print(mpki_axis[x_axis[6]])
# print(mpki_axis[x_axis[7]])
# print(mpki_axis[x_axis[8]])
# print(mpki_axis[x_axis[9]])
# print(mpki_axis[x_axis[9]]["403.gcc"])
# # print(mpki_axis[x_axis[5]])
# # print(mpki_axis[x_axis[6]])
# # print(mpki_axis[x_axis[7]])
# # print(mpki_axis[x_axis[8]])
# # print(mpki_axis[x_axis[9]])
# # print(mpki_axis[x_axis[10]])
# # print(len(mpki_axis[x_axis[5]]))
# # print(len(mpki_axis[x_axis[6]]))
# # print(len(mpki_axis[x_axis[7]]))
# # print(len(mpki_axis[x_axis[8]]))
# # print(len(mpki_axis[x_axis[9]]))
# # print(len(mpki_axis[x_axis[10]]))
#
#
# #
Benchmarks=["403.gcc", "429.mcf", "434.zeusmp", "436.cactusADM", "445.gobmk", "450.soplex", "456.hmmer", "458.sjeng", "459.GemsFDTD", "471.omnetpp",  "473.astar", "483.xalancbmk"]
#

mpki_axis_gmean = {}
mpki_axis_total = []
for predictor in x_axis:
	mpki_axis_predicor = []
	for bench in Benchmarks:
		mpki_axis_predicor.append(mpki_axis[predictor][benchmark])
	mpki_axis_gmean[predictor] = gmean(mpki_axis_predicor)
	mpki_axis_total.append(mpki_axis_gmean[predictor])
print(mpki_axis_gmean)
print(mpki_axis_total)


fig, ax1 = plt.subplots()
ax1.grid(True)

xAx = np.arange(len(x_axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_axis), 1))
ax1.set_xticklabels(x_axis, rotation=90)
# plt.xticks(xAx, x_axis, rotation=45)
ax1.set_xlim(-0.5, len(x_axis) - 0.5)
ax1.set_ylim(min(mpki_axis_total) - 0.005, max(mpki_axis_total) + 0.005)
ax1.set_ylabel("$MPKI$")
line1 = ax1.plot(mpki_axis_total, label="mpki", color="green",marker='o')

plt.title(" MPKI")
plt.savefig(os.path.join(TARGET_DIR,'total.png'), bbox_inches='tight')
