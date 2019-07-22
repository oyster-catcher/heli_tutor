# Exercise 11 - The Helicopter Circuit (Square)
msgcode	delay	message
WELCOME	10	Welcome to Exercise 11 - The Helicopter Circuit
INTRO1	10	Completing a circuit well covers many of the skills you have learned until this point such as straight and level flight, turns, hovering and spot turns. A circuit is a short rectangular path around away from and back to the same point on the ground. You need to be aware of other traffic since you are probably at an airstrip
INTRO2	10	We will complete a short anti-clockwise square circuit coming back and landing where we started. I'll give you instructions as we go
INTRO3	10	The circuit should be setup so you are landing into the wind. There are 5 legs called upwind, crosswind, downwind, base and final. Lets start with a hover and some clearing turns to check for traffic
OOH_HI	10	You climbed too high out of the hover, descend
OOH_LO	10	You descended too low, keep in a hover
OOH_MOV	10	You are moving, keep in a hover
DONEL	10	Excellent, thats the left clearing turn done
DONER	10	Good, right clearing turn done
CLIMBNOW	20	Thats 50 knots you can start climbing now, aim for 500 feet per minute
LEG1	30	Okay. Lets start gaining airspeed and start climbing once you reach 50 knots
LEG1_HI	10	You are too high. Keep low to ground until you reach 50 knots
LEG1_TURN	10	Now check we are clear right and left then turn 90 degrees left and keep gaining altitude until 1000 feet AGL. You can use a ground feature 90 degrees left and aim for that
LEG2	10	Great, thats the turn onto the crosswind leg done
AIRSPEED_LO	10	Too slow. Keep airspeed between 60 and 80 knots
AIRSPEED_HI	10	Too fast. Keep airspeed between 60 and 80 knots
LEG_LO	10	Keep climbing up to 1000 feet AGL
LEG_HI	10	Too high, descent down to 1000 feet AGL
KEEPHEADING	10	"Steer back to a heading of " .. math.floor(leg_psi)
LEG2_HI	10	We are looking for 1000 feet on this leg, descend
LEG2_LO	10	You are low, climb to 1000 feet
LEG2_TURN	10	Now its time to turn onto the downwind leg, and stop climbing. Check all around then turn left 90 degrees
LEG3	10	We are now on the downwind leg. On this leg we should see that starting point to our left after a while
LEG4	10	Thats the turn onto the base leg. You should now be descending to 500 feet
LEG3_TURN	10	The starting point is about 45 degrees to the left and behind you. This is a good time to turn into the base leg
TO500	10	Keep descending down to 500 feet, the descend can run into the final leg
LEG4_TURN	10	Now its time to turn 90 degrees left onto the final leg. Continue slowing and descending
LEG5	10	Great you turned onto the final leg. Now keep descending and slow to 60 knots
LEG5_KEEP60	10	A little slow, keep airspeed around 60 knots, keep gradually slowing
LEG5_KEEP50	10	A little slow, keep airspeed around 50 knots, keep gradually slowing
LEG5_KEEP40	10	A little slow, keep airspeed around 40 knots, keep gradually slowing
LEG5_KEEP30	10	A little slow, keep airspeed around 30 knots, keep gradually slowing
LEG5_FAST	10	Keep your airspeed below 60 knots and slower as we reach the landing site
GOOD	1	Good
CLOSE	1	Close
SETDIR	10	Now point in the direction of the upwind leg, either hovering or on the ground
THISWAY	10	"Okay, leg 1 is on a heading of " .. math.floor(leg1_psi) .. " Now clearing turns"
OOH_MOVING	10	Moving too much, keep it stable
POSITION	5	"X=" .. 0.1*math.floor(x*10) .. " Y=" ..0.1*math.floor(y*10)
LOOKLEFT	30	The starting point should be coming up directly to our left
VERYCLOSE	10	You are very close to the starting point, come to a hover then make a soft landing
SLOWTOHOVER	10	Getting very low, now come to a hover if you are at a safe landing spot
TOHOVER	10	Now get to a hover
ONGROUND	10	On ground
OFFGROUND	10	Off ground
LANDING	10	"Good landing, descent feet per minute " .. math.floor(descent)
