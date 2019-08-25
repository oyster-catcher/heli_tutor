#!/usr/bin/env python3

import pylab as P
import matplotlib
from matplotlib.collections import PatchCollection
from matplotlib.patches import Rectangle
import matplotlib.colors as mcolors
import random
import argparse
import sys

global o

def strlim(s,maxlen):
  if len(s)>maxlen:
    s=s[0:maxlen-3]+"..."
  return s

def checkempty(d,k,default=""):
  if k in d:
    return d[k]
  else:
    return default

def todict(s,fieldmap={}):
  d={}
  # parse into parts
  inquote=False
  parts=[]
  current=""
  for c in s:
    if inquote:
      if c!='"':
        current=current+c
      else:
        inquote=False
    else:
      if c==" ":
        parts.append(current)
        current=""
      else:
        if c=='"':
          inquote=True
        else:
          current=current+c
  parts.append(current)

  for kv in parts:
    if "=" in kv:
      k,v = kv.split("=",1)
      if fieldmap and (k in fieldmap):
        k=fieldmap[k]
      try:
        d[k]=float(v)
      except ValueError:
        d[k]=v
  return d

def read_data(f,fieldmap={}):
  fields=None
  for line in f:
    line = line.strip("\r\n")
    data = [x.strip() for x in line.split("|")]
    if not fields:
      fields = []
      for fieldname in fields:
        if fieldname in fieldmap:
          fields.append(fieldmap[fieldname])
        else:
          fields.append(fieldname)
    else:
      d = zip(fields,[float(x) for x in data])
      yield d

def excludekey(d,excludekeys):
  l = [(k,v) for k,v in d.items() if k not in excludekeys]
  return dict(l)

def segment(events):
  """Join repeated events with new labels Tstart,Tend"""
  last={}
  segments=[]
  for d in events:
    if excludekey(last,['T'])==excludekey(d,['T']):
      Tall.append(d['T'])
      Tend=d['T']
    else:
      if last:
        del last['T']
        last['Tstart']=Tstart
        last['Tend']=d['T']
        last['Tall']=Tall
        segments.append(last)
      Tstart=d['T']
      Tend=d['T']
      Tall=[d['T']]
    last=d
  if last:
    del last['T']
    last['Tstart']=Tstart
    last['Tend']=Tend
    last['Tall']=Tall
    segments.append(last)
  return segments

def read_log(f,fieldmap={}):
  colnames=list(mcolors.CSS4_COLORS.keys())
  data=[]
  steps=[] # corresponds to STEP: events (includes state)
  speaks=[] # corresponds to SPEAK: events
  fires=[] # corresponds to FIRE: events
  d={}
  boxes=[]
  colindex=0
  for line in f:
    line=line.strip("\r\n")
    if line.startswith("DATA:"): # always first
      d=todict(line.split(":",1)[1],fieldmap)
      data.append(d)

    if line.startswith("STEP:"):
      d2=todict(line.split(":",1)[1])
      d2['T']=d['T']
      steps.append(d2)

    if line.startswith("SPEAK:"):
      d2=todict(line.split(":",1)[1])
      d2['T']=d['T']
      speaks.append(d2)

    # FIRE: to=intro1 prob=1 command=dir=heading from=check msgcode=HI condition=y_agl_ft<5
    if line.startswith("FIRE:"):
      d2=todict(line.split(":",1)[1])
      d2['T']=d['T']
      fires.append(d2)
  return data,segment(steps),segment(fires),speaks

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
    if x>=curve[i][0] and x<curve[i+1][0]:
      d=(x-curve[i][0])/(curve[i+1][0]-curve[i][0])
      return curve[i][1]*(1-d) + curve[i+1][1]*d
  return None

def get_segment(t,segments):
  for segment in segments:
    if t>=segment['Tstart'] and t<=segment['Tend']:
      return segment
  return None

def plot_line(ax,data,fx,fy,color='black'):
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

def position_text(ax,textstr,Tall,curve,o):
  xmin,xmax = ax.get_xlim()
  ymin,ymax = ax.get_ylim()
  Tstart,Tend = Tall[0],Tall[-1]
  if o.portrait:
    ax.text((xmin+xmax)*0.5, Tstart, strlim(textstr,o.labellim), ha='center', fontsize=7, rotation_mode='anchor', rotation=0, bbox=dict(facecolor='white', alpha=0.6))
    x=xmin+0.05*(xmax-xmin)*random.random()
    l=matplotlib.lines.Line2D([x,(xmin+xmax)*0.5],[(Tstart+Tend)*0.5,Tstart])
    ax.add_line(l)
    for t in Tall:
      l=matplotlib.lines.Line2D([x,(xmin+xmax)*0.5],[t,(Tstart+Tend)*0.5])
      ax.add_line(l)
  else:
    ymid=get_yvalue(0.5*(Tstart+Tend),curve)
    if ymax-ymid < ymid-ymin: # closer to top
      ymid = ymin
    ymid = ymid+(ymax-ymin)*0.1
    ax.text(0.5*(Tstart+Tend), ymid, strlim(textstr,o.labellim), fontsize=7, rotation_mode='anchor', rotation=45, bbox=dict(facecolor='white', alpha=0.6))
    for t in Tall:
      y=get_yvalue(t,curve)
      l=matplotlib.lines.Line2D([t,0.5*(Tstart+Tend)],[y,ymid])
      ax.add_line(l)

def plot(ax,data,states,xname,yname,label=None):
  colnames=list(mcolors.CSS4_COLORS.keys())
  ax.set_xlabel(xname)
  ax.set_ylabel(yname)
  curve = plot_line(ax,data,xname,yname,color='black')
  ax.grid()
  xmin,xmax = ax.get_xlim()
  ymin,ymax = ax.get_ylim()
  if o.portrait:
    Tmin,Tmax=ymin,ymax
  else:
    Tmin,Tmax=xmin,xmax

  # color regions by the state we are in
  statecol={}
  colindex=0
  y=0
  for d in states:
    Tstart = d['Tstart']
    Tend = d['Tend']
    state = d['state']
    if state not in statecol:
      colindex = colindex + 1
      statecol[state] = colnames[colindex]
      colindex = colindex + 1
    col = statecol[state]
    if o.portrait:
      ax.text((xmin+xmax)*0.5, (Tstart+Tend)*0.5, state, fontsize=10, ha='left', rotation_mode='anchor')
    else:
      ax.text((Tstart+Tend)*0.5, y, state, fontsize=10, ha='center', rotation_mode='anchor')
    if o.portrait:
      ax.axhspan(ymin=Tstart,ymax=Tend,facecolor=col,alpha=0.3)
    else:
      ax.axvspan(xmin=Tstart,xmax=Tend,facecolor=col,alpha=0.3)
    y=y+(ymax-ymin)*0.1
    if y>ymax:
      y=y-(ymax-ymin)
  ymin,ymax = ax.get_ylim()

  for d in fires:
    Tstart = d['Tstart']
    Tend = d['Tend']
    if ((Tstart>Tmin)and(Tstart<Tmax)) or ((Tend>Tmin)and(Tend<Tmax)):
      col = 'red'
      textstr=""
      if 'condition' in d:
        textstr=textstr+"IF + " + checkempty(d,'condition') + " THEN "
      if 'msgcode' in d:
        textstr=textstr+'"'+checkempty(d,'msgcode')+'" '
      if 'command' in d:
        textstr=textstr+checkempty(d,'command')
      if textstr and label=="FIRE":
        position_text(ax,textstr,d['Tall'],curve,o)

  for d in speaks:
    T = d['T']
    if (T>Tmin)and(T<Tmax):
      if label=="SPEAK":
        position_text(ax,d['message'],[T],curve,o)
  return curve

parser = argparse.ArgumentParser(description="Plot log file output from heli tutor or simply XPlane data files")
parser.add_argument('--logfile',help='log file from XPlane (Log.txt) or output from heli_tutor.lua on XPlane Data.txt files')
parser.add_argument('--datfile',help='data file from XPlane (Data.txt) - not required if using Log.txt while Heli Tutor is running')
parser.add_argument('--fieldmap',help='2 column tab separated values mapping names in Data.txt to more readable var names')
parser.add_argument('--labellim',type=int,help='Limit length of text on the plot to this many characters (default=50)',default=50)
parser.add_argument('--axes',nargs='+',help='Each axes is a pair or more of values to plot in the form X,Y1,Y2,Y3')
parser.add_argument('--labels',nargs='+',help='One additional text label per plot can be provided. i.e. SPEAK or FIRE',default=[])
parser.add_argument('--portrait',action='store_true',help='Plots should be portrait so they span the entire height with multiple plots across')
o=parser.parse_args()

if o.fieldmap:
  fieldmap = read_fieldmap(open(o.fieldmap))
else:
  fieldmap = {}

def formater(xname,yname,curve,states,fires,speaks):
    def format_coord(x,y):
        y=get_yvalue(x,curve)
        text=""
        stateseg=get_segment(x,states)
        if stateseg:
          text=" state="+stateseg['state']
        fireseg=get_segment(x,fires)
        if fireseg:
          text=" IF %s" % fireseg['condition']
          try:
            text=text+" THEN " + fireseg['command']
          except:
            pass
          try:
            text=text+" SPEAK " + fireseg['msgcode']
          except:
            pass
        text=text.strip("\r\n")
        if y is None:
            return ''
        else:
           return '%s=%1.4f, %s=%1.4f%s' % (xname, x, yname, y, text)
    return format_coord

data=[]
steps=[]
fires=[]
speaks=[]

if o.datfile:
  print(fieldmap)
  data = read_data(open(o.datfile),fieldmap)
  for d in data:
    print(d)
  steps = []
  fires = []
  speaks = []

if o.logfile:
  data,steps,fires,speaks = read_log(open(o.logfile),fieldmap)

if data:
  if o.portrait:
    fig,axes = P.subplots(nrows=1,ncols=len(o.axes),sharey=True)
  else:
    fig,axes = P.subplots(nrows=len(o.axes),ncols=1,sharex=True)
  if len(o.axes)==1:
    axes = [axes]
  curves = []
  li = 0
  for ax,axesnames in zip(axes,o.axes):
    xname,yname = axesnames.split(",")
    if o.portrait:
      xname,yname = yname,xname

    try:
      label=o.labels[li]
    except IndexError:
      label=None
    curves.append(plot(ax,data,steps,xname,yname,label))
    li=li+1
  for i in range(0,len(axes)):
      axesnames = o.axes[i]
      xname,yname = axesnames.split(",")
      axes[i].format_coord = formater(xname,yname,curves[i],steps,fires,speaks)
  P.show()
