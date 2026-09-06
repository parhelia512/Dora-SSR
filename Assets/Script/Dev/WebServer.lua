-- [yue]: Script/Dev/WebServer.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local HttpServer <const> = HttpServer -- 10
local Path <const> = Path -- 10
local Content <const> = Content -- 10
local table <const> = table -- 10
local string <const> = string -- 10
local math <const> = math -- 10
local require <const> = require -- 10
local os <const> = os -- 10
local type <const> = type -- 10
local tostring <const> = tostring -- 10
local DB <const> = DB -- 10
local tonumber <const> = tonumber -- 10
local json <const> = json -- 10
local Git <const> = Git -- 10
local pcall <const> = pcall -- 10
local wait <const> = wait -- 10
local yue <const> = yue -- 10
local load <const> = load -- 10
local teal <const> = teal -- 10
local xml <const> = xml -- 10
local ipairs <const> = ipairs -- 10
local pairs <const> = pairs -- 10
local App <const> = App -- 10
local setmetatable <const> = setmetatable -- 10
local Wasm <const> = Wasm -- 10
local package <const> = package -- 10
local thread <const> = thread -- 10
local print <const> = print -- 10
local sleep <const> = sleep -- 10
local emit <const> = emit -- 10
local Node <const> = Node -- 10
local yarncompile <const> = yarncompile -- 10
HttpServer:stop() -- 12
HttpServer.wwwPath = Path(Content.appPath, ".www") -- 14
HttpServer.authToken = "" -- 16
local authFailedCount = 0 -- 18
local authLockedUntil = 0.0 -- 19
local PendingTTL = 60 -- 21
local _anon_func_0 = function() -- 23
	local _accum_0 = { } -- 23
	local _len_0 = 1 -- 23
	for _ = 1, 4 do -- 23
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff)) -- 24
		_len_0 = _len_0 + 1 -- 24
	end -- 23
	return _accum_0 -- 23
end -- 23
local genAuthToken -- 23
genAuthToken = function() -- 23
	return table.concat(_anon_func_0()) -- 23
end -- 23
local _anon_func_1 = function() -- 26
	local _accum_0 = { } -- 26
	local _len_0 = 1 -- 26
	for _ = 1, 2 do -- 26
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff)) -- 27
		_len_0 = _len_0 + 1 -- 27
	end -- 26
	return _accum_0 -- 26
end -- 26
local genSessionId -- 26
genSessionId = function() -- 26
	return table.concat(_anon_func_1()) -- 26
end -- 26
local genConfirmCode -- 29
genConfirmCode = function() -- 29
	return string.format("%04d", math.random(0, 9999)) -- 29
end -- 29
HttpServer:post("/auth", function(req) -- 31
	local Entry = require("Script.Dev.Entry") -- 32
	local AuthSession = Entry.AuthSession -- 33
	local authCode = Entry.getAuthCode() -- 34
	local now = os.time() -- 35
	if now < authLockedUntil then -- 36
		return { -- 37
			success = false, -- 37
			message = "locked", -- 37
			retryAfter = authLockedUntil - now -- 37
		} -- 37
	end -- 36
	local code = nil -- 38
	do -- 40
		local _type_0 = type(req) -- 40
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 40
		if _tab_0 then -- 40
			do -- 40
				local _obj_0 = req.body -- 40
				local _type_1 = type(_obj_0) -- 40
				if "table" == _type_1 or "userdata" == _type_1 then -- 40
					code = _obj_0.code -- 40
				end -- 40
			end -- 40
			if code ~= nil then -- 40
				code = code -- 41
			end -- 40
		end -- 39
	end -- 39
	if code and tostring(code) == authCode then -- 42
		authFailedCount = 0 -- 43
		Entry.invalidateAuthCode() -- 44
		do -- 45
			local pending = AuthSession.getPending() -- 45
			if pending then -- 45
				if now < pending.expiresAt and not pending.approved then -- 46
					return { -- 47
						success = true, -- 47
						pending = true, -- 47
						sessionId = pending.sessionId, -- 47
						confirmCode = pending.confirmCode, -- 47
						expiresIn = pending.expiresAt - now -- 47
					} -- 47
				end -- 46
			end -- 45
		end -- 45
		local sessionId = genSessionId() -- 48
		local confirmCode = genConfirmCode() -- 49
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL) -- 50
		return { -- 51
			success = true, -- 51
			pending = true, -- 51
			sessionId = sessionId, -- 51
			confirmCode = confirmCode, -- 51
			expiresIn = PendingTTL -- 51
		} -- 51
	else -- 53
		authFailedCount = authFailedCount + 1 -- 53
		if authFailedCount >= 3 then -- 54
			authFailedCount = 0 -- 55
			authLockedUntil = now + 30 -- 56
			return { -- 57
				success = false, -- 57
				message = "locked", -- 57
				retryAfter = 30 -- 57
			} -- 57
		end -- 54
		return { -- 58
			success = false, -- 58
			message = "invalid code" -- 58
		} -- 58
	end -- 42
end) -- 31
HttpServer:post("/auth/confirm", function(req) -- 60
	local now = os.time() -- 61
	local sessionId = nil -- 62
	do -- 64
		local _type_0 = type(req) -- 64
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 64
		if _tab_0 then -- 64
			do -- 64
				local _obj_0 = req.body -- 64
				local _type_1 = type(_obj_0) -- 64
				if "table" == _type_1 or "userdata" == _type_1 then -- 64
					sessionId = _obj_0.sessionId -- 64
				end -- 64
			end -- 64
			if sessionId ~= nil then -- 64
				sessionId = sessionId -- 65
			end -- 64
		end -- 63
	end -- 63
	if not sessionId then -- 66
		return { -- 67
			success = false, -- 67
			message = "invalid session" -- 67
		} -- 67
	end -- 66
	local Entry = require("Script.Dev.Entry") -- 68
	local AuthSession = Entry.AuthSession -- 69
	do -- 70
		local pending = AuthSession.getPending() -- 70
		if pending then -- 70
			if pending.sessionId ~= sessionId then -- 71
				return { -- 72
					success = false, -- 72
					message = "invalid session" -- 72
				} -- 72
			end -- 71
			if now >= pending.expiresAt then -- 73
				AuthSession.clearPending() -- 74
				return { -- 75
					success = false, -- 75
					message = "expired" -- 75
				} -- 75
			end -- 73
			if pending.approved then -- 76
				local secret = genAuthToken() -- 77
				HttpServer.authToken = tostring(sessionId) .. ":" .. tostring(secret) -- 78
				AuthSession.setSession(sessionId, secret) -- 79
				AuthSession.clearPending() -- 80
				return { -- 81
					success = true, -- 81
					sessionId = sessionId, -- 81
					sessionSecret = secret -- 81
				} -- 81
			end -- 76
			return { -- 82
				success = false, -- 82
				message = "pending", -- 82
				retryAfter = 2 -- 82
			} -- 82
		end -- 70
	end -- 70
	return { -- 83
		success = false, -- 83
		message = "invalid session" -- 83
	} -- 83
end) -- 60
local LintYueGlobals, CheckTIC80Code -- 85
do -- 85
	local _obj_0 = require("Utils") -- 85
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 85
end -- 85
local getProjectDirFromFile -- 87
getProjectDirFromFile = function(file) -- 87
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 88
	local parent, current -- 89
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 89
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 90
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 91
		local dir = Path(assetPath, "Script") -- 92
		parent, current = dir, Path:getRelative(file, dir) -- 93
	else -- 95
		parent, current = nil, nil -- 95
	end -- 89
	if not current then -- 96
		return nil -- 96
	end -- 96
	repeat -- 97
		current = Path:getPath(current) -- 98
		if current == "" then -- 99
			break -- 99
		end -- 99
		local _list_0 = Content:getFiles(Path(parent, current)) -- 100
		for _index_0 = 1, #_list_0 do -- 100
			local f = _list_0[_index_0] -- 100
			if Path:getName(f):lower() == "init" then -- 101
				return Path(parent, current, Path:getPath(f)) -- 102
			end -- 101
		end -- 100
	until false -- 97
	return nil -- 104
end -- 87
local relativeToRoot -- 106
relativeToRoot = function(file, root) -- 106
	if not (file and file ~= "" and root and root ~= "") then -- 107
		return nil -- 107
	end -- 107
	local relative = Path:getRelative(file, root) -- 108
	if relative == "" or relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 109
		return nil -- 109
	end -- 109
	if relative == "." then -- 110
		return "" -- 110
	end -- 110
	return relative -- 111
end -- 106
local getProjectSourceRoot -- 113
getProjectSourceRoot = function(projectRoot) -- 113
	if not (projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot)) then -- 114
		return nil -- 114
	end -- 114
	return projectRoot -- 115
end -- 113
local isProjectRootDir -- 117
isProjectRootDir = function(dir) -- 117
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 118
		return false -- 118
	end -- 118
	local _list_0 = Content:getFiles(dir) -- 119
	for _index_0 = 1, #_list_0 do -- 119
		local f = _list_0[_index_0] -- 119
		if Path:getName(f):lower() == "init" then -- 120
			return true -- 121
		end -- 120
	end -- 119
	return false -- 122
end -- 117
local getProjectRootFromPath -- 124
getProjectRootFromPath = function(target, isDir) -- 124
	if isDir == nil then -- 124
		isDir = false -- 124
	end -- 124
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 125
		return nil, "invalid path" -- 125
	end -- 125
	if isDir then -- 126
		if target == Content.writablePath or isProjectRootDir(target) then -- 127
			return target -- 127
		end -- 127
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 128
	end -- 126
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 129
end -- 124
local invalidArguments = { -- 131
	success = false, -- 131
	message = "invalid arguments" -- 131
} -- 131
HttpServer:post("/agent/project-root", function(req) -- 133
	do -- 134
		local _type_0 = type(req) -- 134
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 134
		if _tab_0 then -- 134
			local path -- 134
			do -- 134
				local _obj_0 = req.body -- 134
				local _type_1 = type(_obj_0) -- 134
				if "table" == _type_1 or "userdata" == _type_1 then -- 134
					path = _obj_0.path -- 134
				end -- 134
			end -- 134
			local isDir -- 134
			do -- 134
				local _obj_0 = req.body -- 134
				local _type_1 = type(_obj_0) -- 134
				if "table" == _type_1 or "userdata" == _type_1 then -- 134
					isDir = _obj_0.isDir -- 134
				end -- 134
			end -- 134
			if path ~= nil and isDir ~= nil then -- 134
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 135
				if projectRoot then -- 135
					return { -- 136
						success = true, -- 136
						found = true, -- 136
						projectRoot = projectRoot, -- 136
						title = Path:getFilename(projectRoot) -- 136
					} -- 136
				else -- 138
					return { -- 138
						success = true, -- 138
						found = false, -- 138
						message = err -- 138
					} -- 138
				end -- 135
			end -- 134
		end -- 134
	end -- 134
	return invalidArguments -- 133
end) -- 133
local AgentTools = require("Agent.Tools") -- 140
local AgentSession = require("Agent.Session") -- 141
local GitJobs = { } -- 143
local gitTerminalState -- 145
gitTerminalState = function(status) -- 145
	if not (status and status.state) then -- 146
		return false -- 146
	end -- 146
	local _val_0 = status.state -- 147
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 147
end -- 145
local gitInvalidRepoPath -- 149
gitInvalidRepoPath = function(repoPath) -- 149
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 150
end -- 149
local gitShellSplit -- 152
gitShellSplit = function(command) -- 152
	local args = { } -- 153
	local current = { } -- 154
	local quote = nil -- 155
	local escape = false -- 156
	for i = 1, #command do -- 157
		local ch = command:sub(i, i) -- 158
		if escape then -- 159
			current[#current + 1] = ch -- 160
			escape = false -- 161
		elseif ch == "\\" then -- 162
			escape = true -- 163
		elseif quote then -- 164
			if ch == quote then -- 165
				quote = nil -- 166
			else -- 168
				current[#current + 1] = ch -- 168
			end -- 165
		elseif ch == "'" or ch == '"' then -- 169
			quote = ch -- 170
		elseif ch:match("%s") then -- 171
			if #current > 0 then -- 172
				args[#args + 1] = table.concat(current) -- 173
				current = { } -- 174
			end -- 172
		else -- 176
			current[#current + 1] = ch -- 176
		end -- 159
	end -- 157
	if #current > 0 then -- 177
		args[#args + 1] = table.concat(current) -- 178
	end -- 177
	if args[1] == "git" then -- 179
		table.remove(args, 1) -- 180
	end -- 179
	return args -- 181
end -- 152
local gitQuote -- 183
gitQuote = function(value) -- 183
	local text = tostring(value) -- 184
	if text:match("^[%w%._%-%/]+$") then -- 185
		return text -- 186
	end -- 185
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 187
end -- 183
local gitDirNonEmpty -- 189
gitDirNonEmpty = function(targetPath) -- 189
	if not Content:exist(targetPath) then -- 190
		return false -- 190
	end -- 190
	if not Content:isdir(targetPath) then -- 191
		return false -- 191
	end -- 191
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 192
end -- 189
local gitSafeChildPath -- 194
gitSafeChildPath = function(parentPath, childPath) -- 194
	if not (parentPath and childPath and childPath ~= "") then -- 195
		return nil -- 195
	end -- 195
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 196
		return nil -- 196
	end -- 196
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 197
		return nil -- 197
	end -- 197
	local targetPath = Path(parentPath, childPath) -- 198
	local relative = Path:getRelative(targetPath, parentPath) -- 199
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 200
		return nil -- 200
	end -- 200
	return targetPath -- 201
end -- 194
local gitCloneDirFromURL -- 203
gitCloneDirFromURL = function(url) -- 203
	if not (url and url ~= "") then -- 204
		return nil -- 204
	end -- 204
	local text = tostring(url):match("^%s*(.-)%s*$") -- 205
	if text == "" then -- 206
		return nil -- 206
	end -- 206
	text = text:gsub("[/\\]+$", "") -- 207
	local name = text:match("([^/:]+)$") -- 208
	if not (name and name ~= "") then -- 209
		return nil -- 209
	end -- 209
	name = name:gsub("%.git$", "") -- 210
	if name == "" or name == "." or name == ".." then -- 211
		return nil -- 211
	end -- 211
	return name -- 212
end -- 203
local gitCloneTargetPath -- 214
gitCloneTargetPath = function(repoPath, command) -- 214
	local args = gitShellSplit(command) -- 215
	if not (args[1] == "clone") then -- 216
		return nil -- 216
	end -- 216
	local url = args[2] -- 217
	local index = 3 -- 218
	while index <= #args do -- 219
		local arg = args[index] -- 220
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 221
			index = index + 2 -- 222
		elseif arg:sub(1, 1) == "-" then -- 223
			index = index + 1 -- 224
		else -- 226
			return gitSafeChildPath(repoPath, arg) -- 226
		end -- 221
	end -- 219
	do -- 227
		local dirName = gitCloneDirFromURL(url) -- 227
		if dirName then -- 227
			return gitSafeChildPath(repoPath, dirName) -- 228
		end -- 227
	end -- 227
	return nil -- 229
end -- 214
local gitPathInsideRepo -- 231
gitPathInsideRepo = function(repoPath, relPath) -- 231
	if not (repoPath and relPath and relPath ~= "") then -- 232
		return false -- 232
	end -- 232
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 233
		return false -- 233
	end -- 233
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 234
		return false -- 234
	end -- 234
	local targetPath = Path(repoPath, relPath) -- 235
	local relative = Path:getRelative(targetPath, repoPath) -- 236
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 237
end -- 231
local gitHostFromURL -- 239
gitHostFromURL = function(url) -- 239
	if not (url and url ~= "") then -- 240
		return nil -- 240
	end -- 240
	local text = tostring(url):match("^%s*(.-)%s*$") -- 241
	if text == "" then -- 242
		return nil -- 242
	end -- 242
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 243
	if not host then -- 244
		host = text:match("@([^:/]+)[:/]") -- 244
	end -- 244
	if not host then -- 245
		host = text:match("^([^:/]+):[^/]") -- 245
	end -- 245
	if not (host and host ~= "") then -- 246
		return nil -- 246
	end -- 246
	return string.lower(host) -- 247
end -- 239
local ensureGitTables -- 249
ensureGitTables = function() -- 249
	DB:exec([[		CREATE TABLE IF NOT EXISTS GitCredential(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			host TEXT NOT NULL,
			label TEXT NOT NULL,
			type TEXT NOT NULL,
			username TEXT NOT NULL DEFAULT '',
			secret TEXT NOT NULL DEFAULT '',
			created_at INTEGER,
			updated_at INTEGER,
			last_used_at INTEGER
		);
	]]) -- 250
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 263
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 264
end -- 249
local gitCredentialToPublic -- 273
gitCredentialToPublic = function(row) -- 273
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 274
	return { -- 275
		id = id, -- 275
		host = host, -- 275
		label = label, -- 275
		type = typeName, -- 275
		username = username, -- 275
		createdAt = createdAt, -- 275
		updatedAt = updatedAt, -- 275
		lastUsedAt = lastUsedAt -- 275
	} -- 275
end -- 273
local gitLoadCredential -- 277
gitLoadCredential = function(id) -- 277
	ensureGitTables() -- 278
	local credentialId = tonumber(id) or 0 -- 279
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 280
		credentialId -- 280
	}) -- 280
	if not (rows and rows[1]) then -- 281
		return nil -- 281
	end -- 281
	local row = rows[1] -- 282
	return { -- 283
		id = row[1], -- 283
		host = row[2], -- 283
		label = row[3], -- 283
		type = row[4], -- 283
		username = row[5], -- 283
		secret = row[6] -- 283
	} -- 283
end -- 277
local gitAuthOptionsJSON -- 285
gitAuthOptionsJSON = function(credential) -- 285
	if not credential then -- 286
		return nil -- 286
	end -- 286
	local auth -- 287
	if credential.type == "token" then -- 287
		auth = { -- 289
			type = "token", -- 289
			token = credential.secret, -- 290
			username = credential.username ~= "" and credential.username or "token" -- 291
		} -- 288
	else -- 294
		auth = { -- 295
			type = "basic", -- 295
			username = credential.username, -- 296
			password = credential.secret -- 297
		} -- 294
	end -- 287
	return json.encode({ -- 299
		auth = auth -- 299
	}) -- 299
end -- 285
local gitLoadProfile -- 301
gitLoadProfile = function() -- 301
	ensureGitTables() -- 302
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 303
	if not (rows and rows[1]) then -- 304
		return nil -- 304
	end -- 304
	local name = tostring(rows[1][1] or "") -- 305
	local email = tostring(rows[1][2] or "") -- 306
	if name == "" and email == "" then -- 307
		return nil -- 307
	end -- 307
	return { -- 308
		name = name, -- 308
		email = email -- 308
	} -- 308
end -- 301
local _anon_func_2 = function(args, gitQuote) -- 327
	local _accum_0 = { } -- 327
	local _len_0 = 1 -- 327
	for _index_0 = 1, #args do -- 327
		local arg = args[_index_0] -- 327
		_accum_0[_len_0] = gitQuote(arg) -- 327
		_len_0 = _len_0 + 1 -- 327
	end -- 327
	return _accum_0 -- 327
end -- 327
local gitApplyProfileToCommit -- 310
gitApplyProfileToCommit = function(command) -- 310
	local args = gitShellSplit(command) -- 311
	if not (args[1] == "commit") then -- 312
		return command -- 312
	end -- 312
	local hasName = false -- 313
	local hasEmail = false -- 314
	for _index_0 = 1, #args do -- 315
		local arg = args[_index_0] -- 315
		if arg == "--author-name" then -- 316
			hasName = true -- 316
		end -- 316
		if arg == "--author-email" then -- 317
			hasEmail = true -- 317
		end -- 317
	end -- 315
	if hasName and hasEmail then -- 318
		return command -- 318
	end -- 318
	local profile = gitLoadProfile() -- 319
	if not profile then -- 320
		return command -- 320
	end -- 320
	if not hasName and profile.name ~= "" then -- 321
		args[#args + 1] = "--author-name" -- 322
		args[#args + 1] = profile.name -- 323
	end -- 321
	if not hasEmail and profile.email ~= "" then -- 324
		args[#args + 1] = "--author-email" -- 325
		args[#args + 1] = profile.email -- 326
	end -- 324
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 327
end -- 310
local gitStartJob -- 329
gitStartJob = function(repoPath, command, optionsJSON) -- 329
	if optionsJSON == nil then -- 329
		optionsJSON = nil -- 329
	end -- 329
	if gitInvalidRepoPath(repoPath) then -- 330
		return nil, "invalid repoPath" -- 330
	end -- 330
	if not (command and command ~= "") then -- 331
		return nil, "invalid command" -- 331
	end -- 331
	if not optionsJSON then -- 332
		optionsJSON = "" -- 332
	end -- 332
	command = gitApplyProfileToCommit(command) -- 333
	do -- 334
		local targetPath = gitCloneTargetPath(repoPath, command) -- 334
		if targetPath then -- 334
			if gitDirNonEmpty(targetPath) then -- 335
				return nil, "clone target directory is not empty" -- 336
			end -- 335
		elseif (gitShellSplit(command))[1] == "clone" then -- 337
			return nil, "invalid clone target" -- 338
		end -- 334
	end -- 334
	local statusRef = nil -- 339
	local startGit -- 340
	startGit = function() -- 340
		return Git:run(repoPath, command, (function(status) -- 341
			statusRef = status -- 342
			GitJobs[status.id] = { -- 344
				command = command, -- 344
				status = status, -- 345
				updatedAt = os.time() -- 346
			} -- 343
		end), optionsJSON) -- 341
	end -- 340
	local success, jobId = pcall(startGit) -- 348
	if not success then -- 349
		return nil, tostring(jobId) -- 349
	end -- 349
	if not jobId then -- 350
		return nil, "Git.run did not return a job id" -- 350
	end -- 350
	GitJobs[jobId] = { -- 352
		command = command, -- 352
		status = statusRef or { -- 354
			id = jobId, -- 354
			state = "queued", -- 355
			kind = gitShellSplit(command)[1] or "status", -- 356
			repoPath = repoPath, -- 357
			progress = 0, -- 358
			message = "queued" -- 359
		}, -- 353
		updatedAt = os.time() -- 361
	} -- 351
	return jobId -- 362
end -- 329
local gitRunSync -- 364
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 364
	if optionsJSON == nil then -- 364
		optionsJSON = nil -- 364
	end -- 364
	if timeout == nil then -- 364
		timeout = 20 -- 364
	end -- 364
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 365
	if not jobId then -- 366
		return { -- 366
			success = false, -- 366
			message = err -- 366
		} -- 366
	end -- 366
	local startedAt = os.time() -- 367
	wait(function() -- 368
		local job = GitJobs[jobId] -- 369
		local status = job and job.status -- 370
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 371
	end) -- 368
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 372
	if not gitTerminalState(status) then -- 373
		Git:cancel(jobId) -- 374
		return { -- 375
			success = false, -- 375
			message = "git command timed out", -- 375
			jobId = jobId, -- 375
			status = status -- 375
		} -- 375
	end -- 373
	return { -- 376
		success = status.state == "done", -- 376
		jobId = jobId, -- 376
		status = status, -- 376
		message = status.error or status.message -- 376
	} -- 376
end -- 364
local gitCredentialsForHost -- 378
gitCredentialsForHost = function(host) -- 378
	if not (host and host ~= "") then -- 379
		return { } -- 379
	end -- 379
	ensureGitTables() -- 380
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 381
		host -- 381
	}) -- 381
	if rows then -- 382
		local _accum_0 = { } -- 383
		local _len_0 = 1 -- 383
		for _index_0 = 1, #rows do -- 383
			local row = rows[_index_0] -- 383
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 383
			_len_0 = _len_0 + 1 -- 383
		end -- 383
		return _accum_0 -- 383
	else -- 384
		return { } -- 384
	end -- 382
end -- 378
local gitFirstRemoteURL -- 386
gitFirstRemoteURL = function(repoPath, remoteName) -- 386
	if remoteName == nil then -- 386
		remoteName = nil -- 386
	end -- 386
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 387
	local data = remoteRes.status and remoteRes.status.data -- 388
	if not (data and data.remotes) then -- 389
		return nil -- 389
	end -- 389
	local _list_0 = data.remotes -- 390
	for _index_0 = 1, #_list_0 do -- 390
		local remote = _list_0[_index_0] -- 390
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 391
			return remote.urls[1] -- 392
		end -- 391
	end -- 390
	return nil -- 393
end -- 386
local gitConfigRemoteURL -- 395
gitConfigRemoteURL = function(repoPath, remoteName) -- 395
	if remoteName == nil then -- 395
		remoteName = nil -- 395
	end -- 395
	if gitInvalidRepoPath(repoPath) then -- 396
		return nil -- 396
	end -- 396
	local configPath = Path(repoPath, ".git/config") -- 397
	if not Content:exist(configPath) then -- 398
		return nil -- 398
	end -- 398
	local content = Content:load(configPath) -- 399
	if not (content and content ~= "") then -- 400
		return nil -- 400
	end -- 400
	local currentRemote = nil -- 401
	for line in content:gmatch("[^\r\n]+") do -- 402
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 403
		if sectionRemote then -- 404
			currentRemote = sectionRemote -- 405
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 406
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 407
			if url and url ~= "" then -- 408
				return url -- 408
			end -- 408
		end -- 404
	end -- 402
	return nil -- 409
end -- 395
local gitCommandRemoteArg -- 411
gitCommandRemoteArg = function(args, startIndex) -- 411
	if startIndex == nil then -- 411
		startIndex = 2 -- 411
	end -- 411
	local index = startIndex -- 412
	while index <= #args do -- 413
		local arg = args[index] -- 414
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 415
			index = index + 1 -- 416
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 417
			index = index + 2 -- 418
		elseif arg and arg:sub(1, 1) == "-" then -- 419
			index = index + 1 -- 420
		else -- 422
			return arg -- 422
		end -- 415
	end -- 413
	return nil -- 423
end -- 411
local gitCommandHost -- 425
gitCommandHost = function(repoPath, command) -- 425
	local args = gitShellSplit(command) -- 426
	if not args[1] then -- 427
		return nil -- 427
	end -- 427
	do -- 428
		local _exp_0 = args[1] -- 428
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 429
			return gitHostFromURL(args[2]) -- 430
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 431
			local remoteArg = gitCommandRemoteArg(args, 2) -- 432
			if not remoteArg then -- 433
				return nil -- 433
			end -- 433
			local url = gitHostFromURL(remoteArg) -- 434
			if url then -- 435
				return url -- 435
			end -- 435
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 436
		end -- 428
	end -- 428
	return nil -- 437
end -- 425
local gitAuthSelectionForCommand -- 439
gitAuthSelectionForCommand = function(repoPath, command) -- 439
	local host = gitCommandHost(repoPath, command) -- 440
	if not host then -- 441
		return nil -- 441
	end -- 441
	local items = gitCredentialsForHost(host) -- 442
	if #items == 0 then -- 443
		return nil -- 443
	end -- 443
	return { -- 444
		host = host, -- 444
		items = items -- 444
	} -- 444
end -- 439
local gitDefaultRemote -- 446
gitDefaultRemote = function(remoteStatus) -- 446
	local data = remoteStatus and remoteStatus.data -- 447
	if not (data and data.remotes and data.remotes[1]) then -- 448
		return nil -- 448
	end -- 448
	return data.remotes[1] -- 449
end -- 446
local gitCurrentBranch -- 451
gitCurrentBranch = function(branchStatus) -- 451
	local data = branchStatus and branchStatus.data -- 452
	if data and data.current and data.current ~= "" then -- 453
		return data.current -- 454
	end -- 453
	if data and data.branches then -- 455
		local _list_0 = data.branches -- 456
		for _index_0 = 1, #_list_0 do -- 456
			local branch = _list_0[_index_0] -- 456
			if branch.current then -- 457
				return branch.name -- 457
			end -- 457
		end -- 456
	end -- 455
	return nil -- 458
end -- 451
local gitHeadBranch -- 460
gitHeadBranch = function(repoPath) -- 460
	if gitInvalidRepoPath(repoPath) then -- 461
		return nil -- 461
	end -- 461
	local headPath = Path(repoPath, ".git", "HEAD") -- 462
	if not Content:exist(headPath) then -- 463
		return nil -- 463
	end -- 463
	local head = Content:load(headPath) -- 464
	if not head then -- 465
		return nil -- 465
	end -- 465
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 466
	if branch and branch ~= "" then -- 467
		return branch -- 467
	end -- 467
	return nil -- 468
end -- 460
local gitBranchesWithHead -- 470
gitBranchesWithHead = function(branchStatus, currentBranch) -- 470
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 471
	if not (currentBranch and currentBranch ~= "") then -- 472
		return branches -- 472
	end -- 472
	for _index_0 = 1, #branches do -- 473
		local branch = branches[_index_0] -- 473
		if branch.name == currentBranch then -- 474
			return branches -- 474
		end -- 474
	end -- 473
	local withHead -- 475
	do -- 475
		local _accum_0 = { } -- 475
		local _len_0 = 1 -- 475
		for _index_0 = 1, #branches do -- 475
			local branch = branches[_index_0] -- 475
			_accum_0[_len_0] = branch -- 475
			_len_0 = _len_0 + 1 -- 475
		end -- 475
		withHead = _accum_0 -- 475
	end -- 475
	withHead[#withHead + 1] = { -- 476
		name = currentBranch, -- 476
		current = true, -- 476
		unborn = true -- 476
	} -- 476
	return withHead -- 477
end -- 470
local gitStatusMeansNotRepo -- 479
gitStatusMeansNotRepo = function(statusRes) -- 479
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 480
	message = tostring(message):lower() -- 481
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 482
end -- 479
local gitSummary -- 484
gitSummary = function(repoPath) -- 484
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 485
	if not statusRes.success then -- 486
		if gitStatusMeansNotRepo(statusRes) then -- 487
			return { -- 488
				success = true, -- 488
				isRepo = false, -- 488
				message = statusRes.message, -- 488
				status = statusRes.status -- 488
			} -- 488
		end -- 487
		return { -- 489
			success = false, -- 489
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 489
			status = statusRes.status -- 489
		} -- 489
	end -- 486
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 490
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 491
	local status = statusRes.status -- 492
	local branchStatus = branchRes.status -- 493
	local remoteStatus = remoteRes.status -- 494
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 495
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 496
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 497
	local logStatus -- 498
	if logRes.success then -- 498
		logStatus = logRes.status -- 499
	else -- 501
		logStatus = { -- 502
			state = "done", -- 502
			kind = "log", -- 503
			repoPath = repoPath, -- 504
			progress = 1, -- 505
			message = "git log completed", -- 506
			data = { -- 507
				commits = { } -- 507
			} -- 507
		} -- 501
	end -- 498
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 509
	local tagStatus -- 510
	if hasCommit then -- 510
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 511
	else -- 513
		tagStatus = { -- 514
			state = "done", -- 514
			kind = "tag", -- 515
			repoPath = repoPath, -- 516
			progress = 1, -- 517
			message = "git tag completed", -- 518
			data = { -- 519
				tags = { } -- 519
			} -- 519
		} -- 513
	end -- 510
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 521
	local lastCommit = nil -- 522
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 523
		lastCommit = logStatus.data.commits[1] -- 524
	end -- 523
	return { -- 526
		success = true, -- 526
		isRepo = true, -- 527
		clean = status.data and status.data.clean or false, -- 528
		currentBranch = currentBranch, -- 529
		defaultRemote = defaultRemote, -- 530
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 531
		branches = branches, -- 532
		lastCommit = lastCommit, -- 533
		status = status, -- 534
		branchStatus = branchStatus, -- 535
		remoteStatus = remoteStatus, -- 536
		historyStatus = logStatus, -- 537
		tagStatus = tagStatus -- 538
	} -- 525
end -- 484
HttpServer:post("/git/run", function(req) -- 540
	do -- 541
		local _type_0 = type(req) -- 541
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 541
		if _tab_0 then -- 541
			local body = req.body -- 541
			if body ~= nil then -- 541
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 542
				if authId and not optionsJSON then -- 543
					local credential = gitLoadCredential(authId) -- 544
					if credential then -- 544
						optionsJSON = gitAuthOptionsJSON(credential) -- 545
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 546
							os.time(), -- 546
							credential.id -- 546
						}) -- 546
					end -- 544
				elseif not optionsJSON then -- 547
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 548
					if not authOk then -- 549
						authSelection = nil -- 549
					end -- 549
					if authSelection then -- 550
						if #authSelection.items == 1 then -- 551
							local credential = gitLoadCredential(authSelection.items[1].id) -- 552
							optionsJSON = gitAuthOptionsJSON(credential) -- 553
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 554
								os.time(), -- 554
								credential.id -- 554
							}) -- 554
						else -- 556
							return { -- 556
								success = false, -- 556
								message = "select a Git credential", -- 556
								needsCredentialSelection = true, -- 556
								host = authSelection.host, -- 556
								credentials = authSelection.items -- 556
							} -- 556
						end -- 551
					end -- 550
				end -- 543
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 557
				if not jobId then -- 558
					return { -- 558
						success = false, -- 558
						message = err -- 558
					} -- 558
				end -- 558
				return { -- 559
					success = true, -- 559
					jobId = jobId -- 559
				} -- 559
			end -- 541
		end -- 541
	end -- 541
	return invalidArguments -- 540
end) -- 540
HttpServer:post("/git/status", function(req) -- 561
	do -- 562
		local _type_0 = type(req) -- 562
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 562
		if _tab_0 then -- 562
			local jobId -- 562
			do -- 562
				local _obj_0 = req.body -- 562
				local _type_1 = type(_obj_0) -- 562
				if "table" == _type_1 or "userdata" == _type_1 then -- 562
					jobId = _obj_0.jobId -- 562
				end -- 562
			end -- 562
			if jobId ~= nil then -- 562
				local job = GitJobs[tonumber(jobId) or 0] -- 563
				if not job then -- 564
					return { -- 564
						success = false, -- 564
						message = "git job not found" -- 564
					} -- 564
				end -- 564
				return { -- 565
					success = true, -- 565
					status = job.status, -- 565
					command = job.command -- 565
				} -- 565
			end -- 562
		end -- 562
	end -- 562
	return invalidArguments -- 561
end) -- 561
HttpServer:post("/git/cancel", function(req) -- 567
	do -- 568
		local _type_0 = type(req) -- 568
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 568
		if _tab_0 then -- 568
			local jobId -- 568
			do -- 568
				local _obj_0 = req.body -- 568
				local _type_1 = type(_obj_0) -- 568
				if "table" == _type_1 or "userdata" == _type_1 then -- 568
					jobId = _obj_0.jobId -- 568
				end -- 568
			end -- 568
			if jobId ~= nil then -- 568
				local id = tonumber(jobId) -- 569
				if not id then -- 570
					return { -- 570
						success = false, -- 570
						message = "invalid jobId" -- 570
					} -- 570
				end -- 570
				return { -- 571
					success = Git:cancel(id) -- 571
				} -- 571
			end -- 568
		end -- 568
	end -- 568
	return invalidArguments -- 567
end) -- 567
HttpServer:postSchedule("/git/summary", function(req) -- 573
	do -- 574
		local _type_0 = type(req) -- 574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 574
		if _tab_0 then -- 574
			local repoPath -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					repoPath = _obj_0.repoPath -- 574
				end -- 574
			end -- 574
			if repoPath ~= nil then -- 574
				if gitInvalidRepoPath(repoPath) then -- 575
					return { -- 575
						success = false, -- 575
						message = "invalid repoPath" -- 575
					} -- 575
				end -- 575
				return gitSummary(repoPath) -- 576
			end -- 574
		end -- 574
	end -- 574
	return invalidArguments -- 573
end) -- 573
HttpServer:postSchedule("/git/status-files", function(req) -- 578
	do -- 579
		local _type_0 = type(req) -- 579
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 579
		if _tab_0 then -- 579
			local repoPath -- 579
			do -- 579
				local _obj_0 = req.body -- 579
				local _type_1 = type(_obj_0) -- 579
				if "table" == _type_1 or "userdata" == _type_1 then -- 579
					repoPath = _obj_0.repoPath -- 579
				end -- 579
			end -- 579
			if repoPath ~= nil then -- 579
				return gitRunSync(repoPath, "status", nil, 120) -- 580
			end -- 579
		end -- 579
	end -- 579
	return invalidArguments -- 578
end) -- 578
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 582
	do -- 583
		local _type_0 = type(req) -- 583
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 583
		if _tab_0 then -- 583
			local body = req.body -- 583
			if body ~= nil then -- 583
				local repoPath, paths = body.repoPath, body.paths -- 584
				if gitInvalidRepoPath(repoPath) then -- 585
					return { -- 585
						success = false, -- 585
						message = "invalid repoPath" -- 585
					} -- 585
				end -- 585
				if not (type(paths) == "table") then -- 586
					return { -- 586
						success = false, -- 586
						message = "invalid paths" -- 586
					} -- 586
				end -- 586
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 587
				if not statusRes.success then -- 588
					return statusRes -- 588
				end -- 588
				local untracked = { } -- 589
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 590
				for _index_0 = 1, #_list_0 do -- 590
					local file = _list_0[_index_0] -- 590
					if file.staging == "?" or file.worktree == "?" then -- 591
						untracked[file.path] = true -- 592
					end -- 591
				end -- 590
				local removed = { } -- 593
				for _index_0 = 1, #paths do -- 594
					local relPath = paths[_index_0] -- 594
					relPath = tostring(relPath) -- 595
					if not gitPathInsideRepo(repoPath, relPath) then -- 596
						return { -- 596
							success = false, -- 596
							message = "unsafe path: " .. tostring(relPath) -- 596
						} -- 596
					end -- 596
					if not untracked[relPath] then -- 597
						return { -- 597
							success = false, -- 597
							message = "path is not untracked: " .. tostring(relPath) -- 597
						} -- 597
					end -- 597
				end -- 594
				for _index_0 = 1, #paths do -- 598
					local relPath = paths[_index_0] -- 598
					local targetPath = Path(repoPath, tostring(relPath)) -- 599
					if Content:exist(targetPath) then -- 600
						Content:remove(targetPath) -- 601
						removed[#removed + 1] = tostring(relPath) -- 602
					end -- 600
				end -- 598
				return { -- 603
					success = true, -- 603
					removed = removed -- 603
				} -- 603
			end -- 583
		end -- 583
	end -- 583
	return invalidArguments -- 582
end) -- 582
HttpServer:postSchedule("/git/file-diff", function(req) -- 605
	do -- 606
		local _type_0 = type(req) -- 606
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 606
		if _tab_0 then -- 606
			local body = req.body -- 606
			if body ~= nil then -- 606
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 607
				if gitInvalidRepoPath(repoPath) then -- 608
					return { -- 608
						success = false, -- 608
						message = "invalid repoPath" -- 608
					} -- 608
				end -- 608
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 609
					return { -- 609
						success = false, -- 609
						message = "unsafe path" -- 609
					} -- 609
				end -- 609
				local command -- 610
				if staged == true then -- 610
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 611
				else -- 613
					command = "diff -- " .. tostring(gitQuote(path)) -- 613
				end -- 610
				local res = gitRunSync(repoPath, command, nil, 10) -- 614
				if not res.success then -- 615
					return res -- 615
				end -- 615
				return { -- 616
					success = true, -- 616
					status = res.status, -- 616
					data = res.status and res.status.data -- 616
				} -- 616
			end -- 606
		end -- 606
	end -- 606
	return invalidArguments -- 605
end) -- 605
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 618
	do -- 619
		local _type_0 = type(req) -- 619
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 619
		if _tab_0 then -- 619
			local body = req.body -- 619
			if body ~= nil then -- 619
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 620
				if gitInvalidRepoPath(repoPath) then -- 621
					return { -- 621
						success = false, -- 621
						message = "invalid repoPath" -- 621
					} -- 621
				end -- 621
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 622
					return { -- 622
						success = false, -- 622
						message = "invalid commit" -- 622
					} -- 622
				end -- 622
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 623
					return { -- 623
						success = false, -- 623
						message = "unsafe path" -- 623
					} -- 623
				end -- 623
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 624
				if not res.success then -- 625
					return res -- 625
				end -- 625
				return { -- 626
					success = true, -- 626
					status = res.status, -- 626
					data = res.status and res.status.data -- 626
				} -- 626
			end -- 619
		end -- 619
	end -- 619
	return invalidArguments -- 618
end) -- 618
HttpServer:postSchedule("/git/history", function(req) -- 628
	do -- 629
		local _type_0 = type(req) -- 629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 629
		if _tab_0 then -- 629
			local body = req.body -- 629
			if body ~= nil then -- 629
				local repoPath, limit = body.repoPath, body.limit -- 630
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 631
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 632
			end -- 629
		end -- 629
	end -- 629
	return invalidArguments -- 628
end) -- 628
HttpServer:postSchedule("/git/remotes", function(req) -- 634
	do -- 635
		local _type_0 = type(req) -- 635
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 635
		if _tab_0 then -- 635
			local body = req.body -- 635
			if body ~= nil then -- 635
				local repoPath, command = body.repoPath, body.command -- 636
				command = command or "remote -v" -- 637
				return gitRunSync(repoPath, command, nil, 10) -- 638
			end -- 635
		end -- 635
	end -- 635
	return invalidArguments -- 634
end) -- 634
HttpServer:postSchedule("/git/branches", function(req) -- 640
	do -- 641
		local _type_0 = type(req) -- 641
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 641
		if _tab_0 then -- 641
			local body = req.body -- 641
			if body ~= nil then -- 641
				local repoPath, command = body.repoPath, body.command -- 642
				command = command or "branch" -- 643
				return gitRunSync(repoPath, command, nil, 10) -- 644
			end -- 641
		end -- 641
	end -- 641
	return invalidArguments -- 640
end) -- 640
HttpServer:postSchedule("/git/tags", function(req) -- 646
	do -- 647
		local _type_0 = type(req) -- 647
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 647
		if _tab_0 then -- 647
			local body = req.body -- 647
			if body ~= nil then -- 647
				local repoPath, command = body.repoPath, body.command -- 648
				command = command or "tag" -- 649
				return gitRunSync(repoPath, command, nil, 10) -- 650
			end -- 647
		end -- 647
	end -- 647
	return invalidArguments -- 646
end) -- 646
HttpServer:post("/git/profile/get", function() -- 652
	ensureGitTables() -- 653
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 654
	local profile -- 655
	if rows and rows[1] then -- 655
		profile = { -- 656
			name = rows[1][1], -- 656
			email = rows[1][2] -- 656
		} -- 656
	else -- 658
		profile = { -- 658
			name = "", -- 658
			email = "" -- 658
		} -- 658
	end -- 655
	return { -- 659
		success = true, -- 659
		profile = profile -- 659
	} -- 659
end) -- 652
HttpServer:post("/git/profile/save", function(req) -- 661
	do -- 662
		local _type_0 = type(req) -- 662
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 662
		if _tab_0 then -- 662
			local name -- 662
			do -- 662
				local _obj_0 = req.body -- 662
				local _type_1 = type(_obj_0) -- 662
				if "table" == _type_1 or "userdata" == _type_1 then -- 662
					name = _obj_0.name -- 662
				end -- 662
			end -- 662
			local email -- 662
			do -- 662
				local _obj_0 = req.body -- 662
				local _type_1 = type(_obj_0) -- 662
				if "table" == _type_1 or "userdata" == _type_1 then -- 662
					email = _obj_0.email -- 662
				end -- 662
			end -- 662
			if name ~= nil and email ~= nil then -- 662
				ensureGitTables() -- 663
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 665
					tostring(name or ""), -- 665
					tostring(email or ""), -- 666
					os.time() -- 667
				}) -- 664
				return { -- 669
					success = true -- 669
				} -- 669
			end -- 662
		end -- 662
	end -- 662
	return invalidArguments -- 661
end) -- 661
HttpServer:post("/git/auth/list", function(req) -- 671
	ensureGitTables() -- 672
	local host = nil -- 673
	do -- 674
		local _type_0 = type(req) -- 674
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 674
		if _tab_0 then -- 674
			local body = req.body -- 674
			if body ~= nil then -- 674
				host = body.host -- 675
			end -- 674
		end -- 674
	end -- 674
	local rows -- 676
	if host and host ~= "" then -- 676
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 677
			tostring(host):lower() -- 677
		}) -- 677
	else -- 679
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 679
	end -- 676
	local items -- 680
	if rows then -- 680
		local _accum_0 = { } -- 680
		local _len_0 = 1 -- 680
		for _index_0 = 1, #rows do -- 680
			local row = rows[_index_0] -- 680
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 680
			_len_0 = _len_0 + 1 -- 680
		end -- 680
		items = _accum_0 -- 680
	else -- 680
		items = { } -- 680
	end -- 680
	return { -- 681
		success = true, -- 681
		items = items -- 681
	} -- 681
end) -- 671
HttpServer:postSchedule("/git/auth/match", function(req) -- 683
	do -- 684
		local _type_0 = type(req) -- 684
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 684
		if _tab_0 then -- 684
			local body = req.body -- 684
			if body ~= nil then -- 684
				local repoPath, command, url = body.repoPath, body.command, body.url -- 685
				local host -- 686
				if url and url ~= "" then -- 686
					host = gitHostFromURL(url) -- 686
				else -- 686
					host = gitCommandHost(repoPath, command) -- 686
				end -- 686
				if not host then -- 687
					return { -- 687
						success = false, -- 687
						message = "git host is required" -- 687
					} -- 687
				end -- 687
				local items = gitCredentialsForHost(host) -- 688
				return { -- 689
					success = true, -- 689
					host = host, -- 689
					items = items, -- 689
					needsSelection = #items > 1, -- 689
					authId = (#items == 1 and items[1].id or nil) -- 689
				} -- 689
			end -- 684
		end -- 684
	end -- 684
	return invalidArguments -- 683
end) -- 683
HttpServer:post("/git/auth/save", function(req) -- 691
	do -- 692
		local _type_0 = type(req) -- 692
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 692
		if _tab_0 then -- 692
			local body = req.body -- 692
			if body ~= nil then -- 692
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 693
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 694
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 695
				local credentialType = tostring(body.type or "token") -- 696
				username = tostring(username or "") -- 697
				local secret -- 698
				if credentialType == "basic" then -- 698
					secret = tostring(password or "") -- 698
				else -- 698
					secret = tostring(token or password or "") -- 698
				end -- 698
				if host == "" then -- 699
					return { -- 699
						success = false, -- 699
						message = "host is required" -- 699
					} -- 699
				end -- 699
				if label == "" then -- 700
					return { -- 700
						success = false, -- 700
						message = "label is required" -- 700
					} -- 700
				end -- 700
				if secret == "" then -- 701
					return { -- 701
						success = false, -- 701
						message = "secret is required" -- 701
					} -- 701
				end -- 701
				if not (("basic" == credentialType or "token" == credentialType)) then -- 702
					return { -- 702
						success = false, -- 702
						message = "invalid type" -- 702
					} -- 702
				end -- 702
				ensureGitTables() -- 703
				local now = os.time() -- 704
				if id then -- 705
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 707
						host, -- 707
						label, -- 707
						credentialType, -- 707
						username, -- 707
						secret, -- 707
						now, -- 707
						(tonumber(id) or 0) -- 707
					}) -- 706
					return { -- 709
						success = true, -- 709
						id = tonumber(id) -- 709
					} -- 709
				else -- 711
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 712
						host, -- 712
						label, -- 712
						credentialType, -- 712
						username, -- 712
						secret, -- 712
						now, -- 712
						now -- 712
					}) -- 711
					local rows = DB:query("select last_insert_rowid()") -- 714
					return { -- 715
						success = true, -- 715
						id = rows and rows[1] and rows[1][1] -- 715
					} -- 715
				end -- 705
			end -- 692
		end -- 692
	end -- 692
	return invalidArguments -- 691
end) -- 691
HttpServer:post("/git/auth/delete", function(req) -- 717
	do -- 718
		local _type_0 = type(req) -- 718
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 718
		if _tab_0 then -- 718
			local id -- 718
			do -- 718
				local _obj_0 = req.body -- 718
				local _type_1 = type(_obj_0) -- 718
				if "table" == _type_1 or "userdata" == _type_1 then -- 718
					id = _obj_0.id -- 718
				end -- 718
			end -- 718
			if id ~= nil then -- 718
				ensureGitTables() -- 719
				local credentialId = tonumber(id) or 0 -- 720
				DB:exec("delete from GitCredential where id = ?", { -- 721
					credentialId -- 721
				}) -- 721
				return { -- 722
					success = true -- 722
				} -- 722
			end -- 718
		end -- 718
	end -- 718
	return invalidArguments -- 717
end) -- 717
HttpServer:postSchedule("/git/auth/test", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local body = req.body -- 725
			if body ~= nil then -- 725
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 726
				local credential = gitLoadCredential(authId) -- 727
				local optionsJSON = gitAuthOptionsJSON(credential) -- 728
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 729
			end -- 725
		end -- 725
	end -- 725
	return invalidArguments -- 724
end) -- 724
HttpServer:post("/agent/session/create", function(req) -- 731
	do -- 732
		local _type_0 = type(req) -- 732
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 732
		if _tab_0 then -- 732
			local projectRoot -- 732
			do -- 732
				local _obj_0 = req.body -- 732
				local _type_1 = type(_obj_0) -- 732
				if "table" == _type_1 or "userdata" == _type_1 then -- 732
					projectRoot = _obj_0.projectRoot -- 732
				end -- 732
			end -- 732
			local title -- 732
			do -- 732
				local _obj_0 = req.body -- 732
				local _type_1 = type(_obj_0) -- 732
				if "table" == _type_1 or "userdata" == _type_1 then -- 732
					title = _obj_0.title -- 732
				end -- 732
			end -- 732
			if projectRoot ~= nil and title ~= nil then -- 732
				return AgentSession.createSession(projectRoot, title) -- 733
			end -- 732
		end -- 732
	end -- 732
	return invalidArguments -- 731
end) -- 731
HttpServer:post("/agent/session/create-sub", function(req) -- 735
	do -- 736
		local _type_0 = type(req) -- 736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 736
		if _tab_0 then -- 736
			local parentSessionId -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					parentSessionId = _obj_0.parentSessionId -- 736
				end -- 736
			end -- 736
			local title -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					title = _obj_0.title -- 736
				end -- 736
			end -- 736
			if parentSessionId ~= nil and title ~= nil then -- 736
				return AgentSession.createSubSession(parentSessionId, title) -- 737
			end -- 736
		end -- 736
	end -- 736
	return invalidArguments -- 735
end) -- 735
HttpServer:post("/agent/session/get", function(req) -- 739
	do -- 740
		local _type_0 = type(req) -- 740
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 740
		if _tab_0 then -- 740
			local sessionId -- 740
			do -- 740
				local _obj_0 = req.body -- 740
				local _type_1 = type(_obj_0) -- 740
				if "table" == _type_1 or "userdata" == _type_1 then -- 740
					sessionId = _obj_0.sessionId -- 740
				end -- 740
			end -- 740
			if sessionId ~= nil then -- 740
				return AgentSession.getSession(sessionId) -- 741
			end -- 740
		end -- 740
	end -- 740
	return invalidArguments -- 739
end) -- 739
HttpServer:post("/agent/vision/asset", function(req) -- 743
	do -- 744
		local _type_0 = type(req) -- 744
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 744
		if _tab_0 then -- 744
			local sessionId -- 744
			do -- 744
				local _obj_0 = req.body -- 744
				local _type_1 = type(_obj_0) -- 744
				if "table" == _type_1 or "userdata" == _type_1 then -- 744
					sessionId = _obj_0.sessionId -- 744
				end -- 744
			end -- 744
			local assetId -- 744
			do -- 744
				local _obj_0 = req.body -- 744
				local _type_1 = type(_obj_0) -- 744
				if "table" == _type_1 or "userdata" == _type_1 then -- 744
					assetId = _obj_0.assetId -- 744
				end -- 744
			end -- 744
			if sessionId ~= nil and assetId ~= nil then -- 744
				return (require("Agent.Tool.VisionAssets")).getSessionVisionImage(sessionId, assetId) -- 745
			end -- 744
		end -- 744
	end -- 744
	return invalidArguments -- 743
end) -- 743
HttpServer:post("/agent/session/mode", function(req) -- 747
	do -- 748
		local _type_0 = type(req) -- 748
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 748
		if _tab_0 then -- 748
			local sessionId -- 748
			do -- 748
				local _obj_0 = req.body -- 748
				local _type_1 = type(_obj_0) -- 748
				if "table" == _type_1 or "userdata" == _type_1 then -- 748
					sessionId = _obj_0.sessionId -- 748
				end -- 748
			end -- 748
			local workMode -- 748
			do -- 748
				local _obj_0 = req.body -- 748
				local _type_1 = type(_obj_0) -- 748
				if "table" == _type_1 or "userdata" == _type_1 then -- 748
					workMode = _obj_0.workMode -- 748
				end -- 748
			end -- 748
			if sessionId ~= nil and workMode ~= nil then -- 748
				return AgentSession.setWorkMode(sessionId, workMode) -- 749
			end -- 748
		end -- 748
	end -- 748
	return invalidArguments -- 747
end) -- 747
HttpServer:post("/agent/session/send", function(req) -- 751
	do -- 752
		local _type_0 = type(req) -- 752
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 752
		if _tab_0 then -- 752
			local sessionId -- 752
			do -- 752
				local _obj_0 = req.body -- 752
				local _type_1 = type(_obj_0) -- 752
				if "table" == _type_1 or "userdata" == _type_1 then -- 752
					sessionId = _obj_0.sessionId -- 752
				end -- 752
			end -- 752
			local prompt -- 752
			do -- 752
				local _obj_0 = req.body -- 752
				local _type_1 = type(_obj_0) -- 752
				if "table" == _type_1 or "userdata" == _type_1 then -- 752
					prompt = _obj_0.prompt -- 752
				end -- 752
			end -- 752
			if sessionId ~= nil and prompt ~= nil then -- 752
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 753
			end -- 752
		end -- 752
	end -- 752
	return invalidArguments -- 751
end) -- 751
HttpServer:post("/agent/session/continue", function(req) -- 755
	do -- 756
		local _type_0 = type(req) -- 756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 756
		if _tab_0 then -- 756
			local sessionId -- 756
			do -- 756
				local _obj_0 = req.body -- 756
				local _type_1 = type(_obj_0) -- 756
				if "table" == _type_1 or "userdata" == _type_1 then -- 756
					sessionId = _obj_0.sessionId -- 756
				end -- 756
			end -- 756
			if sessionId ~= nil then -- 756
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 757
			end -- 756
		end -- 756
	end -- 756
	return invalidArguments -- 755
end) -- 755
HttpServer:post("/agent/session/finish-handoff", function(req) -- 759
	do -- 760
		local _type_0 = type(req) -- 760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 760
		if _tab_0 then -- 760
			local sessionId -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					sessionId = _obj_0.sessionId -- 760
				end -- 760
			end -- 760
			if sessionId ~= nil then -- 760
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 761
			end -- 760
		end -- 760
	end -- 760
	return invalidArguments -- 759
end) -- 759
HttpServer:post("/agent/session/resend", function(req) -- 763
	do -- 764
		local _type_0 = type(req) -- 764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 764
		if _tab_0 then -- 764
			local sessionId -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					sessionId = _obj_0.sessionId -- 764
				end -- 764
			end -- 764
			local messageId -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					messageId = _obj_0.messageId -- 764
				end -- 764
			end -- 764
			local prompt -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					prompt = _obj_0.prompt -- 764
				end -- 764
			end -- 764
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 764
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 765
			end -- 764
		end -- 764
	end -- 764
	return invalidArguments -- 763
end) -- 763
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 767
	do -- 768
		local _type_0 = type(req) -- 768
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 768
		if _tab_0 then -- 768
			local sessionId -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					sessionId = _obj_0.sessionId -- 768
				end -- 768
			end -- 768
			local questionnaireId -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					questionnaireId = _obj_0.questionnaireId -- 768
				end -- 768
			end -- 768
			local answers -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					answers = _obj_0.answers -- 768
				end -- 768
			end -- 768
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 768
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 769
			end -- 768
		end -- 768
	end -- 768
	return invalidArguments -- 767
end) -- 767
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 771
	do -- 772
		local _type_0 = type(req) -- 772
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 772
		if _tab_0 then -- 772
			local sessionId -- 772
			do -- 772
				local _obj_0 = req.body -- 772
				local _type_1 = type(_obj_0) -- 772
				if "table" == _type_1 or "userdata" == _type_1 then -- 772
					sessionId = _obj_0.sessionId -- 772
				end -- 772
			end -- 772
			local questionnaireId -- 772
			do -- 772
				local _obj_0 = req.body -- 772
				local _type_1 = type(_obj_0) -- 772
				if "table" == _type_1 or "userdata" == _type_1 then -- 772
					questionnaireId = _obj_0.questionnaireId -- 772
				end -- 772
			end -- 772
			if sessionId ~= nil and questionnaireId ~= nil then -- 772
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 773
			end -- 772
		end -- 772
	end -- 772
	return invalidArguments -- 771
end) -- 771
HttpServer:post("/agent/task/status", function(req) -- 775
	do -- 776
		local _type_0 = type(req) -- 776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 776
		if _tab_0 then -- 776
			local sessionId -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					sessionId = _obj_0.sessionId -- 776
				end -- 776
			end -- 776
			if sessionId ~= nil then -- 776
				local res = AgentSession.getSession(sessionId) -- 777
				if not res.success then -- 778
					return res -- 778
				end -- 778
				local taskId = res.session.currentTaskId -- 779
				local checkpoints -- 780
				if taskId then -- 780
					checkpoints = AgentTools.listCheckpoints(taskId) -- 780
				else -- 780
					checkpoints = { } -- 780
				end -- 780
				return { -- 782
					success = true, -- 782
					session = res.session, -- 783
					relatedSessions = res.relatedSessions, -- 784
					spawnInfo = res.spawnInfo, -- 785
					messages = res.messages, -- 786
					steps = res.steps, -- 787
					checkpoints = checkpoints, -- 788
					pendingQuestionnaire = res.pendingQuestionnaire, -- 789
					hasActivePlan = res.hasActivePlan -- 790
				} -- 781
			end -- 776
		end -- 776
	end -- 776
	return invalidArguments -- 775
end) -- 775
HttpServer:post("/agent/task/running", function() -- 792
	local res = AgentSession.listRunningSessions() -- 793
	if res.success and #res.sessions == 0 then -- 794
		res.sessions = nil -- 795
	end -- 794
	return res -- 796
end) -- 792
HttpServer:post("/agent/task/stop", function(req) -- 798
	do -- 799
		local _type_0 = type(req) -- 799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 799
		if _tab_0 then -- 799
			local sessionId -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					sessionId = _obj_0.sessionId -- 799
				end -- 799
			end -- 799
			if sessionId ~= nil then -- 799
				return AgentSession.stopSessionTask(sessionId) -- 800
			end -- 799
		end -- 799
	end -- 799
	return invalidArguments -- 798
end) -- 798
HttpServer:post("/agent/checkpoint/list", function(req) -- 802
	do -- 803
		local _type_0 = type(req) -- 803
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 803
		if _tab_0 then -- 803
			local taskId -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					taskId = _obj_0.taskId -- 803
				end -- 803
			end -- 803
			local sessionId -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					sessionId = _obj_0.sessionId -- 803
				end -- 803
			end -- 803
			if sessionId ~= nil then -- 803
				if not taskId and sessionId then -- 804
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 805
				end -- 804
				if not taskId then -- 806
					return { -- 806
						success = false, -- 806
						message = "task not found" -- 806
					} -- 806
				end -- 806
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 807
				if not access.success then -- 808
					return access -- 808
				end -- 808
				return { -- 810
					success = true, -- 810
					taskId = taskId, -- 811
					checkpoints = AgentTools.listCheckpoints(taskId) -- 812
				} -- 809
			end -- 803
		end -- 803
	end -- 803
	return invalidArguments -- 802
end) -- 802
HttpServer:post("/agent/checkpoint/diff", function(req) -- 814
	do -- 815
		local _type_0 = type(req) -- 815
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 815
		if _tab_0 then -- 815
			local sessionId -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					sessionId = _obj_0.sessionId -- 815
				end -- 815
			end -- 815
			local checkpointId -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					checkpointId = _obj_0.checkpointId -- 815
				end -- 815
			end -- 815
			if sessionId ~= nil and checkpointId ~= nil then -- 815
				if not (checkpointId > 0) then -- 816
					return { -- 816
						success = false, -- 816
						message = "invalid checkpointId" -- 816
					} -- 816
				end -- 816
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 817
				if not access.success then -- 818
					return access -- 818
				end -- 818
				return AgentTools.getCheckpointDiff(checkpointId) -- 819
			end -- 815
		end -- 815
	end -- 815
	return invalidArguments -- 814
end) -- 814
HttpServer:post("/agent/task/diff", function(req) -- 821
	do -- 822
		local _type_0 = type(req) -- 822
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 822
		if _tab_0 then -- 822
			local sessionId -- 822
			do -- 822
				local _obj_0 = req.body -- 822
				local _type_1 = type(_obj_0) -- 822
				if "table" == _type_1 or "userdata" == _type_1 then -- 822
					sessionId = _obj_0.sessionId -- 822
				end -- 822
			end -- 822
			local taskId -- 822
			do -- 822
				local _obj_0 = req.body -- 822
				local _type_1 = type(_obj_0) -- 822
				if "table" == _type_1 or "userdata" == _type_1 then -- 822
					taskId = _obj_0.taskId -- 822
				end -- 822
			end -- 822
			if sessionId ~= nil and taskId ~= nil then -- 822
				if not (taskId > 0) then -- 823
					return { -- 823
						success = false, -- 823
						message = "invalid taskId" -- 823
					} -- 823
				end -- 823
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 824
				if not access.success then -- 825
					return access -- 825
				end -- 825
				return AgentTools.getTaskChangeSetDiff(taskId) -- 826
			end -- 822
		end -- 822
	end -- 822
	return invalidArguments -- 821
end) -- 821
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 828
	do -- 829
		local _type_0 = type(req) -- 829
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 829
		if _tab_0 then -- 829
			local sessionId -- 829
			do -- 829
				local _obj_0 = req.body -- 829
				local _type_1 = type(_obj_0) -- 829
				if "table" == _type_1 or "userdata" == _type_1 then -- 829
					sessionId = _obj_0.sessionId -- 829
				end -- 829
			end -- 829
			local checkpointId -- 829
			do -- 829
				local _obj_0 = req.body -- 829
				local _type_1 = type(_obj_0) -- 829
				if "table" == _type_1 or "userdata" == _type_1 then -- 829
					checkpointId = _obj_0.checkpointId -- 829
				end -- 829
			end -- 829
			if sessionId ~= nil and checkpointId ~= nil then -- 829
				if not (checkpointId > 0) then -- 830
					return { -- 830
						success = false, -- 830
						message = "invalid checkpointId" -- 830
					} -- 830
				end -- 830
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 831
				if not access.success then -- 832
					return access -- 832
				end -- 832
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 833
				if not rollbackRes.success then -- 834
					return rollbackRes -- 834
				end -- 834
				return { -- 836
					success = true, -- 836
					checkpointId = rollbackRes.checkpointId -- 837
				} -- 835
			end -- 829
		end -- 829
	end -- 829
	return invalidArguments -- 828
end) -- 828
HttpServer:post("/agent/task/rollback", function(req) -- 839
	do -- 840
		local _type_0 = type(req) -- 840
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 840
		if _tab_0 then -- 840
			local sessionId -- 840
			do -- 840
				local _obj_0 = req.body -- 840
				local _type_1 = type(_obj_0) -- 840
				if "table" == _type_1 or "userdata" == _type_1 then -- 840
					sessionId = _obj_0.sessionId -- 840
				end -- 840
			end -- 840
			local taskId -- 840
			do -- 840
				local _obj_0 = req.body -- 840
				local _type_1 = type(_obj_0) -- 840
				if "table" == _type_1 or "userdata" == _type_1 then -- 840
					taskId = _obj_0.taskId -- 840
				end -- 840
			end -- 840
			if sessionId ~= nil and taskId ~= nil then -- 840
				if not (taskId > 0) then -- 841
					return { -- 841
						success = false, -- 841
						message = "invalid taskId" -- 841
					} -- 841
				end -- 841
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 842
				if not access.success then -- 843
					return access -- 843
				end -- 843
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 844
				if not rollbackRes.success then -- 845
					return rollbackRes -- 845
				end -- 845
				return { -- 847
					success = true, -- 847
					taskId = rollbackRes.taskId, -- 848
					checkpointId = rollbackRes.checkpointId, -- 849
					checkpointCount = rollbackRes.checkpointCount -- 850
				} -- 846
			end -- 840
		end -- 840
	end -- 840
	return invalidArguments -- 839
end) -- 839
local getSearchPath -- 852
getSearchPath = function(file) -- 852
	do -- 853
		local dir = getProjectDirFromFile(file) -- 853
		if dir then -- 853
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 854
		end -- 853
	end -- 853
	return "" -- 852
end -- 852
local getSearchFolders -- 856
getSearchFolders = function(file) -- 856
	do -- 857
		local dir = getProjectDirFromFile(file) -- 857
		if dir then -- 857
			return { -- 859
				Path(dir, "Script"), -- 859
				dir -- 860
			} -- 858
		end -- 857
	end -- 857
	return { } -- 856
end -- 856
local disabledCheckForLua = { -- 863
	"incompatible number of returns", -- 863
	"unknown", -- 864
	"cannot index", -- 865
	"module not found", -- 866
	"don't know how to resolve", -- 867
	"ContainerItem", -- 868
	"cannot resolve a type", -- 869
	"invalid key", -- 870
	"inconsistent index type", -- 871
	"cannot use operator", -- 872
	"attempting ipairs loop", -- 873
	"expects record or nominal", -- 874
	"variable is not being assigned", -- 875
	"<invalid type>", -- 876
	"<any type>", -- 877
	"using the '#' operator", -- 878
	"can't match a record", -- 879
	"redeclaration of variable", -- 880
	"cannot apply pairs", -- 881
	"not a function", -- 882
	"to%-be%-closed" -- 883
} -- 862
local yueCheck -- 885
yueCheck = function(file, content, lax) -- 885
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 886
	if isTIC80 then -- 887
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 888
	end -- 887
	local searchPath = getSearchPath(file) -- 889
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 890
	local info = { } -- 891
	local globals = { } -- 892
	for _index_0 = 1, #checkResult do -- 893
		local _des_0 = checkResult[_index_0] -- 893
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 893
		if "error" == t then -- 894
			info[#info + 1] = { -- 895
				"syntax", -- 895
				file, -- 895
				line, -- 895
				col, -- 895
				msg -- 895
			} -- 895
		elseif "global" == t then -- 896
			globals[#globals + 1] = { -- 897
				msg, -- 897
				line, -- 897
				col -- 897
			} -- 897
		end -- 894
	end -- 893
	if luaCodes then -- 898
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 899
		if success then -- 900
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 901
			if not (lintResult == "") then -- 902
				lintResult = lintResult .. "\n" -- 902
			end -- 902
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 903
		else -- 904
			for _index_0 = 1, #lintResult do -- 904
				local _des_0 = lintResult[_index_0] -- 904
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 904
				if isTIC80 and tic80APIs[name] then -- 905
					goto _continue_0 -- 905
				end -- 905
				info[#info + 1] = { -- 906
					"syntax", -- 906
					file, -- 906
					line, -- 906
					col, -- 906
					"invalid global variable" -- 906
				} -- 906
				::_continue_0:: -- 905
			end -- 904
		end -- 900
	end -- 898
	return luaCodes, info -- 907
end -- 885
local luaCheck -- 909
luaCheck = function(file, content) -- 909
	local res, err = load(content, "check") -- 910
	if not res then -- 911
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 912
		return { -- 913
			success = false, -- 913
			info = { -- 913
				{ -- 913
					"syntax", -- 913
					file, -- 913
					tonumber(line), -- 913
					0, -- 913
					msg -- 913
				} -- 913
			} -- 913
		} -- 913
	end -- 911
	local success, info = teal.checkAsync(content, file, true, "") -- 914
	if info then -- 915
		do -- 916
			local _accum_0 = { } -- 916
			local _len_0 = 1 -- 916
			for _index_0 = 1, #info do -- 916
				local item = info[_index_0] -- 916
				local useCheck = true -- 917
				if not item[5]:match("unused") then -- 918
					for _index_1 = 1, #disabledCheckForLua do -- 919
						local check = disabledCheckForLua[_index_1] -- 919
						if item[5]:match(check) then -- 920
							useCheck = false -- 921
						end -- 920
					end -- 919
				end -- 918
				if not useCheck then -- 922
					goto _continue_0 -- 922
				end -- 922
				do -- 923
					local _exp_0 = item[1] -- 923
					if "type" == _exp_0 then -- 924
						item[1] = "warning" -- 925
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 926
						goto _continue_0 -- 927
					end -- 923
				end -- 923
				_accum_0[_len_0] = item -- 928
				_len_0 = _len_0 + 1 -- 917
				::_continue_0:: -- 917
			end -- 916
			info = _accum_0 -- 916
		end -- 916
		if #info == 0 then -- 929
			info = nil -- 930
			success = true -- 931
		end -- 929
	end -- 915
	return { -- 932
		success = success, -- 932
		info = info -- 932
	} -- 932
end -- 909
local luaCheckWithLineInfo -- 934
luaCheckWithLineInfo = function(file, luaCodes) -- 934
	local res = luaCheck(file, luaCodes) -- 935
	local info = { } -- 936
	if not res.success then -- 937
		local current = 1 -- 938
		local lastLine = 1 -- 939
		local lineMap = { } -- 940
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 941
			local num = lineCode:match("--%s*(%d+)%s*$") -- 942
			if num then -- 943
				lastLine = tonumber(num) -- 944
			end -- 943
			lineMap[current] = lastLine -- 945
			current = current + 1 -- 946
		end -- 941
		local _list_0 = res.info -- 947
		for _index_0 = 1, #_list_0 do -- 947
			local item = _list_0[_index_0] -- 947
			item[3] = lineMap[item[3]] or 0 -- 948
			item[4] = 0 -- 949
			info[#info + 1] = item -- 950
		end -- 947
		return false, info -- 951
	end -- 937
	return true, info -- 952
end -- 934
local getCompiledYueLine -- 954
getCompiledYueLine = function(content, line, row, file, lax) -- 954
	local luaCodes = yueCheck(file, content, lax) -- 955
	if not luaCodes then -- 956
		return nil -- 956
	end -- 956
	local current = 1 -- 957
	local lastLine = 1 -- 958
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 959
	local targetRow = nil -- 960
	local lineMap = { } -- 961
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 962
		local num = lineCode:match("--%s*(%d+)%s*$") -- 963
		if num then -- 964
			lastLine = tonumber(num) -- 964
		end -- 964
		lineMap[current] = lastLine -- 965
		if row <= lastLine and not targetRow then -- 966
			targetRow = current -- 967
			break -- 968
		end -- 966
		current = current + 1 -- 969
	end -- 962
	targetRow = current -- 970
	if targetLine and targetRow then -- 971
		return luaCodes, targetLine, targetRow, lineMap -- 972
	else -- 974
		return nil -- 974
	end -- 971
end -- 954
HttpServer:postSchedule("/check", function(req) -- 976
	do -- 977
		local _type_0 = type(req) -- 977
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 977
		if _tab_0 then -- 977
			local file -- 977
			do -- 977
				local _obj_0 = req.body -- 977
				local _type_1 = type(_obj_0) -- 977
				if "table" == _type_1 or "userdata" == _type_1 then -- 977
					file = _obj_0.file -- 977
				end -- 977
			end -- 977
			local content -- 977
			do -- 977
				local _obj_0 = req.body -- 977
				local _type_1 = type(_obj_0) -- 977
				if "table" == _type_1 or "userdata" == _type_1 then -- 977
					content = _obj_0.content -- 977
				end -- 977
			end -- 977
			if file ~= nil and content ~= nil then -- 977
				local ext = Path:getExt(file) -- 978
				if "tl" == ext then -- 979
					local searchPath = getSearchPath(file) -- 980
					do -- 981
						local isTIC80 = CheckTIC80Code(content) -- 981
						if isTIC80 then -- 981
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 982
						end -- 981
					end -- 981
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 983
					return { -- 984
						success = success, -- 984
						info = info -- 984
					} -- 984
				elseif "lua" == ext then -- 985
					do -- 986
						local isTIC80 = CheckTIC80Code(content) -- 986
						if isTIC80 then -- 986
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 987
						end -- 986
					end -- 986
					return luaCheck(file, content) -- 988
				elseif "yue" == ext then -- 989
					local luaCodes, info = yueCheck(file, content, false) -- 990
					local success = luaCodes ~= nil -- 991
					if luaCodes then -- 992
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 993
						do -- 994
							local _tab_1 = { } -- 994
							local _idx_0 = #_tab_1 + 1 -- 994
							for _index_0 = 1, #info do -- 994
								local _value_0 = info[_index_0] -- 994
								_tab_1[_idx_0] = _value_0 -- 994
								_idx_0 = _idx_0 + 1 -- 994
							end -- 994
							local _idx_1 = #_tab_1 + 1 -- 994
							for _index_0 = 1, #luaInfo do -- 994
								local _value_0 = luaInfo[_index_0] -- 994
								_tab_1[_idx_1] = _value_0 -- 994
								_idx_1 = _idx_1 + 1 -- 994
							end -- 994
							info = _tab_1 -- 994
						end -- 994
						success = success and luaSuccess -- 995
					end -- 992
					if #info > 0 then -- 996
						return { -- 997
							success = success, -- 997
							info = info -- 997
						} -- 997
					else -- 999
						return { -- 999
							success = success -- 999
						} -- 999
					end -- 996
				elseif "xml" == ext then -- 1000
					local success, result = xml.check(content) -- 1001
					if success then -- 1002
						local info -- 1003
						success, info = luaCheckWithLineInfo(file, result) -- 1003
						if #info > 0 then -- 1004
							return { -- 1005
								success = success, -- 1005
								info = info -- 1005
							} -- 1005
						else -- 1007
							return { -- 1007
								success = success -- 1007
							} -- 1007
						end -- 1004
					else -- 1009
						local info -- 1009
						do -- 1009
							local _accum_0 = { } -- 1009
							local _len_0 = 1 -- 1009
							for _index_0 = 1, #result do -- 1009
								local _des_0 = result[_index_0] -- 1009
								local row, err = _des_0[1], _des_0[2] -- 1009
								_accum_0[_len_0] = { -- 1010
									"syntax", -- 1010
									file, -- 1010
									row, -- 1010
									0, -- 1010
									err -- 1010
								} -- 1010
								_len_0 = _len_0 + 1 -- 1010
							end -- 1009
							info = _accum_0 -- 1009
						end -- 1009
						return { -- 1011
							success = false, -- 1011
							info = info -- 1011
						} -- 1011
					end -- 1002
				end -- 979
			end -- 977
		end -- 977
	end -- 977
	return { -- 976
		success = true -- 976
	} -- 976
end) -- 976
HttpServer:post("/body/parse", function(req) -- 1013
	do -- 1014
		local _type_0 = type(req) -- 1014
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1014
		if _tab_0 then -- 1014
			local file -- 1014
			do -- 1014
				local _obj_0 = req.body -- 1014
				local _type_1 = type(_obj_0) -- 1014
				if "table" == _type_1 or "userdata" == _type_1 then -- 1014
					file = _obj_0.file -- 1014
				end -- 1014
			end -- 1014
			local content -- 1014
			do -- 1014
				local _obj_0 = req.body -- 1014
				local _type_1 = type(_obj_0) -- 1014
				if "table" == _type_1 or "userdata" == _type_1 then -- 1014
					content = _obj_0.content -- 1014
				end -- 1014
			end -- 1014
			if file ~= nil and content ~= nil then -- 1014
				if not (file:sub(-6) == ".b.lua") then -- 1015
					return { -- 1016
						success = false, -- 1016
						phase = "request", -- 1016
						message = "only .b.lua files can be converted" -- 1016
					} -- 1016
				end -- 1015
				local loader, err = load("_ENV = {}\n" .. content) -- 1017
				if not loader then -- 1018
					return { -- 1019
						success = false, -- 1019
						phase = "parse", -- 1019
						message = tostring(err) -- 1019
					} -- 1019
				end -- 1018
				local ok, data = pcall(loader) -- 1020
				if not ok then -- 1021
					return { -- 1022
						success = false, -- 1022
						phase = "execute", -- 1022
						message = tostring(data) -- 1022
					} -- 1022
				end -- 1021
				if not ("table" == type(data) and data[1] == "Array") then -- 1023
					return { -- 1024
						success = false, -- 1024
						phase = "validate", -- 1024
						message = "body lua root must be {\"Array\", ...}" -- 1024
					} -- 1024
				end -- 1023
				local text, jsonErr = json.encode(data, false, true) -- 1025
				if not text then -- 1026
					return { -- 1027
						success = false, -- 1027
						phase = "encode", -- 1027
						message = tostring(jsonErr) -- 1027
					} -- 1027
				end -- 1026
				return { -- 1028
					success = true, -- 1028
					json = text -- 1028
				} -- 1028
			end -- 1014
		end -- 1014
	end -- 1014
	return { -- 1013
		success = false, -- 1013
		phase = "request", -- 1013
		message = "invalid request" -- 1013
	} -- 1013
end) -- 1013
local updateInferedDesc -- 1030
updateInferedDesc = function(infered) -- 1030
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1031
		return -- 1031
	end -- 1031
	local key, row = infered.key, infered.row -- 1032
	local codes = Content:loadAsync(key) -- 1033
	if codes then -- 1033
		local comments = { } -- 1034
		local line = 0 -- 1035
		local skipping = false -- 1036
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1037
			line = line + 1 -- 1038
			if line >= row then -- 1039
				break -- 1039
			end -- 1039
			if lineCode:match("^%s*%-%- @") then -- 1040
				skipping = true -- 1041
				goto _continue_0 -- 1042
			end -- 1040
			local result = lineCode:match("^%s*%-%- (.+)") -- 1043
			if result then -- 1043
				if not skipping then -- 1044
					comments[#comments + 1] = result -- 1044
				end -- 1044
			elseif #comments > 0 then -- 1045
				comments = { } -- 1046
				skipping = false -- 1047
			end -- 1043
			::_continue_0:: -- 1038
		end -- 1037
		infered.doc = table.concat(comments, "\n") -- 1048
	end -- 1033
end -- 1030
HttpServer:postSchedule("/infer", function(req) -- 1050
	do -- 1051
		local _type_0 = type(req) -- 1051
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1051
		if _tab_0 then -- 1051
			local lang -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					lang = _obj_0.lang -- 1051
				end -- 1051
			end -- 1051
			local file -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					file = _obj_0.file -- 1051
				end -- 1051
			end -- 1051
			local content -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					content = _obj_0.content -- 1051
				end -- 1051
			end -- 1051
			local line -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					line = _obj_0.line -- 1051
				end -- 1051
			end -- 1051
			local row -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					row = _obj_0.row -- 1051
				end -- 1051
			end -- 1051
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1051
				local searchPath = getSearchPath(file) -- 1052
				if "tl" == lang or "lua" == lang then -- 1053
					if CheckTIC80Code(content) then -- 1054
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1055
					end -- 1054
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1056
					if (infered ~= nil) then -- 1057
						updateInferedDesc(infered) -- 1058
						return { -- 1059
							success = true, -- 1059
							infered = infered -- 1059
						} -- 1059
					end -- 1057
				elseif "yue" == lang then -- 1060
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1061
					if not luaCodes then -- 1062
						return { -- 1062
							success = false -- 1062
						} -- 1062
					end -- 1062
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1063
					if (infered ~= nil) then -- 1064
						local col -- 1065
						file, row, col = infered.file, infered.row, infered.col -- 1065
						if file == "" and row > 0 and col > 0 then -- 1066
							infered.row = lineMap[row] or 0 -- 1067
							infered.col = 0 -- 1068
						end -- 1066
						updateInferedDesc(infered) -- 1069
						return { -- 1070
							success = true, -- 1070
							infered = infered -- 1070
						} -- 1070
					end -- 1064
				end -- 1053
			end -- 1051
		end -- 1051
	end -- 1051
	return { -- 1050
		success = false -- 1050
	} -- 1050
end) -- 1050
local _anon_func_3 = function(doc) -- 1131
	local _accum_0 = { } -- 1131
	local _len_0 = 1 -- 1131
	local _list_0 = doc.params -- 1131
	for _index_0 = 1, #_list_0 do -- 1131
		local param = _list_0[_index_0] -- 1131
		_accum_0[_len_0] = param.name -- 1131
		_len_0 = _len_0 + 1 -- 1131
	end -- 1131
	return _accum_0 -- 1131
end -- 1131
local getParamDocs -- 1072
getParamDocs = function(signatures) -- 1072
	if not (signatures and #signatures > 0) then -- 1073
		return nil -- 1073
	end -- 1073
	local docs = { } -- 1074
	do -- 1075
		local codes = Content:loadAsync(signatures[1].file) -- 1075
		if codes then -- 1075
			local comments = { } -- 1076
			local params = { } -- 1077
			local line = 0 -- 1078
			local returnType = nil -- 1079
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1080
				line = line + 1 -- 1081
				local needBreak = true -- 1082
				for i, _des_0 in ipairs(signatures) do -- 1083
					local row = _des_0.row -- 1083
					if line >= row and not (docs[i] ~= nil) then -- 1084
						if #comments > 0 or #params > 0 or returnType then -- 1085
							docs[i] = { -- 1087
								doc = table.concat(comments, "  \n"), -- 1087
								returnType = returnType -- 1088
							} -- 1086
							if #params > 0 then -- 1090
								docs[i].params = params -- 1090
							end -- 1090
						else -- 1092
							docs[i] = false -- 1092
						end -- 1085
					end -- 1084
					if not docs[i] then -- 1093
						needBreak = false -- 1093
					end -- 1093
				end -- 1083
				if needBreak then -- 1094
					break -- 1094
				end -- 1094
				local result = lineCode:match("%s*%-%- (.+)") -- 1095
				if result then -- 1095
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1096
					if not name then -- 1097
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1098
					end -- 1097
					if name then -- 1099
						local pname = name -- 1100
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1101
							pname = pname .. "?" -- 1101
						end -- 1101
						params[#params + 1] = { -- 1103
							name = tostring(pname) .. ": " .. tostring(typ), -- 1103
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1104
						} -- 1102
					else -- 1107
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1107
						if typ then -- 1107
							if returnType then -- 1108
								returnType = returnType .. ", " .. typ -- 1109
							else -- 1111
								returnType = typ -- 1111
							end -- 1108
							result = result:gsub("@return", "**return:**") -- 1112
						end -- 1107
						comments[#comments + 1] = result -- 1113
					end -- 1099
				elseif #comments > 0 then -- 1114
					comments = { } -- 1115
					params = { } -- 1116
					returnType = nil -- 1117
				end -- 1095
			end -- 1080
		end -- 1075
	end -- 1075
	local results = { } -- 1118
	for i, signature in ipairs(signatures) do -- 1119
		local item = { -- 1121
			desc = signature.desc, -- 1121
			doc = "", -- 1122
			file = signature.file, -- 1123
			row = signature.row, -- 1124
			col = signature.col -- 1125
		} -- 1120
		do -- 1127
			local doc = docs[i] -- 1127
			if doc then -- 1127
				item.doc = doc.doc -- 1128
				if doc.params then -- 1129
					item.params = doc.params -- 1130
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1131
				elseif doc.returnType then -- 1132
					item.desc = "function()" -- 1133
				end -- 1129
				if doc.returnType then -- 1134
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1134
				end -- 1134
			end -- 1127
		end -- 1127
		results[#results + 1] = item -- 1135
	end -- 1119
	return results -- 1136
end -- 1072
HttpServer:postSchedule("/signature", function(req) -- 1138
	do -- 1139
		local _type_0 = type(req) -- 1139
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1139
		if _tab_0 then -- 1139
			local lang -- 1139
			do -- 1139
				local _obj_0 = req.body -- 1139
				local _type_1 = type(_obj_0) -- 1139
				if "table" == _type_1 or "userdata" == _type_1 then -- 1139
					lang = _obj_0.lang -- 1139
				end -- 1139
			end -- 1139
			local file -- 1139
			do -- 1139
				local _obj_0 = req.body -- 1139
				local _type_1 = type(_obj_0) -- 1139
				if "table" == _type_1 or "userdata" == _type_1 then -- 1139
					file = _obj_0.file -- 1139
				end -- 1139
			end -- 1139
			local content -- 1139
			do -- 1139
				local _obj_0 = req.body -- 1139
				local _type_1 = type(_obj_0) -- 1139
				if "table" == _type_1 or "userdata" == _type_1 then -- 1139
					content = _obj_0.content -- 1139
				end -- 1139
			end -- 1139
			local line -- 1139
			do -- 1139
				local _obj_0 = req.body -- 1139
				local _type_1 = type(_obj_0) -- 1139
				if "table" == _type_1 or "userdata" == _type_1 then -- 1139
					line = _obj_0.line -- 1139
				end -- 1139
			end -- 1139
			local row -- 1139
			do -- 1139
				local _obj_0 = req.body -- 1139
				local _type_1 = type(_obj_0) -- 1139
				if "table" == _type_1 or "userdata" == _type_1 then -- 1139
					row = _obj_0.row -- 1139
				end -- 1139
			end -- 1139
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1139
				local searchPath = getSearchPath(file) -- 1140
				if "tl" == lang or "lua" == lang then -- 1141
					if CheckTIC80Code(content) then -- 1142
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1143
					end -- 1142
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1144
					if signatures then -- 1144
						signatures = getParamDocs(signatures) -- 1145
						if signatures then -- 1145
							return { -- 1146
								success = true, -- 1146
								signatures = signatures -- 1146
							} -- 1146
						end -- 1145
					end -- 1144
				elseif "yue" == lang then -- 1147
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1148
					if not luaCodes then -- 1149
						return { -- 1149
							success = false -- 1149
						} -- 1149
					end -- 1149
					do -- 1150
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1150
						if chainOp then -- 1150
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1151
							if withVar then -- 1151
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1152
							end -- 1151
						end -- 1150
					end -- 1150
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1153
					if signatures then -- 1153
						signatures = getParamDocs(signatures) -- 1154
						if signatures then -- 1154
							return { -- 1155
								success = true, -- 1155
								signatures = signatures -- 1155
							} -- 1155
						end -- 1154
					else -- 1156
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1156
						if signatures then -- 1156
							signatures = getParamDocs(signatures) -- 1157
							if signatures then -- 1157
								return { -- 1158
									success = true, -- 1158
									signatures = signatures -- 1158
								} -- 1158
							end -- 1157
						end -- 1156
					end -- 1153
				end -- 1141
			end -- 1139
		end -- 1139
	end -- 1139
	return { -- 1138
		success = false -- 1138
	} -- 1138
end) -- 1138
local luaKeywords = { -- 1161
	'and', -- 1161
	'break', -- 1162
	'do', -- 1163
	'else', -- 1164
	'elseif', -- 1165
	'end', -- 1166
	'false', -- 1167
	'for', -- 1168
	'function', -- 1169
	'goto', -- 1170
	'if', -- 1171
	'in', -- 1172
	'local', -- 1173
	'nil', -- 1174
	'not', -- 1175
	'or', -- 1176
	'repeat', -- 1177
	'return', -- 1178
	'then', -- 1179
	'true', -- 1180
	'until', -- 1181
	'while' -- 1182
} -- 1160
local tealKeywords = { -- 1186
	'record', -- 1186
	'as', -- 1187
	'is', -- 1188
	'type', -- 1189
	'embed', -- 1190
	'enum', -- 1191
	'global', -- 1192
	'any', -- 1193
	'boolean', -- 1194
	'integer', -- 1195
	'number', -- 1196
	'string', -- 1197
	'thread' -- 1198
} -- 1185
local yueKeywords = { -- 1202
	"and", -- 1202
	"break", -- 1203
	"do", -- 1204
	"else", -- 1205
	"elseif", -- 1206
	"false", -- 1207
	"for", -- 1208
	"goto", -- 1209
	"if", -- 1210
	"in", -- 1211
	"local", -- 1212
	"nil", -- 1213
	"not", -- 1214
	"or", -- 1215
	"repeat", -- 1216
	"return", -- 1217
	"then", -- 1218
	"true", -- 1219
	"until", -- 1220
	"while", -- 1221
	"as", -- 1222
	"class", -- 1223
	"continue", -- 1224
	"export", -- 1225
	"extends", -- 1226
	"from", -- 1227
	"global", -- 1228
	"import", -- 1229
	"macro", -- 1230
	"switch", -- 1231
	"try", -- 1232
	"unless", -- 1233
	"using", -- 1234
	"when", -- 1235
	"with" -- 1236
} -- 1201
local _anon_func_4 = function(f) -- 1272
	local _val_0 = Path:getExt(f) -- 1272
	return "ttf" == _val_0 or "otf" == _val_0 -- 1272
end -- 1272
local _anon_func_5 = function(suggestions) -- 1298
	local _tbl_0 = { } -- 1298
	for _index_0 = 1, #suggestions do -- 1298
		local item = suggestions[_index_0] -- 1298
		_tbl_0[item[1] .. item[2]] = item -- 1298
	end -- 1298
	return _tbl_0 -- 1298
end -- 1298
HttpServer:postSchedule("/complete", function(req) -- 1239
	do -- 1240
		local _type_0 = type(req) -- 1240
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1240
		if _tab_0 then -- 1240
			local lang -- 1240
			do -- 1240
				local _obj_0 = req.body -- 1240
				local _type_1 = type(_obj_0) -- 1240
				if "table" == _type_1 or "userdata" == _type_1 then -- 1240
					lang = _obj_0.lang -- 1240
				end -- 1240
			end -- 1240
			local file -- 1240
			do -- 1240
				local _obj_0 = req.body -- 1240
				local _type_1 = type(_obj_0) -- 1240
				if "table" == _type_1 or "userdata" == _type_1 then -- 1240
					file = _obj_0.file -- 1240
				end -- 1240
			end -- 1240
			local content -- 1240
			do -- 1240
				local _obj_0 = req.body -- 1240
				local _type_1 = type(_obj_0) -- 1240
				if "table" == _type_1 or "userdata" == _type_1 then -- 1240
					content = _obj_0.content -- 1240
				end -- 1240
			end -- 1240
			local line -- 1240
			do -- 1240
				local _obj_0 = req.body -- 1240
				local _type_1 = type(_obj_0) -- 1240
				if "table" == _type_1 or "userdata" == _type_1 then -- 1240
					line = _obj_0.line -- 1240
				end -- 1240
			end -- 1240
			local row -- 1240
			do -- 1240
				local _obj_0 = req.body -- 1240
				local _type_1 = type(_obj_0) -- 1240
				if "table" == _type_1 or "userdata" == _type_1 then -- 1240
					row = _obj_0.row -- 1240
				end -- 1240
			end -- 1240
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1240
				local searchPath = getSearchPath(file) -- 1241
				repeat -- 1242
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1243
					if lang == "yue" then -- 1244
						if not item then -- 1245
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1245
						end -- 1245
						if not item then -- 1246
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1246
						end -- 1246
					end -- 1244
					local searchType = nil -- 1247
					if not item then -- 1248
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1249
						if lang == "yue" then -- 1250
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1251
						end -- 1250
						if (item ~= nil) then -- 1252
							searchType = "Image" -- 1252
						end -- 1252
					end -- 1248
					if not item then -- 1253
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1254
						if lang == "yue" then -- 1255
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1256
						end -- 1255
						if (item ~= nil) then -- 1257
							searchType = "Font" -- 1257
						end -- 1257
					end -- 1253
					if not item then -- 1258
						break -- 1258
					end -- 1258
					local searchPaths = Content.searchPaths -- 1259
					local _list_0 = getSearchFolders(file) -- 1260
					for _index_0 = 1, #_list_0 do -- 1260
						local folder = _list_0[_index_0] -- 1260
						searchPaths[#searchPaths + 1] = folder -- 1261
					end -- 1260
					if searchType then -- 1262
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1262
					end -- 1262
					local tokens -- 1263
					do -- 1263
						local _accum_0 = { } -- 1263
						local _len_0 = 1 -- 1263
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1263
							_accum_0[_len_0] = mod -- 1263
							_len_0 = _len_0 + 1 -- 1263
						end -- 1263
						tokens = _accum_0 -- 1263
					end -- 1263
					local suggestions = { } -- 1264
					for _index_0 = 1, #searchPaths do -- 1265
						local path = searchPaths[_index_0] -- 1265
						local sPath = Path(path, table.unpack(tokens)) -- 1266
						if not Content:exist(sPath) then -- 1267
							goto _continue_0 -- 1267
						end -- 1267
						if searchType == "Font" then -- 1268
							local fontPath = Path(sPath, "Font") -- 1269
							if Content:exist(fontPath) then -- 1270
								local _list_1 = Content:getFiles(fontPath) -- 1271
								for _index_1 = 1, #_list_1 do -- 1271
									local f = _list_1[_index_1] -- 1271
									if _anon_func_4(f) then -- 1272
										if "." == f:sub(1, 1) then -- 1273
											goto _continue_1 -- 1273
										end -- 1273
										suggestions[#suggestions + 1] = { -- 1274
											Path:getName(f), -- 1274
											"font", -- 1274
											"field" -- 1274
										} -- 1274
									end -- 1272
									::_continue_1:: -- 1272
								end -- 1271
							end -- 1270
						end -- 1268
						local _list_1 = Content:getFiles(sPath) -- 1275
						for _index_1 = 1, #_list_1 do -- 1275
							local f = _list_1[_index_1] -- 1275
							if "Image" == searchType then -- 1276
								do -- 1277
									local _exp_0 = Path:getExt(f) -- 1277
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1277
										if "." == f:sub(1, 1) then -- 1278
											goto _continue_2 -- 1278
										end -- 1278
										suggestions[#suggestions + 1] = { -- 1279
											f, -- 1279
											"image", -- 1279
											"field" -- 1279
										} -- 1279
									end -- 1277
								end -- 1277
								goto _continue_2 -- 1280
							elseif "Font" == searchType then -- 1281
								do -- 1282
									local _exp_0 = Path:getExt(f) -- 1282
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1282
										if "." == f:sub(1, 1) then -- 1283
											goto _continue_2 -- 1283
										end -- 1283
										suggestions[#suggestions + 1] = { -- 1284
											f, -- 1284
											"font", -- 1284
											"field" -- 1284
										} -- 1284
									end -- 1282
								end -- 1282
								goto _continue_2 -- 1285
							end -- 1276
							local _exp_0 = Path:getExt(f) -- 1286
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1286
								local name = Path:getName(f) -- 1287
								if "d" == Path:getExt(name) then -- 1288
									goto _continue_2 -- 1288
								end -- 1288
								if "." == name:sub(1, 1) then -- 1289
									goto _continue_2 -- 1289
								end -- 1289
								suggestions[#suggestions + 1] = { -- 1290
									name, -- 1290
									"module", -- 1290
									"field" -- 1290
								} -- 1290
							end -- 1286
							::_continue_2:: -- 1276
						end -- 1275
						local _list_2 = Content:getDirs(sPath) -- 1291
						for _index_1 = 1, #_list_2 do -- 1291
							local dir = _list_2[_index_1] -- 1291
							if "." == dir:sub(1, 1) then -- 1292
								goto _continue_3 -- 1292
							end -- 1292
							suggestions[#suggestions + 1] = { -- 1293
								dir, -- 1293
								"folder", -- 1293
								"variable" -- 1293
							} -- 1293
							::_continue_3:: -- 1292
						end -- 1291
						::_continue_0:: -- 1266
					end -- 1265
					if item == "" and not searchType then -- 1294
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1295
						for _index_0 = 1, #_list_1 do -- 1295
							local _des_0 = _list_1[_index_0] -- 1295
							local name = _des_0[1] -- 1295
							suggestions[#suggestions + 1] = { -- 1296
								name, -- 1296
								"dora module", -- 1296
								"function" -- 1296
							} -- 1296
						end -- 1295
					end -- 1294
					if #suggestions > 0 then -- 1297
						do -- 1298
							local _accum_0 = { } -- 1298
							local _len_0 = 1 -- 1298
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1298
								_accum_0[_len_0] = v -- 1298
								_len_0 = _len_0 + 1 -- 1298
							end -- 1298
							suggestions = _accum_0 -- 1298
						end -- 1298
						return { -- 1299
							success = true, -- 1299
							suggestions = suggestions -- 1299
						} -- 1299
					else -- 1301
						return { -- 1301
							success = false -- 1301
						} -- 1301
					end -- 1297
				until true -- 1242
				if "tl" == lang or "lua" == lang then -- 1303
					do -- 1304
						local isTIC80 = CheckTIC80Code(content) -- 1304
						if isTIC80 then -- 1304
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1305
						end -- 1304
					end -- 1304
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1306
					if not line:match("[%.:]$") then -- 1307
						local checkSet -- 1308
						do -- 1308
							local _tbl_0 = { } -- 1308
							for _index_0 = 1, #suggestions do -- 1308
								local _des_0 = suggestions[_index_0] -- 1308
								local name = _des_0[1] -- 1308
								_tbl_0[name] = true -- 1308
							end -- 1308
							checkSet = _tbl_0 -- 1308
						end -- 1308
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1309
						for _index_0 = 1, #_list_0 do -- 1309
							local item = _list_0[_index_0] -- 1309
							if not checkSet[item[1]] then -- 1310
								suggestions[#suggestions + 1] = item -- 1310
							end -- 1310
						end -- 1309
						for _index_0 = 1, #luaKeywords do -- 1311
							local word = luaKeywords[_index_0] -- 1311
							suggestions[#suggestions + 1] = { -- 1312
								word, -- 1312
								"keyword", -- 1312
								"keyword" -- 1312
							} -- 1312
						end -- 1311
						if lang == "tl" then -- 1313
							for _index_0 = 1, #tealKeywords do -- 1314
								local word = tealKeywords[_index_0] -- 1314
								suggestions[#suggestions + 1] = { -- 1315
									word, -- 1315
									"keyword", -- 1315
									"keyword" -- 1315
								} -- 1315
							end -- 1314
						end -- 1313
					end -- 1307
					if #suggestions > 0 then -- 1316
						return { -- 1317
							success = true, -- 1317
							suggestions = suggestions -- 1317
						} -- 1317
					end -- 1316
				elseif "yue" == lang then -- 1318
					local suggestions = { } -- 1319
					local gotGlobals = false -- 1320
					do -- 1321
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1321
						if luaCodes then -- 1321
							gotGlobals = true -- 1322
							do -- 1323
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1323
								if chainOp then -- 1323
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1324
									if not withVar then -- 1325
										return { -- 1325
											success = false -- 1325
										} -- 1325
									end -- 1325
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1326
								elseif line:match("^([%.\\])$") then -- 1327
									return { -- 1328
										success = false -- 1328
									} -- 1328
								end -- 1323
							end -- 1323
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1329
							for _index_0 = 1, #_list_0 do -- 1329
								local item = _list_0[_index_0] -- 1329
								suggestions[#suggestions + 1] = item -- 1329
							end -- 1329
							if #suggestions == 0 then -- 1330
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1331
								for _index_0 = 1, #_list_1 do -- 1331
									local item = _list_1[_index_0] -- 1331
									suggestions[#suggestions + 1] = item -- 1331
								end -- 1331
							end -- 1330
						end -- 1321
					end -- 1321
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1332
						local checkSet -- 1333
						do -- 1333
							local _tbl_0 = { } -- 1333
							for _index_0 = 1, #suggestions do -- 1333
								local _des_0 = suggestions[_index_0] -- 1333
								local name = _des_0[1] -- 1333
								_tbl_0[name] = true -- 1333
							end -- 1333
							checkSet = _tbl_0 -- 1333
						end -- 1333
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1334
						for _index_0 = 1, #_list_0 do -- 1334
							local item = _list_0[_index_0] -- 1334
							if not checkSet[item[1]] then -- 1335
								suggestions[#suggestions + 1] = item -- 1335
							end -- 1335
						end -- 1334
						if not gotGlobals then -- 1336
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1337
							for _index_0 = 1, #_list_1 do -- 1337
								local item = _list_1[_index_0] -- 1337
								if not checkSet[item[1]] then -- 1338
									suggestions[#suggestions + 1] = item -- 1338
								end -- 1338
							end -- 1337
						end -- 1336
						for _index_0 = 1, #yueKeywords do -- 1339
							local word = yueKeywords[_index_0] -- 1339
							if not checkSet[word] then -- 1340
								suggestions[#suggestions + 1] = { -- 1341
									word, -- 1341
									"keyword", -- 1341
									"keyword" -- 1341
								} -- 1341
							end -- 1340
						end -- 1339
					end -- 1332
					if #suggestions > 0 then -- 1342
						return { -- 1343
							success = true, -- 1343
							suggestions = suggestions -- 1343
						} -- 1343
					end -- 1342
				elseif "xml" == lang then -- 1344
					local items = xml.complete(content) -- 1345
					if #items > 0 then -- 1346
						local suggestions -- 1347
						do -- 1347
							local _accum_0 = { } -- 1347
							local _len_0 = 1 -- 1347
							for _index_0 = 1, #items do -- 1347
								local _des_0 = items[_index_0] -- 1347
								local label, insertText = _des_0[1], _des_0[2] -- 1347
								_accum_0[_len_0] = { -- 1348
									label, -- 1348
									insertText, -- 1348
									"field" -- 1348
								} -- 1348
								_len_0 = _len_0 + 1 -- 1348
							end -- 1347
							suggestions = _accum_0 -- 1347
						end -- 1347
						return { -- 1349
							success = true, -- 1349
							suggestions = suggestions -- 1349
						} -- 1349
					end -- 1346
				end -- 1303
			end -- 1240
		end -- 1240
	end -- 1240
	return { -- 1239
		success = false -- 1239
	} -- 1239
end) -- 1239
HttpServer:upload("/upload", function(req, filename) -- 1353
	do -- 1354
		local _type_0 = type(req) -- 1354
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1354
		if _tab_0 then -- 1354
			local path -- 1354
			do -- 1354
				local _obj_0 = req.params -- 1354
				local _type_1 = type(_obj_0) -- 1354
				if "table" == _type_1 or "userdata" == _type_1 then -- 1354
					path = _obj_0.path -- 1354
				end -- 1354
			end -- 1354
			if path ~= nil then -- 1354
				local uploadPath = Path(Content.writablePath, ".upload") -- 1355
				if not Content:exist(uploadPath) then -- 1356
					Content:mkdir(uploadPath) -- 1357
				end -- 1356
				local targetPath = Path(uploadPath, filename) -- 1358
				Content:mkdir(Path:getPath(targetPath)) -- 1359
				return targetPath -- 1360
			end -- 1354
		end -- 1354
	end -- 1354
	return nil -- 1353
end, function(req, file) -- 1361
	do -- 1362
		local _type_0 = type(req) -- 1362
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1362
		if _tab_0 then -- 1362
			local path -- 1362
			do -- 1362
				local _obj_0 = req.params -- 1362
				local _type_1 = type(_obj_0) -- 1362
				if "table" == _type_1 or "userdata" == _type_1 then -- 1362
					path = _obj_0.path -- 1362
				end -- 1362
			end -- 1362
			if path ~= nil then -- 1362
				path = Path(Content.writablePath, path) -- 1363
				if Content:exist(path) then -- 1364
					local uploadPath = Path(Content.writablePath, ".upload") -- 1365
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1366
					Content:mkdir(Path:getPath(targetPath)) -- 1367
					if Content:move(file, targetPath) then -- 1368
						return true -- 1369
					end -- 1368
				end -- 1364
			end -- 1362
		end -- 1362
	end -- 1362
	return false -- 1361
end) -- 1351
HttpServer:post("/list", function(req) -- 1372
	do -- 1373
		local _type_0 = type(req) -- 1373
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1373
		if _tab_0 then -- 1373
			local path -- 1373
			do -- 1373
				local _obj_0 = req.body -- 1373
				local _type_1 = type(_obj_0) -- 1373
				if "table" == _type_1 or "userdata" == _type_1 then -- 1373
					path = _obj_0.path -- 1373
				end -- 1373
			end -- 1373
			if path ~= nil then -- 1373
				if Content:exist(path) then -- 1374
					local files = { } -- 1375
					local visitAssets -- 1376
					visitAssets = function(path, folder) -- 1376
						local dirs = Content:getDirs(path) -- 1377
						for _index_0 = 1, #dirs do -- 1378
							local dir = dirs[_index_0] -- 1378
							if dir:match("^%.") or dir == "node_modules" then -- 1379
								goto _continue_0 -- 1379
							end -- 1379
							local current -- 1380
							if folder == "" then -- 1380
								current = dir -- 1381
							else -- 1383
								current = Path(folder, dir) -- 1383
							end -- 1380
							files[#files + 1] = current -- 1384
							visitAssets(Path(path, dir), current) -- 1385
							::_continue_0:: -- 1379
						end -- 1378
						local fs = Content:getFiles(path) -- 1386
						for _index_0 = 1, #fs do -- 1387
							local f = fs[_index_0] -- 1387
							if (".DS_Store" == f) then -- 1388
								goto _continue_1 -- 1389
							end -- 1388
							if folder == "" then -- 1390
								files[#files + 1] = f -- 1391
							else -- 1393
								files[#files + 1] = Path(folder, f) -- 1393
							end -- 1390
							::_continue_1:: -- 1388
						end -- 1387
					end -- 1376
					visitAssets(path, "") -- 1394
					if #files == 0 then -- 1395
						files = nil -- 1395
					end -- 1395
					return { -- 1396
						success = true, -- 1396
						files = files -- 1396
					} -- 1396
				end -- 1374
			end -- 1373
		end -- 1373
	end -- 1373
	return { -- 1372
		success = false -- 1372
	} -- 1372
end) -- 1372
HttpServer:post("/info", function(req) -- 1398
	local Entry = require("Script.Dev.Entry") -- 1399
	local config = Entry.getConfig() -- 1400
	do -- 1401
		local _type_0 = type(req) -- 1401
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1401
		if _tab_0 then -- 1401
			local webIDETourCompleted -- 1401
			do -- 1401
				local _obj_0 = req.body -- 1401
				local _type_1 = type(_obj_0) -- 1401
				if "table" == _type_1 or "userdata" == _type_1 then -- 1401
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1401
				end -- 1401
			end -- 1401
			if webIDETourCompleted ~= nil then -- 1401
				config.webIDETourCompleted = webIDETourCompleted == true -- 1402
			end -- 1401
		end -- 1401
	end -- 1401
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1403
	local engineDev = Entry.getEngineDev() -- 1404
	Entry.connectWebIDE() -- 1405
	return { -- 1407
		platform = App.platform, -- 1407
		locale = App.locale, -- 1408
		version = App.version, -- 1409
		engineDev = engineDev, -- 1410
		webProfiler = webProfiler, -- 1411
		drawerWidth = drawerWidth, -- 1412
		webIDETourCompleted = webIDETourCompleted == true -- 1413
	} -- 1406
end) -- 1398
local ensureLLMConfigTable -- 1415
ensureLLMConfigTable = function() -- 1415
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1416
	if columns and #columns > 0 then -- 1417
		local expected = { -- 1419
			id = true, -- 1419
			name = true, -- 1420
			url = true, -- 1421
			model = true, -- 1422
			api_key = true, -- 1423
			context_window = true, -- 1424
			temperature = true, -- 1425
			max_tokens = true, -- 1426
			reasoning_effort = true, -- 1427
			custom_options = true, -- 1428
			supports_function_calling = true, -- 1429
			active = true, -- 1430
			created_at = true, -- 1431
			updated_at = true -- 1432
		} -- 1418
		local existing = { } -- 1434
		local valid = true -- 1435
		for _index_0 = 1, #columns do -- 1436
			local row = columns[_index_0] -- 1436
			local columnName = tostring(row[2]) -- 1437
			existing[columnName] = true -- 1438
			if not expected[columnName] then -- 1439
				valid = false -- 1440
				break -- 1441
			end -- 1439
		end -- 1436
		if valid then -- 1442
			if not existing.context_window then -- 1443
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1444
			end -- 1443
			if not existing.temperature then -- 1445
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1446
			end -- 1445
			if not existing.max_tokens then -- 1447
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1448
			end -- 1447
			if not existing.reasoning_effort then -- 1449
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1450
			end -- 1449
			if not existing.custom_options then -- 1451
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1452
			end -- 1451
			if not existing.supports_function_calling then -- 1453
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1454
			end -- 1453
		else -- 1456
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1456
		end -- 1442
	end -- 1417
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 64000,
			temperature REAL NOT NULL DEFAULT 0.1,
			max_tokens INTEGER NOT NULL DEFAULT 8192,
			reasoning_effort TEXT NOT NULL DEFAULT '',
			custom_options TEXT NOT NULL DEFAULT '',
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 1457
end -- 1415
local normalizeContextWindow -- 1476
normalizeContextWindow = function(value) -- 1476
	local contextWindow = tonumber(value) -- 1477
	if contextWindow == nil or contextWindow < 64000 then -- 1478
		return 64000 -- 1479
	end -- 1478
	return math.max(64000, math.floor(contextWindow)) -- 1480
end -- 1476
local normalizeTemperature -- 1482
normalizeTemperature = function(value) -- 1482
	local temperature = tonumber(value) -- 1483
	if temperature == nil then -- 1484
		return 0.1 -- 1485
	end -- 1484
	return math.max(0, math.min(2, temperature)) -- 1486
end -- 1482
local normalizeMaxTokens -- 1488
normalizeMaxTokens = function(value) -- 1488
	local maxTokens = tonumber(value) -- 1489
	if maxTokens == nil or maxTokens < 1 then -- 1490
		return 8192 -- 1491
	end -- 1490
	return math.max(1, math.floor(maxTokens)) -- 1492
end -- 1488
local normalizeReasoningEffort -- 1494
normalizeReasoningEffort = function(value) -- 1494
	if value == nil then -- 1495
		return "" -- 1496
	end -- 1495
	local effort = tostring(value) -- 1497
	return effort:match("^%s*(.-)%s*$") or "" -- 1498
end -- 1494
local normalizeCustomOptions -- 1500
normalizeCustomOptions = function(value) -- 1500
	if value == nil then -- 1501
		return "" -- 1502
	end -- 1501
	local options = tostring(value) -- 1503
	options = options:match("^%s*(.-)%s*$") or "" -- 1504
	return options -- 1505
end -- 1500
local validateCustomOptions -- 1507
validateCustomOptions = function(value) -- 1507
	local options = normalizeCustomOptions(value) -- 1508
	if options == "" then -- 1509
		return true -- 1509
	end -- 1509
	if not options:match("^%s*{") then -- 1510
		return false -- 1510
	end -- 1510
	local decoded = json.decode(options) -- 1511
	return type(decoded) == "table" -- 1512
end -- 1507
HttpServer:post("/llm/list", function() -- 1514
	ensureLLMConfigTable() -- 1515
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1516
	local items -- 1520
	if rows and #rows > 0 then -- 1520
		local _accum_0 = { } -- 1521
		local _len_0 = 1 -- 1521
		for _index_0 = 1, #rows do -- 1521
			local _des_0 = rows[_index_0] -- 1521
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1521
			_accum_0[_len_0] = { -- 1522
				id = id, -- 1522
				name = name, -- 1522
				url = url, -- 1522
				model = model, -- 1522
				key = key, -- 1522
				contextWindow = normalizeContextWindow(contextWindow), -- 1522
				temperature = normalizeTemperature(temperature), -- 1522
				maxTokens = normalizeMaxTokens(maxTokens), -- 1522
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1522
				customOptions = normalizeCustomOptions(customOptions), -- 1522
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1522
			} -- 1522
			_len_0 = _len_0 + 1 -- 1522
		end -- 1521
		items = _accum_0 -- 1520
	end -- 1520
	return { -- 1523
		success = true, -- 1523
		items = items -- 1523
	} -- 1523
end) -- 1514
HttpServer:post("/llm/create", function(req) -- 1525
	ensureLLMConfigTable() -- 1526
	do -- 1527
		local _type_0 = type(req) -- 1527
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1527
		if _tab_0 then -- 1527
			local body = req.body -- 1527
			if body ~= nil then -- 1527
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1528
				local now = os.time() -- 1529
				if name == nil or url == nil or model == nil or key == nil then -- 1530
					return invalidArguments -- 1531
				end -- 1530
				contextWindow = normalizeContextWindow(contextWindow) -- 1532
				temperature = normalizeTemperature(temperature) -- 1533
				maxTokens = normalizeMaxTokens(maxTokens) -- 1534
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1535
				customOptions = normalizeCustomOptions(customOptions) -- 1536
				if not validateCustomOptions(customOptions) then -- 1537
					return { -- 1537
						success = false, -- 1537
						message = "customOptions must be a JSON object" -- 1537
					} -- 1537
				end -- 1537
				if supportsFunctionCalling == false then -- 1538
					supportsFunctionCalling = 0 -- 1538
				else -- 1538
					supportsFunctionCalling = 1 -- 1538
				end -- 1538
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1545
					tostring(name), -- 1545
					tostring(url), -- 1546
					tostring(model), -- 1547
					tostring(key), -- 1548
					contextWindow, -- 1549
					temperature, -- 1550
					maxTokens, -- 1551
					reasoningEffort, -- 1552
					customOptions, -- 1553
					supportsFunctionCalling, -- 1554
					1, -- 1555
					now, -- 1556
					now -- 1557
				}) -- 1539
				return { -- 1559
					success = affected >= 0 -- 1559
				} -- 1559
			end -- 1527
		end -- 1527
	end -- 1527
	return invalidArguments -- 1525
end) -- 1525
HttpServer:post("/llm/update", function(req) -- 1561
	ensureLLMConfigTable() -- 1562
	do -- 1563
		local _type_0 = type(req) -- 1563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1563
		if _tab_0 then -- 1563
			local body = req.body -- 1563
			if body ~= nil then -- 1563
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1564
				local now = os.time() -- 1565
				id = tonumber(id) -- 1566
				if id == nil then -- 1567
					return invalidArguments -- 1567
				end -- 1567
				contextWindow = normalizeContextWindow(contextWindow) -- 1568
				temperature = normalizeTemperature(temperature) -- 1569
				maxTokens = normalizeMaxTokens(maxTokens) -- 1570
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1571
				customOptions = normalizeCustomOptions(customOptions) -- 1572
				if not validateCustomOptions(customOptions) then -- 1573
					return { -- 1573
						success = false, -- 1573
						message = "customOptions must be a JSON object" -- 1573
					} -- 1573
				end -- 1573
				if supportsFunctionCalling == false then -- 1574
					supportsFunctionCalling = 0 -- 1574
				else -- 1574
					supportsFunctionCalling = 1 -- 1574
				end -- 1574
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1579
					tostring(name), -- 1579
					tostring(url), -- 1580
					tostring(model), -- 1581
					tostring(key), -- 1582
					contextWindow, -- 1583
					temperature, -- 1584
					maxTokens, -- 1585
					reasoningEffort, -- 1586
					customOptions, -- 1587
					supportsFunctionCalling, -- 1588
					now, -- 1589
					id -- 1590
				}) -- 1575
				return { -- 1592
					success = affected >= 0 -- 1592
				} -- 1592
			end -- 1563
		end -- 1563
	end -- 1563
	return invalidArguments -- 1561
end) -- 1561
HttpServer:post("/llm/delete", function(req) -- 1594
	ensureLLMConfigTable() -- 1595
	do -- 1596
		local _type_0 = type(req) -- 1596
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1596
		if _tab_0 then -- 1596
			local id -- 1596
			do -- 1596
				local _obj_0 = req.body -- 1596
				local _type_1 = type(_obj_0) -- 1596
				if "table" == _type_1 or "userdata" == _type_1 then -- 1596
					id = _obj_0.id -- 1596
				end -- 1596
			end -- 1596
			if id ~= nil then -- 1596
				id = tonumber(id) -- 1597
				if id == nil then -- 1598
					return invalidArguments -- 1598
				end -- 1598
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1599
					id -- 1599
				}) -- 1599
				return { -- 1600
					success = affected >= 0 -- 1600
				} -- 1600
			end -- 1596
		end -- 1596
	end -- 1596
	return invalidArguments -- 1594
end) -- 1594
HttpServer:post("/stat", function(req) -- 1602
	do -- 1603
		local _type_0 = type(req) -- 1603
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1603
		if _tab_0 then -- 1603
			local path -- 1603
			do -- 1603
				local _obj_0 = req.body -- 1603
				local _type_1 = type(_obj_0) -- 1603
				if "table" == _type_1 or "userdata" == _type_1 then -- 1603
					path = _obj_0.path -- 1603
				end -- 1603
			end -- 1603
			if path ~= nil then -- 1603
				if not Content:exist(path) then -- 1604
					return { -- 1605
						success = false, -- 1605
						message = "target not existed" -- 1605
					} -- 1605
				end -- 1604
				if Content:isdir(path) then -- 1606
					return { -- 1607
						success = false, -- 1607
						message = "failed to stat a directory" -- 1607
					} -- 1607
				end -- 1606
				local size, isBinary = Content:getAttr(path) -- 1608
				if size then -- 1608
					return { -- 1609
						success = true, -- 1609
						size = size, -- 1609
						isBinary = isBinary -- 1609
					} -- 1609
				end -- 1608
			end -- 1603
		end -- 1603
	end -- 1603
	return { -- 1602
		success = false, -- 1602
		message = "failed to stat" -- 1602
	} -- 1602
end) -- 1602
HttpServer:post("/new", function(req) -- 1611
	do -- 1612
		local _type_0 = type(req) -- 1612
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1612
		if _tab_0 then -- 1612
			local path -- 1612
			do -- 1612
				local _obj_0 = req.body -- 1612
				local _type_1 = type(_obj_0) -- 1612
				if "table" == _type_1 or "userdata" == _type_1 then -- 1612
					path = _obj_0.path -- 1612
				end -- 1612
			end -- 1612
			local content -- 1612
			do -- 1612
				local _obj_0 = req.body -- 1612
				local _type_1 = type(_obj_0) -- 1612
				if "table" == _type_1 or "userdata" == _type_1 then -- 1612
					content = _obj_0.content -- 1612
				end -- 1612
			end -- 1612
			local folder -- 1612
			do -- 1612
				local _obj_0 = req.body -- 1612
				local _type_1 = type(_obj_0) -- 1612
				if "table" == _type_1 or "userdata" == _type_1 then -- 1612
					folder = _obj_0.folder -- 1612
				end -- 1612
			end -- 1612
			if path ~= nil and content ~= nil and folder ~= nil then -- 1612
				if Content:exist(path) then -- 1613
					return { -- 1614
						success = false, -- 1614
						message = "TargetExisted" -- 1614
					} -- 1614
				end -- 1613
				local parent = Path:getPath(path) -- 1615
				local files = Content:getFiles(parent) -- 1616
				if folder then -- 1617
					local name = Path:getFilename(path):lower() -- 1618
					for _index_0 = 1, #files do -- 1619
						local file = files[_index_0] -- 1619
						if name == Path:getFilename(file):lower() then -- 1620
							return { -- 1621
								success = false, -- 1621
								message = "TargetExisted" -- 1621
							} -- 1621
						end -- 1620
					end -- 1619
					if Content:mkdir(path) then -- 1622
						return { -- 1623
							success = true -- 1623
						} -- 1623
					end -- 1622
				else -- 1625
					local name = Path:getName(path):lower() -- 1625
					for _index_0 = 1, #files do -- 1626
						local file = files[_index_0] -- 1626
						if name == Path:getName(file):lower() then -- 1627
							local ext = Path:getExt(file) -- 1628
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1629
								goto _continue_0 -- 1630
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1631
								goto _continue_0 -- 1632
							end -- 1629
							return { -- 1633
								success = false, -- 1633
								message = "SourceExisted" -- 1633
							} -- 1633
						end -- 1627
						::_continue_0:: -- 1627
					end -- 1626
					if Content:save(path, content) then -- 1634
						return { -- 1635
							success = true -- 1635
						} -- 1635
					end -- 1634
				end -- 1617
			end -- 1612
		end -- 1612
	end -- 1612
	return { -- 1611
		success = false, -- 1611
		message = "Failed" -- 1611
	} -- 1611
end) -- 1611
local deleteAsset -- 1637
deleteAsset = function(path) -- 1637
	if not Content:exist(path) then -- 1638
		return false -- 1638
	end -- 1638
	local projectRoot -- 1639
	if Content:isdir(path) and isProjectRootDir(path) then -- 1639
		projectRoot = path -- 1639
	else -- 1639
		projectRoot = nil -- 1639
	end -- 1639
	local parent = Path:getPath(path) -- 1640
	local files = Content:getFiles(parent) -- 1641
	local name = Path:getName(path):lower() -- 1642
	local ext = Path:getExt(path) -- 1643
	for _index_0 = 1, #files do -- 1644
		local file = files[_index_0] -- 1644
		if name == Path:getName(file):lower() then -- 1645
			local _exp_0 = Path:getExt(file) -- 1646
			if "tl" == _exp_0 then -- 1646
				if ("vs" == ext) then -- 1646
					Content:remove(Path(parent, file)) -- 1647
				end -- 1646
			elseif "lua" == _exp_0 then -- 1648
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1648
					Content:remove(Path(parent, file)) -- 1649
				end -- 1648
			end -- 1646
		end -- 1645
	end -- 1644
	if Content:remove(path) then -- 1650
		if projectRoot then -- 1651
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1652
		end -- 1651
		return true -- 1653
	end -- 1650
	return false -- 1654
end -- 1637
local moveAsset -- 1656
moveAsset = function(old, new) -- 1656
	if not (Content:exist(old) and not Content:exist(new)) then -- 1657
		return false -- 1657
	end -- 1657
	local renamedDir = Content:isdir(old) -- 1658
	local parent = Path:getPath(new) -- 1659
	local files = Content:getFiles(parent) -- 1660
	if renamedDir then -- 1661
		local name = Path:getFilename(new):lower() -- 1662
		for _index_0 = 1, #files do -- 1663
			local file = files[_index_0] -- 1663
			if name == Path:getFilename(file):lower() then -- 1664
				return false -- 1665
			end -- 1664
		end -- 1663
	else -- 1667
		local name = Path:getName(new):lower() -- 1667
		local ext = Path:getExt(new) -- 1668
		for _index_0 = 1, #files do -- 1669
			local file = files[_index_0] -- 1669
			if name == Path:getName(file):lower() then -- 1670
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1671
					goto _continue_0 -- 1672
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1673
					goto _continue_0 -- 1674
				end -- 1671
				return false -- 1675
			end -- 1670
			::_continue_0:: -- 1670
		end -- 1669
	end -- 1661
	if not Content:move(old, new) then -- 1676
		return false -- 1676
	end -- 1676
	if renamedDir then -- 1677
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1678
	end -- 1677
	local newParent = Path:getPath(new) -- 1679
	parent = Path:getPath(old) -- 1680
	files = Content:getFiles(parent) -- 1681
	local newName = Path:getName(new) -- 1682
	local oldName = Path:getName(old) -- 1683
	local name = oldName:lower() -- 1684
	local ext = Path:getExt(old) -- 1685
	for _index_0 = 1, #files do -- 1686
		local file = files[_index_0] -- 1686
		if name == Path:getName(file):lower() then -- 1687
			local _exp_0 = Path:getExt(file) -- 1688
			if "tl" == _exp_0 then -- 1688
				if ("vs" == ext) then -- 1688
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1689
				end -- 1688
			elseif "lua" == _exp_0 then -- 1690
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1690
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1691
				end -- 1690
			end -- 1688
		end -- 1687
	end -- 1686
	return true -- 1692
end -- 1656
HttpServer:post("/delete", function(req) -- 1694
	do -- 1695
		local _type_0 = type(req) -- 1695
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1695
		if _tab_0 then -- 1695
			local path -- 1695
			do -- 1695
				local _obj_0 = req.body -- 1695
				local _type_1 = type(_obj_0) -- 1695
				if "table" == _type_1 or "userdata" == _type_1 then -- 1695
					path = _obj_0.path -- 1695
				end -- 1695
			end -- 1695
			if path ~= nil then -- 1695
				if deleteAsset(path) then -- 1696
					return { -- 1696
						success = true -- 1696
					} -- 1696
				end -- 1696
			end -- 1695
		end -- 1695
	end -- 1695
	return { -- 1694
		success = false -- 1694
	} -- 1694
end) -- 1694
HttpServer:post("/rename", function(req) -- 1698
	do -- 1699
		local _type_0 = type(req) -- 1699
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1699
		if _tab_0 then -- 1699
			local old -- 1699
			do -- 1699
				local _obj_0 = req.body -- 1699
				local _type_1 = type(_obj_0) -- 1699
				if "table" == _type_1 or "userdata" == _type_1 then -- 1699
					old = _obj_0.old -- 1699
				end -- 1699
			end -- 1699
			local new -- 1699
			do -- 1699
				local _obj_0 = req.body -- 1699
				local _type_1 = type(_obj_0) -- 1699
				if "table" == _type_1 or "userdata" == _type_1 then -- 1699
					new = _obj_0.new -- 1699
				end -- 1699
			end -- 1699
			if old ~= nil and new ~= nil then -- 1699
				if moveAsset(old, new) then -- 1700
					return { -- 1700
						success = true -- 1700
					} -- 1700
				end -- 1700
			end -- 1699
		end -- 1699
	end -- 1699
	return { -- 1698
		success = false -- 1698
	} -- 1698
end) -- 1698
local normalizeAssetPaths -- 1702
normalizeAssetPaths = function(paths) -- 1702
	if not (type(paths) == "table") then -- 1703
		return nil -- 1703
	end -- 1703
	local unique = { } -- 1704
	local candidates = { } -- 1705
	for _index_0 = 1, #paths do -- 1706
		local path = paths[_index_0] -- 1706
		if not (type(path) == "string") then -- 1707
			return nil -- 1707
		end -- 1707
		local relative = relativeToRoot(path, Content.writablePath) -- 1708
		if relative == nil or relative == "" or not Content:exist(path) then -- 1709
			return nil -- 1709
		end -- 1709
		if not unique[path] then -- 1710
			unique[path] = true -- 1711
			candidates[#candidates + 1] = path -- 1712
		end -- 1710
	end -- 1706
	table.sort(candidates, function(a, b) -- 1713
		return #a < #b -- 1713
	end) -- 1713
	local result = { } -- 1714
	for _index_0 = 1, #candidates do -- 1715
		local path = candidates[_index_0] -- 1715
		local contained = false -- 1716
		for _index_1 = 1, #result do -- 1717
			local parent = result[_index_1] -- 1717
			if relativeToRoot(path, parent) ~= nil then -- 1718
				contained = true -- 1719
				break -- 1720
			end -- 1718
		end -- 1717
		if not contained then -- 1721
			result[#result + 1] = path -- 1721
		end -- 1721
	end -- 1715
	return result -- 1722
end -- 1702
HttpServer:postSchedule("/assets/batch", function(req) -- 1724
	do -- 1725
		local _type_0 = type(req) -- 1725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1725
		if _tab_0 then -- 1725
			local operation -- 1725
			do -- 1725
				local _obj_0 = req.body -- 1725
				local _type_1 = type(_obj_0) -- 1725
				if "table" == _type_1 or "userdata" == _type_1 then -- 1725
					operation = _obj_0.operation -- 1725
				end -- 1725
			end -- 1725
			local sources -- 1725
			do -- 1725
				local _obj_0 = req.body -- 1725
				local _type_1 = type(_obj_0) -- 1725
				if "table" == _type_1 or "userdata" == _type_1 then -- 1725
					sources = _obj_0.sources -- 1725
				end -- 1725
			end -- 1725
			if operation ~= nil and sources ~= nil then -- 1725
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1726
					return { -- 1726
						success = false, -- 1726
						message = "invalid operation" -- 1726
					} -- 1726
				end -- 1726
				sources = normalizeAssetPaths(sources) -- 1727
				if not (sources and #sources > 0) then -- 1728
					return { -- 1728
						success = false, -- 1728
						message = "invalid sources" -- 1728
					} -- 1728
				end -- 1728
				local target = req.body.target -- 1729
				local destinations = { } -- 1730
				if operation ~= "delete" then -- 1731
					if not (type(target) == "string") then -- 1732
						return { -- 1732
							success = false, -- 1732
							message = "invalid target" -- 1732
						} -- 1732
					end -- 1732
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1733
					if targetRelative == nil then -- 1734
						return { -- 1734
							success = false, -- 1734
							message = "invalid target" -- 1734
						} -- 1734
					end -- 1734
					if not (Content:exist(target) and Content:isdir(target)) then -- 1735
						return { -- 1735
							success = false, -- 1735
							message = "invalid target" -- 1735
						} -- 1735
					end -- 1735
					for _index_0 = 1, #sources do -- 1736
						local source = sources[_index_0] -- 1736
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1737
							return { -- 1738
								success = false, -- 1738
								message = "target inside source" -- 1738
							} -- 1738
						end -- 1737
						local destination = Path(target, Path:getFilename(source)) -- 1739
						if Content:exist(destination) then -- 1740
							return { -- 1740
								success = false, -- 1740
								message = "target existed" -- 1740
							} -- 1740
						end -- 1740
						if destinations[destination] then -- 1741
							return { -- 1741
								success = false, -- 1741
								message = "duplicate target" -- 1741
							} -- 1741
						end -- 1741
						destinations[destination] = true -- 1742
					end -- 1736
				end -- 1731
				local changes = { } -- 1743
				local affectedSet = { } -- 1744
				local affectedDirectories = { } -- 1745
				local addAffected -- 1746
				addAffected = function(dir) -- 1746
					if affectedSet[dir] then -- 1747
						return -- 1747
					end -- 1747
					affectedSet[dir] = true -- 1748
					affectedDirectories[#affectedDirectories + 1] = dir -- 1749
				end -- 1746
				if operation ~= "delete" then -- 1750
					addAffected(target) -- 1750
				end -- 1750
				for _index_0 = 1, #sources do -- 1751
					local source = sources[_index_0] -- 1751
					addAffected(Path:getPath(source)) -- 1752
					if operation == "delete" then -- 1753
						if not deleteAsset(source) then -- 1754
							return { -- 1754
								success = false, -- 1754
								message = "delete failed", -- 1754
								changes = changes, -- 1754
								affectedDirectories = affectedDirectories -- 1754
							} -- 1754
						end -- 1754
						changes[#changes + 1] = { -- 1755
							old = source -- 1755
						} -- 1755
					else -- 1757
						local destination = Path(target, Path:getFilename(source)) -- 1757
						local ok -- 1758
						if operation == "copy" then -- 1758
							ok = Content:copyAsync(source, destination) -- 1759
						else -- 1761
							ok = moveAsset(source, destination) -- 1761
						end -- 1758
						if not ok then -- 1762
							return { -- 1762
								success = false, -- 1762
								message = operation .. " failed", -- 1762
								changes = changes, -- 1762
								affectedDirectories = affectedDirectories -- 1762
							} -- 1762
						end -- 1762
						changes[#changes + 1] = { -- 1763
							old = source, -- 1763
							new = destination -- 1763
						} -- 1763
					end -- 1753
				end -- 1751
				return { -- 1764
					success = true, -- 1764
					changes = changes, -- 1764
					affectedDirectories = affectedDirectories -- 1764
				} -- 1764
			end -- 1725
		end -- 1725
	end -- 1725
	return { -- 1724
		success = false, -- 1724
		message = "invalid request" -- 1724
	} -- 1724
end) -- 1724
local withProjectSearchPaths -- 1766
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1766
	local fallbackPaths = { } -- 1767
	local addFallback -- 1768
	addFallback = function(dir) -- 1768
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1768
			fallbackPaths[#fallbackPaths + 1] = dir -- 1768
		end -- 1768
	end -- 1768
	if projectRoot and projectRoot ~= "" then -- 1769
		addFallback(Path(projectRoot, "Script")) -- 1770
		addFallback(projectRoot) -- 1771
	end -- 1769
	if projFile then -- 1772
		local projDir = getProjectDirFromFile(projFile) -- 1773
		if projDir then -- 1773
			addFallback(Path(projDir, "Script")) -- 1774
			addFallback(projDir) -- 1775
		else -- 1777
			addFallback(Path:getPath(projFile)) -- 1777
		end -- 1773
	end -- 1772
	if not (#fallbackPaths > 0) then -- 1778
		return fn() -- 1778
	end -- 1778
	local searchPaths = Content.searchPaths -- 1779
	for _index_0 = 1, #fallbackPaths do -- 1780
		local dir = fallbackPaths[_index_0] -- 1780
		Content:addSearchPath(dir) -- 1780
	end -- 1780
	local _ <close> = setmetatable({ }, { -- 1781
		__close = function() -- 1781
			Content.searchPaths = searchPaths -- 1781
		end -- 1781
	}) -- 1781
	return fn() -- 1782
end -- 1766
HttpServer:post("/exist", function(req) -- 1783
	do -- 1784
		local _type_0 = type(req) -- 1784
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1784
		if _tab_0 then -- 1784
			local file -- 1784
			do -- 1784
				local _obj_0 = req.body -- 1784
				local _type_1 = type(_obj_0) -- 1784
				if "table" == _type_1 or "userdata" == _type_1 then -- 1784
					file = _obj_0.file -- 1784
				end -- 1784
			end -- 1784
			if file ~= nil then -- 1784
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1785
					return { -- 1786
						success = Content:exist(file) -- 1786
					} -- 1786
				end) -- 1785
			end -- 1784
		end -- 1784
	end -- 1784
	return { -- 1783
		success = false -- 1783
	} -- 1783
end) -- 1783
HttpServer:postSchedule("/read", function(req) -- 1787
	do -- 1788
		local _type_0 = type(req) -- 1788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1788
		if _tab_0 then -- 1788
			local path -- 1788
			do -- 1788
				local _obj_0 = req.body -- 1788
				local _type_1 = type(_obj_0) -- 1788
				if "table" == _type_1 or "userdata" == _type_1 then -- 1788
					path = _obj_0.path -- 1788
				end -- 1788
			end -- 1788
			if path ~= nil then -- 1788
				local readFile -- 1789
				readFile = function() -- 1789
					if Content:exist(path) and not Content:isdir(path) then -- 1790
						local content = Content:loadAsync(path) -- 1791
						if content then -- 1791
							return { -- 1792
								content = content, -- 1792
								success = true, -- 1792
								fullPath = Content:getFullPath(path) -- 1792
							} -- 1792
						end -- 1791
					end -- 1790
					return nil -- 1789
				end -- 1789
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1793
				if result then -- 1793
					return result -- 1793
				end -- 1793
			end -- 1788
		end -- 1788
	end -- 1788
	return { -- 1787
		success = false -- 1787
	} -- 1787
end) -- 1787
local agentDocLanguage -- 1795
agentDocLanguage = function(language) -- 1795
	if language == "zh-Hans" then -- 1796
		return "zh" -- 1796
	else -- 1796
		return "en" -- 1796
	end -- 1796
end -- 1795
HttpServer:postSchedule("/doc/search", function(req) -- 1798
	local body = req.body or { } -- 1799
	local language = body.docLanguage -- 1800
	if not (("en" == language or "zh-Hans" == language)) then -- 1801
		return { -- 1801
			success = false, -- 1801
			message = "unsupported doc language" -- 1801
		} -- 1801
	end -- 1801
	local docType = body.docType -- 1802
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1803
		return { -- 1803
			success = false, -- 1803
			message = "unsupported doc type" -- 1803
		} -- 1803
	end -- 1803
	local codeLanguage = body.programmingLanguage -- 1804
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1805
		return { -- 1805
			success = false, -- 1805
			message = "unsupported programming language" -- 1805
		} -- 1805
	end -- 1805
	if not body.pattern then -- 1806
		return { -- 1806
			success = false, -- 1806
			message = "missing pattern" -- 1806
		} -- 1806
	end -- 1806
	local result = nil -- 1807
	AgentTools.searchDoraDocHttp({ -- 1809
		pattern = body.pattern, -- 1809
		docLanguage = agentDocLanguage(language), -- 1810
		docType = docType, -- 1811
		programmingLanguage = codeLanguage, -- 1812
		limit = body.limit, -- 1813
		useRegex = body.useRegex, -- 1814
		caseSensitive = body.caseSensitive, -- 1815
		includeContent = body.includeContent, -- 1816
		contentWindow = body.contentWindow -- 1817
	}, function(res) -- 1818
		result = res -- 1819
	end) -- 1808
	wait(function() -- 1820
		return result ~= nil -- 1820
	end) -- 1820
	if result and result.success then -- 1821
		result.docLanguage = language -- 1822
	end -- 1821
	if result then -- 1823
		return result -- 1824
	else -- 1826
		return { -- 1826
			success = false, -- 1826
			message = "doc search failed" -- 1826
		} -- 1826
	end -- 1823
	return { -- 1798
		success = false, -- 1798
		message = "invalid call" -- 1798
	} -- 1798
end) -- 1798
HttpServer:postSchedule("/doc/read", function(req) -- 1828
	local body = req.body or { } -- 1829
	local language = body.docLanguage -- 1830
	if not (("en" == language or "zh-Hans" == language)) then -- 1831
		return { -- 1831
			success = false, -- 1831
			message = "unsupported doc language" -- 1831
		} -- 1831
	end -- 1831
	if not body.file then -- 1832
		return { -- 1832
			success = false, -- 1832
			message = "missing file" -- 1832
		} -- 1832
	end -- 1832
	local result = AgentTools.readDoraDoc({ -- 1834
		docLanguage = agentDocLanguage(language), -- 1834
		file = body.file, -- 1835
		startLine = body.startLine, -- 1836
		endLine = body.endLine -- 1837
	}) -- 1833
	if result and result.success then -- 1838
		result.docLanguage = language -- 1839
	end -- 1838
	return result -- 1840
end) -- 1828
HttpServer:get("/read-sync", function(req) -- 1842
	do -- 1843
		local _type_0 = type(req) -- 1843
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1843
		if _tab_0 then -- 1843
			local params = req.params -- 1843
			if params ~= nil then -- 1843
				local path = params.path -- 1844
				local exts -- 1845
				if params.exts then -- 1845
					local _accum_0 = { } -- 1846
					local _len_0 = 1 -- 1846
					for ext in params.exts:gmatch("[^|]*") do -- 1846
						_accum_0[_len_0] = ext -- 1846
						_len_0 = _len_0 + 1 -- 1846
					end -- 1846
					exts = _accum_0 -- 1846
				else -- 1847
					exts = { -- 1847
						"" -- 1847
					} -- 1847
				end -- 1845
				local readFileAt -- 1848
				readFileAt = function(targetPath) -- 1848
					if Content:exist(targetPath) then -- 1849
						local content = Content:load(targetPath) -- 1850
						if content then -- 1850
							return { -- 1851
								content = content, -- 1851
								success = true, -- 1851
								fullPath = Content:getFullPath(targetPath) -- 1851
							} -- 1851
						end -- 1850
					end -- 1849
					return nil -- 1848
				end -- 1848
				local readFile -- 1852
				readFile = function(fallbackPaths) -- 1852
					for _index_0 = 1, #exts do -- 1853
						local ext = exts[_index_0] -- 1853
						local targetPath = path .. ext -- 1854
						if not Content:isAbsolutePath(targetPath) then -- 1855
							for _index_1 = 1, #fallbackPaths do -- 1856
								local fallback = fallbackPaths[_index_1] -- 1856
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1857
								if fallbackResult then -- 1857
									return fallbackResult -- 1858
								end -- 1857
							end -- 1856
						end -- 1855
						local fileResult = readFileAt(targetPath) -- 1859
						if fileResult then -- 1859
							return fileResult -- 1860
						end -- 1859
					end -- 1853
					return nil -- 1852
				end -- 1852
				local fallbackPaths = { } -- 1861
				local fallbackCandidates = { } -- 1862
				do -- 1863
					local projectRoot = req.params.projectRoot -- 1863
					if projectRoot then -- 1863
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1864
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1865
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1866
						end -- 1864
					end -- 1863
				end -- 1863
				do -- 1867
					local projFile = req.params.projFile -- 1867
					if projFile then -- 1867
						local projDir = getProjectDirFromFile(projFile) -- 1868
						if projDir then -- 1868
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1869
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1870
						else -- 1872
							projDir = Path:getPath(projFile) -- 1872
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1873
						end -- 1868
					end -- 1867
				end -- 1867
				for _index_0 = 1, #fallbackCandidates do -- 1874
					local dir = fallbackCandidates[_index_0] -- 1874
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1875
						local exists = false -- 1876
						for _index_1 = 1, #fallbackPaths do -- 1877
							local fallback = fallbackPaths[_index_1] -- 1877
							if fallback == dir then -- 1878
								exists = true -- 1879
								break -- 1880
							end -- 1878
						end -- 1877
						if not exists then -- 1881
							fallbackPaths[#fallbackPaths + 1] = dir -- 1881
						end -- 1881
					end -- 1875
				end -- 1874
				local readResult = readFile(fallbackPaths) -- 1882
				if readResult then -- 1882
					return readResult -- 1883
				end -- 1882
			end -- 1843
		end -- 1843
	end -- 1843
	return { -- 1842
		success = false -- 1842
	} -- 1842
end) -- 1842
local addGeneratedSourceHeader -- 1885
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1885
	if preserveTIC80 == nil then -- 1885
		preserveTIC80 = false -- 1885
	end -- 1885
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1886
	if preserveTIC80 then -- 1887
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1888
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1889
		end -- 1888
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1890
	end -- 1887
	return tostring(header) .. "\n" .. tostring(codes) -- 1891
end -- 1885
local compileFileAsync -- 1893
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1893
	if projectRoot == nil then -- 1893
		projectRoot = nil -- 1893
	end -- 1893
	local file = inputFile -- 1894
	local searchPath -- 1895
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1895
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1896
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1900
	elseif not Content:isAbsolutePath(inputFile) then -- 1901
		searchPath = "" -- 1902
	else -- 1903
		local dir = getProjectDirFromFile(inputFile) -- 1903
		if dir then -- 1903
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1904
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1908
		else -- 1910
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1910
			searchPath = "" -- 1913
		end -- 1903
	end -- 1895
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1914
	local yueext = yue.options.extension -- 1915
	local resultCodes = nil -- 1916
	local resultError = nil -- 1917
	do -- 1918
		local _exp_0 = Path:getExt(inputFile) -- 1918
		if yueext == _exp_0 then -- 1918
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1919
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1920
				if not codes then -- 1921
					resultError = err -- 1922
					return -- 1923
				end -- 1921
				local extraGlobal -- 1924
				if isTIC80 then -- 1924
					extraGlobal = tic80APIs -- 1924
				else -- 1924
					extraGlobal = nil -- 1924
				end -- 1924
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1925
				if not success then -- 1926
					resultError = message -- 1927
					return -- 1928
				end -- 1926
				if codes == "" then -- 1929
					resultCodes = "" -- 1930
					return nil -- 1931
				end -- 1929
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1932
				return resultCodes -- 1933
			end, function(success) -- 1920
				if not success then -- 1934
					Content:remove(outputFile) -- 1935
					if resultCodes == nil then -- 1936
						resultCodes = false -- 1937
					end -- 1936
				end -- 1934
			end) -- 1920
		elseif "tl" == _exp_0 then -- 1938
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1939
			if isTIC80 then -- 1940
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1941
			end -- 1940
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1942
			if codes then -- 1942
				if isTIC80 then -- 1943
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1944
				end -- 1943
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 1945
				Content:saveAsync(outputFile, resultCodes) -- 1946
			else -- 1948
				Content:remove(outputFile) -- 1948
				resultCodes = false -- 1949
				resultError = err -- 1950
			end -- 1942
		elseif "xml" == _exp_0 then -- 1951
			local codes, err = xml.tolua(sourceCodes) -- 1952
			if codes then -- 1952
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1953
				Content:saveAsync(outputFile, resultCodes) -- 1954
			else -- 1956
				Content:remove(outputFile) -- 1956
				resultCodes = false -- 1957
				resultError = err -- 1958
			end -- 1952
		end -- 1918
	end -- 1918
	wait(function() -- 1959
		return resultCodes ~= nil -- 1959
	end) -- 1959
	if resultCodes then -- 1960
		return resultCodes -- 1961
	else -- 1963
		return nil, resultError -- 1963
	end -- 1960
	return nil -- 1893
end -- 1893
HttpServer:postSchedule("/write", function(req) -- 1965
	do -- 1966
		local _type_0 = type(req) -- 1966
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1966
		if _tab_0 then -- 1966
			local path -- 1966
			do -- 1966
				local _obj_0 = req.body -- 1966
				local _type_1 = type(_obj_0) -- 1966
				if "table" == _type_1 or "userdata" == _type_1 then -- 1966
					path = _obj_0.path -- 1966
				end -- 1966
			end -- 1966
			local content -- 1966
			do -- 1966
				local _obj_0 = req.body -- 1966
				local _type_1 = type(_obj_0) -- 1966
				if "table" == _type_1 or "userdata" == _type_1 then -- 1966
					content = _obj_0.content -- 1966
				end -- 1966
			end -- 1966
			if path ~= nil and content ~= nil then -- 1966
				if Content:saveAsync(path, content) then -- 1967
					do -- 1968
						local _exp_0 = Path:getExt(path) -- 1968
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1968
							if '' == Path:getExt(Path:getName(path)) then -- 1969
								local resultCodes = compileFileAsync(path, content) -- 1970
								return { -- 1971
									success = true, -- 1971
									resultCodes = resultCodes -- 1971
								} -- 1971
							end -- 1969
						end -- 1968
					end -- 1968
					return { -- 1972
						success = true -- 1972
					} -- 1972
				end -- 1967
			end -- 1966
		end -- 1966
	end -- 1966
	return { -- 1965
		success = false -- 1965
	} -- 1965
end) -- 1965
local getWaProjectDirFromFile = nil -- 1974
HttpServer:postSchedule("/build", function(req) -- 1976
	do -- 1977
		local _type_0 = type(req) -- 1977
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1977
		if _tab_0 then -- 1977
			local path -- 1977
			do -- 1977
				local _obj_0 = req.body -- 1977
				local _type_1 = type(_obj_0) -- 1977
				if "table" == _type_1 or "userdata" == _type_1 then -- 1977
					path = _obj_0.path -- 1977
				end -- 1977
			end -- 1977
			if path ~= nil then -- 1977
				local projectRoot = req.body.projectRoot -- 1978
				if Content:isdir(path) then -- 1979
					local projDir = getWaProjectDirFromFile(path) -- 1980
					if projDir then -- 1980
						local message = Wasm:buildWaAsync(projDir) -- 1981
						if message == "" then -- 1982
							return { -- 1983
								success = true -- 1983
							} -- 1983
						else -- 1985
							return { -- 1985
								success = false, -- 1985
								message = message -- 1985
							} -- 1985
						end -- 1982
					end -- 1980
				end -- 1979
				local _exp_0 = Path:getExt(path) -- 1986
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1987
					if '' == Path:getExt(Path:getName(path)) then -- 1988
						local content = Content:loadAsync(path) -- 1989
						if content then -- 1989
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1990
							if resultCodes then -- 1990
								return { -- 1991
									success = true, -- 1991
									resultCodes = resultCodes -- 1991
								} -- 1991
							end -- 1990
						end -- 1989
					end -- 1988
				elseif "wa" == _exp_0 then -- 1992
					local projDir = getWaProjectDirFromFile(path) -- 1993
					if projDir then -- 1993
						local message = Wasm:buildWaAsync(projDir) -- 1994
						if message == "" then -- 1995
							return { -- 1996
								success = true -- 1996
							} -- 1996
						else -- 1998
							return { -- 1998
								success = false, -- 1998
								message = message -- 1998
							} -- 1998
						end -- 1995
					else -- 2000
						return { -- 2000
							success = false, -- 2000
							message = 'Wa file needs a project' -- 2000
						} -- 2000
					end -- 1993
				end -- 1986
			end -- 1977
		end -- 1977
	end -- 1977
	return { -- 1976
		success = false -- 1976
	} -- 1976
end) -- 1976
local extentionLevels = { -- 2003
	vs = 2, -- 2003
	bl = 2, -- 2004
	ts = 1, -- 2005
	tsx = 1, -- 2006
	tl = 1, -- 2007
	yue = 1, -- 2008
	xml = 1, -- 2009
	lua = 0 -- 2010
} -- 2002
local visitAssets -- 2012
visitAssets = function(path, workspace, builtin, recursive) -- 2012
	if recursive == nil then -- 2012
		recursive = true -- 2012
	end -- 2012
	local children = nil -- 2013
	local dirs = Content:getDirs(path) -- 2014
	for _index_0 = 1, #dirs do -- 2015
		local dir = dirs[_index_0] -- 2015
		if workspace then -- 2016
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2017
				goto _continue_0 -- 2018
			end -- 2017
		elseif dir == ".git" then -- 2019
			goto _continue_0 -- 2020
		end -- 2016
		if not children then -- 2021
			children = { } -- 2021
		end -- 2021
		local dirPath = Path(path, dir) -- 2022
		if recursive then -- 2023
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2024
		else -- 2026
			children[#children + 1] = { -- 2027
				key = dirPath, -- 2027
				dir = true, -- 2028
				title = dir, -- 2029
				builtin = builtin, -- 2030
				isLeaf = false -- 2031
			} -- 2026
		end -- 2023
		::_continue_0:: -- 2016
	end -- 2015
	local files = Content:getFiles(path) -- 2033
	local names = { } -- 2034
	for _index_0 = 1, #files do -- 2035
		local file = files[_index_0] -- 2035
		if (".DS_Store" == file) then -- 2036
			goto _continue_1 -- 2037
		end -- 2036
		local name = Path:getName(file) -- 2038
		local ext = names[name] -- 2039
		if ext then -- 2039
			local lv1 -- 2040
			do -- 2040
				local _exp_0 = extentionLevels[ext] -- 2040
				if _exp_0 ~= nil then -- 2040
					lv1 = _exp_0 -- 2040
				else -- 2040
					lv1 = -1 -- 2040
				end -- 2040
			end -- 2040
			ext = Path:getExt(file) -- 2041
			local lv2 -- 2042
			do -- 2042
				local _exp_0 = extentionLevels[ext] -- 2042
				if _exp_0 ~= nil then -- 2042
					lv2 = _exp_0 -- 2042
				else -- 2042
					lv2 = -1 -- 2042
				end -- 2042
			end -- 2042
			if lv2 > lv1 then -- 2043
				names[name] = ext -- 2044
			elseif lv2 == lv1 then -- 2045
				names[name .. '.' .. ext] = "" -- 2046
			end -- 2043
		else -- 2048
			ext = Path:getExt(file) -- 2048
			if not extentionLevels[ext] then -- 2049
				names[file] = "" -- 2050
			else -- 2052
				names[name] = ext -- 2052
			end -- 2049
		end -- 2039
		::_continue_1:: -- 2036
	end -- 2035
	do -- 2053
		local _accum_0 = { } -- 2053
		local _len_0 = 1 -- 2053
		for name, ext in pairs(names) do -- 2053
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2053
			_len_0 = _len_0 + 1 -- 2053
		end -- 2053
		files = _accum_0 -- 2053
	end -- 2053
	for _index_0 = 1, #files do -- 2054
		local file = files[_index_0] -- 2054
		if not children then -- 2055
			children = { } -- 2055
		end -- 2055
		children[#children + 1] = { -- 2057
			key = Path(path, file), -- 2057
			dir = false, -- 2058
			title = file, -- 2059
			builtin = builtin -- 2060
		} -- 2056
	end -- 2054
	if children then -- 2062
		table.sort(children, function(a, b) -- 2063
			if a.dir == b.dir then -- 2064
				return a.title < b.title -- 2065
			else -- 2067
				return a.dir -- 2067
			end -- 2064
		end) -- 2063
	end -- 2062
	return { -- 2069
		key = path, -- 2069
		dir = true, -- 2070
		title = Path:getFilename(path), -- 2071
		builtin = builtin, -- 2072
		isLeaf = not children, -- 2073
		children = children -- 2074
	} -- 2068
end -- 2012
HttpServer:post("/assets/children", function(req) -- 2077
	do -- 2078
		local _type_0 = type(req) -- 2078
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2078
		if _tab_0 then -- 2078
			local path -- 2078
			do -- 2078
				local _obj_0 = req.body -- 2078
				local _type_1 = type(_obj_0) -- 2078
				if "table" == _type_1 or "userdata" == _type_1 then -- 2078
					path = _obj_0.path -- 2078
				end -- 2078
			end -- 2078
			if path ~= nil then -- 2078
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2079
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2080
					return { -- 2080
						success = false -- 2080
					} -- 2080
				end -- 2080
				local node = visitAssets(path, workspace, builtin, false) -- 2081
				return { -- 2082
					success = true, -- 2082
					children = node.children or { } -- 2082
				} -- 2082
			end -- 2078
		end -- 2078
	end -- 2078
	return { -- 2077
		success = false -- 2077
	} -- 2077
end) -- 2077
HttpServer:post("/assets/files", function(req) -- 2084
	do -- 2085
		local _type_0 = type(req) -- 2085
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2085
		if _tab_0 then -- 2085
			local path -- 2085
			do -- 2085
				local _obj_0 = req.body -- 2085
				local _type_1 = type(_obj_0) -- 2085
				if "table" == _type_1 or "userdata" == _type_1 then -- 2085
					path = _obj_0.path -- 2085
				end -- 2085
			end -- 2085
			if path ~= nil then -- 2085
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2086
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2087
				if not (workspace or builtin) then -- 2088
					return { -- 2088
						success = false -- 2088
					} -- 2088
				end -- 2088
				if not (Content:exist(path) and Content:isdir(path)) then -- 2089
					return { -- 2089
						success = false -- 2089
					} -- 2089
				end -- 2089
				local globs = { -- 2090
					"**", -- 2090
					"!**/.DS_Store" -- 2090
				} -- 2090
				if workspace then -- 2091
					globs = { -- 2093
						"**", -- 2093
						"!**/.DS_Store", -- 2093
						"!**/.upload/**", -- 2094
						"!**/.download/**", -- 2094
						"!**/.www/**", -- 2095
						"!**/.build/**", -- 2095
						"!**/.git/**", -- 2096
						"!**/.cache/**", -- 2096
						"!**/node_modules/**" -- 2097
					} -- 2092
				end -- 2091
				local files -- 2099
				do -- 2099
					local _accum_0 = { } -- 2099
					local _len_0 = 1 -- 2099
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2099
					for _index_0 = 1, #_list_0 do -- 2099
						local file = _list_0[_index_0] -- 2099
						_accum_0[_len_0] = Path(path, file) -- 2099
						_len_0 = _len_0 + 1 -- 2099
					end -- 2099
					files = _accum_0 -- 2099
				end -- 2099
				return { -- 2100
					success = true, -- 2100
					files = files -- 2100
				} -- 2100
			end -- 2085
		end -- 2085
	end -- 2085
	return { -- 2084
		success = false -- 2084
	} -- 2084
end) -- 2084
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2141
	local _tab_0 = { -- 2141
		{ -- 2142
			key = Path(Content.assetPath), -- 2142
			dir = true, -- 2143
			builtin = true, -- 2144
			title = zh and "内置资源" or "Built-in", -- 2145
			children = builtinChildren -- 2146
		} -- 2141
	} -- 2148
	local _obj_0 = workspace.children or { } -- 2148
	local _idx_0 = #_tab_0 + 1 -- 2148
	for _index_0 = 1, #_obj_0 do -- 2148
		local _value_0 = _obj_0[_index_0] -- 2148
		_tab_0[_idx_0] = _value_0 -- 2148
		_idx_0 = _idx_0 + 1 -- 2148
	end -- 2148
	return _tab_0 -- 2141
end -- 2141
HttpServer:post("/assets", function() -- 2102
	local Entry = require("Script.Dev.Entry") -- 2103
	local engineDev = Entry.getEngineDev() -- 2104
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2105
	local zh = (App.locale:match("^zh") ~= nil) -- 2106
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2107
	readme.title = zh and "说明文档" or "Readme" -- 2108
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2109
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2110
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2111
	tools.title = zh and "开发工具" or "Tools" -- 2112
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2113
	font.title = zh and "字体" or "Font" -- 2114
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2115
	lib.title = zh and "程序库" or "Lib" -- 2116
	if engineDev then -- 2117
		local _list_0 = lib.children -- 2118
		for _index_0 = 1, #_list_0 do -- 2118
			local child = _list_0[_index_0] -- 2118
			if not (child.title == "Dora") then -- 2119
				goto _continue_0 -- 2119
			end -- 2119
			local title = zh and "zh-Hans" or "en" -- 2120
			do -- 2121
				local _accum_0 = { } -- 2121
				local _len_0 = 1 -- 2121
				local _list_1 = child.children -- 2121
				for _index_1 = 1, #_list_1 do -- 2121
					local c = _list_1[_index_1] -- 2121
					if c.title ~= title then -- 2121
						_accum_0[_len_0] = c -- 2121
						_len_0 = _len_0 + 1 -- 2121
					end -- 2121
				end -- 2121
				child.children = _accum_0 -- 2121
			end -- 2121
			break -- 2122
			::_continue_0:: -- 2119
		end -- 2118
	else -- 2124
		local _accum_0 = { } -- 2124
		local _len_0 = 1 -- 2124
		local _list_0 = lib.children -- 2124
		for _index_0 = 1, #_list_0 do -- 2124
			local child = _list_0[_index_0] -- 2124
			if child.title ~= "Dora" then -- 2124
				_accum_0[_len_0] = child -- 2124
				_len_0 = _len_0 + 1 -- 2124
			end -- 2124
		end -- 2124
		lib.children = _accum_0 -- 2124
	end -- 2117
	local builtinChildren = { -- 2125
		readme, -- 2125
		apiDoc, -- 2125
		tools, -- 2125
		font, -- 2125
		lib -- 2125
	} -- 2125
	if engineDev then -- 2126
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2127
		do -- 2128
			local _obj_0 = dev.children -- 2128
			_obj_0[#_obj_0 + 1] = { -- 2129
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2129
				dir = false, -- 2130
				builtin = true, -- 2131
				title = "init.yue" -- 2132
			} -- 2128
		end -- 2128
		builtinChildren[#builtinChildren + 1] = dev -- 2134
	end -- 2126
	return { -- 2136
		key = Content.writablePath, -- 2136
		dir = true, -- 2137
		root = true, -- 2138
		title = "Assets", -- 2139
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2140
	} -- 2135
end) -- 2102
HttpServer:post("/entry/list", function(req) -- 2152
	local Entry = require("Script.Dev.Entry") -- 2153
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2154
	res.success = true -- 2155
	return res -- 2156
end) -- 2152
HttpServer:post("/run/status", function() -- 2158
	local Entry = require("Script.Dev.Entry") -- 2159
	return Entry.getCurrentEntryStatus() -- 2160
end) -- 2158
HttpServer:postSchedule("/run", function(req) -- 2162
	do -- 2163
		local _type_0 = type(req) -- 2163
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2163
		if _tab_0 then -- 2163
			local file -- 2163
			do -- 2163
				local _obj_0 = req.body -- 2163
				local _type_1 = type(_obj_0) -- 2163
				if "table" == _type_1 or "userdata" == _type_1 then -- 2163
					file = _obj_0.file -- 2163
				end -- 2163
			end -- 2163
			local asProj -- 2163
			do -- 2163
				local _obj_0 = req.body -- 2163
				local _type_1 = type(_obj_0) -- 2163
				if "table" == _type_1 or "userdata" == _type_1 then -- 2163
					asProj = _obj_0.asProj -- 2163
				end -- 2163
			end -- 2163
			if file ~= nil and asProj ~= nil then -- 2163
				if not Content:isAbsolutePath(file) then -- 2164
					local devFile = Path(Content.writablePath, file) -- 2165
					if Content:exist(devFile) then -- 2166
						file = devFile -- 2166
					end -- 2166
				end -- 2164
				local Entry = require("Script.Dev.Entry") -- 2167
				local workDir -- 2168
				if asProj then -- 2169
					local projectRoot = req.body.projectRoot -- 2170
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2171
						workDir = projectRoot -- 2172
					else -- 2174
						workDir = getProjectDirFromFile(file) -- 2174
					end -- 2171
					if workDir then -- 2175
						Entry.allClear() -- 2176
						local target = Path(workDir, "init") -- 2177
						local success, err = Entry.enterEntryAsync({ -- 2178
							entryName = "Project", -- 2178
							fileName = target, -- 2178
							workDir = workDir, -- 2178
							projectRoot = workDir, -- 2178
							runKind = "project" -- 2178
						}) -- 2178
						target = Path:getName(Path:getPath(target)) -- 2179
						return { -- 2180
							success = success, -- 2180
							target = target, -- 2180
							err = err -- 2180
						} -- 2180
					end -- 2175
				else -- 2182
					workDir = getProjectDirFromFile(file) -- 2182
					if not workDir and Path:getExt(file) == "wasm" then -- 2183
						local parent = Path:getPath(file) -- 2184
						if Content:exist(Path(parent, "wa.mod")) then -- 2185
							workDir = parent -- 2186
						end -- 2185
					end -- 2183
				end -- 2169
				Entry.allClear() -- 2187
				file = Path:replaceExt(file, "") -- 2188
				local entry = { -- 2190
					entryName = Path:getName(file), -- 2190
					fileName = file, -- 2191
					runKind = "file" -- 2192
				} -- 2189
				if workDir then -- 2193
					entry.workDir = workDir -- 2194
					entry.projectRoot = workDir -- 2195
				end -- 2193
				local success, err = Entry.enterEntryAsync(entry) -- 2196
				return { -- 2197
					success = success, -- 2197
					err = err -- 2197
				} -- 2197
			end -- 2163
		end -- 2163
	end -- 2163
	return { -- 2162
		success = false -- 2162
	} -- 2162
end) -- 2162
HttpServer:postSchedule("/stop", function() -- 2199
	local Entry = require("Script.Dev.Entry") -- 2200
	return { -- 2201
		success = Entry.stop() -- 2201
	} -- 2201
end) -- 2199
local minifyAsync -- 2203
minifyAsync = function(sourcePath, minifyPath) -- 2203
	if not Content:exist(sourcePath) then -- 2204
		return -- 2204
	end -- 2204
	local Entry = require("Script.Dev.Entry") -- 2205
	local errors = { } -- 2206
	local files = Entry.getAllFiles(sourcePath, { -- 2207
		"lua" -- 2207
	}, true) -- 2207
	do -- 2208
		local _accum_0 = { } -- 2208
		local _len_0 = 1 -- 2208
		for _index_0 = 1, #files do -- 2208
			local file = files[_index_0] -- 2208
			if file:sub(1, 1) ~= '.' then -- 2208
				_accum_0[_len_0] = file -- 2208
				_len_0 = _len_0 + 1 -- 2208
			end -- 2208
		end -- 2208
		files = _accum_0 -- 2208
	end -- 2208
	local paths -- 2209
	do -- 2209
		local _tbl_0 = { } -- 2209
		for _index_0 = 1, #files do -- 2209
			local file = files[_index_0] -- 2209
			_tbl_0[Path:getPath(file)] = true -- 2209
		end -- 2209
		paths = _tbl_0 -- 2209
	end -- 2209
	for path in pairs(paths) do -- 2210
		Content:mkdir(Path(minifyPath, path)) -- 2210
	end -- 2210
	local _ <close> = setmetatable({ }, { -- 2211
		__close = function() -- 2211
			package.loaded["luaminify.FormatMini"] = nil -- 2212
			package.loaded["luaminify.ParseLua"] = nil -- 2213
			package.loaded["luaminify.Scope"] = nil -- 2214
			package.loaded["luaminify.Util"] = nil -- 2215
		end -- 2211
	}) -- 2211
	local FormatMini -- 2216
	do -- 2216
		local _obj_0 = require("luaminify") -- 2216
		FormatMini = _obj_0.FormatMini -- 2216
	end -- 2216
	local fileCount = #files -- 2217
	local count = 0 -- 2218
	for _index_0 = 1, #files do -- 2219
		local file = files[_index_0] -- 2219
		thread(function() -- 2220
			local _ <close> = setmetatable({ }, { -- 2221
				__close = function() -- 2221
					count = count + 1 -- 2221
				end -- 2221
			}) -- 2221
			local input = Path(sourcePath, file) -- 2222
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2223
			if Content:exist(input) then -- 2224
				local sourceCodes = Content:loadAsync(input) -- 2225
				local res, err = FormatMini(sourceCodes) -- 2226
				if res then -- 2227
					Content:saveAsync(output, res) -- 2228
					return print("Minify " .. tostring(file)) -- 2229
				else -- 2231
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2231
				end -- 2227
			else -- 2233
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2233
			end -- 2224
		end) -- 2220
		sleep() -- 2234
	end -- 2219
	wait(function() -- 2235
		return count == fileCount -- 2235
	end) -- 2235
	if #errors > 0 then -- 2236
		print(table.concat(errors, '\n')) -- 2237
	end -- 2236
	print("Obfuscation done.") -- 2238
	return files -- 2239
end -- 2203
local zipping = false -- 2241
HttpServer:postSchedule("/zip", function(req) -- 2243
	do -- 2244
		local _type_0 = type(req) -- 2244
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2244
		if _tab_0 then -- 2244
			local path -- 2244
			do -- 2244
				local _obj_0 = req.body -- 2244
				local _type_1 = type(_obj_0) -- 2244
				if "table" == _type_1 or "userdata" == _type_1 then -- 2244
					path = _obj_0.path -- 2244
				end -- 2244
			end -- 2244
			local zipFile -- 2244
			do -- 2244
				local _obj_0 = req.body -- 2244
				local _type_1 = type(_obj_0) -- 2244
				if "table" == _type_1 or "userdata" == _type_1 then -- 2244
					zipFile = _obj_0.zipFile -- 2244
				end -- 2244
			end -- 2244
			local obfuscated -- 2244
			do -- 2244
				local _obj_0 = req.body -- 2244
				local _type_1 = type(_obj_0) -- 2244
				if "table" == _type_1 or "userdata" == _type_1 then -- 2244
					obfuscated = _obj_0.obfuscated -- 2244
				end -- 2244
			end -- 2244
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2244
				if zipping then -- 2245
					goto failed -- 2245
				end -- 2245
				zipping = true -- 2246
				local _ <close> = setmetatable({ }, { -- 2247
					__close = function() -- 2247
						zipping = false -- 2247
					end -- 2247
				}) -- 2247
				if not Content:exist(path) then -- 2248
					goto failed -- 2248
				end -- 2248
				Content:mkdir(Path:getPath(zipFile)) -- 2249
				if obfuscated then -- 2250
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2251
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2252
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2253
					Content:remove(scriptPath) -- 2254
					Content:remove(obfuscatedPath) -- 2255
					Content:remove(tempPath) -- 2256
					Content:mkdir(scriptPath) -- 2257
					Content:mkdir(obfuscatedPath) -- 2258
					Content:mkdir(tempPath) -- 2259
					if not Content:copyAsync(path, tempPath) then -- 2260
						goto failed -- 2260
					end -- 2260
					local Entry = require("Script.Dev.Entry") -- 2261
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2262
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2263
						"tl", -- 2263
						"yue", -- 2263
						"lua", -- 2263
						"ts", -- 2263
						"tsx", -- 2263
						"vs", -- 2263
						"bl", -- 2263
						"xml", -- 2263
						"wa", -- 2263
						"mod" -- 2263
					}, true) -- 2263
					for _index_0 = 1, #scriptFiles do -- 2264
						local file = scriptFiles[_index_0] -- 2264
						Content:remove(Path(tempPath, file)) -- 2265
					end -- 2264
					for _index_0 = 1, #luaFiles do -- 2266
						local file = luaFiles[_index_0] -- 2266
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2267
					end -- 2266
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2268
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2269
					end) then -- 2268
						goto failed -- 2268
					end -- 2268
					return { -- 2270
						success = true -- 2270
					} -- 2270
				else -- 2272
					return { -- 2272
						success = Content:zipAsync(path, zipFile, function(file) -- 2272
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2273
						end) -- 2272
					} -- 2272
				end -- 2250
			end -- 2244
		end -- 2244
	end -- 2244
	::failed:: -- 2274
	return { -- 2243
		success = false -- 2243
	} -- 2243
end) -- 2243
HttpServer:postSchedule("/unzip", function(req) -- 2276
	do -- 2277
		local _type_0 = type(req) -- 2277
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2277
		if _tab_0 then -- 2277
			local zipFile -- 2277
			do -- 2277
				local _obj_0 = req.body -- 2277
				local _type_1 = type(_obj_0) -- 2277
				if "table" == _type_1 or "userdata" == _type_1 then -- 2277
					zipFile = _obj_0.zipFile -- 2277
				end -- 2277
			end -- 2277
			local path -- 2277
			do -- 2277
				local _obj_0 = req.body -- 2277
				local _type_1 = type(_obj_0) -- 2277
				if "table" == _type_1 or "userdata" == _type_1 then -- 2277
					path = _obj_0.path -- 2277
				end -- 2277
			end -- 2277
			if zipFile ~= nil and path ~= nil then -- 2277
				return { -- 2278
					success = Content:unzipAsync(zipFile, path, function(file) -- 2278
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2279
					end) -- 2278
				} -- 2278
			end -- 2277
		end -- 2277
	end -- 2277
	return { -- 2276
		success = false -- 2276
	} -- 2276
end) -- 2276
HttpServer:post("/editing-info", function(req) -- 2281
	local Entry = require("Script.Dev.Entry") -- 2282
	local config = Entry.getConfig() -- 2283
	local _type_0 = type(req) -- 2284
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2284
	local _match_0 = false -- 2284
	if _tab_0 then -- 2284
		local editingInfo -- 2284
		do -- 2284
			local _obj_0 = req.body -- 2284
			local _type_1 = type(_obj_0) -- 2284
			if "table" == _type_1 or "userdata" == _type_1 then -- 2284
				editingInfo = _obj_0.editingInfo -- 2284
			end -- 2284
		end -- 2284
		if editingInfo ~= nil then -- 2284
			_match_0 = true -- 2284
			config.editingInfo = editingInfo -- 2285
			return { -- 2286
				success = true -- 2286
			} -- 2286
		end -- 2284
	end -- 2284
	if not _match_0 then -- 2284
		if not (config.editingInfo ~= nil) then -- 2288
			local folder -- 2289
			if App.locale:match('^zh') then -- 2289
				folder = 'zh-Hans' -- 2289
			else -- 2289
				folder = 'en' -- 2289
			end -- 2289
			config.editingInfo = json.encode({ -- 2291
				index = 0, -- 2291
				files = { -- 2293
					{ -- 2294
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2294
						title = "welcome.md" -- 2295
					} -- 2293
				} -- 2292
			}) -- 2290
		end -- 2288
		return { -- 2299
			success = true, -- 2299
			editingInfo = config.editingInfo -- 2299
		} -- 2299
	end -- 2284
end) -- 2281
HttpServer:post("/command", function(req) -- 2301
	do -- 2302
		local _type_0 = type(req) -- 2302
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2302
		if _tab_0 then -- 2302
			local code -- 2302
			do -- 2302
				local _obj_0 = req.body -- 2302
				local _type_1 = type(_obj_0) -- 2302
				if "table" == _type_1 or "userdata" == _type_1 then -- 2302
					code = _obj_0.code -- 2302
				end -- 2302
			end -- 2302
			local log -- 2302
			do -- 2302
				local _obj_0 = req.body -- 2302
				local _type_1 = type(_obj_0) -- 2302
				if "table" == _type_1 or "userdata" == _type_1 then -- 2302
					log = _obj_0.log -- 2302
				end -- 2302
			end -- 2302
			if code ~= nil and log ~= nil then -- 2302
				emit("AppCommand", code, log) -- 2303
				return { -- 2304
					success = true -- 2304
				} -- 2304
			end -- 2302
		end -- 2302
	end -- 2302
	return { -- 2301
		success = false -- 2301
	} -- 2301
end) -- 2301
HttpServer:post("/log/save", function() -- 2306
	local folder = ".download" -- 2307
	local fullLogFile = "dora_full_logs.txt" -- 2308
	local fullFolder = Path(Content.writablePath, folder) -- 2309
	Content:mkdir(fullFolder) -- 2310
	local logPath = Path(fullFolder, fullLogFile) -- 2311
	if App:saveLog(logPath) then -- 2312
		return { -- 2313
			success = true, -- 2313
			path = Path(folder, fullLogFile) -- 2313
		} -- 2313
	end -- 2312
	return { -- 2306
		success = false -- 2306
	} -- 2306
end) -- 2306
local tailLines -- 2315
tailLines = function(text, count) -- 2315
	local lines = { } -- 2316
	text = text:gsub("\r\n", "\n") -- 2317
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2318
		lines[#lines + 1] = line -- 2319
	end -- 2318
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2320
		table.remove(lines) -- 2321
	end -- 2320
	local start = math.max(1, #lines - count + 1) -- 2322
	local out = { } -- 2323
	for i = start, #lines do -- 2324
		out[#out + 1] = lines[i] -- 2325
	end -- 2324
	return table.concat(out, "\n") -- 2326
end -- 2315
HttpServer:post("/log", function(req) -- 2328
	local count = 100 -- 2329
	if req and req.body and req.body.count ~= nil then -- 2330
		count = req.body.count -- 2331
	end -- 2330
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2332
		return { -- 2333
			success = false, -- 2333
			message = "count must be a positive integer" -- 2333
		} -- 2333
	end -- 2332
	local folder = ".download" -- 2334
	local fullLogFile = "dora_full_logs.txt" -- 2335
	local fullFolder = Path(Content.writablePath, folder) -- 2336
	Content:mkdir(fullFolder) -- 2337
	local logPath = Path(fullFolder, fullLogFile) -- 2338
	if App:saveLog(logPath) then -- 2339
		local text = Content:load(logPath) -- 2340
		if text then -- 2341
			return { -- 2342
				success = true, -- 2342
				log = tailLines(text, count) -- 2342
			} -- 2342
		else -- 2344
			return { -- 2344
				success = false, -- 2344
				message = "failed to read log" -- 2344
			} -- 2344
		end -- 2341
	else -- 2346
		return { -- 2346
			success = false, -- 2346
			message = "failed to save log" -- 2346
		} -- 2346
	end -- 2339
	return { -- 2328
		success = false -- 2328
	} -- 2328
end) -- 2328
HttpServer:post("/yarn/check", function(req) -- 2348
	local yarncompile = require("yarncompile") -- 2349
	do -- 2350
		local _type_0 = type(req) -- 2350
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2350
		if _tab_0 then -- 2350
			local code -- 2350
			do -- 2350
				local _obj_0 = req.body -- 2350
				local _type_1 = type(_obj_0) -- 2350
				if "table" == _type_1 or "userdata" == _type_1 then -- 2350
					code = _obj_0.code -- 2350
				end -- 2350
			end -- 2350
			if code ~= nil then -- 2350
				local jsonObject = json.decode(code) -- 2351
				if jsonObject then -- 2351
					local errors = { } -- 2352
					local _list_0 = jsonObject.nodes -- 2353
					for _index_0 = 1, #_list_0 do -- 2353
						local node = _list_0[_index_0] -- 2353
						local title, body = node.title, node.body -- 2354
						local luaCode, err = yarncompile(body) -- 2355
						if not luaCode then -- 2355
							errors[#errors + 1] = title .. ":" .. err -- 2356
						end -- 2355
					end -- 2353
					return { -- 2357
						success = true, -- 2357
						syntaxError = table.concat(errors, "\n\n") -- 2357
					} -- 2357
				end -- 2351
			end -- 2350
		end -- 2350
	end -- 2350
	return { -- 2348
		success = false -- 2348
	} -- 2348
end) -- 2348
HttpServer:post("/yarn/check-file", function(req) -- 2359
	local yarncompile = require("yarncompile") -- 2360
	do -- 2361
		local _type_0 = type(req) -- 2361
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2361
		if _tab_0 then -- 2361
			local code -- 2361
			do -- 2361
				local _obj_0 = req.body -- 2361
				local _type_1 = type(_obj_0) -- 2361
				if "table" == _type_1 or "userdata" == _type_1 then -- 2361
					code = _obj_0.code -- 2361
				end -- 2361
			end -- 2361
			if code ~= nil then -- 2361
				local res, _, err = yarncompile(code, true) -- 2362
				if not res then -- 2362
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2363
					return { -- 2364
						success = false, -- 2364
						message = message, -- 2364
						line = line, -- 2364
						column = column, -- 2364
						node = node -- 2364
					} -- 2364
				end -- 2362
			end -- 2361
		end -- 2361
	end -- 2361
	return { -- 2359
		success = true -- 2359
	} -- 2359
end) -- 2359
getWaProjectDirFromFile = function(file) -- 2366
	local current -- 2367
	if Content:isdir(file) then -- 2367
		current = file -- 2367
	else -- 2367
		current = Path:getPath(file) -- 2367
	end -- 2367
	if current == "" then -- 2368
		return nil -- 2368
	end -- 2368
	repeat -- 2369
		local modPath = Path(current, "wa.mod") -- 2370
		if Content:exist(modPath) then -- 2371
			return current, modPath -- 2372
		end -- 2371
		local parent = Path:getPath(current) -- 2373
		if parent == "" or parent == current then -- 2374
			break -- 2374
		end -- 2374
		current = parent -- 2375
	until false -- 2369
	return nil -- 2377
end -- 2366
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2379
	do -- 2380
		local _type_0 = type(req) -- 2380
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2380
		if _tab_0 then -- 2380
			local path -- 2380
			do -- 2380
				local _obj_0 = req.body -- 2380
				local _type_1 = type(_obj_0) -- 2380
				if "table" == _type_1 or "userdata" == _type_1 then -- 2380
					path = _obj_0.path -- 2380
				end -- 2380
			end -- 2380
			if path ~= nil then -- 2380
				local projDir = getWaProjectDirFromFile(path) -- 2381
				if projDir then -- 2381
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2382
					if not Content:exist(sourceDoraPath) then -- 2383
						return { -- 2384
							success = false, -- 2384
							message = "missing dora template" -- 2384
						} -- 2384
					end -- 2383
					local targetVendorPath = Path(projDir, "vendor") -- 2385
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2386
					if not Content:exist(targetVendorPath) then -- 2387
						if not Content:mkdir(targetVendorPath) then -- 2388
							return { -- 2389
								success = false, -- 2389
								message = "failed to create vendor folder" -- 2389
							} -- 2389
						end -- 2388
					elseif not Content:isdir(targetVendorPath) then -- 2390
						return { -- 2391
							success = false, -- 2391
							message = "vendor path is not a folder" -- 2391
						} -- 2391
					end -- 2387
					if Content:exist(targetDoraPath) then -- 2392
						if not Content:remove(targetDoraPath) then -- 2393
							return { -- 2394
								success = false, -- 2394
								message = "failed to remove old dora" -- 2394
							} -- 2394
						end -- 2393
					end -- 2392
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2395
						return { -- 2396
							success = false, -- 2396
							message = "failed to copy dora" -- 2396
						} -- 2396
					end -- 2395
					return { -- 2397
						success = true -- 2397
					} -- 2397
				else -- 2399
					return { -- 2399
						success = false, -- 2399
						message = 'Wa file needs a project' -- 2399
					} -- 2399
				end -- 2381
			end -- 2380
		end -- 2380
	end -- 2380
	return { -- 2379
		success = false, -- 2379
		message = "invalid call" -- 2379
	} -- 2379
end) -- 2379
HttpServer:postSchedule("/wa/build", function(req) -- 2401
	do -- 2402
		local _type_0 = type(req) -- 2402
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2402
		if _tab_0 then -- 2402
			local path -- 2402
			do -- 2402
				local _obj_0 = req.body -- 2402
				local _type_1 = type(_obj_0) -- 2402
				if "table" == _type_1 or "userdata" == _type_1 then -- 2402
					path = _obj_0.path -- 2402
				end -- 2402
			end -- 2402
			if path ~= nil then -- 2402
				local projDir = getWaProjectDirFromFile(path) -- 2403
				if projDir then -- 2403
					local message = Wasm:buildWaAsync(projDir) -- 2404
					if message == "" then -- 2405
						return { -- 2406
							success = true -- 2406
						} -- 2406
					else -- 2408
						return { -- 2408
							success = false, -- 2408
							message = message -- 2408
						} -- 2408
					end -- 2405
				else -- 2410
					return { -- 2410
						success = false, -- 2410
						message = 'Wa file needs a project' -- 2410
					} -- 2410
				end -- 2403
			end -- 2402
		end -- 2402
	end -- 2402
	return { -- 2411
		success = false, -- 2411
		message = 'failed to build' -- 2411
	} -- 2411
end) -- 2401
HttpServer:postSchedule("/wa/format", function(req) -- 2413
	do -- 2414
		local _type_0 = type(req) -- 2414
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2414
		if _tab_0 then -- 2414
			local file -- 2414
			do -- 2414
				local _obj_0 = req.body -- 2414
				local _type_1 = type(_obj_0) -- 2414
				if "table" == _type_1 or "userdata" == _type_1 then -- 2414
					file = _obj_0.file -- 2414
				end -- 2414
			end -- 2414
			if file ~= nil then -- 2414
				local code = Wasm:formatWaAsync(file) -- 2415
				if code == "" then -- 2416
					return { -- 2417
						success = false -- 2417
					} -- 2417
				else -- 2419
					return { -- 2419
						success = true, -- 2419
						code = code -- 2419
					} -- 2419
				end -- 2416
			end -- 2414
		end -- 2414
	end -- 2414
	return { -- 2420
		success = false -- 2420
	} -- 2420
end) -- 2413
HttpServer:postSchedule("/wa/create", function(req) -- 2422
	do -- 2423
		local _type_0 = type(req) -- 2423
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2423
		if _tab_0 then -- 2423
			local path -- 2423
			do -- 2423
				local _obj_0 = req.body -- 2423
				local _type_1 = type(_obj_0) -- 2423
				if "table" == _type_1 or "userdata" == _type_1 then -- 2423
					path = _obj_0.path -- 2423
				end -- 2423
			end -- 2423
			if path ~= nil then -- 2423
				if not Content:exist(Path:getPath(path)) then -- 2424
					return { -- 2425
						success = false, -- 2425
						message = "target path not existed" -- 2425
					} -- 2425
				end -- 2424
				if Content:exist(path) then -- 2426
					return { -- 2427
						success = false, -- 2427
						message = "target project folder existed" -- 2427
					} -- 2427
				end -- 2426
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2428
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2429
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2430
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2431
					return { -- 2434
						success = false, -- 2434
						message = "missing template project" -- 2434
					} -- 2434
				end -- 2431
				if not Content:mkdir(path) then -- 2435
					return { -- 2436
						success = false, -- 2436
						message = "failed to create project folder" -- 2436
					} -- 2436
				end -- 2435
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2437
					Content:remove(path) -- 2438
					return { -- 2439
						success = false, -- 2439
						message = "failed to copy template" -- 2439
					} -- 2439
				end -- 2437
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2440
					Content:remove(path) -- 2441
					return { -- 2442
						success = false, -- 2442
						message = "failed to copy template" -- 2442
					} -- 2442
				end -- 2440
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2443
					Content:remove(path) -- 2444
					return { -- 2445
						success = false, -- 2445
						message = "failed to copy template" -- 2445
					} -- 2445
				end -- 2443
				return { -- 2446
					success = true -- 2446
				} -- 2446
			end -- 2423
		end -- 2423
	end -- 2423
	return { -- 2422
		success = false, -- 2422
		message = "invalid call" -- 2422
	} -- 2422
end) -- 2422
local tsBuildGlobs = { -- 2449
	"**/*.ts", -- 2449
	"**/*.tsx", -- 2450
	"!**/.*/**", -- 2451
	"!**/node_modules/**" -- 2452
} -- 2448
local tsSnapshotGlobs = { -- 2455
	"**/*.ts", -- 2455
	"**/*.tsx", -- 2456
	"**/*.lua", -- 2457
	"!**/.*/**", -- 2458
	"!**/node_modules/**" -- 2459
} -- 2454
local collectTSVirtualFiles -- 2461
collectTSVirtualFiles = function(sourceRoot) -- 2461
	local files = { } -- 2462
	local seen = { } -- 2463
	local addFile -- 2464
	addFile = function(file, moduleName, virtualFile) -- 2464
		if moduleName == nil then -- 2464
			moduleName = nil -- 2464
		end -- 2464
		if virtualFile == nil then -- 2464
			virtualFile = nil -- 2464
		end -- 2464
		local targetFile = virtualFile or file -- 2465
		do -- 2466
			local entry = seen[targetFile] -- 2466
			if entry then -- 2466
				if moduleName and moduleName ~= "" then -- 2467
					entry.moduleName = moduleName -- 2467
				end -- 2467
				return -- 2468
			end -- 2466
		end -- 2466
		local content = Content:load(file) -- 2469
		if content then -- 2469
			local entry = { -- 2470
				file = targetFile, -- 2470
				content = content -- 2470
			} -- 2470
			if moduleName and moduleName ~= "" then -- 2471
				entry.moduleName = moduleName -- 2471
			end -- 2471
			seen[targetFile] = entry -- 2472
			files[#files + 1] = entry -- 2473
		end -- 2469
	end -- 2464
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2474
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2475
		for _index_0 = 1, #_list_0 do -- 2475
			local subFile = _list_0[_index_0] -- 2475
			addFile(Path(sourceRoot, subFile)) -- 2476
		end -- 2475
		local libraryRoots = { -- 2478
			Path(sourceRoot, "Script", "Lib"), -- 2478
			Path(sourceRoot, "Lib"), -- 2479
			Path(Content.assetPath, "Script", "Lib") -- 2480
		} -- 2477
		for _index_0 = 1, #libraryRoots do -- 2481
			local libraryRoot = libraryRoots[_index_0] -- 2481
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2482
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2483
				for _index_1 = 1, #_list_1 do -- 2483
					local subFile = _list_1[_index_1] -- 2483
					local file = Path(libraryRoot, subFile) -- 2484
					local virtualFile = Path(sourceRoot, subFile) -- 2485
					addFile(file, nil, virtualFile) -- 2486
				end -- 2483
			end -- 2482
		end -- 2481
	end -- 2474
	local locale -- 2487
	if App.locale:match('^zh') then -- 2487
		locale = 'zh-Hans' -- 2487
	else -- 2487
		locale = 'en' -- 2487
	end -- 2487
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2488
	local _list_0 = Content:getFiles(declarationRoot) -- 2489
	for _index_0 = 1, #_list_0 do -- 2489
		local file = _list_0[_index_0] -- 2489
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2490
			local fullPath = Path(declarationRoot, file) -- 2491
			local moduleName = Path:getName(Path:getName(file)) -- 2492
			addFile(fullPath, moduleName) -- 2493
		end -- 2490
	end -- 2489
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2494
	do -- 2495
		local content = Content:load(lualibBundle) -- 2495
		if content then -- 2495
			files[#files + 1] = { -- 2496
				file = "lualib_bundle.lua", -- 2496
				content = content -- 2496
			} -- 2496
		end -- 2495
	end -- 2495
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2497
	local _list_1 = Content:getFiles(lualibRoot) -- 2498
	for _index_0 = 1, #_list_1 do -- 2498
		local file = _list_1[_index_0] -- 2498
		if Path:getExt(file) == "lua" then -- 2499
			local content = Content:load(Path(lualibRoot, file)) -- 2500
			if content then -- 2500
				files[#files + 1] = { -- 2501
					file = Path("lualib", file), -- 2501
					content = content -- 2501
				} -- 2501
			end -- 2500
		end -- 2499
	end -- 2498
	return files -- 2502
end -- 2461
local transpileTSFileWithWebIDE -- 2504
do -- 2504
	local tsReadyTimeout <const> = 5 -- 2505
	local tsBuildTimeout <const> = 30 -- 2506
	local tsBuildRequestId = 0 -- 2507
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files) -- 2508
		tsBuildRequestId = tsBuildRequestId + 1 -- 2509
		local requestId = tsBuildRequestId -- 2510
		local done = false -- 2511
		local ready = false -- 2512
		local result = nil -- 2513
		local listener = Node() -- 2514
		listener:gslot("AppWS", function(event) -- 2515
			if event.type == "Receive" then -- 2516
				local res = json.decode(event.msg) -- 2517
				if res then -- 2517
					if res.name == "TranspileTSProbe" and res.id == requestId then -- 2518
						ready = true -- 2519
					elseif res.name == "TranspileTS" and res.id == requestId then -- 2520
						listener:removeFromParent() -- 2521
						if res.success then -- 2522
							local luaFile = Path:replaceExt(file, "lua") -- 2523
							Content:save(luaFile, res.luaCode) -- 2524
							result = { -- 2525
								success = true, -- 2525
								file = file -- 2525
							} -- 2525
						else -- 2527
							result = { -- 2527
								success = false, -- 2527
								file = file, -- 2527
								message = res.message -- 2527
							} -- 2527
						end -- 2522
						done = true -- 2528
					end -- 2518
				end -- 2517
			end -- 2516
		end) -- 2515
		emit("AppWS", "Send", json.encode({ -- 2529
			name = "TranspileTSProbe", -- 2529
			id = requestId -- 2529
		})) -- 2529
		local readyDeadline = App.runningTime + tsReadyTimeout -- 2530
		wait(function() -- 2531
			return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline -- 2531
		end) -- 2531
		if not ready then -- 2532
			listener:removeFromParent() -- 2533
			if HttpServer.wsConnectionCount == 0 then -- 2534
				return { -- 2535
					success = false, -- 2535
					file = file, -- 2535
					message = "Web IDE disconnected" -- 2535
				} -- 2535
			end -- 2534
			return { -- 2536
				success = false, -- 2536
				file = file, -- 2536
				message = "TypeScript transpiler is not ready" -- 2536
			} -- 2536
		end -- 2532
		emit("AppWS", "Send", json.encode({ -- 2537
			name = "TranspileTS", -- 2537
			id = requestId, -- 2537
			file = file, -- 2537
			content = content, -- 2537
			projectRoot = sourceRoot, -- 2537
			files = files -- 2537
		})) -- 2537
		local deadline = App.runningTime + tsBuildTimeout -- 2538
		wait(function() -- 2539
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2539
		end) -- 2539
		if not done then -- 2540
			listener:removeFromParent() -- 2541
			if HttpServer.wsConnectionCount == 0 then -- 2542
				return { -- 2543
					success = false, -- 2543
					file = file, -- 2543
					message = "Web IDE disconnected" -- 2543
				} -- 2543
			end -- 2542
			return { -- 2544
				success = false, -- 2544
				file = file, -- 2544
				message = "TypeScript transpile timed out" -- 2544
			} -- 2544
		end -- 2540
		return result -- 2545
	end -- 2508
end -- 2504
local compilerReadyTimeout <const> = 15 -- 2547
local compilerBuildTimeout <const> = 30 -- 2548
local compilerIdleCloseSeconds <const> = 8 -- 2549
local compilerReady = false -- 2550
local compilerRequested = false -- 2551
local compilerUsers = 0 -- 2552
local compilerCloseGeneration = 0 -- 2553
local compilerJobId = 0 -- 2554
local compilerJobs = { } -- 2555
local compilerResults = { } -- 2556
local compilerInFlight = { } -- 2557
HttpServer:post("/compiler/ready", function() -- 2559
	compilerReady = true -- 2560
	return { -- 2561
		success = true -- 2561
	} -- 2561
end) -- 2559
HttpServer:post("/compiler/poll", function() -- 2563
	compilerReady = true -- 2564
	local job = table.remove(compilerJobs, 1) -- 2565
	if job then -- 2566
		compilerInFlight[job.id] = true -- 2567
	end -- 2566
	return { -- 2568
		success = true, -- 2568
		job = job -- 2568
	} -- 2568
end) -- 2563
HttpServer:post("/compiler/result", function(req) -- 2570
	do -- 2571
		local _type_0 = type(req) -- 2571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2571
		if _tab_0 then -- 2571
			local body = req.body -- 2571
			if body ~= nil then -- 2571
				local id = body.id -- 2572
				if not (id and compilerInFlight[id]) then -- 2573
					return { -- 2573
						success = false, -- 2573
						message = "invalid compiler job" -- 2573
					} -- 2573
				end -- 2573
				compilerInFlight[id] = nil -- 2574
				compilerResults[id] = body -- 2575
				return { -- 2576
					success = true -- 2576
				} -- 2576
			end -- 2571
		end -- 2571
	end -- 2571
	return { -- 2570
		success = false -- 2570
	} -- 2570
end) -- 2570
local acquireCompiler -- 2578
acquireCompiler = function() -- 2578
	compilerUsers = compilerUsers + 1 -- 2579
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2580
	if not compilerRequested then -- 2581
		compilerRequested = true -- 2582
		compilerReady = false -- 2583
		return emit("AppWebView", "/compiler.html", true) -- 2584
	end -- 2581
end -- 2578
local releaseCompiler -- 2586
releaseCompiler = function() -- 2586
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2587
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2588
	if not (compilerUsers == 0) then -- 2589
		return -- 2589
	end -- 2589
	local closeGeneration = compilerCloseGeneration -- 2590
	return thread(function() -- 2591
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2592
		wait(function() -- 2593
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or HttpServer.wsConnectionCount > 0 or App.runningTime >= closeDeadline -- 2594
		end) -- 2593
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2598
			compilerRequested = false -- 2599
			compilerReady = false -- 2600
			return emit("AppWebView", "/compiler.html", false) -- 2601
		end -- 2598
	end) -- 2591
end -- 2586
local removeCompilerJob -- 2603
removeCompilerJob = function(id) -- 2603
	for index = #compilerJobs, 1, -1 do -- 2604
		if compilerJobs[index].id == id then -- 2605
			table.remove(compilerJobs, index) -- 2606
		end -- 2605
	end -- 2604
	compilerInFlight[id] = nil -- 2607
	compilerResults[id] = nil -- 2608
end -- 2603
local transpileTSFileWithCompiler -- 2610
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2610
	acquireCompiler() -- 2611
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2612
	wait(function() -- 2613
		return compilerReady or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2613
	end) -- 2613
	if not compilerReady then -- 2614
		releaseCompiler() -- 2615
		if isCancelled and isCancelled() then -- 2616
			return { -- 2617
				success = false, -- 2617
				file = file, -- 2617
				message = "build canceled", -- 2617
				interrupted = true -- 2617
			} -- 2617
		end -- 2616
		return { -- 2618
			success = false, -- 2618
			file = file, -- 2618
			message = "TypeScript compiler WebView is not ready" -- 2618
		} -- 2618
	end -- 2614
	compilerJobId = compilerJobId + 1 -- 2619
	local jobId = compilerJobId -- 2620
	compilerJobs[#compilerJobs + 1] = { -- 2622
		id = jobId, -- 2622
		file = file, -- 2623
		content = content, -- 2624
		projectRoot = sourceRoot, -- 2625
		files = files -- 2626
	} -- 2621
	local deadline = App.runningTime + compilerBuildTimeout -- 2627
	wait(function() -- 2628
		return compilerResults[jobId] or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2628
	end) -- 2628
	local response = compilerResults[jobId] -- 2629
	removeCompilerJob(jobId) -- 2630
	releaseCompiler() -- 2631
	if not response then -- 2632
		if isCancelled and isCancelled() then -- 2633
			return { -- 2634
				success = false, -- 2634
				file = file, -- 2634
				message = "build canceled", -- 2634
				interrupted = true -- 2634
			} -- 2634
		end -- 2633
		return { -- 2635
			success = false, -- 2635
			file = file, -- 2635
			message = "TypeScript transpile timed out" -- 2635
		} -- 2635
	end -- 2632
	if response.success then -- 2636
		local luaFile = Path:replaceExt(file, "lua") -- 2637
		if Content:save(luaFile, response.luaCode) then -- 2638
			return { -- 2639
				success = true, -- 2639
				file = file -- 2639
			} -- 2639
		end -- 2638
		return { -- 2640
			success = false, -- 2640
			file = file, -- 2640
			message = "failed to save " .. tostring(luaFile) -- 2640
		} -- 2640
	end -- 2636
	return { -- 2641
		success = false, -- 2641
		file = file, -- 2641
		message = response.message or "TypeScript transpile failed" -- 2641
	} -- 2641
end -- 2610
local transpileTSFile -- 2643
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2643
	if App.platform == "Android" and HttpServer.wsConnectionCount == 0 then -- 2644
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2645
	end -- 2644
	return transpileTSFileWithWebIDE(file, content, sourceRoot, files) -- 2646
end -- 2643
local _anon_func_7 = function(path) -- 2657
	local _val_0 = Path:getExt(path) -- 2657
	return "ts" == _val_0 or "tsx" == _val_0 -- 2657
end -- 2657
HttpServer:postSchedule("/ts/build", function(req) -- 2648
	do -- 2649
		local _type_0 = type(req) -- 2649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2649
		if _tab_0 then -- 2649
			local path -- 2649
			do -- 2649
				local _obj_0 = req.body -- 2649
				local _type_1 = type(_obj_0) -- 2649
				if "table" == _type_1 or "userdata" == _type_1 then -- 2649
					path = _obj_0.path -- 2649
				end -- 2649
			end -- 2649
			if path ~= nil then -- 2649
				if App.platform ~= "Android" and HttpServer.wsConnectionCount == 0 then -- 2650
					return { -- 2651
						success = false, -- 2651
						message = "Web IDE not connected" -- 2651
					} -- 2651
				end -- 2650
				local projectRoot = req.body.projectRoot -- 2652
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2653
				if not Content:exist(path) then -- 2654
					return { -- 2655
						success = false, -- 2655
						message = "path not existed" -- 2655
					} -- 2655
				end -- 2654
				if not Content:isdir(path) then -- 2656
					if not (_anon_func_7(path)) then -- 2657
						return { -- 2658
							success = false, -- 2658
							message = "expecting a TypeScript file" -- 2658
						} -- 2658
					end -- 2657
					local messages = { } -- 2659
					local content = Content:load(path) -- 2660
					if not content then -- 2661
						return { -- 2662
							success = false, -- 2662
							message = "failed to read file" -- 2662
						} -- 2662
					end -- 2661
					emit("AppWS", "Send", json.encode({ -- 2663
						name = "UpdateFile", -- 2663
						file = path, -- 2663
						exists = true, -- 2663
						content = content, -- 2663
						projectRoot = sourceRoot -- 2663
					})) -- 2663
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2664
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2665
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2666
					end -- 2664
					return { -- 2667
						success = true, -- 2667
						messages = messages -- 2667
					} -- 2667
				else -- 2669
					local fileData = { } -- 2669
					local messages = { } -- 2670
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2671
					for _index_0 = 1, #_list_0 do -- 2671
						local subFile = _list_0[_index_0] -- 2671
						local file = Path(path, subFile) -- 2672
						local content = Content:load(file) -- 2673
						if content then -- 2673
							fileData[file] = content -- 2674
							emit("AppWS", "Send", json.encode({ -- 2675
								name = "UpdateFile", -- 2675
								file = file, -- 2675
								exists = true, -- 2675
								content = content, -- 2675
								projectRoot = sourceRoot -- 2675
							})) -- 2675
						else -- 2677
							messages[#messages + 1] = { -- 2677
								success = false, -- 2677
								file = file, -- 2677
								message = "failed to read file" -- 2677
							} -- 2677
						end -- 2673
					end -- 2671
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2678
					for file, content in pairs(fileData) do -- 2679
						if "d" == Path:getExt(Path:getName(file)) then -- 2680
							goto _continue_0 -- 2680
						end -- 2680
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2681
						::_continue_0:: -- 2680
					end -- 2679
					return { -- 2682
						success = true, -- 2682
						messages = messages -- 2682
					} -- 2682
				end -- 2656
			end -- 2649
		end -- 2649
	end -- 2649
	return { -- 2648
		success = false -- 2648
	} -- 2648
end) -- 2648
HttpServer:post("/download", function(req) -- 2684
	do -- 2685
		local _type_0 = type(req) -- 2685
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2685
		if _tab_0 then -- 2685
			local url -- 2685
			do -- 2685
				local _obj_0 = req.body -- 2685
				local _type_1 = type(_obj_0) -- 2685
				if "table" == _type_1 or "userdata" == _type_1 then -- 2685
					url = _obj_0.url -- 2685
				end -- 2685
			end -- 2685
			local target -- 2685
			do -- 2685
				local _obj_0 = req.body -- 2685
				local _type_1 = type(_obj_0) -- 2685
				if "table" == _type_1 or "userdata" == _type_1 then -- 2685
					target = _obj_0.target -- 2685
				end -- 2685
			end -- 2685
			if url ~= nil and target ~= nil then -- 2685
				local Entry = require("Script.Dev.Entry") -- 2686
				Entry.downloadFile(url, target) -- 2687
				return { -- 2688
					success = true -- 2688
				} -- 2688
			end -- 2685
		end -- 2685
	end -- 2685
	return { -- 2684
		success = false -- 2684
	} -- 2684
end) -- 2684
local isDesktopPlatform -- 2690
isDesktopPlatform = function() -- 2690
	local _val_0 = App.platform -- 2691
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2691
end -- 2690
local getServerStatus -- 2693
getServerStatus = function() -- 2693
	local Entry = require("Script.Dev.Entry") -- 2694
	local running = Entry.getCurrentEntryStatus() -- 2695
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2696
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2697
	return { -- 2699
		success = true, -- 2699
		platform = App.platform, -- 2700
		locale = App.locale, -- 2701
		version = App.version, -- 2702
		url = "http://localhost:8866", -- 2703
		wsConnectionCount = wsConnectionCount, -- 2704
		webIDEConnected = wsConnectionCount > 0, -- 2705
		assetPath = Content.assetPath, -- 2706
		writablePath = Content.writablePath, -- 2707
		appPath = Content.appPath, -- 2708
		waTemplateReady = waTemplateReady, -- 2709
		running = running -- 2710
	} -- 2698
end -- 2693
HttpServer:post("/status", function() -- 2713
	return getServerStatus() -- 2714
end) -- 2713
HttpServer:postSchedule("/doctor/fix", function(req) -- 2716
	do -- 2717
		local _type_0 = type(req) -- 2717
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2717
		if _tab_0 then -- 2717
			local openWebIDE -- 2717
			do -- 2717
				local _obj_0 = req.body -- 2717
				local _type_1 = type(_obj_0) -- 2717
				if "table" == _type_1 or "userdata" == _type_1 then -- 2717
					openWebIDE = _obj_0.openWebIDE -- 2717
				end -- 2717
			end -- 2717
			if openWebIDE ~= nil then -- 2717
				if not openWebIDE then -- 2718
					return { -- 2719
						success = false, -- 2719
						message = "nothing to fix" -- 2719
					} -- 2719
				end -- 2718
				local status = getServerStatus() -- 2720
				if status.webIDEConnected then -- 2721
					return { -- 2722
						success = true, -- 2722
						fixed = false, -- 2722
						message = "Web IDE already connected.", -- 2722
						status = status -- 2722
					} -- 2722
				end -- 2721
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2723
				if waitSeconds > 0 then -- 2724
					local deadline = os.time() + waitSeconds -- 2725
					repeat -- 2726
						sleep(0.2) -- 2727
						status = getServerStatus() -- 2728
						if status.webIDEConnected then -- 2729
							return { -- 2730
								success = true, -- 2730
								fixed = false, -- 2730
								reconnected = true, -- 2730
								message = "Web IDE reconnected.", -- 2730
								status = status -- 2730
							} -- 2730
						end -- 2729
					until os.time() >= deadline -- 2726
				end -- 2724
				if not isDesktopPlatform() then -- 2732
					return { -- 2733
						success = false, -- 2733
						message = "opening Web IDE is only supported on desktop platforms", -- 2733
						status = status -- 2733
					} -- 2733
				end -- 2732
				local url = "http://localhost:8866" -- 2734
				App:openURL(url) -- 2735
				status.openedURL = url -- 2736
				return { -- 2737
					success = true, -- 2737
					fixed = true, -- 2737
					message = "Opened Web IDE in the local browser.", -- 2737
					url = url, -- 2737
					status = status -- 2737
				} -- 2737
			end -- 2717
		end -- 2717
	end -- 2717
	return { -- 2716
		success = false, -- 2716
		message = "invalid call" -- 2716
	} -- 2716
end) -- 2716
local status = { } -- 2739
_module_0 = status -- 2740
status.transpileTSFile = transpileTSFile -- 2742
status.buildAsync = function(path) -- 2744
	if not Content:exist(path) then -- 2745
		return { -- 2746
			success = false, -- 2746
			file = path, -- 2746
			message = "file not existed" -- 2746
		} -- 2746
	end -- 2745
	do -- 2747
		local _exp_0 = Path:getExt(path) -- 2747
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2747
			if '' == Path:getExt(Path:getName(path)) then -- 2748
				local content = Content:loadAsync(path) -- 2749
				if content then -- 2749
					local resultCodes, err = compileFileAsync(path, content) -- 2750
					if resultCodes then -- 2750
						return { -- 2751
							success = true, -- 2751
							file = path -- 2751
						} -- 2751
					else -- 2753
						return { -- 2753
							success = false, -- 2753
							file = path, -- 2753
							message = err -- 2753
						} -- 2753
					end -- 2750
				end -- 2749
			end -- 2748
		elseif "lua" == _exp_0 then -- 2754
			local content = Content:loadAsync(path) -- 2755
			if content then -- 2755
				do -- 2756
					local isTIC80 = CheckTIC80Code(content) -- 2756
					if isTIC80 then -- 2756
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2757
					end -- 2756
				end -- 2756
				local success, info -- 2758
				do -- 2758
					local _obj_0 = luaCheck(path, content) -- 2758
					success, info = _obj_0.success, _obj_0.info -- 2758
				end -- 2758
				if success then -- 2759
					return { -- 2760
						success = true, -- 2760
						file = path -- 2760
					} -- 2760
				elseif info and #info > 0 then -- 2761
					local messages = { } -- 2762
					for _index_0 = 1, #info do -- 2763
						local _des_0 = info[_index_0] -- 2763
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2763
						local lineText = "" -- 2764
						if line then -- 2765
							local currentLine = 1 -- 2766
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2767
								if currentLine == line then -- 2768
									lineText = text -- 2769
									break -- 2770
								end -- 2768
								currentLine = currentLine + 1 -- 2771
							end -- 2767
						end -- 2765
						if line then -- 2772
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2773
						else -- 2775
							messages[#messages + 1] = message -- 2775
						end -- 2772
					end -- 2763
					return { -- 2776
						success = false, -- 2776
						file = path, -- 2776
						message = table.concat(messages, "\n") -- 2776
					} -- 2776
				else -- 2778
					return { -- 2778
						success = false, -- 2778
						file = path, -- 2778
						message = "lua check failed" -- 2778
					} -- 2778
				end -- 2759
			end -- 2755
		elseif "yarn" == _exp_0 then -- 2779
			local content = Content:loadAsync(path) -- 2780
			if content then -- 2780
				local res, _, err = yarncompile(content, true) -- 2781
				if res then -- 2781
					return { -- 2782
						success = true, -- 2782
						file = path -- 2782
					} -- 2782
				else -- 2784
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2784
					local lineText = "" -- 2785
					if line then -- 2786
						local currentLine = 1 -- 2787
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2788
							if currentLine == line then -- 2789
								lineText = text -- 2790
								break -- 2791
							end -- 2789
							currentLine = currentLine + 1 -- 2792
						end -- 2788
					end -- 2786
					if node ~= "" then -- 2793
						node = "node: " .. tostring(node) .. ", " -- 2794
					else -- 2795
						node = "" -- 2795
					end -- 2793
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2796
					return { -- 2797
						success = false, -- 2797
						file = path, -- 2797
						message = message -- 2797
					} -- 2797
				end -- 2781
			end -- 2780
		end -- 2747
	end -- 2747
	return { -- 2798
		success = false, -- 2798
		file = path, -- 2798
		message = "invalid file to build" -- 2798
	} -- 2798
end -- 2744
HttpServer:postSchedule("/git/commit-files", function(req) -- 2800
	do -- 2801
		local _type_0 = type(req) -- 2801
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2801
		if _tab_0 then -- 2801
			local body = req.body -- 2801
			if body ~= nil then -- 2801
				local repoPath, commit = body.repoPath, body.commit -- 2802
				if gitInvalidRepoPath(repoPath) then -- 2803
					return { -- 2803
						success = false, -- 2803
						message = "invalid repoPath" -- 2803
					} -- 2803
				end -- 2803
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 2804
					return { -- 2804
						success = false, -- 2804
						message = "invalid commit" -- 2804
					} -- 2804
				end -- 2804
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 2805
				if not res.success then -- 2806
					return res -- 2806
				end -- 2806
				return { -- 2807
					success = true, -- 2807
					status = res.status, -- 2807
					data = res.status and res.status.data -- 2807
				} -- 2807
			end -- 2801
		end -- 2801
	end -- 2801
	return invalidArguments -- 2800
end) -- 2800
thread(function() -- 2809
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2810
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2811
	if Content:exist(doraWeb) then -- 2812
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 2813
		local heavyAssetsContent -- 2814
		if Content:exist(heavyAssets) then -- 2814
			heavyAssetsContent = Content:load(heavyAssets) -- 2814
		else -- 2814
			heavyAssetsContent = "" -- 2814
		end -- 2814
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) .. "\n" .. heavyAssetsContent -- 2815
		local needReload -- 2816
		if Content:exist(doraReady) then -- 2816
			needReload = readyContent ~= Content:load(doraReady) -- 2817
		else -- 2818
			needReload = true -- 2818
		end -- 2816
		if needReload then -- 2819
			Content:remove(Path(Content.appPath, ".www")) -- 2820
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2821
			Content:save(doraReady, readyContent) -- 2825
			print("Dora Dora is ready!") -- 2826
		end -- 2819
	end -- 2812
	HttpServer:clearStaticCacheControls() -- 2827
	HttpServer:setStaticCacheControl("no-cache") -- 2828
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 2829
	if HttpServer:start(8866) then -- 2833
		local localIP = HttpServer.localIP -- 2834
		if localIP == "" then -- 2835
			localIP = "localhost" -- 2835
		end -- 2835
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2836
		return HttpServer:startWS(8868) -- 2837
	else -- 2839
		status.url = nil -- 2839
		return print("8866 Port not available!") -- 2840
	end -- 2833
end) -- 2809
return _module_0 -- 1
