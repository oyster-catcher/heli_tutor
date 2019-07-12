m2f=3.28
f2m=1/3.28

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

function climb_or_descend(alt,tgt_alt)
  if alt < tgt_alt then
    return "climb"
  else
    return "descend"
  end
end
