#!/usr/bin/env python

import sys
import numpy as np

## We need matplotlib:
## $ apt-get install python-matplotlib python-scipy python-numpy
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats.mstats import gmean

ipc_color="red"


configurations=12

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
			elif (line.startswith("  Data Tlb")):
				sizeLine = fp.readline()
				tlb_size = sizeLine.split()[1]
				bsizeLine = fp.readline()
				tlb_bsize = bsizeLine.split()[2]
				assocLine = fp.readline()
				tlb_assoc = assocLine.split()[1]

				print ipc
				print ipc_conf

			line = fp.readline()

		fp.close()

	ipc_geo = gmean(ipc_conf)
	print ipc_geo

	tlbConfigStr = '{}.{}.{}B'.format(tlb_size,tlb_assoc,tlb_bsize)
	print tlbConfigStr
	x_Axis.append(tlbConfigStr)
	ipc_Axis.append(ipc_geo)

normal_ipc = min(ipc_Axis)

print ipc_Axis
##ipc_Axis = [x / normal_ipc for x in ipc_Axis]

print x_Axis
print ipc_Axis

fig, ax1 = plt.subplots()
ax1.grid(True)
ax1.set_xlabel("TLB - CacheSize.Assoc.BlockSize")

xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(ipc_Axis) - 0.05 * min(ipc_Axis), max(ipc_Axis) + 0.05 * max(ipc_Axis))
ax1.set_ylabel("$IPC$")
line1 = ax1.plot(ipc_Axis, label="ipc", color=ipc_color,marker='x')

lns = line1
labs = [l.get_label() for l in lns]

plt.title("Geometric Mean Of IPC")
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("TLB.png",bbox_inches="tight")
