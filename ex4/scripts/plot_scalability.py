#!/usr/bin/env python

import sys, os
import itertools, operator
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def get_params_from_basename(basename):
	tokens = basename.split('.')
	lock_mech = tokens[0]
	nthreads = int(tokens[1].split('-')[0].split('_')[1])
	grain_size = int(tokens[1].split('-')[1].split('_')[1])
	return (lock_mech, nthreads, grain_size)

def get_cycles_from_output_file(output_file):
	cycles = -999
	fp = open(output_file, "r")
	line = fp.readline()
	while line:
		if "Cycles" in line:
			cycles = int(line.split()[2]) / 1000000.0
		line = fp.readline()

	fp.close()
	return cycles

def tuples_by_lock_mech(tuples):
	ret = []
	tuples_sorted = sorted(tuples, key=operator.itemgetter(1))
	for key,group in itertools.groupby(tuples_sorted,operator.itemgetter(1)):
		ret.append((key, zip(*map(lambda x: x[1:], list(group)))))
	return ret



if len(sys.argv) < 2:
	print "usage:", sys.argv[0], "<output_directories>"
	sys.exit(1)

results_tuples = []
nthreads_list = [1, 2, 4, 8, 16]

for dirname in sys.argv[1:]:
	if dirname.endswith("/"):
		dirname = dirname[0:-1]
	basename = os.path.basename(dirname)
	output_file = dirname + "/sim.out"

	(lock_mech, nthreads, grain_size) = get_params_from_basename(basename)
	cycles = get_cycles_from_output_file(output_file)
	results_tuples.append((nthreads, lock_mech, cycles))


markers = ['.', 'o', 'v', '*', 'D']
colours = ["c", "y", "g", "b", "r", "m"]
fig = plt.figure()
plt.grid(True)
ax = plt.subplot(111)
ax.set_xlabel("$Threads$")
ax.set_ylabel("$Cycles\_(Millions)$")

i = 0
tuples_by_gs = tuples_by_lock_mech(results_tuples)

# print "RESULT_TUPLES:"
# print results_tuples
# print "TUPLES_BY_GS:"
# print tuples_by_gs

for tuple in tuples_by_gs:
	print(tuple)
	gs = tuple[0]
	y_axis = tuple[1][1]
	x_axis = nthreads_list
	x_ticks = np.arange(0, len(x_axis))
	x_labels = [str(x) + "-Threads" for x in x_axis]

	# print "tuple:"
	# print tuple
	# print "gs:", gs
	# print "y_axis:", y_axis
	# print "x_axis:", x_axis
	# print "x_ticks:", x_ticks
	# print "x_labels:", x_labels

	ax.plot(x_ticks, y_axis, label=str(gs), marker=markers[i%len(markers)])
	i = i + 1

x_total_ticks = np.arange(0, len(nthreads_list))
x_total_labels = map(str, nthreads_list)
ax.xaxis.set_ticks(x_total_ticks)
ax.xaxis.set_ticklabels(x_total_labels)

lgd = ax.legend(ncol=len(tuples_by_gs), loc="lower center", bbox_to_anchor=(0.5, -0.2), prop={'size':8})
plt.title("Grain Size " + str(grain_size) + " - Scalability")
plt.savefig(str(grain_size) + '.png', bbox_extra_artists=(lgd,), bbox_inches='tight')
