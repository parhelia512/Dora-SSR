-- [ts]: Build.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Node = ____Dora.Node -- 2
local emit = ____Dora.emit -- 2
local wait = ____Dora.wait -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 4
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 4
local ____Workspace = require("Agent.Tool.Workspace") -- 5
local resolveWorkspaceSearchPath = ____Workspace.resolveWorkspaceSearchPath -- 6
local toWorkspaceRelativePath = ____Workspace.toWorkspaceRelativePath -- 7
local listFiles = ____Workspace.listFiles -- 8
local codeExtensions = ____Workspace.codeExtensions -- 9
local function isDtsFile(path) -- 39
	return Path:getExt(Path:getName(path)) == "d" -- 40
end -- 39
local function isTiledEditorContent(content) -- 43
	return __TS__StringStartsWith( -- 44
		__TS__StringTrim(content), -- 44
		"<?xml" -- 44
	) -- 44
end -- 43
local function getSupportedBuildKind(path) -- 49
	repeat -- 49
		local ____switch5 = Path:getExt(path) -- 49
		local ____cond5 = ____switch5 == "ts" or ____switch5 == "tsx" -- 49
		if ____cond5 then -- 49
			return "ts" -- 51
		end -- 51
		____cond5 = ____cond5 or ____switch5 == "xml" -- 51
		if ____cond5 then -- 51
			return "xml" -- 52
		end -- 52
		____cond5 = ____cond5 or ____switch5 == "tl" -- 52
		if ____cond5 then -- 52
			return "teal" -- 53
		end -- 53
		____cond5 = ____cond5 or ____switch5 == "lua" -- 53
		if ____cond5 then -- 53
			return "lua" -- 54
		end -- 54
		____cond5 = ____cond5 or ____switch5 == "yue" -- 54
		if ____cond5 then -- 54
			return "yue" -- 55
		end -- 55
		____cond5 = ____cond5 or ____switch5 == "yarn" -- 55
		if ____cond5 then -- 55
			return "yarn" -- 56
		end -- 56
		do -- 56
			return nil -- 57
		end -- 57
	until true -- 57
end -- 49
local function encodeJSON(obj) -- 61
	local text = safeJsonEncode(obj) -- 62
	return text -- 63
end -- 61
local function runSingleNonTsBuild(file) -- 66
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 66
		return ____awaiter_resolve( -- 66
			nil, -- 66
			__TS__New( -- 67
				__TS__Promise, -- 67
				function(____, resolve) -- 67
					local moduleName = "Script.Dev.WebServer" -- 68
					local ____require_result_0 = require(moduleName) -- 69
					local buildAsync = ____require_result_0.buildAsync -- 69
					Director.systemScheduler:schedule(once(function() -- 70
						local result = buildAsync(file) -- 71
						resolve(nil, result) -- 72
					end)) -- 70
				end -- 67
			) -- 67
		) -- 67
	end) -- 67
end -- 66
local transpileRequestSeq = 0 -- 77
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 78
local TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 79
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 81
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 81
		if App.platform == "Android" then -- 81
			return ____awaiter_resolve( -- 81
				nil, -- 81
				__TS__New( -- 88
					__TS__Promise, -- 88
					function(____, resolve) -- 88
						local moduleName = "Script.Dev.WebServer" -- 89
						local webServer = require(moduleName) -- 90
						Director.systemScheduler:schedule(once(function() -- 100
							resolve( -- 101
								nil, -- 101
								webServer.transpileTSFile( -- 101
									file, -- 101
									content, -- 101
									projectRoot, -- 101
									nil, -- 101
									isCancelled -- 101
								) -- 101
							) -- 101
						end)) -- 100
					end -- 88
				) -- 88
			) -- 88
		end -- 88
		local done = false -- 105
		local ready = false -- 106
		transpileRequestSeq = transpileRequestSeq + 1 -- 107
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 108
		local result = {success = false, file = file, message = "Web IDE not connected"} -- 109
		if HttpServer.wsConnectionCount == 0 then -- 109
			return ____awaiter_resolve(nil, result) -- 109
		end -- 109
		local listener = Node() -- 117
		listener:gslot( -- 118
			"AppWS", -- 118
			function(event) -- 118
				if event.type ~= "Receive" then -- 118
					return -- 119
				end -- 119
				local res = safeJsonDecode(event.msg) -- 120
				if not res or __TS__ArrayIsArray(res) then -- 120
					return -- 121
				end -- 121
				local payload = res -- 122
				if payload.id ~= requestId then -- 122
					return -- 123
				end -- 123
				if payload.name == "TranspileTSProbe" then -- 123
					ready = true -- 125
					return -- 126
				end -- 126
				if payload.name ~= "TranspileTS" then -- 126
					return -- 128
				end -- 128
				if payload.success then -- 128
					local luaFile = Path:replaceExt(file, "lua") -- 130
					if Content:save( -- 130
						luaFile, -- 131
						tostring(payload.luaCode) -- 131
					) then -- 131
						result = {success = true, file = file} -- 132
					else -- 132
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 134
					end -- 134
				else -- 134
					result = { -- 137
						success = false, -- 137
						file = file, -- 137
						message = tostring(payload.message) -- 137
					} -- 137
				end -- 137
				done = true -- 139
			end -- 118
		) -- 118
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 141
		local buildPayload = encodeJSON({ -- 142
			name = "TranspileTS", -- 143
			id = requestId, -- 144
			file = file, -- 145
			content = content, -- 146
			projectRoot = projectRoot -- 147
		}) -- 147
		if not probePayload or not buildPayload then -- 147
			listener:removeFromParent() -- 150
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 150
		end -- 150
		__TS__Await(__TS__New( -- 153
			__TS__Promise, -- 153
			function(____, resolve) -- 153
				Director.systemScheduler:schedule(once(function() -- 154
					emit("AppWS", "Send", probePayload) -- 155
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 156
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 157
					if not ready then -- 157
						listener:removeFromParent() -- 162
						if (isCancelled and isCancelled()) == true then -- 162
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 164
						elseif HttpServer.wsConnectionCount == 0 then -- 164
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 166
						else -- 166
							result = {success = false, file = file, message = "TypeScript transpiler is not ready"} -- 168
						end -- 168
						resolve(nil) -- 170
						return -- 171
					end -- 171
					emit("AppWS", "Send", buildPayload) -- 173
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 174
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 175
					if not done then -- 175
						listener:removeFromParent() -- 180
						if (isCancelled and isCancelled()) == true then -- 180
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 182
						elseif HttpServer.wsConnectionCount == 0 then -- 182
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 184
						else -- 184
							result = {success = false, file = file, message = "TypeScript transpile timed out"} -- 186
						end -- 186
					end -- 186
					resolve(nil) -- 189
				end)) -- 154
			end -- 153
		)) -- 153
		return ____awaiter_resolve(nil, result) -- 153
	end) -- 153
end -- 81
local function finalizeBuildResult(workDir, messages) -- 195
	local normalized = __TS__ArrayMap( -- 196
		messages, -- 196
		function(____, m) return m.success and __TS__ObjectAssign( -- 196
			{}, -- 197
			m, -- 197
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 197
		) or __TS__ObjectAssign( -- 197
			{}, -- 198
			m, -- 198
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 198
		) end -- 198
	) -- 198
	local total = #normalized -- 199
	local failed = 0 -- 200
	do -- 200
		local i = 0 -- 201
		while i < #normalized do -- 201
			if not normalized[i + 1].success then -- 201
				failed = failed + 1 -- 202
			end -- 202
			i = i + 1 -- 201
		end -- 201
	end -- 201
	local passed = total - failed -- 204
	if failed > 0 then -- 204
		local interrupted = __TS__ArraySome( -- 206
			normalized, -- 206
			function(____, message) return not message.success and message.interrupted == true end -- 206
		) -- 206
		return { -- 207
			success = false, -- 208
			message = interrupted and "Build canceled." or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 209
			total = total, -- 210
			passed = passed, -- 211
			failed = failed, -- 212
			messages = normalized, -- 213
			interrupted = interrupted or nil -- 214
		} -- 214
	end -- 214
	return { -- 217
		success = true, -- 218
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 219
		total = total, -- 220
		passed = passed, -- 221
		failed = 0, -- 222
		messages = normalized -- 223
	} -- 223
end -- 195
function ____exports.build(req) -- 227
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 227
		local ____this_10 -- 227
		____this_10 = req -- 228
		local ____opt_9 = ____this_10.isCancelled -- 228
		if (____opt_9 and ____opt_9(____this_10)) == true then -- 228
			return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", interrupted = true}) -- 228
		end -- 228
		local targetRel = req.path or "" -- 231
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 232
		if not target then -- 232
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 232
		end -- 232
		if not Content:exist(target) then -- 232
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 232
		end -- 232
		local messages = {} -- 239
		if not Content:isdir(target) then -- 239
			local kind = getSupportedBuildKind(target) -- 241
			if not kind then -- 241
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 241
			end -- 241
			if kind == "ts" then -- 241
				local content = Content:load(target) -- 246
				if content == nil then -- 246
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 246
				end -- 246
				if isTiledEditorContent(content) then -- 246
					Log("Info", "[build] skip tiled editor file=" .. target) -- 251
					return ____awaiter_resolve( -- 251
						nil, -- 251
						finalizeBuildResult(req.workDir, messages) -- 252
					) -- 252
				end -- 252
				if not sendWebIDEFileUpdate(target, true, content) then -- 252
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 252
				end -- 252
				if not isDtsFile(target) then -- 252
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 258
				end -- 258
			else -- 258
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 261
			end -- 261
			Log( -- 263
				"Info", -- 263
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 263
			) -- 263
			return ____awaiter_resolve( -- 263
				nil, -- 263
				finalizeBuildResult(req.workDir, messages) -- 264
			) -- 264
		end -- 264
		local listResult = listFiles({ -- 266
			workDir = req.workDir, -- 267
			path = targetRel, -- 268
			globs = __TS__ArrayMap( -- 269
				codeExtensions, -- 269
				function(____, e) return "**/*" .. e end -- 269
			), -- 269
			maxEntries = 10000 -- 270
		}) -- 270
		local relFiles = listResult.success and listResult.files or ({}) -- 273
		local tsFileData = {} -- 274
		local buildQueue = {} -- 275
		for ____, rel in ipairs(relFiles) do -- 276
			do -- 276
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 277
				local kind = getSupportedBuildKind(file) -- 278
				if not kind then -- 278
					goto __continue58 -- 279
				end -- 279
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 280
				if kind ~= "ts" then -- 280
					goto __continue58 -- 282
				end -- 282
				local content = Content:load(file) -- 284
				if content == nil then -- 284
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 286
					goto __continue58 -- 287
				end -- 287
				if isTiledEditorContent(content) then -- 287
					Log("Info", "[build] skip tiled editor file=" .. file) -- 290
					goto __continue58 -- 291
				end -- 291
				tsFileData[file] = content -- 293
			end -- 293
			::__continue58:: -- 293
		end -- 293
		do -- 293
			local i = 0 -- 295
			while i < #buildQueue do -- 295
				do -- 295
					local ____this_12 -- 295
					____this_12 = req -- 296
					local ____opt_11 = ____this_12.isCancelled -- 296
					if (____opt_11 and ____opt_11(____this_12)) == true then -- 296
						return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", messages = messages, interrupted = true}) -- 296
					end -- 296
					local ____buildQueue_index_13 = buildQueue[i + 1] -- 299
					local file = ____buildQueue_index_13.file -- 299
					local kind = ____buildQueue_index_13.kind -- 299
					if kind == "ts" then -- 299
						local content = tsFileData[file] -- 301
						if content == nil or isDtsFile(file) then -- 301
							goto __continue65 -- 303
						end -- 303
						if not sendWebIDEFileUpdate(file, true, content) then -- 303
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 306
							goto __continue65 -- 307
						end -- 307
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 309
						goto __continue65 -- 310
					end -- 310
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 312
				end -- 312
				::__continue65:: -- 312
				i = i + 1 -- 295
			end -- 295
		end -- 295
		if #messages == 0 then -- 295
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 315
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 315
		end -- 315
		Log( -- 318
			"Info", -- 318
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 318
		) -- 318
		return ____awaiter_resolve( -- 318
			nil, -- 318
			finalizeBuildResult(req.workDir, messages) -- 319
		) -- 319
	end) -- 319
end -- 227
return ____exports -- 227