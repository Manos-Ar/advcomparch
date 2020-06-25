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

def get_time_from_output_file(output_file):
	time = -999
	fp = open(output_file, "r")
	line = fp.readline()
	while line:
		if "Execution time" in line:
			time = float(line.split()[1].split(':')[1])
		line = fp.readline()

	fp.close()
	return time

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
nthreads_list = []
nthreads_base = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
nthreads_total = int(sys.argv[1])

for i in range(0, nthreads_base.index(nthreads_total) + 1):
	nthreads_list.append(nthreads_base[i])

for dirname in sys.argv[2:]:
	basename = os.path.basename(dirname)
	output_file = dirname
	# print output_file
	# print basename

	(lock_mech, nthreads, grain_size) = get_params_from_basename(basename)
	# print lock_mech, nthreads, grain_size
	time = get_time_from_output_file(output_file)
	# print time
	results_tuples.append((nthreads, lock_mech, time))


markers = ['.', 'o', 'v', '*', 'D']
colours = ["c", "y", "g", "b", "r", "m"]
fig = plt.figure()
plt.grid(True)
ax = plt.subplot(111)
ax.set_xlabel("$Threads$")
ax.set_ylabel("$Time\_(seconds)$")

i = 0
tuples_by_gs = tuples_by_lock_mech(results_tuples)

# print "RESULT_TUPLES:"
# print results_tuples
# print "TUPLES_BY_GS:"
# print tuples_by_gs

for tuple in tuples_by_gs:
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

x_total_ticks = np.arange(0, len(x_axis))
x_total_labels = map(str, x_axis)
ax.xaxis.set_ticks(x_total_ticks)
ax.xaxis.set_ticklabels(x_total_labels)

lgd = ax.legend(ncol=len(tuples_by_gs), loc="lower center", bbox_to_anchor=(0.5, -0.2), prop={'size':8})
plt.title("Grain Size " + str(grain_size) + " - Scalability")
plt.savefig(str(grain_size) + '.png', bbox_extra_artists=(lgd,), bbox_inches='tight')
