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

function bearing( lat1_d, lon1_d, lat2_d, lon2_d )
   lat1 = math.rad(lat1_d)
   lon1 = math.rad(lon1_d)
   lat2 = math.rad(lat2_d)
   lon2 = math.rad(lon2_d)
   L    = lon2 - lon1
   cosD = math.sin(lat1)*math.sin(lat2) + math.cos(lat1)*math.cos(lat2)*math.cos(L)
   D    = math.acos(cosD)
   cosC = (math.sin(lat2) - cosD*math.sin(lat1))/(math.sin(D)*math.cos(lat1))
   if( cosC > 1.0 ) then
     cosC = 1.0
   end
   C = 180.0*math.acos(cosC)/math.pi
   if( math.sin(L) < 0.0 ) then
        C = 360.0 - C
   end
   return C
end

function dist( lat1_d, lon1_d, lat2_d, lon2_d )
  x = lon2_d - lon1_d
  y = lat2_d - lat1_d
  x = x * math.cos(math.rad(lat1_d))
  return math.sqrt(x*x+y*y)*60.0 -- 1 degree lat or lon = 60 nm at equator
end

function wp_hdg(wp)
  return bearing(LATITUDE,LONGITUDE,wp.lat,wp.lon)
end

function wp_dist(wp)
  return dist(LATITUDE,LONGITUDE,wp.lat,wp.lon)
end

function dp(x,numdp)
  local sc = math.pow(10,numdp)
  return math.floor(x*sc)/sc
end

-- works only for small distances
function new_wp_on_bearing(lat,lon,hdg,dist)
  lat2 = lat + math.cos(math.rad(hdg))*dist/60.0
  lon2 = lon + math.sin(math.rad(hdg))*dist/math.cos(math.rad(lat))/60.0
  return {lat=lat2, lon=lon2}
end

function setup_waypoints(heading)
  local wp = {}
  wp[1] = new_wp_on_bearing(LATITUDE,LONGITUDE,heading,3)
  wp[2] = new_wp_on_bearing(wp[1].lat,wp[1].lon,heading-90,3)
  wp[3] = new_wp_on_bearing(wp[2].lat,wp[2].lon,heading-180,6)
  wp[4] = new_wp_on_bearing(LATITUDE,LONGITUDE,heading-180,3)
  return wp
end

-- returns "straight ahead", "right", "left", "right a bit", "left a bit"
-- hdg1 = current heading
-- hdg2 - new heading
function turnLR(hdg1,hdg2)
  hdg1 = hdg1%360
  hdg2 = hdg2%360
  if hdg1 < 180 and hdg2 > 180 then
    hdg2 = hdg2 - 360
  end
  if hdg1 > 180 and hdg2 < 180 then
    hdg2 = hdg2 + 360
  end
  if math.abs(hdg2-hdg1) < 5 then
    return "straight"
  end
  if hdg2-hdg1 > 45 then
    return "turn right"
  end
  if hdg2-hdg1 < -45 then
    return "turn left"
  end
  if hdg2-hdg1 > 5 then
    return "turn right a bit"
  end
  if hdg2-hdg1 < -5 then
    return "turn left a bit"
  end
end

LATITUDE=45
LONGITUDE=180

wp = setup_waypoints(45)
print(wp[1].lat,wp[1].lon)
print(wp_hdg(wp[1]))
print(wp_dist(wp[1]))
