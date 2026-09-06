-- [ts]: Preview.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local Path = ____Dora.Path -- 2
local once = ____Dora.once -- 2
local sleep = ____Dora.sleep -- 2
local DoraObject = ____Dora.Object -- 2
local Config = require("Agent.Config") -- 3
local ____EntryLease = require("Agent.Tool.EntryLease") -- 4
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 4
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 4
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 4
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 4
local ____Workspace = require("Agent.Tool.Workspace") -- 5
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 5
local ____Operation = require("Agent.Tool.Operation") -- 6
local createOperationId = ____Operation.createOperationId -- 6
local ____VisionAssets = require("Agent.Tool.VisionAssets") -- 7
local ensureVisionQuota = ____VisionAssets.ensureVisionQuota -- 7
local publishVisionAsset = ____VisionAssets.publishVisionAsset -- 7
local visionAssetPath = ____VisionAssets.visionAssetPath -- 7
local ____ToolBudgets = require("Agent.Tool.ToolBudgets") -- 8
local PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS = ____ToolBudgets.PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS -- 8
local PREVIEW_GAME_TIMEOUT_SECONDS = ____ToolBudgets.PREVIEW_GAME_TIMEOUT_SECONDS -- 8
local ____Validation = require("Agent.Tool.Validation") -- 9
local validateAgentToolInput = ____Validation.validateAgentToolInput -- 9
function ____exports.previewGame(req) -- 11
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 11
		local validation = validateAgentToolInput("preview_game", {entry = req.entry, captureAtSeconds = req.captureAtSeconds}) -- 12
		if not validation.success then -- 12
			return ____awaiter_resolve(nil, {success = false, message = validation.message}) -- 12
		end -- 12
		local file = req.entry or "init.lua" -- 14
		local times = req.captureAtSeconds or ({0.5}) -- 14
		if not isValidWorkspacePath(file) or not file or Path:getExt(file) ~= "lua" and Path:getExt(file) ~= "" then -- 14
			return ____awaiter_resolve(nil, {success = false, message = "preview_game requires a built project-relative Lua entry"}) -- 14
		end -- 14
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 14
			times, -- 16
			function(____, t, i) return type(t) ~= "number" or t < 0 or t > 10 or t ~= t or i > 0 and t <= times[i] end -- 16
		) then -- 16
			return ____awaiter_resolve(nil, {success = false, message = "Choose 1–3 increasing capture times between 0 and 10 seconds"}) -- 16
		end -- 16
		local full = Path:replaceExt( -- 17
			Path(req.workingDir, file), -- 17
			"lua" -- 17
		) -- 17
		if not Content:exist(full) then -- 17
			return ____awaiter_resolve(nil, {success = false, message = "Build the entry before preview_game"}) -- 17
		end -- 17
		local entry = require("Script.Dev.Entry") -- 19
		local operationId = createOperationId() -- 20
		local assets = {} -- 20
		local scope = false -- 21
		local leased = false -- 21
		local complete = false -- 21
		local previewStart = App.runningTime -- 22
		return ____awaiter_resolve( -- 22
			nil, -- 22
			__TS__New( -- 23
				__TS__Promise, -- 23
				function(____, resolve) -- 23
					Director.systemScheduler:schedule(once(function() -- 24
						local result = {success = false, message = "Preview did not complete"} -- 25
						local pendingPaths = {} -- 26
						do -- 26
							local function ____catch(e) -- 26
								result = { -- 77
									success = false, -- 77
									operationId = operationId, -- 77
									assets = assets, -- 77
									cancelled = req:isCancelled(), -- 77
									message = tostring(e) -- 77
								} -- 77
							end -- 77
							local ____try, ____hasReturned = pcall(function() -- 77
								if req:isCancelled() then -- 77
									error("Preview cancelled") -- 28
								end -- 28
								ensureVisionQuota(req, #times) -- 29
								acquireEntryLease(operationId, entry) -- 30
								leased = true -- 30
								entry.allClear() -- 31
								scope = Director:beginGameCapture() -- 32
								if not scope then -- 32
									error("Game capture is unavailable or busy") -- 33
								end -- 33
								local objects = DoraObject.count -- 34
								local refs = DoraObject.luaRefCount -- 34
								recordEntryLeaseRun(operationId, entry) -- 35
								local previousHook, previousMask, previousCount = debug.gethook() -- 36
								do -- 36
									local ____try, ____error = pcall(function() -- 36
										debug.sethook( -- 38
											function() -- 38
												if req:isCancelled() then -- 38
													error("Preview cancelled during startup") -- 39
												end -- 39
												if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 39
													error("Preview startup exceeded the game frame time budget") -- 40
												end -- 40
												if App.runningTime - previewStart > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 40
													error("Preview startup exceeded the startup time budget") -- 41
												end -- 41
												if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 41
													error("Preview startup exceeded the game object budget") -- 42
												end -- 42
											end, -- 38
											"", -- 43
											Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 43
										) -- 43
										local ok, message = entry.enterEntryAsync({ -- 44
											entryName = Path:getName(full), -- 44
											fileName = Path:replaceExt(full, ""), -- 44
											workDir = req.workingDir, -- 44
											projectRoot = req.workingDir, -- 44
											runKind = "agent_test" -- 44
										}) -- 44
										if not ok then -- 44
											error(message or "Game entry failed") -- 45
										end -- 45
									end) -- 45
									do -- 45
										if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 45
											debug.sethook(previousHook, previousMask, previousCount) -- 48
										else -- 48
											debug.sethook() -- 49
										end -- 49
									end -- 49
									if not ____try then -- 49
										error(____error, 0) -- 49
									end -- 49
								end -- 49
								local started = App.runningTime -- 51
								local function check() -- 52
									if req:isCancelled() then -- 52
										error("Preview cancelled") -- 53
									end -- 53
									if not ownsEntryLease(operationId, entry) then -- 53
										error("Preview lost ownership of the running game") -- 54
									end -- 54
									if App.runningTime - previewStart > PREVIEW_GAME_TIMEOUT_SECONDS then -- 54
										error("Preview timed out") -- 55
									end -- 55
									if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 55
										error("Preview exceeded the game object budget") -- 56
									end -- 56
								end -- 52
								for ____, time in ipairs(times) do -- 58
									while App.runningTime - started < time do -- 58
										check() -- 59
										sleep() -- 59
									end -- 59
									check() -- 60
									local assetId = createOperationId() -- 61
									local path = visionAssetPath(assetId) -- 62
									pendingPaths[#pendingPaths + 1] = path -- 63
									local done = false -- 64
									local saved = false -- 64
									local capturedAt = 0 -- 64
									local sourceWidth = 0 -- 64
									local sourceHeight = 0 -- 64
									if not Director:captureGameAsync( -- 64
										path, -- 65
										function(success, frameTime, sourceSize) -- 65
											if complete then -- 65
												Content:remove(path) -- 66
												return -- 66
											end -- 66
											saved = success -- 67
											capturedAt = frameTime -- 67
											sourceWidth = sourceSize.width -- 67
											sourceHeight = sourceSize.height -- 67
											done = true -- 67
										end -- 65
									) then -- 65
										error("Capture request was rejected") -- 68
									end -- 68
									while not done do -- 68
										check() -- 69
										sleep() -- 69
									end -- 69
									check() -- 70
									if not saved then -- 70
										error("Game capture could not be saved") -- 71
									end -- 71
									assets[#assets + 1] = publishVisionAsset( -- 72
										req, -- 72
										{ -- 72
											assetId = assetId, -- 72
											entry = file, -- 72
											runId = entry.getCurrentEntryStatus().runId or 0, -- 72
											capturedAt = capturedAt, -- 72
											elapsedSeconds = capturedAt - started, -- 72
											sourceWidth = sourceWidth, -- 72
											sourceHeight = sourceHeight -- 72
										} -- 72
									) -- 72
								end -- 72
								local cleanupError = releaseEntryLease(operationId, entry) -- 74
								leased = false -- 74
								if cleanupError then -- 74
									error(cleanupError) -- 75
								end -- 75
								result = { -- 76
									success = true, -- 76
									operationId = operationId, -- 76
									assets = assets, -- 76
									scope = "game", -- 76
									entry = file -- 76
								} -- 76
							end) -- 76
							if not ____try then -- 76
								____catch(____hasReturned) -- 76
							end -- 76
							do -- 76
								complete = true -- 79
								if scope then -- 79
									Director:endGameCapture() -- 80
								end -- 80
								if leased then -- 80
									local cleanupError = releaseEntryLease(operationId, entry) -- 81
									if cleanupError then -- 81
										result = __TS__ObjectAssign({}, result, {success = false, cleanupError = cleanupError}) -- 81
									end -- 81
								end -- 81
								for ____, path in ipairs(pendingPaths) do -- 82
									if not __TS__ArraySome( -- 82
										assets, -- 82
										function(____, a) return visionAssetPath(a.assetId) == path end -- 82
									) then -- 82
										Content:remove(path) -- 82
									end -- 82
								end -- 82
							end -- 82
						end -- 82
						resolve(nil, result) -- 84
					end)) -- 24
				end -- 23
			) -- 23
		) -- 23
	end) -- 23
end -- 11
return ____exports -- 11