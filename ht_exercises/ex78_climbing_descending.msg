msgcode	delay	message
WELCOME	1	Welcome to exercises 7 and 8
INTRO	1	Today we are going to practice climbing and descending. We are going to learn the A.P.T. and P.A.T. methods for ascending and descending
TAKEOFF	1	"Lets take off, increase our airspeed to about 60 knots and climb to " .. tgt_elevation_ft .. " above sea level"
OKAY	1	We are underway, lets start the exercise
CLIMBINTRO1	1	To climb we need to have excess power available, which may require reducing airspeed first
CLIMBINTRO2	1	So if necessary we change attitude to reduce airspeed, increase power by raising the collective and then trim to correct airspeed and rate of climb. This sequence of Attitude, Power, Trim gives the acronym A.P.T.
CLIMBINTRO3	1	"For this climb we will aim for an airspeed of 60 knots and a climb rate of " .. tgt_vh_ind_fpm .. " feet per minute. Use the pedals to keep us pointing forwards when adjusting the collective as the change in torque needs to be cancelled"
TARGET	30	"We are climbing to " .. tgt_elevation_ft .. " feet, aiming for " .. tgt_airspeed .. " knots with a climb rate of " .. tgt_vh_ind_fpm .. " feet per minute"
TOOSLOW	10	"Put some forward pressure on the cyclic to increase airspeed to " .. tgt_airspeed .. " knots"
TOOFAST	10	"Put some backward pressure on the cyclic to reduce airspeed to " .. tgt_airspeed .. " knots"
CLIMBHI	10	"Climb rate of " .. math.floor(vh_ind_fpm) .. " feet per minute is over the target of " .. tgt_vh_ind_fpm .. ". Reduce collective"
CLIMBLO	10	"Climb rate of " .. math.floor(vh_ind_fpm) .. " feet per minute is under the target of " .. tgt_vh_ind_fpm .. ". Increase collective"
LEVELOFF	15	"Nearly at " .. tgt_elevation_ft .. " feet so start leveling off using attitude, power, trim, A.P.T. Aim to level off at an airspeed of " .. tgt_airspeed .. " knots"
TOOHIGH	15	"Too high. Your target altitude is " .. tgt_elevation_ft .. " feet, descent to this altitude and set your airspeed to " .. tgt_airspeed .. " knots"
CLIMBGOOD	30	Your climb rate and airspeed are good
CLIMBGOOD	30	Good rate of climb and airspeed
CLIMBGOOD	30	Excellent. Maintain this
TOC	30	"You've reached the top of climb, now level off and accelerate to " .. tgt_airspeed .. " knots"
GOODLEVELTIME	40	"Well done you leveled off well in " .. math.floor(T-T_leveloff) .. " seconds"
GOODLEVEL	40	"Well done you leveled off in " .. math.floor(T-T_leveloff) .. " seconds"
NEWDESCENT	30	"Now we will descend. We will use Power, Attitude, Trim, P.A.T. so reduce power to begin the descent then set attitude and finally trim. Aim to descent at 500 f.p.m. at " .. tgt_airspeed .. " knots to " .. tgt_elevation_ft .. " feet. Your current score is " .. math.floor(score) .. "%"
NEWCLIMB	30	"Now we will climb. We will use Attitude, Power, Trim, A.P.T. so reduce power to begin the descent then set attitude and finally trim. Aim to descent at 500 f.p.m. at " .. tgt_airspeed .. " knots to " .. tgt_elevation_ft .. " feet. Your current score is " .. math.floor(score) .. "%"
DESCENTHI	10	"Descent rate of " .. math.floor(-vh_ind_fpm) .. " feet per minute is over the target of " .. tgt_vh_ind_fpm .. ". Raise collective"
DESCENTLO	10	"Descent rate of " .. math.floor(-vh_ind_fpm) .. " feet per minute is under the target of " .. tgt_vh_ind_fpm .. ". Lower collective"
DESCENTGOOD	30	Your descent rate and airspeed are good
DESCENTGOOD	30	Excellent. Keep this airspeed and descent rate
REACHED	10	"Almost reached the target altitude. Now start leveling off to " .. tgt_airspeed .. " knots"
END	10	"Well done. You scored " .. math.floor(score) .. "%.  Thats the end of the exercise."
LOOKINGFOR	30	"I'm looking for vertical speed under 100 fpm, airspeed between " .. (tgt_airspeed-5) .. " and " .. (tgt_airspeed+5) .. " knots and altitude between " .. (tgt_elevation_ft-50) .. " and " .. (tgt_elevation_ft+50) .. " feet"
SUMSCORE	5	"Score is " .. math.floor(score) .. " for " .. M .. " samples"
