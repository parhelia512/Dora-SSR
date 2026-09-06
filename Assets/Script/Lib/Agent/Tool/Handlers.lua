-- [ts]: Handlers.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____VisionAnalysis = require("Agent.Tool.VisionAnalysis") -- 2
local analyzeImage = ____VisionAnalysis.analyzeImage -- 2
local AgentConfig = require("Agent.Config") -- 3
local ____Questionnaire = require("Agent.Questionnaire") -- 4
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 4
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 5
local ____Guards = require("Agent.Tool.Guards") -- 6
local getAgentFileEditPlanGuardDenial = ____Guards.getAgentFileEditPlanGuardDenial -- 6
local ____Validation = require("Agent.Tool.Validation") -- 7
local getAgentFileEditInputs = ____Validation.getAgentFileEditInputs -- 7
local AgentUtils = require("Agent.Utils") -- 8
local Tools = require("Agent.Tools") -- 9
local function readOneFile(context, input) -- 12
	local ____input_startLine_0 = input.startLine -- 13
	if ____input_startLine_0 == nil then -- 13
		____input_startLine_0 = 1 -- 13
	end -- 13
	local startLine = __TS__Number(____input_startLine_0) -- 13
	local ____input_endLine_1 = input.endLine -- 14
	if ____input_endLine_1 == nil then -- 14
		____input_endLine_1 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 14
	end -- 14
	local endLine = __TS__Number(____input_endLine_1) -- 14
	local clippedAfterCompression = false -- 15
	if context.workflow.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 15
		endLine = startLine + 159 -- 22
		clippedAfterCompression = true -- 23
	end -- 23
	local path = type(input.path) == "string" and input.path or "" -- 25
	if __TS__StringTrim(path) == "" then -- 25
		return {success = false, message = "missing path"} -- 27
	end -- 27
	local output = Tools.readFile( -- 29
		context.workingDir, -- 30
		path, -- 31
		startLine, -- 32
		endLine, -- 33
		context.useChineseResponse and "zh" or "en" -- 34
	) -- 34
	if clippedAfterCompression and output.success == true then -- 34
		output.clipped = true -- 37
		output.message = context.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 38
	end -- 38
	return output -- 42
end -- 12
local function readFile(context, input) -- 45
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 45
		if __TS__ArrayIsArray(input.reads) then -- 45
			local reads = input.reads -- 47
			local results = {} -- 48
			local succeeded = 0 -- 49
			do -- 49
				local i = 0 -- 50
				while i < #reads do -- 50
					local item = reads[i + 1] -- 51
					local output = readOneFile(context, item) -- 52
					if output.success == true then -- 52
						succeeded = succeeded + 1 -- 53
					end -- 53
					results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 54
					i = i + 1 -- 50
				end -- 50
			end -- 50
			return ____awaiter_resolve(nil, {output = { -- 50
				success = succeeded == #results, -- 57
				partial = succeeded > 0 and succeeded < #results, -- 58
				mode = "batch", -- 59
				readCount = #results, -- 60
				succeededReadCount = succeeded, -- 61
				failedReadCount = #results - succeeded, -- 62
				results = results -- 63
			}}) -- 63
		end -- 63
		return ____awaiter_resolve( -- 63
			nil, -- 63
			{output = readOneFile(context, input)} -- 66
		) -- 66
	end) -- 66
end -- 45
local function grepFiles(context, input) -- 69
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 69
		local ____Tools_searchFiles_17 = Tools.searchFiles -- 70
		local ____context_workingDir_8 = context.workingDir -- 71
		local ____temp_9 = input.path or "" -- 72
		local ____temp_10 = context.useChineseResponse and "zh" or "en" -- 73
		local ____temp_11 = input.pattern or "" -- 74
		local ____input_globs_12 = input.globs -- 75
		local ____input_useRegex_13 = input.useRegex -- 76
		local ____input_caseSensitive_14 = input.caseSensitive -- 77
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 79
		local ____math_max_4 = math.max -- 80
		local ____math_floor_3 = math.floor -- 80
		local ____input_limit_2 = input.limit -- 80
		if ____input_limit_2 == nil then -- 80
			____input_limit_2 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 80
		end -- 80
		local ____math_max_4_result_16 = ____math_max_4( -- 80
			1, -- 80
			____math_floor_3(__TS__Number(____input_limit_2)) -- 80
		) -- 80
		local ____math_max_7 = math.max -- 81
		local ____math_floor_6 = math.floor -- 81
		local ____input_offset_5 = input.offset -- 81
		if ____input_offset_5 == nil then -- 81
			____input_offset_5 = 0 -- 81
		end -- 81
		local output = __TS__Await(____Tools_searchFiles_17({ -- 70
			workDir = ____context_workingDir_8, -- 71
			path = ____temp_9, -- 72
			docLanguage = ____temp_10, -- 73
			pattern = ____temp_11, -- 74
			globs = ____input_globs_12, -- 75
			useRegex = ____input_useRegex_13, -- 76
			caseSensitive = ____input_caseSensitive_14, -- 77
			includeContent = true, -- 78
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15, -- 79
			limit = ____math_max_4_result_16, -- 80
			offset = ____math_max_7( -- 81
				0, -- 81
				____math_floor_6(__TS__Number(____input_offset_5)) -- 81
			), -- 81
			groupByFile = input.groupByFile == true -- 82
		})) -- 82
		return ____awaiter_resolve(nil, {output = output}) -- 82
	end) -- 82
end -- 69
local function globFiles(context, input) -- 87
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 87
		local ____Tools_listFiles_24 = Tools.listFiles -- 88
		local ____context_workingDir_21 = context.workingDir -- 89
		local ____temp_22 = input.path or "" -- 90
		local ____input_globs_23 = input.globs -- 91
		local ____math_max_20 = math.max -- 92
		local ____math_floor_19 = math.floor -- 92
		local ____input_maxEntries_18 = input.maxEntries -- 92
		if ____input_maxEntries_18 == nil then -- 92
			____input_maxEntries_18 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 92
		end -- 92
		local output = ____Tools_listFiles_24({ -- 88
			workDir = ____context_workingDir_21, -- 89
			path = ____temp_22, -- 90
			globs = ____input_globs_23, -- 91
			maxEntries = ____math_max_20( -- 92
				1, -- 92
				____math_floor_19(__TS__Number(____input_maxEntries_18)) -- 92
			) -- 92
		}) -- 92
		return ____awaiter_resolve(nil, {output = output}) -- 92
	end) -- 92
end -- 87
local function searchDoraDoc(context, input) -- 97
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 97
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 98
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 99
		local ____temp_29 = input.pattern or "" -- 100
		local ____temp_30 = input.docType or "dora-api" -- 101
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 102
		local ____temp_32 = input.programmingLanguage or "ts" -- 103
		local ____math_min_28 = math.min -- 104
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 104
		local ____math_max_26 = math.max -- 104
		local ____input_limit_25 = input.limit -- 104
		if ____input_limit_25 == nil then -- 104
			____input_limit_25 = 8 -- 104
		end -- 104
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 99
			pattern = ____temp_29, -- 100
			docType = ____temp_30, -- 101
			docLanguage = ____temp_31, -- 102
			programmingLanguage = ____temp_32, -- 103
			limit = ____math_min_28( -- 104
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 104
				____math_max_26( -- 104
					1, -- 104
					__TS__Number(____input_limit_25) -- 104
				) -- 104
			), -- 104
			useRegex = input.useRegex, -- 105
			caseSensitive = false, -- 106
			includeContent = true, -- 107
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 108
		})) -- 108
		return ____awaiter_resolve(nil, {output = output}) -- 108
	end) -- 108
end -- 97
local function build(context, input) -- 113
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 113
		local paths = input.paths -- 114
		local results = {} -- 115
		local rawResults = {} -- 116
		local succeeded = 0 -- 117
		do -- 117
			local i = 0 -- 118
			while i < #paths do -- 118
				local result = __TS__Await(Tools.build({ -- 119
					workDir = context.workingDir, -- 120
					path = paths[i + 1], -- 121
					isCancelled = function() return context.cancellation:isCancelled() end -- 122
				})) -- 122
				local rawResult = result -- 124
				if result.success then -- 124
					succeeded = succeeded + 1 -- 125
				end -- 125
				rawResults[#rawResults + 1] = rawResult -- 126
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, rawResult) -- 127
				if context.cancellation:isCancelled() then -- 127
					break -- 128
				end -- 128
				i = i + 1 -- 118
			end -- 118
		end -- 118
		local output = { -- 130
			success = succeeded == #paths, -- 131
			partial = succeeded > 0 and succeeded < #paths, -- 132
			mode = "batch", -- 133
			requestedBuildCount = #paths, -- 134
			buildCount = #results, -- 135
			succeededBuildCount = succeeded, -- 136
			failedBuildCount = #results - succeeded, -- 137
			skippedBuildCount = #paths - #results, -- 138
			results = results -- 139
		} -- 139
		context.workflow.unbuiltEdits = false -- 141
		context.workflow.editsSinceBuild = 0 -- 142
		context.workflow.editedPathsSinceBuild = {} -- 143
		context.workflow.hasBuilt = true -- 144
		context.workflow.lastBuildSucceeded = output.success == true -- 145
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 145
			context.workflow.freshProjectBuildPending = false -- 147
		end -- 147
		context.workflow.apiSearchesSinceBuild = 0 -- 149
		context.workflow.buildRepairPending = false -- 150
		if output.success ~= true then -- 150
			do -- 150
				local r = 0 -- 152
				while r < #rawResults do -- 152
					local messages = rawResults[r + 1].messages -- 153
					do -- 153
						local i = 0 -- 154
						while i < (messages and #messages or 0) do -- 154
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 154
								context.workflow.buildRepairPending = true -- 156
								break -- 157
							end -- 157
							i = i + 1 -- 154
						end -- 154
					end -- 154
					r = r + 1 -- 152
				end -- 152
			end -- 152
		end -- 152
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 152
			context.workflow.failedTestNeedsBuild = false -- 163
			context.workflow.failedTestHasSourceEdit = false -- 164
		end -- 164
		return ____awaiter_resolve(nil, {output = output}) -- 164
	end) -- 164
end -- 113
local function fetchUrl(context, input) -- 169
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 169
		local output = __TS__Await(Tools.fetchUrl({ -- 170
			workDir = context.workingDir, -- 171
			url = type(input.url) == "string" and input.url or "", -- 172
			target = type(input.target) == "string" and input.target or "", -- 173
			isCancelled = function() return context.cancellation:isCancelled() end, -- 174
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 175
		})) -- 175
		return ____awaiter_resolve(nil, {output = output}) -- 175
	end) -- 175
end -- 169
local function updateDeterministicTestState(context, output) -- 180
	local deterministicFailure = false -- 181
	local deterministicPass = false -- 182
	local outputLines = __TS__StringSplit(output, "\n") -- 183
	do -- 183
		local i = 0 -- 184
		while i < #outputLines and not deterministicFailure do -- 184
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 185
			if line == "passed" then -- 185
				deterministicPass = true -- 186
			end -- 186
			if line == "failed" then -- 186
				deterministicFailure = true -- 188
				break -- 189
			end -- 189
			local searchFrom = 0 -- 191
			while searchFrom < #line do -- 191
				local failedIndex = (string.find( -- 193
					line, -- 193
					"failed", -- 193
					math.max(searchFrom + 1, 1), -- 193
					true -- 193
				) or 0) - 1 -- 193
				if failedIndex < 0 then -- 193
					break -- 194
				end -- 194
				local after = failedIndex + #"failed" -- 195
				while after < #line do -- 195
					local ch = __TS__StringSlice(line, after, after + 1) -- 197
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 197
						break -- 198
					end -- 198
					after = after + 1 -- 199
				end -- 199
				local afterEnd = after -- 201
				while afterEnd < #line do -- 201
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 203
					if ch < "0" or ch > "9" then -- 203
						break -- 204
					end -- 204
					afterEnd = afterEnd + 1 -- 205
				end -- 205
				local count -- 207
				if afterEnd > after then -- 207
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 209
				else -- 209
					local before = failedIndex - 1 -- 211
					while before >= 0 do -- 211
						local ch = __TS__StringSlice(line, before, before + 1) -- 213
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 213
							break -- 214
						end -- 214
						before = before - 1 -- 215
					end -- 215
					local beforeEnd = before + 1 -- 217
					while before >= 0 do -- 217
						local ch = __TS__StringSlice(line, before, before + 1) -- 219
						if ch < "0" or ch > "9" then -- 219
							break -- 220
						end -- 220
						before = before - 1 -- 221
					end -- 221
					if beforeEnd > before + 1 then -- 221
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 223
					end -- 223
				end -- 223
				if count ~= nil and count > 0 then -- 223
					deterministicFailure = true -- 226
					break -- 227
				end -- 227
				searchFrom = failedIndex + #"failed" -- 229
			end -- 229
			i = i + 1 -- 184
		end -- 184
	end -- 184
	if deterministicFailure then -- 184
		context.workflow.failedTestNeedsBuild = true -- 233
		context.workflow.failedTestHasSourceEdit = false -- 234
	elseif deterministicPass then -- 234
		context.workflow.failedTestNeedsBuild = false -- 236
		context.workflow.failedTestHasSourceEdit = false -- 237
	end -- 237
end -- 180
local function executeCommand(context, input) -- 241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 241
		local mode = type(input.mode) == "string" and input.mode or "" -- 242
		local output = __TS__Await(Tools.executeCommand({ -- 243
			workDir = context.workingDir, -- 244
			mode = mode, -- 245
			code = type(input.code) == "string" and input.code or nil, -- 246
			command = type(input.command) == "string" and input.command or nil, -- 247
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 248
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 249
			isCancelled = function() return context.cancellation:isCancelled() end, -- 250
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 251
		})) -- 251
		if output.success and mode == "lua" then -- 251
			updateDeterministicTestState(context, output.output) -- 254
		end -- 254
		return ____awaiter_resolve(nil, {output = output}) -- 254
	end) -- 254
end -- 241
local function editFile(context, input) -- 276
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 276
		local operations = getAgentFileEditInputs(input) -- 277
		local isBatch = __TS__ArrayIsArray(input.edits) -- 278
		if #operations == 0 then -- 278
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 278
		end -- 278
		local staged = {} -- 280
		local results = {} -- 281
		local successfulOperations = {} -- 282
		local function failOperation(index, path, code, message) -- 283
			results[#results + 1] = { -- 284
				index = index, -- 284
				path = path, -- 284
				success = false, -- 284
				code = code, -- 284
				message = message -- 284
			} -- 284
		end -- 283
		do -- 283
			local i = 0 -- 287
			while i < #operations do -- 287
				do -- 287
					local operation = operations[i + 1] -- 288
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 289
					if path == "" then -- 289
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 291
						goto __continue60 -- 292
					end -- 292
					if operation.oldStr == operation.newStr then -- 292
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 295
						goto __continue60 -- 296
					end -- 296
					local stagedIndex = -1 -- 298
					do -- 298
						local j = 0 -- 299
						while j < #staged do -- 299
							if staged[j + 1].path == path then -- 299
								stagedIndex = j -- 301
								break -- 302
							end -- 302
							j = j + 1 -- 299
						end -- 299
					end -- 299
					if stagedIndex < 0 then -- 299
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 306
						if not targetState.success then -- 306
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 308
							goto __continue60 -- 309
						end -- 309
						staged[#staged + 1] = { -- 311
							path = path, -- 312
							initialExists = targetState.exists, -- 313
							exists = targetState.exists, -- 314
							content = targetState.content, -- 315
							changed = false -- 316
						} -- 316
						stagedIndex = #staged - 1 -- 318
					end -- 318
					local target = staged[stagedIndex + 1] -- 320
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 321
					if guardDenial ~= nil then -- 321
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 323
						goto __continue60 -- 324
					end -- 324
					local mode = "" -- 326
					if operation.oldStr == "" then -- 326
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 326
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 329
							goto __continue60 -- 330
						end -- 330
						mode = target.exists and "overwrite" or "create" -- 332
						target.exists = true -- 333
						target.content = operation.newStr -- 334
					else -- 334
						if not target.exists then -- 334
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 337
							goto __continue60 -- 338
						end -- 338
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 340
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 341
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 342
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 343
						if occurrences == 0 then -- 343
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 345
							if not indentTolerant.success then -- 345
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 347
								goto __continue60 -- 348
							end -- 348
							target.content = indentTolerant.content -- 350
							mode = "replace_indent_tolerant" -- 351
						else -- 351
							if occurrences > 1 then -- 351
								failOperation( -- 354
									i, -- 354
									path, -- 354
									"AMBIGUOUS_MATCH", -- 354
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 354
								) -- 354
								goto __continue60 -- 355
							end -- 355
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 357
							mode = "replace" -- 358
						end -- 358
					end -- 358
					target.changed = true -- 361
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 362
					successfulOperations[#successfulOperations + 1] = operation -- 363
				end -- 363
				::__continue60:: -- 363
				i = i + 1 -- 287
			end -- 287
		end -- 287
		local changedTargets = __TS__ArrayFilter( -- 366
			staged, -- 366
			function(____, item) return item.changed end -- 366
		) -- 366
		if #changedTargets == 0 then -- 366
			local firstFailure = results[1] -- 368
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 368
				success = false, -- 371
				changed = false, -- 372
				mode = "batch", -- 373
				operationCount = #operations, -- 374
				succeededOperationCount = 0, -- 375
				failedOperationCount = #results, -- 376
				results = results, -- 377
				actualSaved = false -- 378
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 378
		end -- 378
		local changes = __TS__ArrayMap( -- 388
			changedTargets, -- 388
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 388
		) -- 388
		local applyRes = Tools.applyFileChanges( -- 393
			context.taskId, -- 393
			context.workingDir, -- 393
			changes, -- 393
			{ -- 393
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 394
				toolName = "edit_file" -- 397
			} -- 397
		) -- 397
		if not applyRes.success then -- 397
			return ____awaiter_resolve( -- 397
				nil, -- 397
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 400
			) -- 400
		end -- 400
		local files = __TS__ArrayMap( -- 403
			changes, -- 403
			function(____, change) return {path = change.path, op = change.op} end -- 403
		) -- 403
		local output -- 404
		if not isBatch then -- 404
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 406
				success = true, -- 407
				changed = true, -- 408
				mode = results[1].mode, -- 409
				checkpointId = applyRes.checkpointId, -- 410
				checkpointSeq = applyRes.checkpointSeq, -- 411
				files = files -- 412
			}) -- 412
		else -- 412
			local totalCharacters = 0 -- 415
			local actualSaved = true -- 416
			for ____, item in ipairs(changedTargets) do -- 417
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 418
				if not current.success or current.content ~= item.content then -- 418
					actualSaved = false -- 419
				end -- 419
				if current.success then -- 419
					totalCharacters = totalCharacters + #current.content -- 420
				end -- 420
			end -- 420
			output = { -- 422
				success = true, -- 423
				changed = true, -- 424
				mode = "batch", -- 425
				operationCount = #operations, -- 426
				succeededOperationCount = #successfulOperations, -- 427
				failedOperationCount = #operations - #successfulOperations, -- 428
				partial = #successfulOperations < #operations, -- 429
				fileCount = #changedTargets, -- 430
				checkpointId = applyRes.checkpointId, -- 431
				checkpointSeq = applyRes.checkpointSeq, -- 432
				files = files, -- 433
				results = results, -- 434
				actualSaved = actualSaved, -- 435
				actualSavedCharacters = totalCharacters, -- 436
				currentFileExists = actualSaved, -- 437
				currentCharacters = totalCharacters, -- 438
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 439
			} -- 439
		end -- 439
		local authoredOperations = 0 -- 445
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 446
		for ____, operation in ipairs(successfulOperations) do -- 447
			do -- 447
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 448
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 448
					goto __continue88 -- 449
				end -- 449
				authoredOperations = authoredOperations + 1 -- 450
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 450
					editedPaths[#editedPaths + 1] = path -- 451
				end -- 451
			end -- 451
			::__continue88:: -- 451
		end -- 451
		if authoredOperations > 0 then -- 451
			context.workflow.unbuiltEdits = true -- 454
			context.workflow.lastBuildSucceeded = false -- 455
			if context.workflow.failedTestNeedsBuild == true then -- 455
				context.workflow.failedTestHasSourceEdit = true -- 456
			end -- 456
			context.workflow.editedPathsSinceBuild = editedPaths -- 457
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 458
		end -- 458
		return ____awaiter_resolve(nil, {output = output}) -- 458
	end) -- 458
end -- 276
local function deleteFile(context, input) -- 463
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 463
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 464
		if __TS__StringTrim(targetFile) == "" then -- 464
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 464
		end -- 464
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 466
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 467
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 468
		if not result.success then -- 468
			return ____awaiter_resolve(nil, {output = result}) -- 468
		end -- 468
		if not isInternalDocumentEdit then -- 468
			context.workflow.unbuiltEdits = true -- 474
			context.workflow.lastBuildSucceeded = false -- 475
			if context.workflow.failedTestNeedsBuild == true then -- 475
				context.workflow.failedTestHasSourceEdit = true -- 476
			end -- 476
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 477
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 477
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 478
			end -- 478
			context.workflow.editedPathsSinceBuild = editedPaths -- 479
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 480
		end -- 480
		local ____result_checkpointed_41 = result.checkpointed -- 487
		local ____result_reversible_42 = result.reversible -- 488
		local ____result_binary_43 = result.binary -- 489
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 490
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 491
		local ____result_checkpointed_40 -- 492
		if result.checkpointed then -- 492
			____result_checkpointed_40 = nil -- 492
		else -- 492
			____result_checkpointed_40 = result.message -- 492
		end -- 492
		return ____awaiter_resolve(nil, {output = { -- 492
			success = true, -- 484
			changed = true, -- 485
			mode = "delete", -- 486
			checkpointed = ____result_checkpointed_41, -- 487
			reversible = ____result_reversible_42, -- 488
			binary = ____result_binary_43, -- 489
			checkpointId = ____temp_44, -- 490
			checkpointSeq = ____temp_45, -- 491
			message = ____result_checkpointed_40, -- 492
			files = {{path = targetFile, op = "delete"}} -- 493
		}}) -- 493
	end) -- 493
end -- 463
local function askUser(context, input) -- 498
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 498
		if context.services.publishQuestionnaire == nil then -- 498
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 498
		end -- 498
		if context.sessionId == nil or context.sessionId <= 0 then -- 498
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 498
		end -- 498
		local normalized = normalizeQuestionnaire(input) -- 505
		if not normalized.success then -- 505
			return ____awaiter_resolve(nil, {output = normalized}) -- 505
		end -- 505
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 507
		if not result.success then -- 507
			return ____awaiter_resolve(nil, {output = result}) -- 507
		end -- 507
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 514
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 514
	end) -- 514
end -- 498
local function spawnSubAgent(context, input) -- 521
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 521
		if context.services.spawnSubAgent == nil then -- 521
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 521
		end -- 521
		if context.sessionId == nil or context.sessionId <= 0 then -- 521
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 521
		end -- 521
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 528
			input.filesHint, -- 529
			function(____, item) return type(item) == "string" end -- 529
		) or nil -- 529
		local result = __TS__Await(context.services:spawnSubAgent({ -- 531
			parentSessionId = context.sessionId, -- 532
			projectRoot = context.workingDir, -- 533
			title = type(input.title) == "string" and input.title or "Sub", -- 534
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 535
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 536
			filesHint = filesHint, -- 537
			disabledAgentTools = context.disabledAgentTools -- 538
		})) -- 538
		if not result.success then -- 538
			return ____awaiter_resolve(nil, {output = result}) -- 538
		end -- 538
		context.workflow.hasSpawnedSubAgentThisTask = true -- 541
		return ____awaiter_resolve(nil, {output = { -- 541
			success = true, -- 544
			sessionId = result.sessionId, -- 545
			taskId = result.taskId, -- 546
			title = result.title, -- 547
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 548
		}, control = {spawnedSubAgent = true}}) -- 548
	end) -- 548
end -- 521
local function listSubAgents(context, input) -- 554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 554
		if context.services.listSubAgents == nil then -- 554
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 554
		end -- 554
		if context.sessionId == nil or context.sessionId <= 0 then -- 554
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 554
		end -- 554
		local result = __TS__Await(context.services:listSubAgents({ -- 561
			sessionId = context.sessionId, -- 562
			projectRoot = context.workingDir, -- 563
			status = type(input.status) == "string" and input.status or nil, -- 564
			limit = type(input.limit) == "number" and input.limit or nil, -- 565
			offset = type(input.offset) == "number" and input.offset or nil, -- 566
			query = type(input.query) == "string" and input.query or nil -- 567
		})) -- 567
		return ____awaiter_resolve(nil, {output = result}) -- 567
	end) -- 567
end -- 554
local function finish(_context, input) -- 572
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 572
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 573
		return ____awaiter_resolve( -- 573
			nil, -- 573
			{ -- 574
				output = {success = true, message = message}, -- 575
				control = { -- 576
					concludeTask = true, -- 577
					finalMessage = message, -- 578
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 579
				} -- 579
			} -- 579
		) -- 579
	end) -- 579
end -- 572
____exports.AGENT_TOOL_HANDLERS = { -- 584
	read_file = readFile, -- 585
	grep_files = grepFiles, -- 586
	glob_files = globFiles, -- 587
	search_dora_doc = searchDoraDoc, -- 588
	build = build, -- 589
	fetch_url = fetchUrl, -- 590
	execute_command = executeCommand, -- 591
	analyze_image = function(context, input) return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 592
		return ____awaiter_resolve( -- 592
			nil, -- 592
			{output = __TS__Await(analyzeImage({ -- 592
				workingDir = context.workingDir, -- 592
				taskId = context.taskId, -- 592
				sessionId = context.sessionId, -- 592
				binding = context.visionBinding, -- 592
				paths = input.paths, -- 592
				question = input.question, -- 592
				criteria = input.criteria, -- 592
				isCancelled = function() return context.cancellation:isCancelled() end -- 592
			}))} -- 592
		) -- 592
	end) end, -- 592
	edit_file = editFile, -- 593
	delete_file = deleteFile, -- 594
	ask_user = askUser, -- 595
	spawn_sub_agent = spawnSubAgent, -- 596
	list_sub_agents = listSubAgents, -- 597
	finish = finish -- 598
} -- 598
return ____exports -- 598