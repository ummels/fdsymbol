#!/usr/bin/env python3

import sys
import re
import os.path
from functools import reduce

res = set()
stack = [os.path.normpath(x) for x in sys.argv[1:]]
expr = re.compile("input\s+([\w.]+)")

while stack:
    current = stack.pop() # Pop from stack
    try:
        basedir = os.path.dirname(current)
        with open(current, 'r') as f:
            matches = expr.findall(f.read())
        for r in matches:
            if not "." in r: r = r + ".mf"
            r = os.path.normpath(os.path.join(basedir, r))
            if os.path.exists(r) and r not in res:
                stack.append(r) # Push on stack
                res.add(r)
    except IOError:
        pass

if res:
    print(reduce(lambda x, y: x + " " + y, res))
