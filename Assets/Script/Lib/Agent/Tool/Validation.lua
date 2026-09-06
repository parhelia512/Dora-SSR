-- [ts]: Validation.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local AgentConfig = require("Agent.Config") -- 2
local ____Questionnaire = require("Agent.Questionnaire") -- 3
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 3
local AgentUtils = require("Agent.Utils") -- 4
local ____Workspace = require("Agent.Tool.Workspace") -- 6
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 6
local function getDecisionPath(input) -- 8
	if type(input.path) == "string" then -- 8
		return __TS__StringTrim(input.path) -- 9
	end -- 9
	if type(input.target_file) == "string" then -- 9
		return __TS__StringTrim(input.target_file) -- 10
	end -- 10
	return "" -- 11
end -- 8
function ____exports.getAgentFileEditInputs(input) -- 21
	if __TS__ArrayIsArray(input.edits) then -- 21
		local commonPath = type(input.path) == "string" and __TS__StringTrim(input.path) or "" -- 23
		local edits = {} -- 24
		do -- 24
			local i = 0 -- 25
			while i < #input.edits do -- 25
				local item = input.edits[i + 1] -- 26
				edits[#edits + 1] = { -- 27
					index = i, -- 28
					path = type(item.path) == "string" and __TS__StringTrim(item.path) ~= "" and __TS__StringTrim(item.path) or commonPath, -- 29
					oldStr = type(item.old_str) == "string" and item.old_str or "", -- 30
					newStr = type(item.new_str) == "string" and item.new_str or "" -- 31
				} -- 31
				i = i + 1 -- 25
			end -- 25
		end -- 25
		return edits -- 34
	end -- 34
	return {{ -- 36
		index = 0, -- 37
		path = type(input.path) == "string" and __TS__StringTrim(input.path) or "", -- 38
		oldStr = type(input.old_str) == "string" and input.old_str or "", -- 39
		newStr = type(input.new_str) == "string" and input.new_str or "" -- 40
	}} -- 40
end -- 21
local function clampInteger(value, fallback, minValue, maxValue) -- 44
	local num = __TS__Number(value) -- 45
	if not __TS__NumberIsFinite(num) then -- 45
		num = fallback -- 46
	end -- 46
	num = math.floor(num) -- 47
	if num < minValue then -- 47
		num = minValue -- 48
	end -- 48
	if maxValue ~= nil and num > maxValue then -- 48
		num = maxValue -- 49
	end -- 49
	return num -- 50
end -- 44
local function parseReadLine(value, fallback, name) -- 53
	local num = __TS__Number(value) -- 56
	if not __TS__NumberIsFinite(num) then -- 56
		num = fallback -- 57
	end -- 57
	num = math.floor(num) -- 58
	if num == 0 then -- 58
		return {success = false, message = name .. " cannot be 0"} -- 59
	end -- 59
	return {success = true, value = num} -- 60
end -- 53
local function normalizeReadRange(value, index) -- 63
	local suffix = index == nil and "" or " at index " .. tostring(index) -- 64
	if type(value) ~= "table" or value == nil or __TS__ArrayIsArray(value) then -- 64
		return {success = false, message = "read_file requires an object" .. suffix} -- 66
	end -- 66
	local input = value -- 68
	local path = type(input.path) == "string" and __TS__StringTrim(input.path) or "" -- 69
	if path == "" then -- 69
		return {success = false, message = "read_file requires path" .. suffix} -- 70
	end -- 70
	local start = parseReadLine(input.startLine, 1, "startLine") -- 71
	if start.success == false then -- 71
		return {success = false, message = start.message .. suffix} -- 72
	end -- 72
	local ____end = parseReadLine(input.endLine, start.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit, "endLine") -- 73
	if ____end.success == false then -- 73
		return {success = false, message = ____end.message .. suffix} -- 74
	end -- 74
	return {success = true, value = {path = path, startLine = start.value, endLine = ____end.value}} -- 75
end -- 63
local function getFinishMessage(input) -- 78
	local candidates = {input.message, input.response, input.summary} -- 79
	do -- 79
		local i = 0 -- 80
		while i < #candidates do -- 80
			if type(candidates[i + 1]) == "string" and __TS__StringTrim(candidates[i + 1]) ~= "" then -- 80
				return __TS__StringTrim(candidates[i + 1]) -- 82
			end -- 82
			i = i + 1 -- 80
		end -- 80
	end -- 80
	return "" -- 85
end -- 78
function ____exports.validateAgentToolInput(tool, input) -- 88
	local value = __TS__ObjectAssign({}, input) -- 89
	if tool == "finish" then -- 89
		local message = getFinishMessage(value) -- 91
		if message == "" then -- 91
			return {success = false, message = "finish requires params.message"} -- 92
		end -- 92
		local completion = AgentUtils.normalizeAgentCompletionReport(value) -- 93
		value.message = message -- 94
		value.outcome = completion.outcome -- 95
		value.validation = completion.validation -- 96
		value.knownIssues = completion.knownIssues -- 97
		value.assumptions = completion.assumptions -- 98
		value.learningCandidates = completion.learningCandidates -- 99
		return {success = true, value = value} -- 100
	end -- 100
	if tool == "ask_user" then -- 100
		local normalized = normalizeQuestionnaire(value) -- 103
		return normalized.success and ({success = true, value = normalized.schema}) or normalized -- 104
	end -- 104
	if tool == "read_file" then -- 104
		local hasReads = value.reads ~= nil -- 109
		local hasPath = value.path ~= nil -- 110
		if not hasReads and not hasPath then -- 110
			return {success = false, message = "read_file requires path or reads"} -- 112
		end -- 112
		if not hasPath and (value.startLine ~= nil or value.endLine ~= nil) then -- 112
			return {success = false, message = "read_file startLine/endLine require a top-level path"} -- 115
		end -- 115
		local reads = {} -- 117
		if hasPath then -- 117
			local normalized = normalizeReadRange(value) -- 119
			if normalized.success == false then -- 119
				return normalized -- 120
			end -- 120
			reads[#reads + 1] = normalized.value -- 121
		end -- 121
		if hasReads then -- 121
			if not __TS__ArrayIsArray(value.reads) or #value.reads < 1 then -- 121
				return {success = false, message = "read_file reads must be a non-empty array"} -- 125
			end -- 125
			do -- 125
				local i = 0 -- 127
				while i < #value.reads do -- 127
					local normalized = normalizeReadRange(value.reads[i + 1], i) -- 128
					if normalized.success == false then -- 128
						return normalized -- 129
					end -- 129
					reads[#reads + 1] = normalized.value -- 130
					i = i + 1 -- 127
				end -- 127
			end -- 127
		end -- 127
		if not hasReads then -- 127
			value.path = reads[1].path -- 134
			value.startLine = reads[1].startLine -- 135
			value.endLine = reads[1].endLine -- 136
			return {success = true, value = value} -- 137
		end -- 137
		value.path = nil -- 139
		value.startLine = nil -- 140
		value.endLine = nil -- 141
		value.reads = reads -- 142
		return {success = true, value = value} -- 143
	end -- 143
	if tool == "edit_file" then -- 143
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 146
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 147
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 147
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 149
		end -- 149
		local edits = ____exports.getAgentFileEditInputs(value) -- 151
		if #edits < 1 then -- 151
			return {success = false, message = "edit_file edits must not be empty"} -- 153
		end -- 153
		if not hasBatch then -- 153
			if edits[1].path == "" then -- 153
				return {success = false, message = "edit_file requires path"} -- 156
			end -- 156
			if edits[1].oldStr == edits[1].newStr then -- 156
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 157
			end -- 157
		end -- 157
		if hasBatch then -- 157
			value.edits = __TS__ArrayMap( -- 160
				edits, -- 160
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 160
			) -- 160
		else -- 160
			value.path = edits[1].path -- 162
			value.old_str = edits[1].oldStr -- 163
			value.new_str = edits[1].newStr -- 164
		end -- 164
		return {success = true, value = value} -- 166
	end -- 166
	if tool == "delete_file" then -- 166
		local target = getDecisionPath(value) -- 169
		if target == "" then -- 169
			return {success = false, message = "delete_file requires target_file"} -- 170
		end -- 170
		value.target_file = target -- 171
		return {success = true, value = value} -- 172
	end -- 172
	if tool == "grep_files" or tool == "search_dora_doc" then -- 172
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 175
		if pattern == "" then -- 175
			return {success = false, message = tool .. " requires pattern"} -- 176
		end -- 176
		value.pattern = pattern -- 177
		if tool == "grep_files" then -- 177
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 179
			value.offset = clampInteger(value.offset, 0, 0) -- 180
		else -- 180
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 182
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 182
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 184
			end -- 184
			value.docType = docType -- 186
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 187
		end -- 187
		return {success = true, value = value} -- 189
	end -- 189
	if tool == "glob_files" then -- 189
		value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 192
		return {success = true, value = value} -- 193
	end -- 193
	if tool == "build" then -- 193
		local hasPaths = value.paths ~= nil -- 196
		local hasPath = value.path ~= nil -- 197
		if not hasPaths and not hasPath then -- 197
			return {success = false, message = "build requires paths or path"} -- 198
		end -- 198
		local paths = {} -- 199
		if hasPath then -- 199
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 201
			if path == "" then -- 201
				return {success = false, message = "build path must be non-empty"} -- 202
			end -- 202
			paths[#paths + 1] = path -- 203
		end -- 203
		if hasPaths then -- 203
			if not __TS__ArrayIsArray(value.paths) then -- 203
				return {success = false, message = "build paths must be a non-empty array"} -- 206
			end -- 206
			local arrayPaths = __TS__ArrayMap( -- 207
				value.paths, -- 207
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 207
			) -- 207
			if #arrayPaths < 1 or __TS__ArraySome( -- 207
				arrayPaths, -- 208
				function(____, path) return path == "" end -- 208
			) then -- 208
				return {success = false, message = "build paths must contain non-empty paths"} -- 209
			end -- 209
			do -- 209
				local i = 0 -- 211
				while i < #arrayPaths do -- 211
					paths[#paths + 1] = arrayPaths[i + 1] -- 211
					i = i + 1 -- 211
				end -- 211
			end -- 211
		end -- 211
		value.path = nil -- 213
		value.paths = paths -- 214
		return {success = true, value = value} -- 215
	end -- 215
	if tool == "fetch_url" then -- 215
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 218
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 219
		if url == "" then -- 219
			return {success = false, message = "fetch_url requires url"} -- 220
		end -- 220
		if target == "" then -- 220
			return {success = false, message = "fetch_url requires target"} -- 221
		end -- 221
		value.url = url -- 222
		value.target = target -- 223
		return {success = true, value = value} -- 224
	end -- 224
	if tool == "preview_game" then -- 224
		if value.entry ~= nil and (type(value.entry) ~= "string" or __TS__StringTrim(value.entry) == "" or not isValidWorkspacePath(value.entry)) then -- 224
			return {success = false, message = "preview_game entry must be a project-relative path"} -- 228
		end -- 228
		if value.captureAtSeconds ~= nil then -- 228
			if not __TS__ArrayIsArray(value.captureAtSeconds) then -- 228
				return {success = false, message = "captureAtSeconds must be an array"} -- 231
			end -- 231
			local times = value.captureAtSeconds -- 232
			if #times < 1 or #times > 3 or __TS__ArraySome( -- 232
				times, -- 233
				function(____, time, i) return type(time) ~= "number" or not __TS__NumberIsFinite(time) or time < 0 or time > 10 or i > 0 and time <= times[i] end -- 233
			) then -- 233
				return {success = false, message = "Choose 1–3 increasing capture times between 0 and 10 seconds"} -- 234
			end -- 234
		end -- 234
		return {success = true, value = value} -- 237
	end -- 237
	if tool == "analyze_image" then -- 237
		if not __TS__ArrayIsArray(value.assetIds) or #value.assetIds < 1 or #value.assetIds > 3 or __TS__ArraySome( -- 237
			value.assetIds, -- 240
			function(____, id) return type(id) ~= "string" or (string.match(id, "^%d+%-%d+$")) == nil end -- 240
		) then -- 240
			return {success = false, message = "analyze_image requires 1–3 valid image asset IDs, not paths or URLs"} -- 241
		end -- 241
		for ____, name in ipairs({"question", "criteria"}) do -- 243
			do -- 243
				local text = value[name] -- 244
				if name == "criteria" and text == nil then -- 244
					goto __continue80 -- 245
				end -- 245
				if type(text) ~= "string" or name == "question" and __TS__StringTrim(text) == "" then -- 245
					return {success = false, message = name .. " must be valid text"} -- 246
				end -- 246
				local length = utf8.len(text) -- 247
				if length == nil or length > 4000 then -- 247
					return {success = false, message = name .. " must contain at most 4000 Unicode characters"} -- 248
				end -- 248
			end -- 248
			::__continue80:: -- 248
		end -- 248
		return {success = true, value = value} -- 250
	end -- 250
	if tool == "execute_command" then -- 250
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 253
		if mode ~= "lua" and mode ~= "git" then -- 253
			return {success = false, message = "execute_command requires mode: lua or git"} -- 254
		end -- 254
		value.mode = mode -- 255
		if mode == "lua" then -- 255
			local code = type(value.code) == "string" and value.code or "" -- 257
			if __TS__StringTrim(code) == "" then -- 257
				return {success = false, message = "execute_command lua mode requires code"} -- 258
			end -- 258
			value.code = code -- 259
		else -- 259
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 261
			if command == "" then -- 261
				return {success = false, message = "execute_command git mode requires command"} -- 262
			end -- 262
			value.command = command -- 263
			if type(value.cwd) == "string" then -- 263
				value.cwd = __TS__StringTrim(value.cwd) -- 264
			end -- 264
		end -- 264
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 120 or 1800) -- 266
		return {success = true, value = value} -- 267
	end -- 267
	if tool == "list_sub_agents" then -- 267
		if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 267
			value.status = __TS__StringTrim(value.status) -- 270
		end -- 270
		value.limit = clampInteger(value.limit, 5, 1) -- 271
		value.offset = clampInteger(value.offset, 0, 0) -- 272
		if type(value.query) == "string" then -- 272
			value.query = __TS__StringTrim(value.query) -- 273
		end -- 273
		return {success = true, value = value} -- 274
	end -- 274
	if tool == "spawn_sub_agent" then -- 274
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 277
		local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 278
		if prompt == "" then -- 278
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 279
		end -- 279
		if title == "" then -- 279
			return {success = false, message = "spawn_sub_agent requires title"} -- 280
		end -- 280
		value.prompt = prompt -- 281
		value.title = title -- 282
		if type(value.expectedOutput) == "string" then -- 282
			value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 283
		end -- 283
		if __TS__ArrayIsArray(value.filesHint) then -- 283
			value.filesHint = __TS__ArrayMap( -- 285
				__TS__ArrayFilter( -- 285
					value.filesHint, -- 285
					function(____, item) return type(item) == "string" end -- 285
				), -- 285
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 285
			) -- 285
		end -- 285
		return {success = true, value = value} -- 287
	end -- 287
	return {success = true, value = value} -- 289
end -- 88
____exports.AGENT_TOOL_VALIDATORS = { -- 292
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 293
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 294
	delete_file = function(value) return ____exports.validateAgentToolInput("delete_file", value) end, -- 295
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 296
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 297
	glob_files = function(value) return ____exports.validateAgentToolInput("glob_files", value) end, -- 298
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 299
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 300
	preview_game = function(value) return ____exports.validateAgentToolInput("preview_game", value) end, -- 301
	analyze_image = function(value) return ____exports.validateAgentToolInput("analyze_image", value) end, -- 302
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 303
	list_sub_agents = function(value) return ____exports.validateAgentToolInput("list_sub_agents", value) end, -- 304
	spawn_sub_agent = function(value) return ____exports.validateAgentToolInput("spawn_sub_agent", value) end, -- 305
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 306
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 307
} -- 307
return ____exports -- 307