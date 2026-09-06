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
local ____Validation = require("Agent.Tool.Validation") -- 8
local validateAgentToolInput = ____Validation.validateAgentToolInput -- 8
function ____exports.previewGame(req) -- 10
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 10
		local validation = validateAgentToolInput("preview_game", {entry = req.entry, captureAtSeconds = req.captureAtSeconds}) -- 11
		if not validation.success then -- 11
			return ____awaiter_resolve(nil, {success = false, message = validation.message}) -- 11
		end -- 11
		local file = req.entry or "init.lua" -- 13
		local times = req.captureAtSeconds or ({0.5}) -- 13
		if not isValidWorkspacePath(file) or not file or Path:getExt(file) ~= "lua" and Path:getExt(file) ~= "" then -- 13
			return ____awaiter_resolve(nil, {success = false, message = "preview_game requires a built project-relative Lua entry"}) -- 13
		end -- 13
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 13
			times, -- 15
			function(____, t, i) return type(t) ~= "number" or t < 0 or t > 10 or t ~= t or i > 0 and t <= times[i] end -- 15
		) then -- 15
			return ____awaiter_resolve(nil, {success = false, message = "Choose 1–3 increasing capture times between 0 and 10 seconds"}) -- 15
		end -- 15
		local full = Path:replaceExt( -- 16
			Path(req.workingDir, file), -- 16
			"lua" -- 16
		) -- 16
		if not Content:exist(full) then -- 16
			return ____awaiter_resolve(nil, {success = false, message = "Build the entry before preview_game"}) -- 16
		end -- 16
		local entry = require("Script.Dev.Entry") -- 18
		local operationId = createOperationId() -- 19
		local assets = {} -- 19
		local scope = false -- 20
		local leased = false -- 20
		local complete = false -- 20
		return ____awaiter_resolve( -- 20
			nil, -- 20
			__TS__New( -- 21
				__TS__Promise, -- 21
				function(____, resolve) -- 21
					Director.systemScheduler:schedule(once(function() -- 22
						local result = {success = false, message = "Preview did not complete"} -- 23
						local pendingPaths = {} -- 24
						do -- 24
							local function ____catch(e) -- 24
								result = { -- 74
									success = false, -- 74
									operationId = operationId, -- 74
									assets = assets, -- 74
									cancelled = req:isCancelled(), -- 74
									message = tostring(e) -- 74
								} -- 74
							end -- 74
							local ____try, ____hasReturned = pcall(function() -- 74
								if req:isCancelled() then -- 74
									error("Preview cancelled") -- 26
								end -- 26
								ensureVisionQuota(req, #times) -- 27
								acquireEntryLease(operationId, entry) -- 28
								leased = true -- 28
								entry.allClear() -- 29
								scope = Director:beginGameCapture() -- 30
								if not scope then -- 30
									error("Game capture is unavailable or busy") -- 31
								end -- 31
								local objects = DoraObject.count -- 32
								local refs = DoraObject.luaRefCount -- 32
								recordEntryLeaseRun(operationId, entry) -- 33
								local previousHook, previousMask, previousCount = debug.gethook() -- 34
								do -- 34
									local ____try, ____error = pcall(function() -- 34
										debug.sethook( -- 36
											function() -- 36
												if req:isCancelled() then -- 36
													error("Preview cancelled during startup") -- 37
												end -- 37
												if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 37
													error("Preview startup exceeded the game frame time budget") -- 38
												end -- 38
												if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 38
													error("Preview startup exceeded the game object budget") -- 39
												end -- 39
											end, -- 36
											"", -- 40
											Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 40
										) -- 40
										local ok, message = entry.enterEntryAsync({ -- 41
											entryName = Path:getName(full), -- 41
											fileName = Path:replaceExt(full, ""), -- 41
											workDir = req.workingDir, -- 41
											projectRoot = req.workingDir, -- 41
											runKind = "agent_test" -- 41
										}) -- 41
										if not ok then -- 41
											error(message or "Game entry failed") -- 42
										end -- 42
									end) -- 42
									do -- 42
										if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 42
											debug.sethook(previousHook, previousMask, previousCount) -- 45
										else -- 45
											debug.sethook() -- 46
										end -- 46
									end -- 46
									if not ____try then -- 46
										error(____error, 0) -- 46
									end -- 46
								end -- 46
								local started = App.runningTime -- 48
								local function check() -- 49
									if req:isCancelled() then -- 49
										error("Preview cancelled") -- 50
									end -- 50
									if not ownsEntryLease(operationId, entry) then -- 50
										error("Preview lost ownership of the running game") -- 51
									end -- 51
									if App.runningTime - started > 30 then -- 51
										error("Preview timed out") -- 52
									end -- 52
									if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 52
										error("Preview exceeded the game object budget") -- 53
									end -- 53
								end -- 49
								for ____, time in ipairs(times) do -- 55
									while App.runningTime - started < time do -- 55
										check() -- 56
										sleep() -- 56
									end -- 56
									check() -- 57
									local assetId = createOperationId() -- 58
									local path = visionAssetPath(assetId) -- 59
									pendingPaths[#pendingPaths + 1] = path -- 60
									local done = false -- 61
									local saved = false -- 61
									local capturedAt = 0 -- 61
									local sourceWidth = 0 -- 61
									local sourceHeight = 0 -- 61
									if not Director:captureGameAsync( -- 61
										path, -- 62
										function(success, frameTime, sourceSize) -- 62
											if complete then -- 62
												Content:remove(path) -- 63
												return -- 63
											end -- 63
											saved = success -- 64
											capturedAt = frameTime -- 64
											sourceWidth = sourceSize.width -- 64
											sourceHeight = sourceSize.height -- 64
											done = true -- 64
										end -- 62
									) then -- 62
										error("Capture request was rejected") -- 65
									end -- 65
									while not done do -- 65
										check() -- 66
										sleep() -- 66
									end -- 66
									check() -- 67
									if not saved then -- 67
										error("Game capture could not be saved") -- 68
									end -- 68
									assets[#assets + 1] = publishVisionAsset( -- 69
										req, -- 69
										{ -- 69
											assetId = assetId, -- 69
											entry = file, -- 69
											runId = entry.getCurrentEntryStatus().runId or 0, -- 69
											capturedAt = capturedAt, -- 69
											elapsedSeconds = capturedAt - started, -- 69
											sourceWidth = sourceWidth, -- 69
											sourceHeight = sourceHeight -- 69
										} -- 69
									) -- 69
								end -- 69
								local cleanupError = releaseEntryLease(operationId, entry) -- 71
								leased = false -- 71
								if cleanupError then -- 71
									error(cleanupError) -- 72
								end -- 72
								result = { -- 73
									success = true, -- 73
									operationId = operationId, -- 73
									assets = assets, -- 73
									scope = "game", -- 73
									entry = file -- 73
								} -- 73
							end) -- 73
							if not ____try then -- 73
								____catch(____hasReturned) -- 73
							end -- 73
							do -- 73
								complete = true -- 76
								if scope then -- 76
									Director:endGameCapture() -- 77
								end -- 77
								if leased then -- 77
									local cleanupError = releaseEntryLease(operationId, entry) -- 78
									if cleanupError then -- 78
										result = __TS__ObjectAssign({}, result, {success = false, cleanupError = cleanupError}) -- 78
									end -- 78
								end -- 78
								for ____, path in ipairs(pendingPaths) do -- 79
									if not __TS__ArraySome( -- 79
										assets, -- 79
										function(____, a) return visionAssetPath(a.assetId) == path end -- 79
									) then -- 79
										Content:remove(path) -- 79
									end -- 79
								end -- 79
							end -- 79
						end -- 79
						resolve(nil, result) -- 81
					end)) -- 22
				end -- 21
			) -- 21
		) -- 21
	end) -- 21
end -- 10
return ____exports -- 10