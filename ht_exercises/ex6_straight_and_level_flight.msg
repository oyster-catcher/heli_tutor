# messages here
msgcode	delay	message
# Introduction and initial climb
HI	1	Welcome to exercise 6
GROUNDINTRO	1	"Today we're going to practice maintaining a given airspeed and altitude. You're on the ground so lets take off and climb to " .. tgt_alt .. " feet above sea level"
AIRINTRO	1	"Today we're going to practice maintaining a given airspeed and altitude. You're already in the air, so lets keep a similar altitude " .. climb_or_descend(ELEVATION*m2f,tgt_alt) .. " to do this exercise at " .. tgt_alt .. " feet above sea level"
AIRINTROLOW	1	"Today we're going to practice maintaining a given airspeed and altitude. You're in the air, but a little low, lets climb to " .. tgt_alt .. " feet above sea level"
REMINDER	30	"Remember " .. tgt_airspeed .. " knots and " .. tgt_alt .. " feet"
TOOLOW	20	"Increase the collective to climb to " .. tgt_alt .. " feet"
TOOLOW1	20	"You've dropped a little. Increase the collective to climb back to " .. tgt_alt .. " feet"
TOOHIGH1	20	"You've climbed too high. Lower the collective to descent down to " .. tgt_alt .. " feet"
CLIMBTOOSLOW	20	Increase your airspeed to about 50 to 70 knots while climbing
CLIMBTOOFAST	20	reduce your airspeed to about 50 to 70 knots while climbing
DESCENTTOOFAST	20	You've increased your airspeed too much, try not to dive forwards but lower the collective instead
DESCENTTOOSLOW	20	Keep your airspeed above 50 knots, otherwise you might enter the dangerous vortex ring state when descending
# Now at the target altitude, try and maintain and airspeed and altitude
TGT1	5	"Excellent. You've reached the target altitude of " .. tgt_alt .. " feet. Now increase your airspeed to " .. tgt_airspeed .. " knots by smoothly pushing the cyclic forwards"
TOOSLOW	5	A little slow. Adjust your attitude to lower the nose by pushing the cyclic forwards and maintaining the new attitude
TOOFAST	5	A little fast. Adjust your attitude to rase the nose by easing the cyclic back a little and keeping the new attitude
RIGHTAIRSPEED	5	Our airspeed is good. Try and maintain attitude to keep this airspeed
SCORINGSTART	5	Your airspeed and altitude are good. I'm going to observe you for the next 30 seconds
TIP1	300	Your airspeed and vertical attitude are linked. As you lower the nose to gain speed there is a smaller vertical component of lift so you need to raise the collective to compensate
TIP2	300	Try not to focus to much on the airspeed indicator but on the horizon, so you maintain the same attitude. With time you will be able to recognise that a given attitude will correspond to an airspeed
TIP3	300	Always operate the controls smoothly and allow the helicopter time to settle down
TIP4	300	When you level off after a climb set the attitude, lower power, or collective and then trim. This has the mnemomic A.P.T.
TIP5	300	When climbing and descending we can use the mnenomic P.A.T., standing for power, attitude, trim. So the climb we raise power, or collective in a helicopter, set the attitude and then trim.
TIP6	300	When descending more than 300 feet per minute keep your airspeed over 50 knots otherwise you might be in danger of vortex ring state. This is when the helicopter descends through its own downdraft which leads to instability and a descent thats difficult to arrest
TIP7	300	You are flying the Cabri G2, its the helicopter I find the most fun to fly
FINISHED	30	"Well done. You scored " .. math.floor(sc_airspeed) .. "% for airspeed and " .. math.floor(sc_alt) .. "% for altitude. A combined score of " .. math.floor(sc) .. "%"
SCORINGGOOD	10	Good. Keep it going
SCORINGBAD	10	"Keep going. Remember " .. tgt_airspeed .. " knots and " .. tgt_alt .. " feet"
DIFFERENTAIRSPEED	1	"Okay now we're going to try to do this at " .. tgt_airspeed .. " knots. Adjust to the new airspeed and I'll score you again"
TAKECARESLOWINGDOWN	20	When you need to reduce airspeed significantly you need to reduce collective to compensate for the increase lift as the helicopter is more level
TAKECARESPEEDINGUP	20	When you need to increase airspeed significantly you need to raise the collective to compensate for the reduced lift as the nose drops
END	5	Okay. Well done. Lets end the exercise there. Keep practicing until you are really happy with your performance, or try another exercise
PEDALS	60	Use your pedals to keep facing forwards, try to keep the black blob in the centre of the yellow strip
LEFTPEDAL	10	Use some left pedal
RIGHTPEDAL	10	Use some right pedal
BIGLEFTPEDAL	10	Large left pedal input needed
BIGRIGHTPEDAL	10	Large right pedal input needed
PEDALS1	6	"yaw " .. math.floor(yaw)
PEDALGOOD	20	Good you've trimmed out the slip
UNSAFE_BACKWARDS	5	Unsafe backwards
UNSAFE_DROPPING	5	Unsafe drop
UNSAFE_YAW	5	Unsafe yaw
UNSAFE_YAWRATE	5	Unsafe yaw rate
UNSAFE_PITCH	5	Unsafe pitch
UNSAFE_PITCHRATE	5	Unsafe pitch rate
UNSAFE_ROLL	5	Unsafe roll
UNSAFE_ROLLRATE	5	Unsafe roll rate
UNSAFE_AIRSPEED	5	Unsafe airspeed
