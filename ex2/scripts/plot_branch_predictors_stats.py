#!/usr/bin/env python

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
print(sys.argv[1])
file = sys.argv[1].split("/")
print file
name = file[6].split(".")
print name
benchmark = name[0]+"."+name[1]
print benchmark


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
	elif (line.startswith("  Conditional-Taken-Branches:")):
		cond_taken_branches = long(tokens[1])
		print cond_taken_branches
		branches_Axis.append(cond_taken_branches)

		cond_taken_branches_perc = "{:.2f}".format((cond_taken_branches*100.0) / total_branches)
		print cond_taken_branches_perc, '%'
		branches_percent_Axis.append(cond_taken_branches_perc)
	elif (line.startswith("  Conditional-NotTaken-Branches:")):
		cond_not_taken_branches = long(tokens[1])
		print cond_not_taken_branches
		branches_Axis.append(cond_not_taken_branches)

		cond_not_taken_branches_perc = "{:.2f}".format((cond_not_taken_branches*100.0) / total_branches)
		print cond_not_taken_branches_perc, '%'
		branches_percent_Axis.append(cond_not_taken_branches_perc)
	elif (line.startswith("  Unconditional-Branches:")):
		uncond_branches = long(tokens[1])
		print uncond_branches
		branches_Axis.append(uncond_branches)

		uncond_branches_perc =  "{:.2f}".format((uncond_branches*100.0) / total_branches)
		print uncond_branches_perc, '%'
		branches_percent_Axis.append(uncond_branches_perc)
	elif (line.startswith("  Calls:")):
		calls = long(tokens[1])
		print calls
		branches_Axis.append(calls)

		calls_perc =  "{:.2f}".format((calls*100.0) / total_branches)
		print calls_perc, '%'
		branches_percent_Axis.append(calls_perc)
	elif (line.startswith("  Returns:")):
		returns = long(tokens[1])
		print returns
		branches_Axis.append(returns)

		returns_perc =  "{:.2f}".format((returns*100.0) / total_branches)
		print returns_perc, '%'
		branches_percent_Axis.append(returns_perc)

	line = fp.readline()


# BARS CHART
fig1, ax1 = plt.subplots()
ax1.grid(True, linestyle='--', which='major', color='grey', alpha=.25)

xAx = np.arange(len(x_Axis))
ax1.set_ylabel("$Branches$")
plt.xticks(rotation=45)

line1 = ax1.bar(xAx, branches_Axis, color="green", width=0.8, tick_label=x_Axis)

# Add the data value on head of the bar
#for value in line1:
#	height = value.get_height()
#	ax1.text(value.get_x() + value.get_width()/2., 1.002*height,'%d' % int(height), ha='center', va='bottom')

# lgd = ax1.legend()
# lgd.draw_frame(False)
plt.title(benchmark)
fig1.savefig("bar.png",bbox_inches="tight")

# PIE CHART
fig2, ax2 = plt.subplots()
labels =  ['Conditional-Taken-Branches', 'Conditional-NotTaken-Branches', 'Unconditional-Branches', 'Calls', 'Returns']
line2 = ax2.pie(branches_percent_Axis, explode=None, labels=labels, autopct='%1.1f%%', shadow=True)
ax2.axis('equal')

plt.title(benchmark)
fig2.savefig("pie.png",bbox_inches="tight")
