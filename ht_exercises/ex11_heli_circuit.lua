m2f=3.28

function every()
  if ln0 and ln1 then
    x,y=coords(ln0,lt0,ln1,lt1,LONGITUDE,LATITUDE)
  else
    x,y=0,0
  end
end

function neardir(target,tolerance,actual)
  if (target<0) then
    if actual>0 then
      actual = actual - 360
    end
  end
  if (target>360) then
    if actual<360 then
      actual = actual + 360
    end
  end
  return (actual > target-tolerance) and (actual < target+tolerance)
end

function coord(orgLon,orgLat,Lon,Lat)
  x = Lon - orgLon
  y = Lat - orgLat
  -- compensate for lines on longitude getting closer nearer poles
  x = x * math.cos(math.rad(orgLat))
  -- convert to nautical miles East and North
  x = x*60.0
  y = y*60.0
  return x,y
end

-- defines a co-ordinate frame where point A to B
-- defines the Y axis
-- call the function coord(LONGITUDE,LATITUDE) so get
-- x and y coords on the ground in nautical miles
function coords(LonA,LatA,LonB,LatB,Lon,Lat)
  ax,ay = coord(LonA,LatA,LonB,LatB)
  -- normalise
  d = math.sqrt(ax*ax+ay*ay)
  ax = ax/d
  ay = ay/d
  dx,dy = coord(LonA,LatA,Lon,Lat)
  x =  dx*ax + dy*ay
  y = -dx*ay + dy*ax
  return x,y
end

function dist(LonA,LatA,LonB,LatB)
  x,y = coord(LonA,LatA,LonB,LatB)
  return math.sqrt(x*x+y*y)
end
