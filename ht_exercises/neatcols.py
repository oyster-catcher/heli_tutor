#!/usr/bin/env python3
# neatly space columns by | separator (or other)

import sys

try:
  sep=sys.argv[1]
except:
  sep="\t"

maxlens=[]
lines=[]
for line in sys.stdin:
  line = line.strip("\r\n")
  if not line.startswith("#"):
    data = [d.strip(" ") for d in line.split(sep)]
    i=0
    for d in data:
      try:
        maxlens[i] = max(maxlens[i],len(d.strip(" ")))
      except IndexError:
        maxlens.append(len(d.strip(" ")))
      i=i+1
  lines.append(line)

maxlens[-1]=1

for line in lines:
  out=[]
  line = line.strip("\r\n")
  if not line.startswith("#"):
    data = [d.strip(" ") for d in line.split(sep)]
    for l,d in zip(maxlens,data):
      if sep!="\t":
        fmt="%%-%ds" % (l+2)
      else:
        fmt="%s"
      out.append(fmt % d)
    print(sep.join(out))
  else:
    print(line)
