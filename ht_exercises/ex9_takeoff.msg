msgcode	delay	message
HI	10	"Welcome to Exercise 9. heading " .. math.floor(dir)
#INTRO1	10	Today we are going to practice a safe take off by keeping outside of the avoid regions of the height velocity diagram, that is the region whereby an engine failure would not be recoverable by autorotation. To keep we need to keep under 8 feet in the hover and up to 50 feet at 45 knots for the Cabri G2.
#INTRO2	10	To safely takeoff we need to gather airspeed close to the ground and only climb once we reach 50 knots
#INTRO3	10	Before we increase airspeed we need to come to a low hover and check for traffic left and right. Come to a hover
INTRO1	10	intro
INTRO2	10	intro
INTRO3	10	intro
LAND	30	This exercise should be started when landing. I'll wait for you to land
GATHERAIRSPEED	10	Good keep gathering airspeed
TRANSLIFT	10	Watch out for transitional lift which may make us climb, so lower collective or push the cyclic forwards to keep low
FASTENOUGH	10	"You've reached 50 knots so you can now start climbing at a max of 500 feet per minute. Keep accelerating beyond 50 knots and over 500 feet AGL"
LETSGO	10	All clear, push the cyclic forwards to gather airspeed. Keep low
MISSEDTURNS	10	You've missed the clearing turns
GOODHOVER	5	"Good hovering, groundspeed " .. math.floor(groundspeed) .. " vert " .. math.floor(y_agl_ft) .. " feet "
OUTOFHOVER1	10	You've climbed out of the low hover, above 12 feet, try and keep under 8 feet
OUTOFHOVER2	10	"You are drifting to much, try and stabilise the hover, ground speed " .. math.floor(groundspeed)
TOOHIGHSLOW	5	Too high with insufficient airspeed, in the avoid area of the height velocity curve
TURNHELP	10	"Take off bearing is " .. math.floor(dir) .. "Make turns in the hover 90 degrees to the left and right of this to visually check for traffic. Heading is " .. math.floor(heading)
GOODLEFTTURN	10	Take a good look left
GOODRIGHTTURN	10	Take a good look right
HIGHLEFTTURN	10	Good looking left but you need to be lower
HIGHRIGHTTURN	10	Good looking right but you need to be lower
MOVINGLEFTTURN	10	Good try looking left but moving too much
MOVINGRIGHTTURN	10	Good try looking right but moving too much
HIGHANDMOVING	10	Good try at the turns but too high and moving too much
END	10	"Good. You scored " .. math.floor(sc_hover) .. "% for the hover, " .. math.floor(sc_turns) .. "% for clearing turns and " .. math.floor(sc_takeoff) .. "% for the take off itself"
