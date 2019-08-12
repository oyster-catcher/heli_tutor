msgcode	delay	message
SETTING	2	"Setting up waypoints for heading " .. dp(heading,0)
WAYPOINT1	15	turnLR(heading,wp_hdg(wp[1])) .. " to heading " .. dp(wp_hdg(wp[1]),0) .. " for " .. dp(wp_dist(wp[1]),1) .. " miles"
WAYPOINT2	15	turnLR(heading,wp_hdg(wp[2])) .. " to heading " .. dp(wp_hdg(wp[2]),0) .. " for " .. dp(wp_dist(wp[2]),1) .. " miles"
WAYPOINT3	15	turnLR(heading,wp_hdg(wp[3])) .. " to heading " .. dp(wp_hdg(wp[3]),0) .. " for " .. dp(wp_dist(wp[3]),1) .. " miles"
WAYPOINT4	15	turnLR(heading,wp_hdg(wp[4])) .. " to heading " .. dp(wp_hdg(wp[4]),0) .. " for " .. dp(wp_dist(wp[4]),1) .. " miles"
REACHED1	2	"Waypoint 1 reached. Now " .. turnLR(heading,wp_hdg(wp[2])) .. " to heading " .. dp(wp_hdg(wp[2]),0) .. " for waypoint 2"
REACHED2	2	"Waypoint 2 reached. Now " .. turnLR(heading,wp_hdg(wp[3])) .. " to heading " .. dp(wp_hdg(wp[3]),0) .. " for waypoint 3"
REACHED3	2	"Waypoint 3 reached. Now " .. turnLR(heading,wp_hdg(wp[4])) .. " to heading " .. dp(wp_hdg(wp[4]),0) .. " for waypoint 4"
REACHED4	2	"Waypoint 4 reached. Finished"
