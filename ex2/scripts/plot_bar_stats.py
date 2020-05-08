#!/usr/bin/env python

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


x_Axis = ['Total-Branches', 'Conditional-Taken-Branches', 'Conditional-NotTaken-Branches', 'Unconditional-Branches', 'Calls', 'Returns']
print x_Axis
branches_Axis = []
branches_percent_Axis = []

total_branches = 1L

fp = open(sys.argv[1])
line = fp.readline()
while line:
	tokens = line.split()
	if line.startswith("  Total-Branches:"):
		total_branches = long(tokens[1])
		print total_branches
		branches_Axis.append(total_branches)
		print total_branches
	elif (line.startswith("  Conditional-Taken-Branches:")):
		cond_taken_branches = long(tokens[1])
		print cond_taken_branches
		branches_Axis.append(cond_taken_branches)

		cond_taken_branches_perc = ((cond_taken_branches*100.0) / total_branches)
		print cond_taken_branches_perc, '%'
		branches_percent_Axis.append(cond_taken_branches_perc)
	elif (line.startswith("  Conditional-NotTaken-Branches:")):
		cond_not_taken_branches = long(tokens[1])
		print cond_not_taken_branches
		branches_Axis.append(cond_not_taken_branches)

		cond_not_taken_branches_perc = ((cond_not_taken_branches*100.0) / total_branches)
		print cond_not_taken_branches_perc, '%'
		branches_percent_Axis.append(cond_not_taken_branches_perc)
	elif (line.startswith("  Unconditional-Branches:")):
		uncond_branches = long(tokens[1])
		print uncond_branches
		branches_Axis.append(uncond_branches)

		uncond_branches_perc = ((uncond_branches*100.0) / total_branches)
		print uncond_branches_perc, '%'
		branches_percent_Axis.append(uncond_branches_perc)
	elif (line.startswith("  Calls:")):
		calls = long(tokens[1])
		print calls
		branches_Axis.append(calls)

		calls_perc = ((calls*100.0) / total_branches)
		print calls_perc, '%'
		branches_percent_Axis.append(calls_perc)
	elif (line.startswith("  Returns:")):
		returns = long(tokens[1])
		print returns
		branches_Axis.append(returns)

		returns_perc = ((returns*100.0) / total_branches)
		print returns_perc, '%'
		branches_percent_Axis.append(returns_perc)

	line = fp.readline()


fig, ax1 = plt.subplots()
ax1.grid(True, linestyle='--', which='major', color='grey', alpha=.25)

branches_Axis.sort(reverse = True)
print branches_Axis
print x_Axis

#
# xAx = np.arange(len(x_Axis))
#ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
#ax1.set_xticklabels(x_Axis, rotation=45)
#plt.xticks(np.arange(len(x_Axis)),x_Axis)
plt.xticks(rotation=90)

#ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
#ax1.set_ylim(min(branches_Axis) - 0.05, max(branches_Axis) + 0.05)
ax1.set_ylabel("$Branches$")

# line1 = ax1.plot(branches_Axis, label="mpki", color="red",marker='x')
line1 = plt.bar(x_Axis, branches_Axis,width = 0.5, color="red")


# Add the data value on head of the bar
for value in line1:
	height = value.get_height()
	ax1.text(value.get_x() + value.get_width()/2., 1.002*height,'%d' % int(height), ha='center', va='bottom')

# lgd = ax1.legend()
# lgd.draw_frame(False)


plt.title("Branches")
plt.savefig("stats.png",bbox_inches="tight")
