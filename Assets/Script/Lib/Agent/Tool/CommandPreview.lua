-- [ts]: CommandPreview.ts
local ____lualib = require("lualib_bundle") -- 1
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
--- The previewGame function injected into execute_command's Lua sandbox.
-- It owns the game exclusively, captures 1-3 frames at the requested
-- seconds after startup, saves them under .agent/vision in the project
-- and returns the project-relative paths. Runs synchronously on the
-- command coroutine; frame callbacks are awaited with sleep() polling.
function ____exports.createPreviewGameInjection(req, entry) -- 33
	return function(opts) -- 39
		local o = type(opts) == "table" and opts or ({}) -- 40
		local file = type(o.entry) == "string" and __TS__StringTrim(o.entry) ~= "" and __TS__StringTrim(o.entry) or "init.lua" -- 41
		local rawTimes = __TS__ArrayIsArray(o.captureAtSeconds) and o.captureAtSeconds or ({0.5}) -- 42
		local times = {} -- 43
		for ____, value in ipairs(rawTimes) do -- 44
			if type(value) == "number" and __TS__NumberIsFinite(value) then -- 44
				times[#times + 1] = value -- 45
			end -- 45
		end -- 45
		if not isValidWorkspacePath(file) or Path:getExt(file) ~= "lua" and Path:getExt(file) ~= "" then -- 45
			return {success = false, message = "previewGame requires a built project-relative Lua entry"} -- 48
		end -- 48
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 48
			times, -- 50
			function(____, t, i) return t < 0 or t > 10 or i > 0 and t <= times[i] end -- 50
		) then -- 50
			return {success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"} -- 51
		end -- 51
		local full = Path:replaceExt( -- 53
			Path(req.workDir, file), -- 53
			"lua" -- 53
		) -- 53
		if not Content:exist(full) then -- 53
			return {success = false, message = "Build the entry before previewGame"} -- 55
		end -- 55
		if Director.beginGameCapture == nil or Director.captureGameAsync == nil or Director.endGameCapture == nil then -- 55
			return {success = false, message = "This engine build does not support game capture; update Dora SSR"} -- 58
		end -- 58
		local visionDir = Path(req.workDir, ".agent", "vision") -- 60
		if not ensureDirPath(visionDir) then -- 60
			return {success = false, message = "failed to create the .agent/vision directory"} -- 62
		end -- 62
		local function cancelled() -- 64
			local ____this_1 -- 64
			____this_1 = req -- 64
			local ____opt_0 = ____this_1.isCancelled -- 64
			return (____opt_0 and ____opt_0(____this_1)) == true -- 64
		end -- 64
		local start = App.runningTime -- 65
		local scope = false -- 66
		local leased = false -- 67
		local files = {} -- 68
		local frames = {} -- 69
		local result = {success = false, message = "previewGame did not complete"} -- 70
		local function check() -- 71
			if cancelled() then -- 71
				error("previewGame cancelled") -- 72
			end -- 72
			if not ownsEntryLease(req.operationId, entry) then -- 72
				error("previewGame lost ownership of the running game") -- 73
			end -- 73
			if App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS then -- 73
				error("previewGame timed out") -- 74
			end -- 74
		end -- 71
		do -- 71
			local function ____catch(e) -- 71
				result = { -- 144
					success = false, -- 144
					files = files, -- 144
					message = tostring(e) -- 144
				} -- 144
			end -- 144
			local ____try, ____hasReturned = pcall(function() -- 144
				acquireEntryLease(req.operationId, entry) -- 77
				leased = true -- 78
				entry.allClear() -- 79
				scope = Director:beginGameCapture() -- 80
				if not scope then -- 80
					error("Game capture is unavailable or busy") -- 81
				end -- 81
				local objects = DoraObject.count -- 82
				local refs = DoraObject.luaRefCount -- 83
				recordEntryLeaseRun(req.operationId, entry) -- 84
				local previousHook, previousMask, previousCount = debug.gethook() -- 85
				do -- 85
					local ____try, ____error = pcall(function() -- 85
						debug.sethook( -- 87
							function() -- 87
								if cancelled() then -- 87
									error("previewGame cancelled during startup") -- 88
								end -- 88
								if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 88
									error("previewGame startup exceeded the game frame time budget") -- 89
								end -- 89
								if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 89
									error("previewGame startup exceeded the startup time budget") -- 90
								end -- 90
								if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 90
									error("previewGame startup exceeded the game object budget") -- 91
								end -- 91
							end, -- 87
							"", -- 92
							Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 92
						) -- 92
						local ok, message = entry.enterEntryAsync({ -- 93
							entryName = Path:getName(full), -- 94
							fileName = Path:replaceExt(full, ""), -- 95
							workDir = req.workDir, -- 96
							projectRoot = req.workDir, -- 97
							runKind = "agent_test" -- 98
						}) -- 98
						if not ok then -- 98
							error(message or "Game entry failed") -- 100
						end -- 100
					end) -- 100
					do -- 100
						if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 100
							debug.sethook(previousHook, previousMask, previousCount) -- 103
						else -- 103
							debug.sethook() -- 105
						end -- 105
					end -- 105
					if not ____try then -- 105
						error(____error, 0) -- 105
					end -- 105
				end -- 105
				local started = App.runningTime -- 108
				for ____, time in ipairs(times) do -- 109
					while App.runningTime - started < time do -- 109
						check() -- 111
						sleep() -- 112
					end -- 112
					check() -- 114
					local assetId = createOperationId() -- 115
					local absPath = Path(visionDir, assetId .. ".png") -- 116
					local done = false -- 117
					local saved = false -- 118
					local capturedAt = 0 -- 119
					local width = 0 -- 120
					local height = 0 -- 121
					if not Director:captureGameAsync( -- 121
						absPath, -- 122
						function(success, frameTime, sourceSize) -- 122
							saved = success -- 123
							capturedAt = frameTime -- 124
							width = sourceSize.width -- 125
							height = sourceSize.height -- 126
							done = true -- 127
						end -- 122
					) then -- 122
						error("Capture request was rejected") -- 128
					end -- 128
					while not done do -- 128
						check() -- 130
						sleep() -- 131
					end -- 131
					check() -- 133
					if not saved then -- 133
						error("Game capture could not be saved") -- 134
					end -- 134
					local relative = ((____exports.COMMAND_VISION_DIR .. "/") .. assetId) .. ".png" -- 135
					files[#files + 1] = relative -- 136
					frames[#frames + 1] = {path = relative, width = width, height = height, elapsedSeconds = capturedAt - started} -- 137
				end -- 137
				local cleanupError = releaseEntryLease(req.operationId, entry) -- 139
				leased = false -- 140
				if cleanupError then -- 140
					error(cleanupError) -- 141
				end -- 141
				result = {success = true, files = files, frames = frames} -- 142
			end) -- 142
			if not ____try then -- 142
				____catch(____hasReturned) -- 142
			end -- 142
			do -- 142
				if scope then -- 142
					Director:endGameCapture() -- 146
				end -- 146
				if leased then -- 146
					local cleanupError = releaseEntryLease(req.operationId, entry) -- 148
					if cleanupError ~= nil then -- 148
						result = result.success and ({success = false, files = files, message = cleanupError}) or ({success = false, files = files, message = ((result.message or "previewGame failed") .. "; ") .. cleanupError}) -- 150
					end -- 150
				end -- 150
			end -- 150
		end -- 150
		local encoded = safeJsonEncode(result) -- 156
		if encoded then -- 156
			req:print(encoded) -- 157
		end -- 157
		return result -- 158
	end -- 39
end -- 33
return ____exports -- 33