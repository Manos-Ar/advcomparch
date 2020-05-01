#!/usr/bin/env python

import sys
import numpy as np
from cycles import adjust

## We need matplotlib:
## $ apt-get install python-matplotlib python-scipy python-numpy
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats.mstats import gmean

ipc_color="blue"


configurations=11

x_Axis = []
ipc_Axis = []
ipc_conf = np.ones(10)

inputs = sys.argv[1:]


for outFile in range(0,configurations):
	for bench in range(0,10):
		fp = open(inputs[outFile*10+bench])
		line = fp.readline()
		print outFile
		while line:
			tokens = line.split()
			if (line.startswith("Total Instructions: ")):
				total_instructions = long(tokens[2])
			elif (line.startswith("IPC:")):
				ipc = float(tokens[1])
				ipc_conf[bench] = ipc
			elif (line.startswith("  L1-Data Cache")):
				sizeLine = fp.readline()
				l1_size = sizeLine.split()[1]
				bsizeLine = fp.readline()
				l1_bsize = bsizeLine.split()[2]
				assocLine = fp.readline()
				l1_assoc = assocLine.split()[1]

				print ipc
				print ipc_conf

			line = fp.readline()

		fp.close()

	ipc_geo = gmean(ipc_conf)
	print ipc_geo

	l1ConfigStr = '{}K.{}.{}B'.format(l1_size,l1_assoc,l1_bsize)
	print l1ConfigStr
	x_Axis.append(l1ConfigStr)
	ipc_Axis.append(ipc_geo)

normal_ipc = ipc_Axis[0]

print ipc_Axis

adjusted_ipc_Axis = adjust(x_Axis, ipc_Axis)
##ipc_Axis = [x / normal_ipc for x in ipc_Axis]
print x_Axis
print ipc_Axis
##adjusted_ipc_Axis = [x /normal_ipc for x in adjusted_ipc]
concat_ipc = ipc_Axis + adjusted_ipc_Axis

fig, ax1 = plt.subplots()
ax1.grid(True)
ax1.set_xlabel("L1 - CacheSize.Assoc.BlockSize")

xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(concat_ipc) - 0.05 * min(concat_ipc), max(concat_ipc) + 0.05 * max(concat_ipc))
ax1.set_ylabel("$Normalized$  $IPC$")
ax1.tick_params(axis='y')
line1 = ax1.plot(ipc_Axis, label="ipc_old", color=ipc_color,marker='x')

line2 = ax1.plot(adjusted_ipc_Axis, label="ipc_new", color="green",marker='^')

lns = line1 + line2
labs = [l.get_label() for l in lns]

plt.title("L1-Geometric mean of IPC")
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("L1.png",bbox_inches="tight")
