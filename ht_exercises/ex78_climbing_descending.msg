msgcode	delay	message
WELCOME	1	Welcome to exercises 7 and 8
INTRO	1	Today we are going to practice climbing and descending. We are going to learn the APT and PAT methods for ascending and descending
TAKEOFF	1	"Lets take off, increase our airspeed to about 60 knots and climb to " .. tgt_alt
OKAY	1	We are really underway, lets start the exercise
CLIMBINTRO1	1	To climb we need to have excess power available, which may mean we need to reduce airspeed first
CLIMBINTRO2	1	So if necessary we change attitude to reduce airspeed first, then increase power by raising the collective and then trim to correct airspeed and rate of climb. This gives the acronym APT
CLIMBINTRO3	1	For this climb we will aim for an airspeed of 60 knots and a climb rate of " .. tgt_yinc .. " feet per minute for this climb. Also remember to use the pedals to keep us forwards when adjusting the collective changes torque
TOOSLOW	10	Put some forward pressure on the cyclic in increase airspeed
TOOFAST	10	Put some backward pressure on the cyclic to reduce airspeed
RATEHI	10	"Climb rate is over the target of " .. tgt_yinc .. " feet per minute. Reduce collective"
RATELO	10	"Climb rate is under the target of " .. tgt_yinc .. " feet per minute. Increase collective"
LEVELOFF	15	Now we have only 10% of the climb rate to reach our target so level off by again via attitude, power and then trim. Aim to increase airspeed to 80 knots when leveling off
CLIMBGOOD	30	Your climb rate and airspeed are good
TOC	30	You've reached the top of climb, or TOC if you're being fancy
GOODLEVELTIME	40	"Well done you leveled off well in " .. math.floor(t-t_leveloff) .. " seconds"
GOODLEVEL	40	"Well done you leveled off"
