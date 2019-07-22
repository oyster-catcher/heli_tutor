m2f=3.28
f2m=1/3.28
rads2rpm=60/(2*3.14)

if dataref then
  --dataref("lo_rotor","sim/cockpit/warnings/annunciators/lo_rotor")
  --dataref("hi_rotor","sim/cockpit/warnings/annunciators/hi_rotor")
  --dataref("rotor_radspersec","sim/flightmodel/engine/POINT_tacrad")
  --dataref("collective","sim/cockpit2/engine/actuators/prop_ratio")
  --dataref("vh_ind_fpm","sim/flightmodel/position/vh_ind_fpm")
  --dataref("pitch","sim/flightmodel/position/theta")
  --dataref("roll","sim/flightmodel/position/phi")
  --dataref("ground","sim/flightmodel/failures/onground_any")
end

function fail()
  if set then
    set("sim/cockpit2/engine/actuators/governor_on",0)
    set("sim/operation/override/override_throttles",1)
    set_array("sim/flightmodel/engine/ENGN_thro_use",0,0)
  end
end

function restart()
  if set then
    set("sim/cockpit2/engine/actuators/governor_on",1)
    set("sim/operation/override/override_throttles",0)
  end
end

-- at extreme of tolerance range we get 0% accuracy
-- for for airspeed target 80 knot, tolerance of 5 knots
-- keeping 75 or 85 knots gives 0% accuracy linearly decreasing beyond this
function score(target,tolerance,actual)
  local diff = math.abs(target-actual)
  --print("TARGET: ",target,"TOLERANCE:",tolerance,"ACTUAL:",actual)
  diff = diff/tolerance*100
  diff = math.max(0,diff-10)  -- within 10% of tolerance we want to score 100%
  local sc = math.max(0,100-diff)
  return sc
end

function score_hover()
  local s1 = score(0,10,hPitch)
  local s2 = score(0,10,hRoll)
  local s3 = score(0,20,hYaw)
  local s4 = score(0,200,vh_ind_fpm)
  local s5 = score(2,5,y_agl)   -- 2m +/-5m (generous)
  return (s1+s2+s3+s4+s5)/5.0
end
