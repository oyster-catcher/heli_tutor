-- at extreme of tolerance range we get 0% accuracy
-- for for airspeed target 80 knot, tolerance of 5 knots
-- keeping 75 or 85 knots gives 0% accuracy linearly decreasing beyond this
function calc_score(target,tolerance,actual)
  local diff = math.abs(target-actual)
  --print("TARGET: ",target,"TOLERANCE:",tolerance,"ACTUAL:",actual)
  diff = diff/tolerance*100
  diff = math.max(0,diff-10)  -- within 10% of tolerance we want to score 100%
  local sc = math.max(0,100-diff)
  return sc
end

function max_height_at_airspeed(airspeed)
  -- for Cabri G2
  if airspeed<20 then
    return 8+(airspeed/20.0)*2
  elseif airspeed<40 then
    return 10+(airspeed-20)/20.0*30
  elseif airspeed<45 then
    return 30+(airspeed-5)/5.0*20
  else
    return 99999
  end
end
