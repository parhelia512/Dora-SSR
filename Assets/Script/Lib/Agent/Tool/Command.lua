-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local Dora = require("Dora") -- 2
local ____Dora = require("Dora") -- 3
local Content = ____Dora.Content -- 3
local Path = ____Dora.Path -- 3
local Director = ____Dora.Director -- 3
local once = ____Dora.once -- 3
local App = ____Dora.App -- 3
local AgentConfig = require("Agent.Config") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local ____CommandShared = require("Agent.Tool.CommandShared") -- 8
local toStr = ____CommandShared.toCommandString -- 8
local truncateCommandOutput = ____CommandShared.truncateCommandOutput -- 8
local truncateCommandError = ____CommandShared.truncateCommandError -- 8
local ____GitCommand = require("Agent.Tool.GitCommand") -- 9
local executeGitCommand = ____GitCommand.executeGitCommand -- 9
local ____Operation = require("Agent.Tool.Operation") -- 10
local createOperationId = ____Operation.createOperationId -- 10
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 11
local refreshWorkspaceTree = ____WebIDESync.refreshWorkspaceTree -- 11
local ____Workspace = require("Agent.Tool.Workspace") -- 12
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 13
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 14
local inspectReadableFile = ____Workspace.inspectReadableFile -- 15
local ____EntryLease = require("Agent.Tool.EntryLease") -- 18
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 18
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 18
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 18
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 18
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 21
local function executeLuaCommand(req) -- 24
	local code = __TS__StringTrim(req.code or "") -- 32
	if code == "" then -- 32
		return __TS__Promise.resolve({ -- 34
			success = false, -- 34
			mode = "lua", -- 34
			output = "", -- 34
			message = "missing code", -- 34
			phase = "validate" -- 34
		}) -- 34
	end -- 34
	local output = {} -- 36
	local entry = require("Script.Dev.Entry") -- 37
	local ownsEntryRuntime = false -- 38
	local contentAccessed = false -- 39
	local refreshTreeCalled = false -- 40
	local entryObjectBaseline = 0 -- 41
	local entryLuaRefBaseline = 0 -- 42
	local function acquireEntryRuntime() -- 43
		acquireEntryLease(req.operationId, entry) -- 44
		ownsEntryRuntime = true -- 45
	end -- 43
	local function stopOwnedEntry() -- 47
		if not ownsEntryRuntime then -- 47
			return nil -- 48
		end -- 48
		ownsEntryRuntime = false -- 49
		return releaseEntryLease(req.operationId, entry) -- 50
	end -- 47
	local function startEntryWatchdog() -- 52
		entryObjectBaseline = Dora.Object.count -- 53
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 54
	end -- 52
	local function checkEntryWatchdog() -- 56
		if not ownsEntryRuntime then -- 56
			return nil -- 57
		end -- 57
		local objectCount = Dora.Object.count -- 58
		local luaRefCount = Dora.Object.luaRefCount -- 59
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 60
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 61
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 62
		if not exceededTotal then -- 62
			return nil -- 65
		end -- 65
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 66
	end -- 56
	local function normalizeEntryFile(value) -- 70
		if not value or type(value) ~= "table" then -- 70
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 72
		end -- 72
		local descriptor = value -- 74
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 75
		if relativeFile == "" then -- 75
			relativeFile = "init" -- 76
		end -- 76
		if not isValidWorkspacePath(relativeFile) then -- 76
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 78
		end -- 78
		local fileName = Path(req.workDir, relativeFile) -- 80
		local ext = Path:getExt(fileName) -- 81
		if ext ~= "" then -- 81
			fileName = Path:replaceExt(fileName, "") -- 82
		end -- 82
		local luaFile = Path:replaceExt(fileName, "lua") -- 83
		if not Content:exist(luaFile) then -- 83
			error("Agent test entry was not built: " .. luaFile) -- 85
		end -- 85
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 87
		return { -- 88
			fileName = fileName, -- 89
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 90
		} -- 90
	end -- 70
	local function capturePrint(...) -- 93
		local values = {...} -- 93
		local parts = {} -- 94
		do -- 94
			local i = 0 -- 95
			while i < #values do -- 95
				parts[#parts + 1] = tostring(values[i + 1]) -- 96
				i = i + 1 -- 95
			end -- 95
		end -- 95
		output[#output + 1] = table.concat(parts, "\t") -- 98
	end -- 93
	local function refreshTree(path) -- 100
		refreshTreeCalled = true -- 101
		if path == nil then -- 101
			return refreshWorkspaceTree(req.workDir) -- 103
		end -- 103
		if type(path) ~= "string" then -- 103
			error("refreshTree expects a project-relative file path string or no argument") -- 106
		end -- 106
		return refreshWorkspaceTree(req.workDir, path) -- 108
	end -- 100
	local function resolveLuaContentPath(first, second) -- 110
		local value = type(second) == "string" and second or first -- 111
		if type(value) ~= "string" then -- 111
			error("Content path must be a project-relative string") -- 113
		end -- 113
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 115
		if not fullPath then -- 115
			error("Content path must stay inside projectDir") -- 117
		end -- 117
		return fullPath -- 119
	end -- 110
	local scopedContent = { -- 121
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 122
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 123
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 124
		load = function(first, second) -- 125
			local fullPath = resolveLuaContentPath(first, second) -- 126
			local inspected = inspectReadableFile(fullPath) -- 127
			if not inspected.success then -- 127
				error(inspected.message or "file is not readable") -- 128
			end -- 128
			return Content:load(fullPath) -- 129
		end -- 125
	} -- 125
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 132
	local env = setmetatable( -- 138
		{ -- 138
			projectDir = req.workDir, -- 139
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 140
				if type(moduleNameValue) ~= "string" then -- 140
					error("requireProjectModule expects a project module name string") -- 142
				end -- 142
				local moduleName = __TS__StringTrim(moduleNameValue) -- 144
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 144
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 146
				end -- 146
				local reloadModules = {moduleName} -- 148
				if reloadModulesValue ~= nil then -- 148
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 148
						error("requireProjectModule reloadModules must be an array of module names") -- 151
					end -- 151
					local items = reloadModulesValue -- 153
					do -- 153
						local i = 0 -- 154
						while i < #items do -- 154
							local item = items[i + 1] -- 155
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 155
								error("requireProjectModule reloadModules contains an invalid module name") -- 157
							end -- 157
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 157
								reloadModules[#reloadModules + 1] = item -- 159
							end -- 159
							i = i + 1 -- 154
						end -- 154
					end -- 154
				end -- 154
				local luaPackage = _G.package -- 162
				local previousPath = luaPackage.path -- 166
				local previousSearchPaths = Content.searchPaths -- 167
				local scopedSearchPaths = {req.workDir} -- 168
				do -- 168
					local i = 0 -- 169
					while i < #previousSearchPaths do -- 169
						local searchPath = previousSearchPaths[i + 1] -- 170
						if searchPath ~= req.workDir then -- 170
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 171
						end -- 171
						i = i + 1 -- 169
					end -- 169
				end -- 169
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 173
				Content.searchPaths = scopedSearchPaths -- 174
				do -- 174
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 174
						do -- 174
							local i = 0 -- 176
							while i < #reloadModules do -- 176
								local reloadName = reloadModules[i + 1] -- 177
								luaPackage.loaded[reloadName] = nil -- 178
								luaPackage.loaded[table.concat( -- 179
									__TS__StringSplit(reloadName, "/"), -- 179
									"." -- 179
								)] = nil -- 179
								luaPackage.loaded[table.concat( -- 180
									__TS__StringSplit(reloadName, "."), -- 180
									"/" -- 180
								)] = nil -- 180
								i = i + 1 -- 176
							end -- 176
						end -- 176
						return true, require(table.concat( -- 182
							__TS__StringSplit(moduleName, "/"), -- 182
							"." -- 182
						)) -- 182
					end) -- 182
					do -- 182
						Content.searchPaths = previousSearchPaths -- 184
						luaPackage.path = previousPath -- 185
					end -- 185
					if not ____try then -- 185
						error(____hasReturned, 0) -- 185
					end -- 185
					if ____try and ____hasReturned then -- 185
						return ____returnValue -- 175
					end -- 175
				end -- 175
			end, -- 140
			print = capturePrint, -- 188
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 189
			enterEntryAsync = function(value) -- 190
				local normalized = normalizeEntryFile(value) -- 191
				acquireEntryRuntime() -- 192
				entry.allClear() -- 193
				startEntryWatchdog() -- 194
				recordEntryLeaseRun(req.operationId, entry) -- 195
				local success, message = entry.enterEntryAsync({ -- 196
					entryName = normalized.entryName, -- 197
					fileName = normalized.fileName, -- 198
					workDir = req.workDir, -- 199
					projectRoot = req.workDir, -- 200
					runKind = "agent_test" -- 201
				}) -- 201
				return success, message -- 203
			end, -- 190
			stopEntry = function() -- 205
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 205
					return false -- 206
				end -- 206
				return entry.stop() -- 207
			end, -- 205
			reportProgress = function(value, callbackValue) -- 209
				local ____callbackValue_0 = callbackValue -- 210
				if ____callbackValue_0 == nil then -- 210
					____callbackValue_0 = value -- 210
				end -- 210
				local actualValue = ____callbackValue_0 -- 210
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 210
					return -- 211
				end -- 211
				local progress = actualValue -- 212
				local amount = type(progress.progress) == "number" and math.min( -- 213
					1, -- 214
					math.max(0, progress.progress) -- 214
				) or nil -- 214
				req:onProgress({ -- 216
					state = "running", -- 217
					mode = "lua", -- 218
					operationId = req.operationId, -- 219
					progress = amount, -- 220
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 221
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 222
				}) -- 222
			end -- 209
		}, -- 209
		{__index = function(_table, key) -- 225
			if key == "Content" then -- 225
				contentAccessed = true -- 228
				return scopedContent -- 229
			end -- 229
			if key == "refreshTree" then -- 229
				return refreshTree -- 232
			end -- 232
			local name = tostring(key) -- 234
			if blockedDoraGlobals[name] then -- 234
				return nil -- 235
			end -- 235
			return Dora[name] -- 236
		end} -- 226
	) -- 226
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 239
	if not fn then -- 239
		return __TS__Promise.resolve({ -- 241
			success = false, -- 242
			mode = "lua", -- 243
			output = truncateCommandOutput(table.concat(output, "\n")), -- 244
			message = truncateCommandError(toStr(compileErr)), -- 245
			phase = "compile" -- 246
		}) -- 246
	end -- 246
	return __TS__New( -- 249
		__TS__Promise, -- 249
		function(____, resolve) -- 249
			local settled = false -- 250
			local commandRoutine -- 251
			local startedAt = App.runningTime -- 252
			local onProgress = req.onProgress -- 253
			local isCancelled = req.isCancelled -- 254
			local function finish(result) -- 255
				if settled then -- 255
					return -- 256
				end -- 256
				settled = true -- 257
				local cleanupError -- 258
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 258
					do -- 258
						local function ____catch(e) -- 258
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 263
						end -- 263
						local ____try, ____hasReturned = pcall(function() -- 263
							entry.allClear() -- 261
						end) -- 261
						if not ____try then -- 261
							____catch(____hasReturned) -- 261
						end -- 261
					end -- 261
				end -- 261
				local entryCleanupError = stopOwnedEntry() -- 266
				if cleanupError == nil then -- 266
					cleanupError = entryCleanupError -- 267
				end -- 267
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 267
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 269
				end -- 269
				if not result.success and cleanupError ~= nil then -- 269
					result.cleanupError = cleanupError -- 272
				elseif result.success and cleanupError ~= nil then -- 272
					resolve(nil, { -- 274
						success = false, -- 275
						mode = "lua", -- 276
						output = result.output, -- 277
						message = cleanupError, -- 278
						phase = "execute", -- 279
						cleanupError = cleanupError -- 280
					}) -- 280
					return -- 282
				end -- 282
				resolve(nil, result) -- 284
			end -- 255
			if onProgress then -- 255
				onProgress(nil, { -- 287
					state = "pending", -- 288
					mode = "lua", -- 289
					operationId = req.operationId, -- 290
					stage = "lua", -- 291
					message = "Lua command pending" -- 292
				}) -- 292
			end -- 292
			commandRoutine = once(function() -- 295
				if settled then -- 295
					return -- 296
				end -- 296
				if onProgress then -- 296
					onProgress(nil, { -- 298
						state = "running", -- 299
						mode = "lua", -- 300
						operationId = req.operationId, -- 301
						stage = "lua", -- 302
						message = "Lua command running" -- 303
					}) -- 303
				end -- 303
				local previousGlobalPrint = _G.print -- 306
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 307
				local frameTimedOut = false -- 308
				local watchdogMessage -- 308
				_G.print = capturePrint -- 309
				debug.sethook( -- 310
					function() -- 310
						if watchdogMessage == nil then -- 310
							watchdogMessage = checkEntryWatchdog() -- 311
						end -- 311
						if watchdogMessage ~= nil then -- 311
							error(watchdogMessage) -- 312
						end -- 312
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 312
							frameTimedOut = true -- 314
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 315
						end -- 315
					end, -- 310
					"", -- 317
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 317
				) -- 317
				local ok, runtimeErr = pcall(fn) -- 318
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 318
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 320
				else -- 320
					debug.sethook() -- 326
				end -- 326
				_G.print = previousGlobalPrint -- 328
				if not ok then -- 328
					local ____truncateCommandOutput_result_2 = truncateCommandOutput(table.concat(output, "\n")) -- 333
					local ____temp_3 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 334
					local ____temp_4 = frameTimedOut and "timeout" or "execute" -- 335
					local ____temp_1 -- 336
					if watchdogMessage ~= nil or frameTimedOut then -- 336
						____temp_1 = true -- 336
					else -- 336
						____temp_1 = nil -- 336
					end -- 336
					finish({ -- 330
						success = false, -- 331
						mode = "lua", -- 332
						output = ____truncateCommandOutput_result_2, -- 333
						message = ____temp_3, -- 334
						phase = ____temp_4, -- 335
						interrupted = ____temp_1 -- 336
					}) -- 336
					return -- 338
				end -- 338
				finish({ -- 340
					success = true, -- 340
					mode = "lua", -- 340
					output = truncateCommandOutput(table.concat(output, "\n")) -- 340
				}) -- 340
			end) -- 295
			Director.systemScheduler:schedule(function() -- 342
				if settled then -- 342
					return true -- 343
				end -- 343
				local watchdogMessage = checkEntryWatchdog() -- 344
				if watchdogMessage ~= nil then -- 344
					finish({ -- 346
						success = false, -- 347
						mode = "lua", -- 348
						output = truncateCommandOutput(table.concat(output, "\n")), -- 349
						message = watchdogMessage, -- 350
						phase = "execute", -- 351
						interrupted = true -- 352
					}) -- 352
					return true -- 354
				end -- 354
				if isCancelled and isCancelled(nil) then -- 354
					finish({ -- 357
						success = false, -- 358
						mode = "lua", -- 359
						output = truncateCommandOutput(table.concat(output, "\n")), -- 360
						message = "Lua command canceled", -- 361
						phase = "execute", -- 362
						interrupted = true -- 363
					}) -- 363
					return true -- 365
				end -- 365
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 365
					finish({ -- 368
						success = false, -- 369
						mode = "lua", -- 370
						output = truncateCommandOutput(table.concat(output, "\n")), -- 371
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 372
						phase = "timeout" -- 373
					}) -- 373
					return true -- 375
				end -- 375
				if commandRoutine == nil then -- 375
					finish({ -- 378
						success = false, -- 379
						mode = "lua", -- 380
						output = truncateCommandOutput(table.concat(output, "\n")), -- 381
						message = "Lua command coroutine is unavailable", -- 382
						phase = "execute" -- 383
					}) -- 383
					return true -- 385
				end -- 385
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 387
				if not resumeSuccess then -- 387
					finish({ -- 389
						success = false, -- 390
						mode = "lua", -- 391
						output = truncateCommandOutput(table.concat(output, "\n")), -- 392
						message = truncateCommandError(toStr(resumeResult)), -- 393
						phase = "execute" -- 394
					}) -- 394
					return true -- 396
				end -- 396
				return settled or resumeResult == true -- 398
			end) -- 342
		end -- 249
	) -- 249
end -- 24
function ____exports.executeCommand(req) -- 403
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 403
		local mode = req.mode -- 413
		if mode ~= "lua" and mode ~= "git" then -- 413
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 413
		end -- 413
		if mode == "lua" then -- 413
			return ____awaiter_resolve( -- 413
				nil, -- 413
				executeLuaCommand({ -- 418
					workDir = req.workDir, -- 419
					code = req.code or "", -- 420
					timeoutSeconds = math.max( -- 421
						1, -- 421
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 421
					), -- 421
					operationId = createOperationId(), -- 422
					onProgress = req.onProgress, -- 423
					isCancelled = req.isCancelled -- 424
				}) -- 424
			) -- 424
		end -- 424
		local operationId = createOperationId() -- 427
		return ____awaiter_resolve( -- 427
			nil, -- 427
			executeGitCommand({ -- 428
				workDir = req.workDir, -- 429
				command = req.command or "", -- 430
				cwd = req.cwd, -- 431
				timeoutSeconds = math.max( -- 432
					1, -- 432
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 432
				), -- 432
				operationId = operationId, -- 433
				onProgress = req.onProgress, -- 434
				isCancelled = req.isCancelled -- 435
			}) -- 435
		) -- 435
	end) -- 435
end -- 403
return ____exports -- 403