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
local ____CommandPreview = require("Agent.Tool.CommandPreview") -- 19
local createPreviewGameInjection = ____CommandPreview.createPreviewGameInjection -- 19
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 22
local function executeLuaCommand(req) -- 25
	local code = __TS__StringTrim(req.code or "") -- 33
	if code == "" then -- 33
		return __TS__Promise.resolve({ -- 35
			success = false, -- 35
			mode = "lua", -- 35
			output = "", -- 35
			message = "missing code", -- 35
			phase = "validate" -- 35
		}) -- 35
	end -- 35
	local output = {} -- 37
	local entry = require("Script.Dev.Entry") -- 38
	local ownsEntryRuntime = false -- 39
	local contentAccessed = false -- 40
	local refreshTreeCalled = false -- 41
	local entryObjectBaseline = 0 -- 42
	local entryLuaRefBaseline = 0 -- 43
	local function acquireEntryRuntime() -- 44
		acquireEntryLease(req.operationId, entry) -- 45
		ownsEntryRuntime = true -- 46
	end -- 44
	local function stopOwnedEntry() -- 48
		if not ownsEntryRuntime then -- 48
			return nil -- 49
		end -- 49
		ownsEntryRuntime = false -- 50
		return releaseEntryLease(req.operationId, entry) -- 51
	end -- 48
	local function startEntryWatchdog() -- 53
		entryObjectBaseline = Dora.Object.count -- 54
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 55
	end -- 53
	local function checkEntryWatchdog() -- 57
		if not ownsEntryRuntime then -- 57
			return nil -- 58
		end -- 58
		local objectCount = Dora.Object.count -- 59
		local luaRefCount = Dora.Object.luaRefCount -- 60
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 61
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 62
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 63
		if not exceededTotal then -- 63
			return nil -- 66
		end -- 66
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 67
	end -- 57
	local function normalizeEntryFile(value) -- 71
		if not value or type(value) ~= "table" then -- 71
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 73
		end -- 73
		local descriptor = value -- 75
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 76
		if relativeFile == "" then -- 76
			relativeFile = "init" -- 77
		end -- 77
		if not isValidWorkspacePath(relativeFile) then -- 77
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 79
		end -- 79
		local fileName = Path(req.workDir, relativeFile) -- 81
		local ext = Path:getExt(fileName) -- 82
		if ext ~= "" then -- 82
			fileName = Path:replaceExt(fileName, "") -- 83
		end -- 83
		local luaFile = Path:replaceExt(fileName, "lua") -- 84
		if not Content:exist(luaFile) then -- 84
			error("Agent test entry was not built: " .. luaFile) -- 86
		end -- 86
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 88
		return { -- 89
			fileName = fileName, -- 90
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 91
		} -- 91
	end -- 71
	local function capturePrint(...) -- 94
		local values = {...} -- 94
		local parts = {} -- 95
		do -- 95
			local i = 0 -- 96
			while i < #values do -- 96
				parts[#parts + 1] = tostring(values[i + 1]) -- 97
				i = i + 1 -- 96
			end -- 96
		end -- 96
		output[#output + 1] = table.concat(parts, "\t") -- 99
	end -- 94
	local function refreshTree(path) -- 101
		refreshTreeCalled = true -- 102
		if path == nil then -- 102
			return refreshWorkspaceTree(req.workDir) -- 104
		end -- 104
		if type(path) ~= "string" then -- 104
			error("refreshTree expects a project-relative file path string or no argument") -- 107
		end -- 107
		return refreshWorkspaceTree(req.workDir, path) -- 109
	end -- 101
	local function resolveLuaContentPath(first, second) -- 111
		local value = type(second) == "string" and second or first -- 112
		if type(value) ~= "string" then -- 112
			error("Content path must be a project-relative string") -- 114
		end -- 114
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 116
		if not fullPath then -- 116
			error("Content path must stay inside projectDir") -- 118
		end -- 118
		return fullPath -- 120
	end -- 111
	local scopedContent = { -- 122
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 123
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 124
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 125
		load = function(first, second) -- 126
			local fullPath = resolveLuaContentPath(first, second) -- 127
			local inspected = inspectReadableFile(fullPath) -- 128
			if not inspected.success then -- 128
				error(inspected.message or "file is not readable") -- 129
			end -- 129
			return Content:load(fullPath) -- 130
		end -- 126
	} -- 126
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 133
	local env = setmetatable( -- 139
		{ -- 139
			projectDir = req.workDir, -- 140
			previewGame = createPreviewGameInjection( -- 141
				{ -- 141
					workDir = req.workDir, -- 142
					operationId = req.operationId, -- 143
					isCancelled = req.isCancelled, -- 144
					print = function(____, line) return capturePrint(line) end -- 145
				}, -- 145
				entry -- 146
			), -- 146
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 147
				if type(moduleNameValue) ~= "string" then -- 147
					error("requireProjectModule expects a project module name string") -- 149
				end -- 149
				local moduleName = __TS__StringTrim(moduleNameValue) -- 151
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 151
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 153
				end -- 153
				local reloadModules = {moduleName} -- 155
				if reloadModulesValue ~= nil then -- 155
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 155
						error("requireProjectModule reloadModules must be an array of module names") -- 158
					end -- 158
					local items = reloadModulesValue -- 160
					do -- 160
						local i = 0 -- 161
						while i < #items do -- 161
							local item = items[i + 1] -- 162
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 162
								error("requireProjectModule reloadModules contains an invalid module name") -- 164
							end -- 164
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 164
								reloadModules[#reloadModules + 1] = item -- 166
							end -- 166
							i = i + 1 -- 161
						end -- 161
					end -- 161
				end -- 161
				local luaPackage = _G.package -- 169
				local previousPath = luaPackage.path -- 173
				local previousSearchPaths = Content.searchPaths -- 174
				local scopedSearchPaths = {req.workDir} -- 175
				do -- 175
					local i = 0 -- 176
					while i < #previousSearchPaths do -- 176
						local searchPath = previousSearchPaths[i + 1] -- 177
						if searchPath ~= req.workDir then -- 177
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 178
						end -- 178
						i = i + 1 -- 176
					end -- 176
				end -- 176
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 180
				Content.searchPaths = scopedSearchPaths -- 181
				do -- 181
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 181
						do -- 181
							local i = 0 -- 183
							while i < #reloadModules do -- 183
								local reloadName = reloadModules[i + 1] -- 184
								luaPackage.loaded[reloadName] = nil -- 185
								luaPackage.loaded[table.concat( -- 186
									__TS__StringSplit(reloadName, "/"), -- 186
									"." -- 186
								)] = nil -- 186
								luaPackage.loaded[table.concat( -- 187
									__TS__StringSplit(reloadName, "."), -- 187
									"/" -- 187
								)] = nil -- 187
								i = i + 1 -- 183
							end -- 183
						end -- 183
						return true, require(table.concat( -- 189
							__TS__StringSplit(moduleName, "/"), -- 189
							"." -- 189
						)) -- 189
					end) -- 189
					do -- 189
						Content.searchPaths = previousSearchPaths -- 191
						luaPackage.path = previousPath -- 192
					end -- 192
					if not ____try then -- 192
						error(____hasReturned, 0) -- 192
					end -- 192
					if ____try and ____hasReturned then -- 192
						return ____returnValue -- 182
					end -- 182
				end -- 182
			end, -- 147
			print = capturePrint, -- 195
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 196
			enterEntryAsync = function(value) -- 197
				local normalized = normalizeEntryFile(value) -- 198
				acquireEntryRuntime() -- 199
				entry.allClear() -- 200
				startEntryWatchdog() -- 201
				recordEntryLeaseRun(req.operationId, entry) -- 202
				local success, message = entry.enterEntryAsync({ -- 203
					entryName = normalized.entryName, -- 204
					fileName = normalized.fileName, -- 205
					workDir = req.workDir, -- 206
					projectRoot = req.workDir, -- 207
					runKind = "agent_test" -- 208
				}) -- 208
				return success, message -- 210
			end, -- 197
			stopEntry = function() -- 212
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 212
					return false -- 213
				end -- 213
				return entry.stop() -- 214
			end, -- 212
			reportProgress = function(value, callbackValue) -- 216
				local ____callbackValue_0 = callbackValue -- 217
				if ____callbackValue_0 == nil then -- 217
					____callbackValue_0 = value -- 217
				end -- 217
				local actualValue = ____callbackValue_0 -- 217
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 217
					return -- 218
				end -- 218
				local progress = actualValue -- 219
				local amount = type(progress.progress) == "number" and math.min( -- 220
					1, -- 221
					math.max(0, progress.progress) -- 221
				) or nil -- 221
				req:onProgress({ -- 223
					state = "running", -- 224
					mode = "lua", -- 225
					operationId = req.operationId, -- 226
					progress = amount, -- 227
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 228
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 229
				}) -- 229
			end -- 216
		}, -- 216
		{__index = function(_table, key) -- 232
			if key == "Content" then -- 232
				contentAccessed = true -- 235
				return scopedContent -- 236
			end -- 236
			if key == "refreshTree" then -- 236
				return refreshTree -- 239
			end -- 239
			local name = tostring(key) -- 241
			if blockedDoraGlobals[name] then -- 241
				return nil -- 242
			end -- 242
			return Dora[name] -- 243
		end} -- 233
	) -- 233
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 246
	if not fn then -- 246
		return __TS__Promise.resolve({ -- 248
			success = false, -- 249
			mode = "lua", -- 250
			output = truncateCommandOutput(table.concat(output, "\n")), -- 251
			message = truncateCommandError(toStr(compileErr)), -- 252
			phase = "compile" -- 253
		}) -- 253
	end -- 253
	return __TS__New( -- 256
		__TS__Promise, -- 256
		function(____, resolve) -- 256
			local settled = false -- 257
			local commandRoutine -- 258
			local startedAt = App.runningTime -- 259
			local onProgress = req.onProgress -- 260
			local isCancelled = req.isCancelled -- 261
			local function finish(result) -- 262
				if settled then -- 262
					return -- 263
				end -- 263
				settled = true -- 264
				local cleanupError -- 265
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 265
					do -- 265
						local function ____catch(e) -- 265
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 270
						end -- 270
						local ____try, ____hasReturned = pcall(function() -- 270
							entry.allClear() -- 268
						end) -- 268
						if not ____try then -- 268
							____catch(____hasReturned) -- 268
						end -- 268
					end -- 268
				end -- 268
				local entryCleanupError = stopOwnedEntry() -- 273
				if cleanupError == nil then -- 273
					cleanupError = entryCleanupError -- 274
				end -- 274
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 274
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 276
				end -- 276
				if not result.success and cleanupError ~= nil then -- 276
					result.cleanupError = cleanupError -- 279
				elseif result.success and cleanupError ~= nil then -- 279
					resolve(nil, { -- 281
						success = false, -- 282
						mode = "lua", -- 283
						output = result.output, -- 284
						message = cleanupError, -- 285
						phase = "execute", -- 286
						cleanupError = cleanupError -- 287
					}) -- 287
					return -- 289
				end -- 289
				resolve(nil, result) -- 291
			end -- 262
			if onProgress then -- 262
				onProgress(nil, { -- 294
					state = "pending", -- 295
					mode = "lua", -- 296
					operationId = req.operationId, -- 297
					stage = "lua", -- 298
					message = "Lua command pending" -- 299
				}) -- 299
			end -- 299
			commandRoutine = once(function() -- 302
				if settled then -- 302
					return -- 303
				end -- 303
				if onProgress then -- 303
					onProgress(nil, { -- 305
						state = "running", -- 306
						mode = "lua", -- 307
						operationId = req.operationId, -- 308
						stage = "lua", -- 309
						message = "Lua command running" -- 310
					}) -- 310
				end -- 310
				local previousGlobalPrint = _G.print -- 313
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 314
				local frameTimedOut = false -- 315
				local watchdogMessage -- 315
				_G.print = capturePrint -- 316
				debug.sethook( -- 317
					function() -- 317
						if watchdogMessage == nil then -- 317
							watchdogMessage = checkEntryWatchdog() -- 318
						end -- 318
						if watchdogMessage ~= nil then -- 318
							error(watchdogMessage) -- 319
						end -- 319
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 319
							frameTimedOut = true -- 321
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 322
						end -- 322
					end, -- 317
					"", -- 324
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 324
				) -- 324
				local ok, runtimeErr = pcall(fn) -- 325
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 325
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 327
				else -- 327
					debug.sethook() -- 333
				end -- 333
				_G.print = previousGlobalPrint -- 335
				if not ok then -- 335
					local ____truncateCommandOutput_result_2 = truncateCommandOutput(table.concat(output, "\n")) -- 340
					local ____temp_3 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 341
					local ____temp_4 = frameTimedOut and "timeout" or "execute" -- 342
					local ____temp_1 -- 343
					if watchdogMessage ~= nil or frameTimedOut then -- 343
						____temp_1 = true -- 343
					else -- 343
						____temp_1 = nil -- 343
					end -- 343
					finish({ -- 337
						success = false, -- 338
						mode = "lua", -- 339
						output = ____truncateCommandOutput_result_2, -- 340
						message = ____temp_3, -- 341
						phase = ____temp_4, -- 342
						interrupted = ____temp_1 -- 343
					}) -- 343
					return -- 345
				end -- 345
				finish({ -- 347
					success = true, -- 347
					mode = "lua", -- 347
					output = truncateCommandOutput(table.concat(output, "\n")) -- 347
				}) -- 347
			end) -- 302
			Director.systemScheduler:schedule(function() -- 349
				if settled then -- 349
					return true -- 350
				end -- 350
				local watchdogMessage = checkEntryWatchdog() -- 351
				if watchdogMessage ~= nil then -- 351
					finish({ -- 353
						success = false, -- 354
						mode = "lua", -- 355
						output = truncateCommandOutput(table.concat(output, "\n")), -- 356
						message = watchdogMessage, -- 357
						phase = "execute", -- 358
						interrupted = true -- 359
					}) -- 359
					return true -- 361
				end -- 361
				if isCancelled and isCancelled(nil) then -- 361
					finish({ -- 364
						success = false, -- 365
						mode = "lua", -- 366
						output = truncateCommandOutput(table.concat(output, "\n")), -- 367
						message = "Lua command canceled", -- 368
						phase = "execute", -- 369
						interrupted = true -- 370
					}) -- 370
					return true -- 372
				end -- 372
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 372
					finish({ -- 375
						success = false, -- 376
						mode = "lua", -- 377
						output = truncateCommandOutput(table.concat(output, "\n")), -- 378
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 379
						phase = "timeout" -- 380
					}) -- 380
					return true -- 382
				end -- 382
				if commandRoutine == nil then -- 382
					finish({ -- 385
						success = false, -- 386
						mode = "lua", -- 387
						output = truncateCommandOutput(table.concat(output, "\n")), -- 388
						message = "Lua command coroutine is unavailable", -- 389
						phase = "execute" -- 390
					}) -- 390
					return true -- 392
				end -- 392
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 394
				if not resumeSuccess then -- 394
					finish({ -- 396
						success = false, -- 397
						mode = "lua", -- 398
						output = truncateCommandOutput(table.concat(output, "\n")), -- 399
						message = truncateCommandError(toStr(resumeResult)), -- 400
						phase = "execute" -- 401
					}) -- 401
					return true -- 403
				end -- 403
				return settled or resumeResult == true -- 405
			end) -- 349
		end -- 256
	) -- 256
end -- 25
function ____exports.executeCommand(req) -- 410
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 410
		local mode = req.mode -- 420
		if mode ~= "lua" and mode ~= "git" then -- 420
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 420
		end -- 420
		if mode == "lua" then -- 420
			return ____awaiter_resolve( -- 420
				nil, -- 420
				executeLuaCommand({ -- 425
					workDir = req.workDir, -- 426
					code = req.code or "", -- 427
					timeoutSeconds = math.max( -- 428
						1, -- 428
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 428
					), -- 428
					operationId = createOperationId(), -- 429
					onProgress = req.onProgress, -- 430
					isCancelled = req.isCancelled -- 431
				}) -- 431
			) -- 431
		end -- 431
		local operationId = createOperationId() -- 434
		return ____awaiter_resolve( -- 434
			nil, -- 434
			executeGitCommand({ -- 435
				workDir = req.workDir, -- 436
				command = req.command or "", -- 437
				cwd = req.cwd, -- 438
				timeoutSeconds = math.max( -- 439
					1, -- 439
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 439
				), -- 439
				operationId = operationId, -- 440
				onProgress = req.onProgress, -- 441
				isCancelled = req.isCancelled -- 442
			}) -- 442
		) -- 442
	end) -- 442
end -- 410
return ____exports -- 410