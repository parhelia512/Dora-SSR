package.path = "?.lua"
package.cpath = nil
package.moonpath = "?.moon"

local App = builtin.Application()
local Director = builtin.Director()
local Content = builtin.Content()
local View = builtin.View()
local Audio = builtin.Audio()
local Keyboard = builtin.Keyboard()
local AI = builtin.Platformer.AI()
local Data = builtin.Platformer.Data()

builtin.App = App
builtin.Content = Content
builtin.Director = Director
builtin.View = View
builtin.Audio = Audio
builtin.Keyboard = Keyboard
builtin.Platformer.AI = AI
builtin.Platformer.Data = Data

local yield = coroutine.yield
local wrap = coroutine.wrap
local table_insert = table.insert
local table_remove = table.remove
local type = type
local unpack = unpack
local xpcall = xpcall

local function wait(cond)
	repeat
		yield(false)
	until cond()
end

local function once(work)
	return wrap(function(...)
		work(...)
		yield(false)
		return true
	end)
end

local function loop(work)
	return wrap(function(...)
		while work(...) ~= true do
			yield(false)
		end
		return true
	end)
end

local function seconds(duration)
	local time = 0
	return function(deltaTime)
		time = time + deltaTime
		return time < duration
	end
end

local function cycle(duration,work)
	local time = 0
	local function worker()
		local deltaTime = Director.deltaTime
		time = time + deltaTime
		if time < duration then
			work(time/duration)
			return true
		else
			work(1)
			return false
		end
	end
	work(0)
	if time < duration then
		yield(false)
		while worker() do
			yield(false)
		end
	end
end

local function Routine_end() return true end
local Routine =
{
	remove = function(self,routine)
		for i = 1,#self do
			if self[i] == routine then
				self[i] = Routine_end
				return true
			end
		end
		return false
	end,
	clear = function(self)
		while #self > 0 do
			table_remove(self)
		end
	end,
}

setmetatable(Routine,
{
	__call = function(self,routine)
		table_insert(self,routine)
		return routine
	end,
})

local function traceback(err)
	return debug.traceback(err,1)
end

Director.postScheduler:schedule(function()
	local i,count = 1,#Routine
	while i <= count do
		local success,result = xpcall(Routine[i],traceback)
		if (success and result) or (not success) then
			Routine[i] = Routine[count]
			table_remove(Routine,count)
			i = i-1
			count = count-1
		end
		if not success then
			print(result)
		end
		i = i+1
	end
	return false
end)

builtin.Routine = Routine
builtin.wait = wait
builtin.once = once
builtin.loop = loop
builtin.seconds = seconds
builtin.cycle = cycle

builtin.thread = function(routine)
	return Routine(once(routine))
end

builtin.threadLoop = function(routine)
	return Routine(loop(routine))
end

builtin.sleep = function(duration)
	if duration then
		local time = 0
		repeat
			yield(false)
			time = time + Director.deltaTime
		until time >= duration
	else
		yield(false)
	end
end

builtin.namespace = function(path)
	return function(name)
		return require(path.."."..name)
	end
end
_G.namespace = builtin.namespace

-- Async functions

local Content_loadAsync = Content.loadAsync
Content.loadAsync = function(self,filename)
	local loadedData
	Content_loadAsync(self,filename,function(data)
		loadedData = data
	end)
	wait(function() return loadedData end)
	return loadedData
end

local Content_saveAsync = Content.saveAsync
Content.saveAsync = function(self,filename,content)
	local saved = false
	Content_saveAsync(self,filename,content,function()
		saved = true
	end)
	wait(function() return saved end)
end

local Content_copyAsync = Content.copyAsync
Content.copyAsync = function(self,src,dst)
	local loaded  = false
	Content_copyAsync(self,src,dst,function()
		loaded = true
	end)
	wait(function() return loaded end)
end

local Cache = builtin.Cache
local Cache_loadAsync = Cache.loadAsync
Cache.loadAsync = function(self,target,handler)
	local files
	if type(target) == "table" then
		files = target
	else
		files = {target}
	end
	local count = 0
	local total = #files
	for i = 1,total do
		Cache_loadAsync(self,files[i],function()
			if handler then
				handler(files[i])
			end
			count = count + 1
		end)
	end
	wait(function() return count == total end)
end

local RenderTarget = builtin.RenderTarget
local RenderTarget_saveAsync = RenderTarget.saveAsync
RenderTarget.saveAsync = function(self,filename)
	local saved = false
	RenderTarget_saveAsync(self,filename,function()
		saved = true
	end)
	wait(function() return saved end)
end

-- Action

local Action = builtin.Action
local Node = builtin.Node
local Node_runAction = Node.runAction
Node.runAction = function(self,action)
	if type(action) == "table" then
		Node_runAction(self,Action(action))
	else
		Node_runAction(self,action)
	end
end
local Node_perform = Node.perform
Node.perform = function(self,action)
	if type(action) == "table" then
		Node_perform(self,Action(action))
	else
		Node_perform(self,action)
	end
end

for _,actionName in ipairs{
	"X",
	"Y",
	"Z",
	"ScaleX",
	"ScaleY",
	"SkewX",
	"SkewY",
	"Angle",
	"AngleX",
	"AngleY",
	"Width",
	"Height",
	"AnchorX",
	"AnchorY",
	"Opacity",
	"Roll",
	"Hide",
	"Show",
	"Delay",
	"Emit",
	"Spawn",
	"Sequence",
	} do
	builtin[actionName] = function(...)
		return {actionName, ...}
	end
end

local Spawn = builtin.Spawn
local X = builtin.X
local Y = builtin.Y
local ScaleX = builtin.ScaleX
local ScaleY = builtin.ScaleY

builtin.Move = function(duration, start, stop, ease)
	return Spawn(
		X(duration, start.x, stop.x, ease),
		Y(duration, start.y, stop.y, ease))
end

builtin.Scale = function(duration, start, stop, ease)
	return Spawn(
		ScaleX(duration, start, stop, ease),
		ScaleY(duration, start, stop, ease))
end

-- Array

local Array = builtin.Array
local Array_index = Array.__index
local Array_get = Array.get
Array.__index = function(self,key)
	if type(key) == "number" then
		return Array_get(self,key)
	end
	return Array_index(self,key)
end

local Array_newindex = Array.__newindex
local Array_set = Array.set
Array.__newindex = function(self,key,value)
	if type(key) == "number" then
		Array_set(self,key,value)
	else
		Array_newindex(self,key,value)
	end
end
Array.__len = function(self)
	return self.count
end

-- Dictionary

local Dictionary = builtin.Dictionary
local Dictionary_index = Dictionary.__index
local Dictionary_get = Dictionary.get
Dictionary.__index = function(self,key)
	local item = Dictionary_get(self,key)
	if item ~= nil then return item end
	return Dictionary_index(self,key)
end

local Dictionary_newindex = Dictionary.__newindex
local Dictionary_set = Dictionary.set
Dictionary.__newindex = function(self,key,value)
	local vtype = type(value)
	if vtype == "function" or vtype == "table" then
		Dictionary_newindex(self,key,value)
	else
		Dictionary_set(self,key,value)
	end
end
Dictionary.__len = function(self)
	return self.count
end

-- Entity

local Entity = builtin.Entity

local Entity_create = Entity[2]
local Entity_cache = {}
Entity[2] = function(cls)
	local entity = Entity_create(cls)
	Entity_cache[entity.index+1] = entity
	return entity
end

local Entity_clear = Entity.clear
Entity.clear = function(cls)
	Entity_cache = {}
	Entity_clear(cls)
end

local Entity_getOld = Entity.getOld
local Entity_oldValues
Entity_oldValues = setmetatable({false},{
	__mode = "v",
	__index = function(_,key)
		return Entity_getOld(Entity_oldValues[1],key)
	end,
	__newindex = function(_,_)
		error("Can not assign value cache.")
	end
})

local Entity_index = Entity.__index
local Entity_get = Entity.get
local rawset = rawset
Entity.__index = function(self,key)
	if key == "oldValues" then
		rawset(Entity_oldValues, 1, self)
		return Entity_oldValues
	end
	local item = Entity_get(self,key)
	if item ~= nil then return item end
	return Entity_index(self,key)
end

local Entity_newindex = Entity.__newindex
local Entity_set = Entity.set
Entity.__newindex = function(self,key,value)
	local vtype = type(value)
	if vtype == "function" or vtype == "table" then
		Entity_newindex(self,key,value)
	else
		Entity_set(self,key,value)
	end
end

Entity.setRaw = function(self,key,value)
	Entity_set(self,key,value,true)
end

-- UnitAction

local UnitAction = builtin.Platformer.UnitAction
local UnitAction_add = UnitAction.add
UnitAction.add = function(self, name, params)
	UnitAction_add(self, name,
		params.priority,
		params.reaction,
		params.recovery,
		params.available,
		params.create,
		params.stop)
end

-- ImGui
local ImGui = builtin.ImGui

local function traceback(msg)
	msg = debug.traceback(msg)
	print(msg)
end

local function pairCallA(beginFunc, endFunc)
	return function(...)
		local args = {...}
		local callFunc = table_remove(args)
		if type(callFunc) ~= "function" then
			error("ImGui paired calls now require a function as last argument in 'Begin' function.")
		end
		if beginFunc(unpack(args)) then
			xpcall(callFunc, traceback)
		end
		endFunc()
	end
end

local function pairCallB(beginFunc, endFunc)
	return function(...)
		local args = {...}
		local callFunc = table_remove(args)
		if type(callFunc) ~= "function" then
			error("ImGui paired calls now require a function as last argument in 'Begin' function.")
		end
		if beginFunc(unpack(args)) then
			xpcall(callFunc, traceback)
			endFunc()
		end
	end
end

local function pairCallC(beginFunc, endFunc)
	return function(...)
		local args = {...}
		local callFunc = table_remove(args)
		if type(callFunc) ~= "function" then
			error("ImGui paired calls now require a function as last argument in 'Begin' function.")
		end
		beginFunc(unpack(args))
		xpcall(callFunc, traceback)
		endFunc()
	end
end

ImGui.Begin = pairCallA(ImGui.Begin,ImGui.End)
ImGui.End = nil
ImGui.BeginChild = pairCallA(ImGui.BeginChild,ImGui.EndChild)
ImGui.EndChild = nil
ImGui.BeginChildFrame = pairCallA(ImGui.BeginChildFrame,ImGui.EndChildFrame)
ImGui.EndChildFrame = nil
ImGui.BeginPopup = pairCallB(ImGui.BeginPopup,ImGui.EndPopup)
ImGui.BeginPopupModal = pairCallB(ImGui.BeginPopupModal,ImGui.EndPopup)
ImGui.BeginPopupContextItem = pairCallB(ImGui.BeginPopupContextItem,ImGui.EndPopup)
ImGui.BeginPopupContextWindow = pairCallB(ImGui.BeginPopupContextWindow,ImGui.EndPopup)
ImGui.BeginPopupContextVoid = pairCallB(ImGui.BeginPopupContextVoid,ImGui.EndPopup)
ImGui.EndPopup = nil
ImGui.BeginGroup = pairCallC(ImGui.BeginGroup,ImGui.EndGroup)
ImGui.EndGroup = nil
ImGui.BeginTooltip = pairCallC(ImGui.BeginTooltip,ImGui.EndTooltip)
ImGui.EndTooltip = nil
ImGui.BeginMainMenuBar = pairCallC(ImGui.BeginMainMenuBar,ImGui.EndMainMenuBar)
ImGui.EndMainMenuBar = nil
ImGui.BeginMenuBar = pairCallC(ImGui.BeginMenuBar,ImGui.EndMenuBar)
ImGui.EndMenuBar = nil
ImGui.BeginMenu = pairCallC(ImGui.BeginMenu,ImGui.EndMenu)
ImGui.EndMenu = nil
ImGui.PushStyleColor = pairCallC(ImGui.PushStyleColor,ImGui.PopStyleColor)
ImGui.PopStyleColor = nil
ImGui.PushStyleVar = pairCallC(ImGui.PushStyleVar,ImGui.EndMenu)
ImGui.PopStyleVar = nil
ImGui.PushItemWidth = pairCallC(ImGui.PushItemWidth,ImGui.PopItemWidth)
ImGui.PopItemWidth = nil
ImGui.PushTextWrapPos = pairCallC(ImGui.PushTextWrapPos,ImGui.PopTextWrapPos)
ImGui.PopTextWrapPos = nil
ImGui.PushAllowKeyboardFocus = pairCallC(ImGui.PushAllowKeyboardFocus,ImGui.PopAllowKeyboardFocus)
ImGui.PopAllowKeyboardFocus = nil
ImGui.PushButtonRepeat = pairCallC(ImGui.PushButtonRepeat,ImGui.PopButtonRepeat)
ImGui.PopButtonRepeat = nil
ImGui.PushID = pairCallC(ImGui.PushID,ImGui.PopID)
ImGui.PopID = nil
ImGui.TreePush = pairCallC(ImGui.TreePush,ImGui.TreePop)
ImGui.TreePop = nil
ImGui.PushClipRect = pairCallC(ImGui.PushClipRect,ImGui.PopClipRect)
ImGui.PopClipRect = nil

-- Helpers

local function disallowAssignGlobal(_,name)
	error("Disallow creating global variable \""..name.."\".")
end

local function Dorothy(...)
	if select("#", ...) == 0 then
		setfenv(2,builtin)
	else
		local envs
		envs = {
			__index = function(_,key)
				for _,env in ipairs(envs) do
					local item = env[key]
					if item then
						return item
					end
				end
				return nil
			end,
			__newindex = disallowAssignGlobal,
			builtin,...
		}
		setfenv(2,setmetatable(envs,envs))
	end
end
_G.Dorothy = Dorothy
builtin.Dorothy = Dorothy

for k,v in pairs(_G) do
	builtin[k] = v
end
setmetatable(package.loaded,{__index=builtin})

local builtinEnvMeta = {
	__newindex = disallowAssignGlobal
}
setmetatable(_G,builtinEnvMeta)
setmetatable(builtin,builtinEnvMeta)

-- moonscript
local moonp = package.loaded["moonp"]
moonp.file_exist = function(fname)
	return Content:exist(fname)
end
moonp.read_file = function(fname)
	return Content:load(fname)
end

collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)