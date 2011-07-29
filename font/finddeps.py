#!/usr/bin/python

import sys, re

res = set()
stack = sys.argv[1:]
expr = re.compile("input\s+([\w.]+)")

while stack:
	current = stack.pop() # Pop from stack
	try:
		with open(current, 'r') as f:
			matches = expr.findall(f.read())
		for r in matches:
			if not "." in r: r = r + ".mf"
			if not r in res:
				stack.append(r) # Push on stack
				res.add(r)
	except IOError:
		pass

if res:
	print reduce(lambda x, y: x + " " + y, res)
