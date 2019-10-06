#!/usr/bin/env python3

import pylab as P
import matplotlib
import math
import numpy as N
import matplotlib.gridspec as gridspec
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

def get_xyvalue_from_t(t,curve):
  """curve is a list of entries with t,x,y"""
  for i in range(0,len(curve)-1):
    if t>=curve[i][0] and t<curve[i+1][0]:
      d=(t-curve[i][0])/(curve[i+1][0]-curve[i][0])
      return curve[i][1]*(1-d) + curve[i+1][1]*d, curve[i][2]*(1-d) + curve[i+1][2]*d
  return None,None

def get_nearest(x,y,curve):
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

def plot_line(ax,data,fx,fy,color='black',width=1,alpha=1):
  tt=[float(d['T']) for d in data]
  if fx:
    xx=[float(d[fx]) for d in data]
  else:
    xx=[]
  if fy:
    yy=[float(d[fy]) for d in data]
  else:
    yy=[]
  # Deal with special case with no X or Y axis, the most likely case for
  # this is when you just want to show FIRE or SPEAK against T with no
  # line shown
  if yy and (not xx):
    xx=[0]*len(yy)
  if xx and (not yy):
    yy=[0]*len(xx)
  if xx and yy:
    ax.plot(xx,yy,color=color,linewidth=width,alpha=alpha)
  return list(zip(tt,xx,yy))

def read_fieldmap(f):
  fieldmap = {}
  for line in f:
    line = line.strip("\n\r")
    x,y = line.split("\t")
    fieldmap[x] = y
  return fieldmap

def position_text(ax,textstr,Tall,curve,xname,yname,o):
  xmin,xmax = ax.get_xlim()
  ymin,ymax = ax.get_ylim()
  useT = (xname=='T') or (yname=='T')
  Tstart,Tend = Tall[0],Tall[-1]
  tx,ty=get_xyvalue_from_t(0.5*(Tstart+Tend),curve)
  if (tx is None) or (ty is None):
    return
  if useT:
    if xname=='T':
      ha='left'
      rotation=o.labelrot
      tx=tx+(xmax-xmin)*o.labeloffx
      ty=ty+(ymax-ymin)*o.labeloffy
      #ax.text((xmin+xmax)*0.5, Tstart, strlim(textstr,o.labellim), ha='center', fontsize=7, rotation_mode='anchor', rotation=0, bbox=dict(facecolor='white', alpha=0.6))
      #x=xmin+0.05*(xmax-xmin)*random.random()
      #l=matplotlib.lines.Line2D([x,(xmin+xmax)*0.5],[(Tstart+Tend)*0.5,Tstart])
      #ax.add_line(l)
      #for t in Tall:
      #  nx,vy = get_xyvalue_from_t(t,curve)
      #  l=matplotlib.lines.Line2D([nx,xmid],[ny,ymid])
      #  ax.add_line(l)
    else:
      ha='left'
      rotation=0
      tx=tx+(xmax-xmin)*o.labeloffx
  else: # could be LAT vs LON, a non-linear plot to text positioning needs to change
    ha='left'
    rotation=0
    dx,dy = tx-0.5*(xmin+xmax), ty-0.5*(ymin+ymax)
    d= math.sqrt(dx*dx+dy*dy)
    dx,dy = dx/d,dy/d
    tx = tx + dx*(xmax-xmin)*o.labeloffx
    ty = ty + dy*(ymax-ymin)*o.labeloffy
    if tx < 0.5*(xmin+xmax):
      ha='right'
    #ax.text(tx, ty, strlim(textstr,o.labellim), fontsize=7, ha='left', rotation_mode='anchor', rotation=0, bbox=dict(facecolor='white', alpha=0.6))

  # Draw text
  ax.text(tx, ty, strlim(textstr,o.labellim), fontsize=7, ha=ha, rotation_mode='anchor', rotation=rotation, bbox=dict(facecolor='white', alpha=0.6))

  # Draw multiple lines to curve if multiple repetitions
  for t in Tall:
    nx,ny = get_xyvalue_from_t(t,curve)
    l=matplotlib.lines.Line2D([nx,tx],[ny,ty])
    x,y=get_xyvalue_from_t(t,curve)
    l=matplotlib.lines.Line2D([nx,tx],[ny,ty],linestyle='--',alpha=0.5)
    ax.add_line(l)

def plot(ax,data,states,xname,yname,label=None):
  colnames=list(mcolors.CSS4_COLORS.keys())
  ax.set_xlabel(xname)
  ax.set_ylabel(yname)
  curve = plot_line(ax,data,xname,yname,color='black')
  ax.grid()
  if not xname:
    ax.set_xlim((0,1))
  if not yname:
    ax.set_ylim((0,1))
  xmin,xmax = ax.get_xlim()
  ymin,ymax = ax.get_ylim()
  Tmin,Tmax=xmin,xmax
  if xname!="T":
    Tmin=0
    Tmax=10000

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
    if yname=='T':
      ax.text((xmin+xmax)*0.5, (Tstart+Tend)*0.5, state, fontsize=10, ha='left', rotation_mode='anchor')
    if xname=='T':
      ax.text((Tstart+Tend)*0.5, y, state, fontsize=10, ha='center', rotation_mode='anchor')
    if yname=='T':
      ax.axhspan(ymin=Tstart,ymax=Tend,facecolor=col,alpha=0.3)
    if xname=='T':
      ax.axvspan(xmin=Tstart,xmax=Tend,facecolor=col,alpha=0.3)
    if xname!='T' and yname!='T':
      dataseg=[]
      for d in data:
        if d['T']>Tstart and d['T']<Tend:
          dataseg.append(d)
      plot_line(ax,dataseg,xname,yname,width=20,alpha=0.2,color=col)
    y=y+(ymax-ymin)*0.1
    if y>ymax:
      y=y-(ymax-ymin)
  ymin,ymax = ax.get_ylim()

  for label in labels:
    for d in fires:
      if label=="FIRE":
        print("FIRE:",d)
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
          if textstr:
            position_text(ax,textstr,d['Tall'],curve,xname,yname,o)

    if label=="SPEAK":
      for d in speaks:
        T = d['T']
        if (T>Tmin)and(T<Tmax):
          position_text(ax,d['message'],[T],curve,xname,yname,o)
  return curve

parser = argparse.ArgumentParser(description="Plot log file output from heli tutor or simply XPlane data files")
parser.add_argument('--logfile',help='log file from XPlane (Log.txt) or output from heli_tutor.lua on XPlane Data.txt files')
parser.add_argument('--datfile',help='data file from XPlane (Data.txt) - not required if using Log.txt while Heli Tutor is running')
parser.add_argument('--fieldmap',help='2 column tab separated values mapping names in Data.txt to more readable var names')
parser.add_argument('--labellim',type=int,help='Limit length of text on the plot to this many characters (default=50)',default=50)
parser.add_argument('--axes',nargs='+',help='Each axes is a pair or more of values to plot in the form X,Y[,LABELS][,LABELS] - where LABELS can be SPEAK or FIRE')
#parser.add_argument('--labels',nargs='+',help='One additional text label per plot can be provided. i.e. SPEAK or FIRE',default=[])
parser.add_argument('--labelrot',type=float,help='Label rotation (default=45)',default=45)
parser.add_argument('--labeloffx',type=float,help='Label offset in X direction as proportion of plot width',default=0.1)
parser.add_argument('--labeloffy',type=float,help='Label offset in X direction as proportion of plot width',default=0.1)
parser.add_argument('--ncols',type=int,help='Number of columns for the plots',default=1)
o=parser.parse_args()

if o.fieldmap:
  fieldmap = read_fieldmap(open(o.fieldmap))
else:
  fieldmap = {}

def formater(xname,yname,curve,states,fires,speaks):
    def format_coord(x,y):
        nx,ny=get_xyvalue_from_t(x,curve)
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
  # Sharing X or Y?
  sharex=True
  sharey=True
  print(o.axes)
  xname0,yname0 = (o.axes[0]).split(",")[0:2]
  for axesnames in o.axes:
    xname,yname = axesnames.split(",")[:2]
    if xname!=xname0:
      sharex=False
    if yname!=yname0:
      sharey=False

  nrows = 1
  while(nrows*o.ncols < len(o.axes)):
    nrows = nrows+1
  print("row/cols",nrows,o.ncols)
  fig = P.figure(constrained_layout=True)
  #fig,axes = P.subplots(nrows=nrows,ncols=o.ncols,sharex=sharex,sharey=sharey)
  spec = gridspec.GridSpec(ncols=o.ncols, nrows=nrows, figure=fig)
  print(spec)
  axes = {}
  for i in range(0,nrows):
    for j in range(0,o.ncols):
      print(i,j)
      axes[(i,j)] = fig.add_subplot(spec[i,j])

  curves = []
  li = 0

  row,col = 0,0
  print(o.axes)
  for axesnames in o.axes:
    ax = axes[(row,col)]
    xname,yname = axesnames.split(",")[:2]
    try:
      labels = axesnames.split(",")[2:]
    except IndexError:
      labels = []
    # check labels
    for label in labels:
      if label not in ["SPEAK","FIRE"]:
        print("Label name %s must be either SPEAK or FIRE" % label, file=sys.stderr)
        sys.exit(1)
    curves.append(plot(ax,data,steps,xname,yname,labels))
    li=li+1
    col = col + 1
    if col >= o.ncols:
      row = row + 1
      col = 0

  row,col=0,0
  for i in range(0,len(o.axes)):
      ax = axes[row,col]
      axesnames = o.axes[i]
      xname,yname = axesnames.split(",")[0:2]
      ax.format_coord = formater(xname,yname,curves[i],steps,fires,speaks)
      row = row + 1
      if row >= nrows:
        row=0
        col=col+1
  P.show()
