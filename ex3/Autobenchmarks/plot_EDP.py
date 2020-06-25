#!/usr/bin/env python

import sys, os
import itertools, operator
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def get_params_from_basename(basename):
	tokens = basename.split('.')
	bench = tokens[0]
	input_size = 'ref'
	dw = int(tokens[1].split('-')[0].split('_')[1])
	ws = int(tokens[1].split('-')[1].split('_')[1])
	return (bench, input_size, dw, ws)

def get_time_from_output_file(output_file):
	time = -999
	fp = open(output_file, "r")
	line = fp.readline()
	while line:
		if "  Time (ns)" in line:
			time = float(line.split()[3])
		line = fp.readline()

	fp.close()
	return time

def get_energy_from_power_file(power_file):
	energy = -999
	fp = open(power_file, "r")
	line = fp.readline()
	while line:
		if (line.startswith("  total")):
			energy = float(line.split()[3])
		line = fp.readline()
	fp.close()
	return energy

def tuples_by_dispatch_width(tuples):
	ret = []
	tuples_sorted = sorted(tuples, key=operator.itemgetter(0))
	for key,group in itertools.groupby(tuples_sorted,operator.itemgetter(0)):
		ret.append((key, zip(*map(lambda x: x[1:], list(group)))))
	return ret

global_ws = [16,32,64,96,128,192,256,384]

if len(sys.argv) < 2:
	print "usage:", sys.argv[0], "<output_directories>"
	sys.exit(1)

results_tuples = []

for dirname in sys.argv[1:]:
	if dirname.endswith("/"):
		dirname = dirname[0:-1]
	basename = os.path.basename(dirname)
	# print dirname
	# print basename
	benchmark = basename.split('.')[0]
	# print benchmark
	#output_dirname = '/'.join(['.', 'Outputs', benchmark, basename])
	# print output_dirname

	output_file = dirname + "/sim.out"
	power_file = dirname + "/power.total.out"

	# print output_file
	# print power_file

	(bench, input_size, dispatch_width, window_size) = get_params_from_basename(basename)
	time = get_time_from_output_file(output_file)
	energy = get_energy_from_power_file(power_file)
	EDP = (time / 1000000000) * energy
	# print time
	# print energy
	# print EDP
	results_tuples.append((dispatch_width, window_size, EDP))

markers = ['.', 'o', 'v', '*', 'D']
colours = ["r", "y", "g", "b", "c", "m"]
fig = plt.figure()
plt.grid(True)
ax = plt.subplot(111)
ax.set_xlabel("$Window\_Size$")
ax.set_ylabel("$EDP$")

i = 0
tuples_by_dw = tuples_by_dispatch_width(results_tuples)

# print "RESULT_TUPLES:"
# print results_tuples
# print "TUPLES_BY_DW:"
# print tuples_by_dw

for tuple in tuples_by_dw:
	dw = tuple[0]
	ws_axis = tuple[1][0]
	ipc_axis = tuple[1][1]
	x_ticks = np.arange(len(global_ws)-len(ws_axis), len(global_ws))
	x_labels = map(str, ws_axis)

	# print "tuple:"
	# print tuple
	# print "dw:", dw
	# print "ws_axis:", ws_axis
	# print "ipc_axis:", ipc_axis
	# print "len(global_ws)-len(ws_axis) =",len(global_ws)-len(ws_axis)
	# print "x_ticks:", x_ticks
	# print "x_labels:", x_labels


	ax.plot(x_ticks, ipc_axis, label="DW_"+str(dw), marker=markers[i%len(markers)], color=colours[i])
	i = i + 1

x_total_ticks = np.arange(0, len(global_ws))
x_total_labels = map(str, global_ws)
ax.xaxis.set_ticks(x_total_ticks)
ax.xaxis.set_ticklabels(x_total_labels)

lgd = ax.legend(ncol=len(tuples_by_dw), loc="lower center", bbox_to_anchor=(0.5, -0.2), prop={'size':8})
plt.title(bench + " - EDP")
plt.savefig(bench+'_EDP.png', bbox_extra_artists=(lgd,), bbox_inches='tight')
