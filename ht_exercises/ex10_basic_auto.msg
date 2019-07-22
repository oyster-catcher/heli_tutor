msgcode	delay	message
WELCOME	10	Welcome to exercise 10. Basic autorotation
INTRO	10	Today we are going to practice engine failures and autorotation to enable a safe landing. When we reach 1000 feet AGL I will call engine failure and roll off the throttle. Aim to keep the airspeed around 50 knots all the way down, with rotor R.P.M. in the green. If its looking good you can continue to the flare where we can throttle up to a hover, otherwise I'll throttle up early. Climb to above 1000 feet with cruising speed
FAIL	10	Engine failure
ENABLE	10	Throttling up
ALT	45	"Height " .. math.floor(y_agl*m2f) .. " feet AGL"
SLOW	8	Too slow, try and accelerate to 50 knots
FAST	15	Too fast, try and slow to 50 knots
PERFECT	10	Perfect
DESCENT	10	Entry phase over. Look for a landing site. You should have airspeed, rotor speed and slip under control
RIGHTPEDAL	5	Right pedal
LEFTPEDAL	5	Left pedal
SLOWROTOR	20	Rotor speed too slow, lower collective
FASTROTOR	20	Rotor speed too fast, raise collective
ROTOR	10	"Rotor RPM " .. math.floor(rotor_rpm)
ENTRYSLOWROTOR	10	Drop the collective fast to gain rotor speed
ENTRYSLOW	10	Push the cyclic forwards to gain airspeed
ENTRYFAST	10	Keep us more level, don't gain too much speed
EVAL_EXCELLENT	10	That was really excellent. Superb control of airspeed and rotor speed all the way down
EVAL_GOOD	10	That was very good. Good control of airspeed and rotor speed
EVAL_GOOD_AIRSPEED	10	Very good control of airspeed, rotor speed not quite so good
EVAL_GOOD_ROTORSPEED	10	Very good control of rotor speed with the collective, not quite so good control of airspeed
EVAL_FASTDESCENT	10	That was a very fast descent, and not very safe. Try and listen to my instructions next time
EVAL_POOR	10	Still work to do. Airspeed and rotor were outside of the ideal ranges for a lot of the time. Lets keep trying
SCORES	10	"You scored " .. math.floor(sc_rotor) .. "% for rotor speed, and " .. math.floor(sc_airspeed) .. "% for airspeed with an average descent rate of " .. math.floor(fpm) .. " feet per minute and " .. math.floor(sc_hover) .. "% for the hover. Lets climb and try again"
SCORING	3	score
FLAREHELP	120	At around 50 feet, flare. Back on the cyclic to slow and stay low aiming for a hover
FLARE	10	flare now
ABORT	1	"abort. descent rate too fast at " .. -math.floor(vh_ind_fpm) .. " feet per minute. I'm looking for under 1500"
#HOVER 	 1 	 "Hovering. Yaw " .. math.floor(hYaw) .. " Pitch " .. math.floor(hPitch) .. " Roll " .. math.floor(hRoll) .. " Height " .. math.floor(y_agl*m2f) .. " Descent " .. math.floor(vh_ind_fpm) .. " Score " .. math.floor(sc_hover)
HOVER	1	Hover
GROUND	1	Ground strike
