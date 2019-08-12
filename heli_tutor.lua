require "package"
if SCRIPT_DIRECTORY then
  package.path=package.path .. ";" .. SCRIPT_DIRECTORY .. "ht_exercises/?.lua"
end

lang="en"
rads2rpm=2*3.14*60
ht=false

-- misc functions --

-- read map file which contains 2 columns of key -> value
-- and returns a table mapping key -> value
function read_map(filename,sep)
  local map = {}
  print("INFO: reading field mapping file '" .. filename .. "'")
  for line in io.lines(filename) do
    if #line > 0 and not line:startswith("#") then
      -- detect separator as | or TAB on first non comment line
      if not sep then
        if string.find(line,"|") then
          sep = "|"
        elseif string.find(line,"\t") then
          sep = "\t"
        end
      end
      data = split(line,sep)
      if #data == 2 then
          print("INFO: mapping field name " .. data[1] .. " -> " .. data[2])
          map[data[1]] = data[2]
      end
    end
  end
  return map
end

function read_data_file(filename,sep,fieldmap)
  fieldmap = fieldmap or {}
  local alldata = {}
  local fields = nil
  print("INFO: read_data_file " .. filename .. " with " .. (sep or "nil"))
  for line in io.lines(filename) do
    if #line > 0 and not line:startswith("#") then
      -- detect separator as | or TAB on first non comment line
      if not sep then
        if string.find(line,"|") then
          sep = "|"
        elseif string.find(line,"\t") then
          sep = "\t"
        end
      end
      data = split(line,sep)
      --print("INFO:" .. inspect(data))
      tdata = {} -- each fields is trimmed of leading+trailing spaces
      for i,v in ipairs(data) do
        table.insert(tdata,v:strip())
      end
      if not fields then
        fields = {}
        for _,field in ipairs(tdata) do
          table.insert(fields,fieldmap[field] or field)
        end
      else
        table.insert(alldata,zip(fields,tdata))
      end
    end
  end
  return alldata
end

function join(list, delimiter)
   local len = getn(list)
   if len == 0 then
      return "" 
   end
   local string = list[1]
   for i = 2, len do 
      string = string .. delimiter .. list[i] 
   end
   return string
end

function write_data_file(data,filename,sep)
  print("write_data_file: " .. filename)
  local fields = {}
  for i,d in ipairs(data) do
    if not fields then
      fields = {}
      for k,v in pairs(d) do
        table.insert(fields,k)
      end
      s = join(fields,"\t")
      print(s)
    end
  end
end

-- reading and writing scores for exercises

function read_scores(filename)
  print("read_scores: " .. filename)
  data = read_data_file(filename,"\t")
  local scores = {}
  for i,d in ipairs(data) do
    scores[d.exercise] = d.score
  end
  return scores
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function write_scores(scores,filename)
  print("write_scores: " .. filename)
  f = io.open(filename,"w")
  io.output(f)
  io.write("exercise\tscore\n")
  for exercise,score in spairs(scores) do
    print(exercise .. "=" .. score)
    io.write(exercise .. "\t" .. math.floor(score) .. "\n")
  end
  io.close(f)
end

function save_score(score)
  if ex_index then
    exercises[ex_index].score = score
    if SCRIPT_DIRECTORY then
      write_data_file(exercises,SCRIPT_DIRECTORY .. "ht_exercises/exercises.txt","\t")
    else
      write_data_file(exercises,"ht_exercises/exercises.txt","\t")
    end
  else
    print("Don't know which row in exercises.txt to use. Would have set score to " .. score)
  end
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function string:strip()
    return self:match "^%s*(.-)%s*$"
end

function string:startswith(s)
   return self:sub(1,#s) == s
end

function inspect(o)
  local s="{",k,v
  for k,v in pairs(o) do
    s = s .. k .. "=" .. tostring(v) .. ", "
  end
  return s .. "}"
end

function asjson(o)
  local s="{",k,v
  local first = true
  for k,v in pairs(o) do
    if not first then
      s = s .. ","
    end
    if k ~= "" then
      s = s .. '"' .. k .. '":' .. tostring(v)
    end
    first = false
  end
  return s .. "}"
end


function zip(a,b)
  o = {}
  for i,a in ipairs(a) do
    o[a] = b[i]
  end
  return o
end

function heading_in_range(heading,lo,hi)
  local h = heading
  if lo<0 and hi<0 then
    h = h - 360
  end
  if lo>360 and hi>360 then
    h = h + 360
  end
  if lo<360 and hi>360 and h<180 then
    h = h + 360
  end
  return h>lo and h<hi
end

-- draw functions --

function draw_exercises(exercises)
    -- view from top with box around hover box (draw helipad)
    cx,cy = 10,400
    width = 300
    colwidth = 250
    rowheight = 20
    bordx,bordy = 5,15
    height = rowheight * (1+#exercises) + bordy
    graphics.set_color(0, 0, 0, 0.5)
    graphics.draw_rectangle(cx, cy, cx+width, cy+height)
    graphics.set_color(1, 1, 1, 1)
    -- setup scores
    i=0
    color="grey"
    graphics.draw_string(cx+bordx, cy+height-bordy-i*rowheight, "Exercise", color)
    graphics.draw_string(cx+bordx+colwidth, cy+height-bordy-i*rowheight, "Score", color)
    for i,d in ipairs(exercises) do
      score = tonumber(d.score)
      if score>50 then
        graphics.set_color(0, 0.8, 0, 1)
        color = "green"
      else
        graphics.set_color(1, 0, 0, 1)
        color = "red"
      end
      if ex_index==i then
        color = "white"
      end
      graphics.draw_string(cx+bordx, cy+height-bordy-i*rowheight, d.exercise, color)
      graphics.draw_string(cx+bordx+colwidth, cy+height-bordy-i*rowheight, math.floor(score) .. "%", color)
      i=i+1
    end
end

function on_mouse_click()
    cx,cy = 10,400
    width = 300
    colwidth = 250
    rowheight = 20
    bordx,bordy = 5,15
    if MOUSE_X < cx or MOUSE_X > cx+width or MOUSE_Y < cy or MOUSE_Y > cy+height then
        return
    end
    row = math.floor(0.5+(cy+height-bordy-MOUSE_Y)/rowheight)
    if row>0 then
        e = load_exercise(exercises[row].filename)
        ex_index = row
        RESUME_MOUSE_CLICK = true
    end
end

-- speak functions --

local speakrate = 0.08 -- 0.01 secs/character
local next_time = {}
local not_speaking_time = -1000

function can_speak(T,msgcode,messages)
  if not msgcode then
    return true
  end
  local phrase = messages[msgcode]
  if not phrase then
    print("ERROR! No such phrase " .. msgcode)
    return false
  end
  nt = next_time[msgcode] or 0
  if (T < not_speaking_time) or (nt > T) then
    return false
  end
  return true
end

function speak(t,msgcode,messages)
  -- pick randomly
  msgs = messages[msgcode]

  --phrase = messages[msgcode].message
  if not msgs then
    phrase = msgcode
    delay = 0
  else
    d = msgs[math.random(#msgs)]
    phrase = d.message
    delay = d.delay
  end
  if string.find(phrase, '"') then -- code to execure
    fphrase = load("return " .. phrase)
    if not fphrase then
      print("ERROR! Can't execute command '" .. phrase .. "'")
    end
    phrase = fphrase()
  end
  print("SPEAK: " .. phrase .. "'")
  if XPLMSpeakString then
    XPLMSpeakString(phrase)
  end
  not_speaking_time = t + speakrate*#phrase -- estimate 0.1 secs/character
  next_time[msgcode] = t + delay
end

-- rules --

--
-- A rule has
--   condition - a string to evaluate to true/false
--   command   - a string with lua code
--   to        - a state to transition to if condition=true
--   prob      - a probability of firing

local mtRule = {}

local function nilstr(x)
  if x then
    return x
  else
    return "nil"
  end
end

local newRule = function(val)
  local obj = val or {}
  obj.prob = tonumber(val.prob) or 1  -- default to 1.0
  if obj.msgcode == "" then
    obj.msgcode = nil
  end
  return setmetatable(obj, mtRule)
end

local tostringRule = function(self)
  return "Rule" .. inspect(self)
end

local istrue = function(self,t,messages)
  local r = true
  if self.condition then
    f = load("return " .. self.condition)
    if not f then
      print("ERROR! Can't evaluate condition '" .. self.condition .. "'")
    end
    r = f()
  end
  if self.msgcode then
    b = can_speak(t,self.msgcode,messages)
    r = r and b
  end
  return r
end

local fire = function(self,T,messages)
  print("FIRE: " .. inspect(self))
  if self.command then
    f = load(self.command)
    if not f then
      print("ERROR! command '" .. self.command .. " cannot be executed")
    end
    f()
  end
  if self.msgcode then
    speak(T,self.msgcode,messages)
  end
  return self.to
end

mtRule.istrue = istrue
mtRule.fire = fire
mtRule.__tostring = tostringRule
mtRule.__index = mtRule
mtRule.__metatable = {}

local ctorRule = function(cls, ...)
  return newRule(...)
end

Rule = setmetatable({}, { __call = ctorRule })

-- State --

local mtState = {}

local function nilstr(x)
  if x then
    return x
  else
    return "nil"
  end
end

local newState = function(o)
  local o = o or {}
  o.rules = {}
  return setmetatable(o, mtState)
end

local tostringState = function(self)
  local numrules = 0
  if self.rules then
    numrules = #self.rules
  end
  local rule
  local rules = ""
  if numrules > 0 then
    for _,rule in ipairs(self.rules) do
      rules = rules .. "  " .. tostring(rule) .. "\n"
    end
  end
  return "State(numrules=" .. numrules .. ")\n" .. rules
end

local addrule = function(self, rule)
  table.insert(self.rules,rule)
end

-- return index from item to choose given list of probabilities
local function choose(probs)
  local sump = 0
  local i,p
  for i,p in ipairs(probs) do
    sump = sump + p
  end
  local r = math.random()*sump
  local min = 0
  local max = probs[1]
  for i,p in ipairs(probs) do
    if (r>=0) and (r<p) then
      return i
    end
    r = r - p
  end
  return nil
end

local function process_datarefs()
  local m2f = 3.28 -- convert metres to feet
  if rotor_radspersec then
      rotor_rpm = rotor_radspersec*rads2rpm
  end
  if ELEVATION then
      elevation_ft = ELEVATION*m2f
  end
  if y_agl then
      y_agl_ft = y_agl * m2f
  end
end

-- evaludate rules and move to next state
local step = function(self,T,messages)
  process_datarefs()
  local active = {}
  local probs = {}
  -- if this global function defined (in the exercise lua code)
  if every then
    every()
  end

  -- find all rules with condition true
  for i,rule in ipairs(self.rules) do
    istrue = rule:istrue(T,messages)
    --print(istrue,rule)
    if rule:istrue(T,messages) then
      table.insert(active, rule)
      table.insert(probs, rule.prob)
    end
  end
  local i = choose(probs)
  if i then
    active[i]:fire(T,messages)
    return active[i].to
  else
    return nil
  end
end

mtState.addrule = addrule
mtState.step = step
mtState.__tostring = tostringState
mtState.__index = mtState
mtState.__metatable = {}

local ctorState = function(cls, ...)
  return newState(...)
end

State = setmetatable({}, { __call = ctorState })

-- exercise --

local mtExercise = {}

local newExercise = function()
  obj = {messages={},rules={},states={}}
  return setmetatable(obj, mtExercise)
end

local reset = function(self)
  self.current_state_name =  self.start_state_name
end

local load = function(self, fn_rules, fn_messages)
  self.start_state_name = nil
  self.fn_rules = fn_rules
  self.fn_messages = fn_messages
  self.states = {}
  self.messages = {}
  local section = nil
  local fields = nil
  local line,data,fields

  -- Read messages
  for i,d in ipairs(read_data_file(fn_messages,nil)) do
     if not d.msgcode or not d.message or not d.delay then
       print("ERROR! Messages file " .. fn_messages .. " must contain the fields msgcode, delay, message separated by |")
       return
     end
     msgcode = d.msgcode
     d.msgcode = nil
     -- each msgcode is a table so we can have multiple messages for the same code
     if not self.messages[msgcode] then
       self.messages[msgcode] = {}
     end
     table.insert(self.messages[msgcode],d)
  end

  -- Read rules
  -- create all State()'s first
  for i,d in ipairs(read_data_file(fn_rules,nil)) do
     if d.from and not self.states[d.from] then
         self.states[d.from] = State()
         if not self.start_state_name then
             self.start_state_name = d.from
         end
     end
     if d.to and not self.states[d.to] then
         self.states[d.to] = State()
     end
  end

  for i,d in ipairs(read_data_file(fn_rules,nil)) do
      local r = Rule(d)
      froms = {d.from}
      for _,from in ipairs(froms) do
          local state = self.states[from]
          if not self.start_state_name then
              self.start_state_name = from
          end
          state:addrule(r)
      end
  end
  if not self.start_state_name then
    print("ERROR! No starting state")
  end
  self:reset()
end

local tostringExercise = function(self)
  local s = "Exercise(filename=" .. self.fn_rules .. "\n"
  local state,rule,name,j
  s = s .. "  messages:\n"
  for msgcode,msgs in pairs(self.messages) do
    for _,d in ipairs(msgs) do
      s = s .. "    " .. msgcode .. "=" .. inspect(d) .. "\n"
    end
  end
  s = s .. "  states:\n"
  for name,state in pairs(self.states) do
    s = s .. "    " .. name .. ":" .. "\n"
    for j,rule in ipairs(state.rules) do
      s = s .. "      " .. tostring(rule) .. "\n"
    end
  end
  return s .. "  )"
end

local step = function(self,t)
  print("STATE: " .. self.current_state_name)
  local state = self.states[self.current_state_name]
  --print(tostring(state))
  local next_state_name = state:step(t,self.messages)
  if next_state_name then
    self.current_state_name = next_state_name
  end
end

local ctorExercise = function(cls, ...)
  return newExercise(...)
end

mtExercise.__tostring = tostringExercise
mtExercise.__index = mtExercise
mtExercise.__metatable = {}
mtExercise.load = load
mtExercise.reset = reset
mtExercise.step = step

Exercise = setmetatable({}, { __call = ctorExercise })

-- main program --

if not arg then
  arg = {}
end

if #arg > 0 and (arg[1]=="-h" or arg[1]=="--help") then
  print("usage: helitutor.lua [ <exercise.txt> <samples.txt> ] - no args for running as XPlane plugin")
  return
end

function load_exercise(exercisename)
  local e=Exercise()
  print("INFO: Loading exercise " .. exercisename)
  if SCRIPT_DIRECTORY then
    fn_rules = SCRIPT_DIRECTORY .. "ht_exercises/" .. exercisename .. ".rul"
    fn_messages = SCRIPT_DIRECTORY .. "ht_exercises/" .. exercisename .. ".msg"
  else
    fn_rules = exercisename .. ".rul"
    fn_messages = exercisename .. ".msg"
  end
  e:load(fn_rules,fn_messages)
  require(exercisename)
  --print(e)
  return e
end

local e = Exercise()
if arg and ((#arg~=0) and (#arg~=2)) then
  print("usage: heli_tutor.lua <exercise name> <data file>")
end

if arg and #arg==2 then
  exercisename = arg[1]
  fn_samples = arg[2]
  e=load_exercise(exercisename)
else
  fn_samples = nil
end

if SCRIPT_DIRECTORY then
    exercises = read_data_file(SCRIPT_DIRECTORY .. "ht_exercises/exercises.txt","\t")
else
    exercises = read_data_file("ht_exercises/exercises.txt","\t")
end


if fn_samples then
  -- load samples
  fieldmap = read_map("fieldmap.txt")
  samples = read_data_file(fn_samples,nil,fieldmap)

  e:reset()
  last_T=0
  for i,sample in ipairs(samples) do
    for k,v in pairs(sample) do
      _G[k] = tonumber(v)
    end
    print("DATA: " .. asjson(sample))
    e:step(T)
  end
end

if do_every_draw then
    do_every_draw("if ht then draw_exercises(exercises) end")
end
if do_on_mouse_click then
    do_on_mouse_click("if ht on_mouse_click()")
end

if dataref then
  -- running as X-Plane plugin
  if not add_macro then
    print("usage: helitutor.lua [ <exercise.txt> <samples.txt> ] - no args for running as XPlane plugin")
  end
  if add_macro then
    add_macro("Heli Tutor", "ht=true" , "ht=false", "deactivate")
  end
  if dataref then
    dataref("heading","sim/flightmodel/position/mag_psi")
    dataref("airspeed", "sim/flightmodel/position/indicated_airspeed")
    dataref("groundspeed", "sim/flightmodel/position/groundspeed")
    dataref("roll", "sim/flightmodel/position/phi")
    dataref("roll_rate","sim/flightmodel/position/P")
    dataref("pitch", "sim/flightmodel/position/theta")
    dataref("pitch_rate","sim/flightmodel/position/Q")
    dataref("yaw", "sim/flightmodel/position/beta") -- direction relative to flown path
    dataref("yaw_rate","sim/flightmodel/position/R")
    dataref("rotor_radspersec","sim/flightmodel/engine/POINT_tacrad")
    dataref("y_agl","sim/flightmodel/position/y_agl")
    dataref("vh_ind_fpm","sim/flightmodel/position/vh_ind_fpm")
    dataref("on_ground","sim/flightmodel/failures/onground_any")
    --
    do_often("if e then T=os.time(); e:step(os.time()) end")
  end
end
