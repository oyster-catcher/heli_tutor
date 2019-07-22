require "package"
if SCRIPT_DIRECTORY then
  package.path=package.path .. ";" .. SCRIPT_DIRECTORY .. "ht_exercises/?.lua"
end

lang="en"
rads2rpm=2*3.14*60

-- misc functions --

-- read map file which contains 2 columns of key -> value
-- and returns a table mapping key -> value
function read_map(filename,sep)
  local map = {}
  print("heli_tutor: reading field mapping file '" .. filename .. "'")
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
      data = line:split(sep)
      if #data == 2 then
          print("heli_tutor: mapping field name " .. data[1] .. " -> " .. data[2])
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
  print("read_data_file: '" .. filename .. "' with sep=" .. (sep or "nil"))
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
      data = line:split(sep)
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

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]*)", sep)
   --local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
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

function zip(a,b)
  o = {}
  for i,a in ipairs(a) do
    o[a] = b[i]
  end
  return o
end

function heading_in_range(heading,lo,hi)
  if lo<0 and hi<0 then
    heading = heading - 360
  end
  if lo>360 and hi>360 then
    heading = heading + 360
  end
  if lo<360 and hi>360 and heading<180 then
    heading = heading + 360
  end
  return heading>lo and heading<hi
end

-- speak functions --

local speakrate = 0.08 -- 0.01 secs/character
local next_time = {}
local not_speaking_time = -1000

function load_phrases()
  phrases["HOVER"] = {msg="Come to a nice hover", delay=5}
end

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
  phrase = messages[msgcode].message
  if not phrase then
    phrase = msgcode
    delay = 0
  else
    delay = messages[msgcode].delay
  end
  if string.find(phrase, '"') then -- code to execure
    fphrase = load("return " .. phrase)
    if not fphrase then
      print("ERROR! Can't execute command '" .. phrase .. "'")
    end
    phrase = fphrase()
  end
  print("  speaking '" .. phrase .. "'")
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
  print("  fire: " .. inspect(self))
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
      alt_ft = ELEVATION*m2f
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
     self.messages[msgcode] = d
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
  for msgcode,msg in pairs(self.messages) do
    s = s .. "    " .. msgcode .. "=" .. inspect(msg) .. "\n"
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
  print("  T=" .. T .. " current=" .. self.current_state_name)
  local state = self.states[self.current_state_name]
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
  print("Loading exercise: " .. exercisename)
  if SCRIPT_DIRECTORY then
    fn_rules = SCRIPT_DIRECTORY .. "ht_exercises/" .. exercisename .. ".rul"
    fn_messages = SCRIPT_DIRECTORY .. "ht_exercises/" .. exercisename .. ".msg"
  else
    fn_rules = exercisename .. ".rul"
    fn_messages = exercisename .. ".msg"
  end
  e:load(fn_rules,fn_messages)
  require(exercisename)
  print(e)
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
  -- Add all exercises
  exercises = {}
  table.insert(exercises,"ex6_straight_and_level_flight")
  table.insert(exercises,"ex78_climbing_descending")
  table.insert(exercises,"ex9_takeoff")
  table.insert(exercises,"ex10_basic_auto")
  fn_samples = nil
end


if fn_samples then
  -- load samples
  fieldmap = read_map("fieldmap.txt")
  samples = read_data_file(fn_samples,nil,fieldmap)

  print("-------------------------")
  e:reset()
  last_T=0
  for i,sample in ipairs(samples) do
    for k,v in pairs(sample) do
      _G[k] = tonumber(v)
    end
    --print("DATALOG:",inspect(sample))
    e:step(T)
  end
end
if dataref then
  -- running as X-Plane plugin
  if not add_macro then
    print("usage: helitutor.lua [ <exercise.txt> <samples.txt> ] - no args for running as XPlane plugin")
  end
  if add_macro then
    add_macro("Heli Tutor: Exercise 6 - Straight and Level Flight", "e=load_exercise('ex6_straight_and_level_flight')" , "e=nil", "deactivate")
    add_macro("Heli Tutor: Exercise 7 & 8 - Climbing and Descending", "e=load_exercise('ex78_climbing_descending')" , "e=nil", "deactivate")
    add_macro("Heli Tutor: Exercise 9 - Take off", "e=load_exercise('ex9_takeoff')" , "e=nil", "deactivate")
    add_macro("Heli Tutor: Exercise 10 - Basic Autorotation", "e=load_exercise('ex10_basic_auto')" , "e=nil", "deactivate")
    add_macro("Heli Tutor: Exercise 11 - The Circuit (Square)", "e=load_exercise('ex11_heli_circuit')" , "e=nil", "deactivate")
  end
  if dataref then
    dataref("heading","sim/flightmodel/position/true_psi")
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
