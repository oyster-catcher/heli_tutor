Heli Tutor
==========

HeliTutor allows you to create flight exercises which is run as a plugin while flying in X-Plane 11.
Such exercises might teach you and evaluate your performance. They can spot what you do wrong and
give advice.

The exercises are written as a state-based graph with transitions between the states that may have a
random probability of be executed based on specific conditions. A typical action might be to speak
a message via TTS, or to perform some lua code. The condition is also written in lua code. The lua
code can access datarefs setup for each exercise all those built into FLyByLua are included wuch as
ELEVATION, LONGITUDE and LATITUDE.

Some exercises for helicopter pilot are included because thats what I'm interested, but the exercise
for any aircraft could easily be developed also.

I am every so grateful for the developer of FlyByLua which this plugin relies on. I searched for a
while for how to fulfill my idea and FLyByLua provided just the right level and power and flexibility.
