HeliTutor
=========

HeliTutor allows you to create flight exercises which are run by the HeliTutor plugin while flying in X-Plane 11.
Such exercises can teach you, giving voice instructions as you fly and can evaluate your performance. They can
spot what you do wrong and give advice.

The exercises are written as a state-based graph with transitions between the states that may have a
random probability of be executed based on specific conditions. A typical action might be to speak
a message via TTS, or to perform some lua code. The condition is written in lua code. The lua code
can access datarefs setup for each exercise all those built into FLyByLua are included wuch as
ELEVATION, LONGITUDE and LATITUDE.

Some exercises for helicopter pilot are included because thats what I'm interested, but the exercise
for any aircraft could easily be developed also.

I am every so grateful for the developer of FlyByLua which this plugin relies on. I searched for a
while for how to fulfill my idea and FLyByLua provided just the right level and power and flexibility.

Installing The Plugin
=====================

First ensure you have installed FlyByLua.
Then copy all files and the ht_exercises sub-directory from the HeliTutor plugininto the X-Plane11 installed location inside
Resources/plugins/FlyByLua/Scripts.

Parts of the Plugin
===================

heli_tutor.lua - Plugin script which is run by FlyWithLua inside X-Plane11, but
can also be run at the command line to process X-Plane11 data files offline
which is great for debugging exercise scripts

ht_plot.py - Provides pretty plots of a recording of an exercise session, an
offline generated log file, or an X-Plane data file

Using The Existing Exercises
============================

Start a new flight with a helicopter. Then access the menu item
"Plugins-FlyWithLua-FlyWithLua Macros - Heli Tutor" and select to enable Heli
Tutor. When started a list of the available exercises will be shown along with
the best score achieved so far for each exercise. Click on the exercise to start
it. Now follow the instructions provided by the exercise and try to follow as
closely as you can and see what score you can get.

Structure of an Exercise
========================

An exercise is structure into three parts
 * Messages (exercise.msg) - A list of messages that will be spoken by TTS
 * Rules (exercise.rul) - A list of state transition rules which may change
   state, run some lua code, or speak a message
 * Lua code (exercise.lua) - Lua code which defines extra functions that can be
   used from the lua commands in the rules file

Note that the messages and rules file are in columns where the first line names
the columns and columns are tab separated.
Here is a very simple example where we tell the pilot whether to turn right or
left to point the aircraft on a specific bearing.

Create these files in the ht_exercises/ directory.

steer.msg:

```
msgcode	delay	message
left	5	turn left
right	5	turn right
target	5	straight ahead
```
steer.rul:
```
from	to	condition	msgcode
start	start	heading>170	right
start	start	heading<190	left
start	start	(heading>170)and(heading<190)	target
```

This short set of rules will instruct you to turn towards a heading of close to
180 telling you to turn left or right if you are 10 degrees away from the
target or say "straight ahead" if you are on target. Note the delay. This will
mean that the instruction will only be repeated after 5 seconds. This provides a
simple way to avoid very rapid repetition.

You also need to add a line to the file ht_exercises/exercises.txt so it is available from the Heli Tutor plugin.
Add the line

```
simple steering example<TAB>steer<TAB>0
```
to the end of this file.

There are a set of built in lua variable which are linked to the DataRefs in FlyWithLua.
Here are those you are most likely to use noting that is some cases conversions are applied to change the default units.

--- | --- | ---
Lua variable | X-Plane DataRef | Units
LONGITUDE | sim/flightmodel/position/longitude | degrees
LATITUDE | sim/flightmodel/position/latitude | degrees
heading | sim/flightmodel/position/mag_psi | degrees
airspeed | sim/flightmodel/position/indicated_airspeed
groundspeed | sim/flightmodel/position/groundspeed
roll | sim/flightmodel/position/phi
roll_rate | sim/flightmodel/position/P
pitch | sim/flightmodel/position/theta
pitch_rate | sim/flightmodel/position/Q
yaw | sim/flightmodel/position/beta
yaw_rate | sim/flightmodel/position/R
rotor_radspersec | sim/flightmodel/engine/POINT_tacrad | rads/sec
rotor_rpm | sim/flightmodel/engine/POINT_tacrad | revs/min
y_agl | sim/flightmodel/position/y_agl | metres
y_agl_ft | sim/flightmodel/position/y_agl | feet
vh_ind_fpm | sim/flightmodel/position/vh_ind_fpm | feets/min
on_ground | sim/flightmodel/failures/onground_any | 1(on ground) or 0(in air)
--- | --- | ---

