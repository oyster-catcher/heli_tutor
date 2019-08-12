# Exercise 11 - The Helicopter Circuit (Square)
msgcode	delay	message
WELCOME	10	Welcome to Exercise 11 - The Helicopter Circuit. Start this exercise in the direction you wish to takeoff, which should be upwind
INTRO1	10	Completing a circuit well covers many of the skills you have learned until this point, such as straight and level flight, turns, hovering and spot turns. A circuit is a short rectangular path around away from and back to the same point on the ground. You should be aware of other traffic and stay well clear of it
INTRO2	10	We will complete a short anti-clockwise square circuit coming back and landing where we started. I'll give you instructions as we go
INTRO3	10	The circuit should be setup so you are landing into the wind. The legs are called upwind, crosswind, downwind, base and final. Lets start with a hover and some clearing turns to check for traffic. Take note of our current altitude so you can calculate above ground level altitudes in your head
OOH_HI	10	You climbed too high out of the hover, descend
OOH_LO	10	You descended too low, keep in a hover
OOH_MOV	10	You are moving, keep in a hover
DONEL	10	Excellent, thats the left clearing turn done
DONER	10	Good, right clearing turn done
CLIMBNOW	20	Thats 50 knots you can start climbing now, aim for 600 to 700 feet per minute
WPLEG1	15	turnLR(heading,wp_hdg(wp[1])) .. " for heading " .. dp(wp_hdg(wp[1]),0) .. " for " .. dp(wp_dist(wp[1]),1) .. " miles"
WPLEG1	15	turnLR(heading,wp_hdg(wp[1])) .. " for heading " .. dp(wp_hdg(wp[1]),0)
WPLEG2	15	turnLR(heading,wp_hdg(wp[2])) .. " for heading " .. dp(wp_hdg(wp[2]),0) .. " for " .. dp(wp_dist(wp[2]),1) .. " miles"
WPLEG2	15	turnLR(heading,wp_hdg(wp[2])) .. " for heading " .. dp(wp_hdg(wp[2]),0)
WPLEG3	15	turnLR(heading,wp_hdg(wp[3])) .. " for heading " .. dp(wp_hdg(wp[3]),0) .. " for " .. dp(wp_dist(wp[3]),1) .. " miles"
WPLEG3	15	turnLR(heading,wp_hdg(wp[3])) .. " for heading " .. dp(wp_hdg(wp[3]),0)
WPLEG4	15	turnLR(heading,wp_hdg(wp[4])) .. " for heading " .. dp(wp_hdg(wp[4]),0) .. " for " .. dp(wp_dist(wp[4]),1) .. " miles"
WPLEG4	15	turnLR(heading,wp_hdg(wp[4])) .. " for heading " .. dp(wp_hdg(wp[4]),0)
WPLEG5	15	turnLR(heading,wp_hdg(wp[5])) .. " for heading " .. dp(wp_hdg(wp[5]),0) .. " for " .. dp(wp_dist(wp[5]),1) .. " miles"
WPLEG5	15	turnLR(heading,wp_hdg(wp[5])) .. " for heading " .. dp(wp_hdg(wp[5]),0)
BACKONTRACK	10	Good, back on track
BACKONTRACK	10	Excellent, straight ahead now
BACKONTRACK	10	Well corrected
LEG1	30	Okay. Lets start gaining airspeed and start climbing once you reach 50 knots
LEG1_LO	15	You are too low, get that climb going at around 500 feet per minute. You want 500 feet AGL by the crosswind turn
LEG1_HI	10	You are too high. Keep low to ground until you reach 50 knots
LEG1_TURN_LOW	10	Ready to turn onto the crosswind leg. Check for traffic then turn left 90 degrees, and keep climbing to 1000 feet AGL
LEG1_TURN_GOOD	10	Ready to turn onto the crosswind leg. Check for traffic then turn left 90 degrees, maintain 1000 feet AGL
LEG1_TURN_HIGH	10	Ready to turn onto the crosswind leg. Check for traffic then turn left 90 degrees, descend to 1000 feet AGL and maintain
LEG2	10	Great, thats the turn onto the crosswind leg done
LEG2	10	Good, you turned onto crosswind
LEG2_LO	15	You are too low, get that climb going at around 500 feet per minute. You want 1000 feet AGL by the downwind turn
REACHED1000FT	10	You reached 1000 feet AGL, great, try and maintain this now. Note the altimeter
AIRSPEED_LO	10	Too slow. Keep airspeed between 60 and 80 knots
AIRSPEED_LO	10	Push the cyclic forwards to maintain around 70 knots
AIRSPEED_LO	10	Try and keep a cruising speed of 70 knots pull pushing the cyclic forwards a little
AIRSPEED_GOOD	10	Airspeed is good now
AIRSPEED_GOOD	10	Well done on airspeed
AIRSPEED_GOOD	10	Well done correcting airspeed
AIRSPEED_HI	10	Too fast. Keep airspeed between 60 and 80 knots
AIRSPEED_HI	10	Pull the cyclic back a little to maintain 70 knots
AIRSPEED_HI	10	Try and cruise at 70 knots, pull the cyclic back a little
LEG_LO	10	Keep climbing up to 1000 feet AGL
LEG_LO	10	Aim for 1000 feet AGL. Keep climbing
LEG_HI	10	Too high, descend to 1000 feet AGL
LEG_HI	10	Aim for 1000 feet AGL. Descend a little
LEG2_HI	10	We are looking for 1000 feet AGL on this leg, descend
LEG2_LO	10	You are low, climb to 1000 feet AGL
LEG2_TURN_LOW	10	"Now its time to turn onto the downwind leg, you are only at " .. dp(y_agl_ft,-1) .. " feet. Keep climbing to 1000 feet AGL but check for traffic and turn left 90 degrees"
LEG2_TURN_GOOD	10	Now its time to turn onto the downwind leg, altitude is close to 1000 feet AGL. Check all around then turn left 90 degrees
LEG2_TURN_HIGH	10	"Now its time to turn onto the downwind leg, you are high at " .. dp(y_agl_ft,-1) .. " feet descend to 1000 feet AGL, check all around then turn left 90 degrees"
LEG3	10	We are now on the downwind leg. On this leg we should see that starting point to our left after a while
LEG4	10	Thats the turn onto the base leg. You should now be descending to 500 feet
LEG3_TURN	10	The starting point is about 45 degrees to the left and behind you. This is a good time to turn left onto the base leg and start descending to 750 feet AGL and slow to 60 knots for the turn onto final
TO750	10	Keep descending down to 750 feet AGL, the descent should continue through the final leg
LEG4_TURN	10	Now its about time to turn 90 degrees left onto the final leg. Observe the landing spot to your left and turn to line up for it
LEG4_TURN2	10	"Looks like you are a bit off track but need to turn onto the final approach. Turn " .. turnLR(heading,wp_hdg(wp[4])) .. " to heading " .. dp(wp_hdg(wp[4]),0) 
LEG5	10	Great you turned onto the final leg. Now keep descending and slow to 60 knots
LEG5_KEEP60	10	Keep airspeed around 60 knots, keep gradually slowing
LEG5_KEEP50	10	Keep airspeed around 50 knots, keep gradually slowing
LEG5_KEEP40	10	Keep airspeed around 40 knots, keep gradually slowing
LEG5_KEEP30	10	Keep airspeed around 30 knots, keep gradually slowing
LEG5_KEEP20	10	Keep airspeed around 20 knots, keep gradually slowing
LEG5_UNDER20	10	Keep your airspeed below 20 knots, gradually slowing to a hover. Don't descend over 300 feet per minute
LEG5_FAST	10	Keep your airspeed below 60 knots and slower as we reach the landing site
INAIR	5	Good, we are in the air. Come to a stable hover
GOOD	1	Good
CLOSE	1	Close
SETDIR	10	Now point in the direction of the upwind leg, either hovering or on the ground
THISWAY	10	"Okay, leg 1 is on a heading of " .. math.floor(leg1_hdg) .. " lets get into a hover and complete our clearing turns"
OOH_MOVING	10	Moving too much, keep it stable
POSITION	5	"X=" .. 0.1*math.floor(x*10) .. " Y=" ..0.1*math.floor(y*10)
LOOKLEFT	30	The starting point should be coming up directly to our left
VERYCLOSE	10	You are very close to the starting point, come to a hover then make a soft landing
SLOWTOHOVER	10	Getting very low, now come to a hover at a safe landing spot
TOHOVER	10	Now get to a hover
GOODHOVER	20	Good hovering
GIVENUPHOVER	10	Looks like you've given up on the clearing turns, not good safety wise, but lets continue on the upwind leg
ONGROUND	10	On ground
OFFGROUND	10	Off ground
LANDING	10	"Good landing, descent feet per minute " .. math.floor(descent)
DISTTOLAND	30	"Distance to landing spot " .. dp(wp_dist(wp[5]),1) .. " miles"
GLIDESLOPE	15	"Glideslope is " .. math.floor(glideslope(wp[5])) .. " degrees which is good. Try to keep the same site picture of the runway"
HIGH	10	"Too high, glideslope is " .. math.floor(glideslope(wp[5])) .. " degrees you are aiming for 10 degrees in a standard approach"
LOW	10	"Too low, glideslope is  " .. math.floor(glideslope(wp[5])) .. " degrees you should aim for 10 degrees for a standard approach"
INTURN	15	"Keep turning to a heading of " .. math.floor(tgt_hdg) .. " degrees"
GOODLANDING	10	"A good landing, well done. Descent rate " .. -math.floor(descent) .. " feet per minute and ground speed " .. math.floor(land_groundspeed)
MOVINGLANDING	10	"A soft landing, but with a ground speed of " .. math.floor(groundspeed) .. " knots"
HEAVYLANDING	10	"That landing was a bit heavy, next time try and bring us down slower. " .. -math.floor(descent) .. " per minute descent"
HEAVYMOVINGLANDING	10	"That landing was a bit heavy and with some groundspeed, next time try and bring us down slower. Descent rate " .. -math.floor(descent) .. " per minute and ground speed " .. math.floor(land_groundspeed) .. " knots"
FASTDESCENT	10	"Danger! Descent rate over 300 feet per minute and slow means vortex ring state. Reduce your descent rate or increase forward speed. Try and get low for the last part of the approach when you reduce forward speed"
EYESOUT	10	Keep your eyes out and keep coming down
ENDOFEXERCISE	10	Thats the end of the exercise
