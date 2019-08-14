#!/usr/bin/env python3

import pylab as P
from matplotlib.collections import PatchCollection
from matplotlib.patches import Rectangle
import matplotlib.colors as mcolors
import argparse
import sys

def todict(s,fieldmap={}):
  d={}
  for kv in s.split(" "):
    if "=" in kv:
      k,v = kv.split("=",1)
      if fieldmap and (k in fieldmap):
        k=fieldmap[k]
      try:
        d[k]=float(v)
      except ValueError:
        d[k]=v
  return d

def read_log(f,fieldmap={}):
  colnames=list(mcolors.CSS4_COLORS.keys())
  data=[]
  states=[]
  statecols={}
  laststate=None
  d={}
  boxes=[]
  colindex=0
  for line in f:
    line=line.strip("\r\n")
    if line.startswith("DATA:"):
      if d:
        #print(d)
        d=todict(line.split(":",1)[1],fieldmap)
        data.append(d)
    if line.startswith("STEP:"):
      d2=todict(line.split(":",1)[1])
      #print("d2:",d2)
      d.update(d2)
      if laststate and laststate!=d2['state']:
        if laststate not in statecols:
          statecols[laststate] = colnames[colindex]
          colindex=colindex+1
        states.append( (float(Tstart),float(d2['T']),laststate,statecols[laststate]) )
        print(statecols[laststate])
      if laststate!=d2['state']:
        laststate=d2['state']
        Tstart=d2['T']
  return data,states

def read_data(f, fieldmap):
  data = []
  fields = None
  for line in f:
    line=line.strip(" \r\n")
    if line and not line.startswith("#"):
      d=line.split("|")
      d=[x.strip() for x in d if x.strip()]
      if not fields or ("_" in line) or ("," in line):
        if fieldmap:
          fields2 = []
          for x in d:
            try:
              fields2.append(fieldmap[x])
            except:
              fields2.append(x)
          fields = fields2
        else:
          fields = d
      else:
        try:
          data.append( dict(zip(fields,[float(x) for x in d])) )
        except:
          sys.exit(1)
  return data

def get_yvalue(x,curve):
  for i in range(0,len(curve)-1):
    if x>curve[i][0] and x<curve[i+1][0]:
      d=(x-curve[i][0])/(curve[i+1][0]-curve[i][0])
      return curve[i][1]*(1-d) + curve[i+1][1]*d
  return None


def plot_line(ax,data,fx,fy,color='black'):
  #print(fx,fy)
  xx=[float(d[fx]) for d in data]
  yy=[float(d[fy]) for d in data]
  ax.plot(xx,yy,color=color)
  return list(zip(xx,yy))

def read_fieldmap(f):
  fieldmap = {}
  for line in f:
    line = line.strip("\n\r")
    x,y = line.split("\t")
    fieldmap[x] = y
  return fieldmap

def plot(ax,data,states,xname,yname):
  #fig = P.figure(1)

  #P.subplot2grid((1,1),(0,0), colspan=1, rowspan=1)
  #ax = P.gca()
  ax.set_xlabel(xname)
  ax.set_ylabel(yname)
  curve = plot_line(ax,data,xname,yname,color='black')
  ax.grid()
  ymin,ymax = ax.get_ylim()

  textstr = "start"
  for Tstate in states:
    Tstart,Tend,state,col = Tstate
    boxes = [ P.Rectangle( (Tstart,ymin), Tend-Tstart, ymax-ymin, facecolor=col, alpha=0.5, edgecolor='black' )]
    pc =  PatchCollection(boxes, facecolor=col, alpha=0.5, edgecolor='black')
    ax.add_collection(pc)
  y=0
  for Tstate in states:
    Tstart,Tend,state,col = Tstate
    ax.text(Tstart+0.05, y, state, fontsize=10, verticalalignment='top')
    y=y+(ymax-ymin)*0.1
    if y>ymax:
      y=y-(ymax-ymin)
  return curve

parser = argparse.ArgumentParser(description="Plot log file output from heli tutor or simply XPlane data files")
parser.add_argument('--logfile',help='log file from XPlane (Log.txt) or output from heli_tutor.lua on XPlane data files (Data.txt)')
parser.add_argument('--fieldmap',help='2 column tab separated values mapping names in Data.txt to more readable var names')
parser.add_argument('--x',nargs='+',help='Name of X field for each subplot')
parser.add_argument('--y',nargs='+',help='Name of Y field for each subplot (, separate if specifying multiple fields)')
o=parser.parse_args()

if len(o.x)!=len(o.y):
  print("ERROR! Number of x fields != y fields. There must be an x,y pair per plot")
  sys.exit(1)

if o.fieldmap:
  fieldmap = read_fieldmap(open(o.fieldmap))
else:
  fieldmap = {}
print(fieldmap)

def formater(xname,yname,curve):
    def format_coord(x,y):
        y=get_yvalue(x,curve)
        if y is None:
            return ''
        else:
           return '%s=%1.4f, %s=%1.4f'%(xname, x, yname, y)
    return format_coord

if o.logfile:
  data,states = read_log(open(o.logfile),fieldmap)
  fig,axes = P.subplots(nrows=len(o.x),ncols=1,sharex=True)
  if len(o.x)==1:
    axes = [axes]
  print(o.x)
  print(o.y)
  curves = []
  for ax,xname,yname in zip(axes,o.x,o.y):
    curves.append(plot(ax,data,states,xname,yname))
  for i in range(0,len(axes)):
      axes[i].format_coord = formater(o.x[i],o.y[i],curves[i])
  P.show()
