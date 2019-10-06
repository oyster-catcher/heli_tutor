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

I am every so grateful to X-Friese, the developer of [FlyByLua](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/) which this plugin relies on. I searched for a
while for how to fulfill my idea and FLyByLua provided just the right level of power, flexibility and simplicity. Its only FlyByLua that has made it all possible to non-expert users to make their own tutorial exercises without requiring the hassle of compiling code.

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

Note that the messages and rules file are in columns where the first line names the columns and columns are tab separated. Here is a very simple example where we tell the pilot whether to turn right or left to point the aircraft on a specific bearing.

There are some simple examples in the ht_exercises/ directory. I describe here how they work.
Note that I've used spaces to make the fields line up, in the actual examples a TAB is used to separate the fields, so they might not appear to line up so well. If you like you get edit them with a spreadsheet app and load/save with TAB separators.

The messages file for the steer example, steer.msg:

steer.msg:
```
msgcode   delay  message
left	    5	     turn left
right	    5	     turn right
target	 5	     straight ahead
```

and the corresponding rules file, steer.rul:

```
from   to      condition                     msgcode
start  start   heading<170                   right
start  start   heading>190                   left
start  start   (heading>170)and(heading<190) target
```

This short set of rules will instruct you to turn towards a heading of close to
180 telling you to turn left or right if you are 10 degrees away from the
target or say "straight ahead" if you are on target. Note the delay. This will
mean that the instruction will only be repeated after 5 seconds. This provides a
simple way to avoid very rapid repetition.

You also need to add a line to the file ht_exercises/exercises.txt so it is available from the Heli Tutor plugin.
Uncomment the line starting "simple steering demo".

```
exercise              filename  score
simple steering demo  steer     0
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

Testing Offline
===============

You can test your exercises outside of X-Plane, and this is recommended as its much faster.
You will need to install a version of lua in order to do this. Go to lua.org to find a version for your OS.

To test you need a data file containing only the values needed for your exercise.
You can fabricate the data or take a flight in X-Plane to generate a Data.txt file.

Here we will test the steer example on some fabricated data. Heres some data in the X-Plane format but with our own variable names.

ht_exercises/steer.dat:
```
T   | heading
0   | 160
5   | 180
10  | 180
15  | 195
20  | 200
25  | 180
30  | 175
```

We can run Heli Tutor on this data file by typing:
```
lua heli_tutor.lua ht_exercises/steer ht_exercises/steer.dat
```
Note that the exercises name "ht_exercises/steer" is a prefix for the .msg, .rul and .lua files making up the exercise.
You should see the following output
```
... information messages ...
DATA: heading=160 T=0
STEP: state=start T=0
FIRE: to=start prob=1 condition=heading<170 msgcode=right from=start
SPEAK: message="turn right"
DATA: heading=180 T=5
STEP: state=start T=5
FIRE: to=start prob=1 condition=(heading>170)and(heading<190) msgcode=target from=start
SPEAK: message="straight ahead"
DATA: heading=180 T=10
STEP: state=start T=10
FIRE: to=start prob=1 condition=(heading>170)and(heading<190) msgcode=target from=start
SPEAK: message="straight ahead"
DATA: heading=195 T=15
STEP: state=start T=15
FIRE: to=start prob=1 condition=heading>190 msgcode=left from=start
SPEAK: message="turn left"
DATA: heading=200 T=20
STEP: state=start T=20
FIRE: to=start prob=1 condition=heading>190 msgcode=left from=start
SPEAK: message="turn left"
DATA: heading=180 T=25
STEP: state=start T=25
FIRE: to=start prob=1 condition=(heading>170)and(heading<190) msgcode=target from=start
SPEAK: message="straight ahead"
DATA: heading=175 T=30
STEP: state=start T=30
FIRE: to=start prob=1 condition=(heading>170)and(heading<190) msgcode=target from=start
SPEAK: message="straight ahead"
```
We can see each line of prefixed with a code. DATA shows the data read from the field with all the values. STEP shows the current state and time. FIRE shows if a condition is tree and this rule has fired. Finally SPEAK shows a message that would be spoken when inside X-Plane. It looks like the exercise is working, as it tells the pilot and turn left and right to point on a heading of 180.

Now this output is a little hard to read. We can plot it.
Firstly you need to ensure you have python and matplotlib installed.
Then run
```
lua heli_tutor.lua ht_exercises/steer ht_exercises/steer.dat > Log.txt
./ht_plot.py --logfile=Log.txt --axes T,heading,SPEAK T,heading,FIRE
```

![alt text](https://github.com/oyster-catcher/heli_tutor/blob/master/steerplot.png "Plot of steer demo")

which as you can see will show two plots which T vs heading, and T vs heading with the labels SPEAK and FIRE respectively.

If you use an X-Plane Data.txt file as input you will need to perform some mapping of the field names from this file, as they are quite verbose and not possible to use a variable names in lua, or most programming languages since they contain commas!

Plotting in more detail
=======================

The examples using ht_plot.py above showed some fairly trivial examples. You can do much more. The trick is trying to show that data without overloading the perform viewing it, as it can get pretty complex!

Heres a more complex example where I plot from the running the circuit from exercise 11 using the Data.txt file from X-Plane with LATITUDE and LONGITUDE rather than time, and show the spoken messages on the plot. Note that the X axis uses LATITUDE, the Y axis used LONGITUDE and following this is SPEAK which means label the curve shown this the spoken output.
```
./ht_plot.py --fieldmap fieldmap.txt --logfile ht_exercises/ex11_heli_circuit.log --axes LATITUDE,LONGITUDE,SPEAK
```
![alt text](https://github.com/oyster-catcher/heli_tutor/blob/master/images/circuit.png "Plot of circuit data")

