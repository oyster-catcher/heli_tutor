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

| Lua variable | X-Plane DataRef | Units |
| --- | --- | --- |
| LONGITUDE | sim/flightmodel/position/longitude | degrees |
| LATITUDE | sim/flightmodel/position/latitude | degrees |
| ELEVATION | sim/flightmodel/position/elevation | metres |
| elevation_ft | sim/flightmodel/position/elevation | feet |
| heading | sim/flightmodel/position/mag_psi | degrees |
| airspeed | sim/flightmodel/position/indicated_airspeed | knots |
| groundspeed | sim/flightmodel/position/groundspeed | knots |
| roll | sim/flightmodel/position/phi | degrees |
| roll_rate | sim/flightmodel/position/P | degrees/sec |
| pitch | sim/flightmodel/position/theta | degrees |
| pitch_rate | sim/flightmodel/position/Q | degrees/sec |
| yaw | sim/flightmodel/position/beta | degrees |
| yaw_rate | sim/flightmodel/position/R | degrees/sec |
| rotor_radspersec | sim/flightmodel/engine/POINT_tacrad | rads/sec |
| rotor_rpm | sim/flightmodel/engine/POINT_tacrad | revs/min |
| y_agl | sim/flightmodel/position/y_agl | metres |
| y_agl_ft | sim/flightmodel/position/y_agl | feet |
| vh_ind_fpm | sim/flightmodel/position/vh_ind_fpm | feets/min |
| on_ground | sim/flightmodel/failures/onground_any | 1(on ground) or 0(in air) |

The best way to access additional datarefs is to add some code to your exercise,
e.g. steer.lua:

```
if dataref then
  dataref("collective","sim/cockpit2/engine/actuators/prop_ratio")
end  
```
You should protect the dataref() command with "if dataref" since its useful to be able to run the code outside of X-Plane when the dataref() function is not available.

You can make the spoken messages a little more advanced by embedding variables within them. For instance you didn't want to just say turn right or left. You wanted to say how many degrees to turn.

Modified steer.rul as follows:
```
msgcode	delay	message
left	5	"turn left " ... math.floor(heading-180) ... " degrees"
right	5	"turn right " ... math.floor(180-heading) ... " degrees"
target	5	straight ahead
```

We surround the message with double quotes are use the standard lua syntax to join strings together with ...
I use math.floor() otherwise the heading will be spoken with about 10 decimal places.

Now, I didn't mention about the "from" and "to" fields yet. I used "start" for all of them.
Think of this like a flowchart and in this case if the condition is trigger you end up back at the same
place (or state). But, if we want to perform a sequence of actions we need to move to the next state when a condition is fulfilled.

Say we want the pilot to takeoff, climb to 50 feet and then descend again. Lets try this:

updown.msg:
```
msgcode	delay	message
climb	5	climb to above 50 feet
reached	5	you reached 50 feet
descend	5	descend back to the ground
landed	5	you landed. Well done!
```

updown.rul:
```
from	to	condition	msgcode
state1	state1	y_agl_ft<50	climb
state1	state2	y_agl_ft>50	reached
state2	state2	y_agl_ft>0	descend
state3	state3	on_ground==1	landed
```

Now there are two remaining fields in the rules file to introduce: prob and command
The prob field allows you to specify a probability of that action firing given the condition is true.
You can use this to randomly choose between different actions in an exercise for variety, or the use a different spoken message.
The probabilities don't need to sum to 1, they will be normalized so they sum to 1 over all the conditions that are true at that time.

And finally the "command" feels allows you to execute lua code. A good reason for doing this is to accumulate a score for evaluation, or to set a lua variable such as the current location.

