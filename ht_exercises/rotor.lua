m2f=3.28
f2m=1/3.28
rads2rpm=60/(2*3.14)

if dataref then
  dataref("lo_rotor","sim/cockpit/warnings/annunciators/lo_rotor")
  dataref("hi_rotor","sim/cockpit/warnings/annunciators/hi_rotor")
  dataref("low_rotor","sim/cockpit2/annunciators/low_rotor")
  dataref("high_rotor","sim/cockpit2/annunciators/high_rotor")
  dataref("lo_rotor_warn","sim/flightmodel/failures/lo_rotor_warning")
  dataref("rotor_radspersec","sim/flightmodel/engine/POINT_tacrad")
  dataref("collective","sim/cockpit2/engine/actuators/prop_ratio")
end

function fail()
  set("sim/cockpit2/engine/actuators/governor_on",0)
  set("sim/operation/override/override_throttles",1)
  set_array("sim/flightmodel/engine/ENGN_thro_use",0,0)
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
