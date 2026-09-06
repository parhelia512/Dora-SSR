-- [ts]: CommandPreview.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local DoraObject = ____Dora.Object -- 2
local Path = ____Dora.Path -- 2
local sleep = ____Dora.sleep -- 2
local Config = require("Agent.Config") -- 3
local ____EntryLease = require("Agent.Tool.EntryLease") -- 4
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 4
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 4
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 4
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 4
local ____Operation = require("Agent.Tool.Operation") -- 5
local createOperationId = ____Operation.createOperationId -- 5
local ____Workspace = require("Agent.Tool.Workspace") -- 6
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 6
local ensureDirPath = ____Workspace.ensureDirPath -- 6
local ____ToolBudgets = require("Agent.Tool.ToolBudgets") -- 7
local PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS = ____ToolBudgets.PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS -- 7
local PREVIEW_GAME_TIMEOUT_SECONDS = ____ToolBudgets.PREVIEW_GAME_TIMEOUT_SECONDS -- 7
local ____Utils = require("Agent.Utils") -- 8
local safeJsonEncode = ____Utils.safeJsonEncode -- 8
____exports.COMMAND_VISION_DIR = ".agent/vision" -- 24
--- Captures kept per project; oldest files roll out first.
____exports.COMMAND_VISION_MAX_FILES = 60 -- 27
--- Keep only the newest COMMAND_VISION_MAX_FILES capture files. Only files
-- named like <timestamp>-<random>.png (this feature's own output) are ever
-- removed; user-placed images in the same directory are untouched. Delete
-- failures are ignored: pruning must never break a capture.
function ____exports.pruneVisionCaptures(dir, keep) -- 35
	if keep == nil then -- 35
		keep = ____exports.COMMAND_VISION_MAX_FILES -- 35
	end -- 35
	if not Content:exist(dir) then -- 35
		return -- 36
	end -- 36
	local names = {} -- 37
	for ____, file in ipairs(Content:getFiles(dir)) do -- 38
		if (string.match(file, "^%d+%-%d+%.png$")) ~= nil then -- 38
			names[#names + 1] = file -- 39
		end -- 39
	end -- 39
	if #names <= keep then -- 39
		return -- 41
	end -- 41
	__TS__ArraySort( -- 43
		names, -- 43
		function(____, a, b) return a < b and 1 or (a > b and -1 or 0) end -- 43
	) -- 43
	do -- 43
		local i = keep -- 44
		while i < #names do -- 44
			Content:remove(Path(dir, names[i + 1])) -- 45
			i = i + 1 -- 44
		end -- 44
	end -- 44
end -- 35
--- The previewGame function injected into execute_command's Lua sandbox.
-- It owns the game exclusively, captures 1-3 frames at the requested
-- seconds after startup, saves them under .agent/vision in the project
-- and returns the project-relative paths. Runs synchronously on the
-- command coroutine; frame callbacks are awaited with sleep() polling.
function ____exports.createPreviewGameInjection(req, entry) -- 56
	return function(opts) -- 62
		local o = type(opts) == "table" and opts or ({}) -- 63
		local file = type(o.entry) == "string" and __TS__StringTrim(o.entry) ~= "" and __TS__StringTrim(o.entry) or "init.lua" -- 64
		local rawTimes = __TS__ArrayIsArray(o.captureAtSeconds) and o.captureAtSeconds or ({0.5}) -- 65
		local times = {} -- 66
		for ____, value in ipairs(rawTimes) do -- 67
			if type(value) == "number" and __TS__NumberIsFinite(value) then -- 67
				times[#times + 1] = value -- 68
			end -- 68
		end -- 68
		if not isValidWorkspacePath(file) or Path:getExt(file) ~= "lua" and Path:getExt(file) ~= "" then -- 68
			return {success = false, message = "previewGame requires a built project-relative Lua entry"} -- 71
		end -- 71
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 71
			times, -- 73
			function(____, t, i) return t < 0 or t > 10 or i > 0 and t <= times[i] end -- 73
		) then -- 73
			return {success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"} -- 74
		end -- 74
		local full = Path:replaceExt( -- 76
			Path(req.workDir, file), -- 76
			"lua" -- 76
		) -- 76
		if not Content:exist(full) then -- 76
			return {success = false, message = "Build the entry before previewGame"} -- 78
		end -- 78
		if Director.beginGameCapture == nil or Director.captureGameAsync == nil or Director.endGameCapture == nil then -- 78
			return {success = false, message = "This engine build does not support game capture; update Dora SSR"} -- 81
		end -- 81
		local visionDir = Path(req.workDir, ".agent", "vision") -- 83
		if not ensureDirPath(visionDir) then -- 83
			return {success = false, message = "failed to create the .agent/vision directory"} -- 85
		end -- 85
		local function cancelled() -- 87
			local ____this_1 -- 87
			____this_1 = req -- 87
			local ____opt_0 = ____this_1.isCancelled -- 87
			return (____opt_0 and ____opt_0(____this_1)) == true -- 87
		end -- 87
		local start = App.runningTime -- 88
		local scope = false -- 89
		local leased = false -- 90
		local files = {} -- 91
		local frames = {} -- 92
		local result = {success = false, message = "previewGame did not complete"} -- 93
		local function check() -- 94
			if cancelled() then -- 94
				error("previewGame cancelled") -- 95
			end -- 95
			if not ownsEntryLease(req.operationId, entry) then -- 95
				error("previewGame lost ownership of the running game") -- 96
			end -- 96
			if App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS then -- 96
				error("previewGame timed out") -- 97
			end -- 97
		end -- 94
		do -- 94
			local function ____catch(e) -- 94
				result = { -- 168
					success = false, -- 168
					files = files, -- 168
					message = tostring(e) -- 168
				} -- 168
			end -- 168
			local ____try, ____hasReturned = pcall(function() -- 168
				acquireEntryLease(req.operationId, entry) -- 100
				leased = true -- 101
				entry.allClear() -- 102
				scope = Director:beginGameCapture() -- 103
				if not scope then -- 103
					error("Game capture is unavailable or busy") -- 104
				end -- 104
				local objects = DoraObject.count -- 105
				local refs = DoraObject.luaRefCount -- 106
				recordEntryLeaseRun(req.operationId, entry) -- 107
				local previousHook, previousMask, previousCount = debug.gethook() -- 108
				do -- 108
					local ____try, ____error = pcall(function() -- 108
						debug.sethook( -- 110
							function() -- 110
								if cancelled() then -- 110
									error("previewGame cancelled during startup") -- 111
								end -- 111
								if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 111
									error("previewGame startup exceeded the game frame time budget") -- 112
								end -- 112
								if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 112
									error("previewGame startup exceeded the startup time budget") -- 113
								end -- 113
								if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 113
									error("previewGame startup exceeded the game object budget") -- 114
								end -- 114
							end, -- 110
							"", -- 115
							Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 115
						) -- 115
						local ok, message = entry.enterEntryAsync({ -- 116
							entryName = Path:getName(full), -- 117
							fileName = Path:replaceExt(full, ""), -- 118
							workDir = req.workDir, -- 119
							projectRoot = req.workDir, -- 120
							runKind = "agent_test" -- 121
						}) -- 121
						if not ok then -- 121
							error(message or "Game entry failed") -- 123
						end -- 123
					end) -- 123
					do -- 123
						if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 123
							debug.sethook(previousHook, previousMask, previousCount) -- 126
						else -- 126
							debug.sethook() -- 128
						end -- 128
					end -- 128
					if not ____try then -- 128
						error(____error, 0) -- 128
					end -- 128
				end -- 128
				local started = App.runningTime -- 131
				for ____, time in ipairs(times) do -- 132
					while App.runningTime - started < time do -- 132
						check() -- 134
						sleep() -- 135
					end -- 135
					check() -- 137
					local assetId = createOperationId() -- 138
					local absPath = Path(visionDir, assetId .. ".png") -- 139
					local done = false -- 140
					local saved = false -- 141
					local capturedAt = 0 -- 142
					local width = 0 -- 143
					local height = 0 -- 144
					if not Director:captureGameAsync( -- 144
						absPath, -- 145
						function(success, frameTime, sourceSize) -- 145
							saved = success -- 146
							capturedAt = frameTime -- 147
							width = sourceSize.width -- 148
							height = sourceSize.height -- 149
							done = true -- 150
						end -- 145
					) then -- 145
						error("Capture request was rejected") -- 151
					end -- 151
					while not done do -- 151
						check() -- 153
						sleep() -- 154
					end -- 154
					check() -- 156
					if not saved then -- 156
						error("Game capture could not be saved") -- 157
					end -- 157
					local relative = ((____exports.COMMAND_VISION_DIR .. "/") .. assetId) .. ".png" -- 158
					files[#files + 1] = relative -- 159
					frames[#frames + 1] = {path = relative, width = width, height = height, elapsedSeconds = capturedAt - started} -- 160
				end -- 160
				____exports.pruneVisionCaptures(visionDir) -- 162
				local cleanupError = releaseEntryLease(req.operationId, entry) -- 163
				leased = false -- 164
				if cleanupError then -- 164
					error(cleanupError) -- 165
				end -- 165
				result = {success = true, files = files, frames = frames} -- 166
			end) -- 166
			if not ____try then -- 166
				____catch(____hasReturned) -- 166
			end -- 166
			do -- 166
				if scope then -- 166
					Director:endGameCapture() -- 170
				end -- 170
				if leased then -- 170
					local cleanupError = releaseEntryLease(req.operationId, entry) -- 172
					if cleanupError ~= nil then -- 172
						result = result.success and ({success = false, files = files, message = cleanupError}) or ({success = false, files = files, message = ((result.message or "previewGame failed") .. "; ") .. cleanupError}) -- 174
					end -- 174
				end -- 174
			end -- 174
		end -- 174
		local encoded = safeJsonEncode(result) -- 180
		if encoded then -- 180
			req:print(encoded) -- 181
		end -- 181
		return result -- 182
	end -- 62
end -- 56
return ____exports -- 56