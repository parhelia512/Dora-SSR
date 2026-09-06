-- [ts]: Session.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, SESSION_SELECT_COLUMNS, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____DoraAgent = require("Agent.DoraAgent") -- 4
local runCodingAgent = ____DoraAgent.runCodingAgent -- 4
local truncateAgentUserPrompt = ____DoraAgent.truncateAgentUserPrompt -- 4
local AgentToolRegistry = require("Agent.Tool.Registry") -- 7
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 8
local Tools = require("Agent.Tools") -- 9
local ____Database = require("Agent.Storage.Database") -- 10
local TABLE_SESSION = ____Database.TABLE_SESSION -- 11
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 12
local TABLE_STEP = ____Database.TABLE_STEP -- 13
local TABLE_TASK = ____Database.TABLE_TASK -- 14
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 15
local addTaskReference = ____Database.addTaskReference -- 16
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 17
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 18
local requireAgentStorage = ____Database.requireAgentStorage -- 19
local ____Memory = require("Agent.Memory") -- 21
local DualLayerStorage = ____Memory.DualLayerStorage -- 21
local ____Utils = require("Agent.Utils") -- 22
local Log = ____Utils.Log -- 22
local getLLMConfig = ____Utils.getLLMConfig -- 22
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 22
local safeJsonDecode = ____Utils.safeJsonDecode -- 22
local safeJsonEncode = ____Utils.safeJsonEncode -- 22
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 22
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 22
local ____Questionnaire = require("Agent.Questionnaire") -- 26
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 26
local ____Support = require("Agent.Storage.Support") -- 28
local getLastInsertRowId = ____Support.getLastInsertRowId -- 28
local queryOne = ____Support.queryOne -- 28
local queryRows = ____Support.queryRows -- 28
local toStr = ____Support.toStr -- 28
function getDefaultUseChineseResponse() -- 334
	local zh = string.match(App.locale, "^zh") -- 335
	return zh ~= nil -- 336
end -- 336
function encodeJson(value) -- 339
	local text = safeJsonEncode(value) -- 340
	return text or "" -- 341
end -- 341
function decodeJsonObject(text) -- 344
	if not text or text == "" then -- 344
		return nil -- 345
	end -- 345
	local value = safeJsonDecode(text) -- 346
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 346
		return value -- 348
	end -- 348
	return nil -- 350
end -- 350
function decodeJsonFiles(text) -- 353
	if not text or text == "" then -- 353
		return nil -- 354
	end -- 354
	local value = safeJsonDecode(text) -- 355
	if not value or not __TS__ArrayIsArray(value) then -- 355
		return nil -- 356
	end -- 356
	local files = {} -- 357
	do -- 357
		local i = 0 -- 358
		while i < #value do -- 358
			do -- 358
				local item = value[i + 1] -- 359
				if type(item) ~= "table" then -- 359
					goto __continue12 -- 360
				end -- 360
				files[#files + 1] = { -- 361
					path = sanitizeUTF8(toStr(item.path)), -- 362
					op = sanitizeUTF8(toStr(item.op)) -- 363
				} -- 363
			end -- 363
			::__continue12:: -- 363
			i = i + 1 -- 358
		end -- 358
	end -- 358
	return files -- 366
end -- 366
function decodeChangeSetSummary(value) -- 369
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 369
		return nil -- 370
	end -- 370
	local row = value -- 371
	if row.success ~= true then -- 371
		return nil -- 372
	end -- 372
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 373
	if taskId <= 0 then -- 373
		return nil -- 374
	end -- 374
	local files = {} -- 375
	if __TS__ArrayIsArray(row.files) then -- 375
		do -- 375
			local i = 0 -- 377
			while i < #row.files do -- 377
				do -- 377
					local file = row.files[i + 1] -- 378
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 378
						goto __continue20 -- 379
					end -- 379
					local fileRow = file -- 380
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 381
					if path == "" then -- 381
						goto __continue20 -- 382
					end -- 382
					local checkpointIds = {} -- 383
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 383
						do -- 383
							local j = 0 -- 385
							while j < #fileRow.checkpointIds do -- 385
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 386
								if checkpointId > 0 then -- 386
									checkpointIds[#checkpointIds + 1] = checkpointId -- 387
								end -- 387
								j = j + 1 -- 385
							end -- 385
						end -- 385
					end -- 385
					local op = toStr(fileRow.op) -- 390
					files[#files + 1] = { -- 391
						path = path, -- 392
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 393
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 394
						checkpointIds = checkpointIds -- 395
					} -- 395
				end -- 395
				::__continue20:: -- 395
				i = i + 1 -- 377
			end -- 377
		end -- 377
	end -- 377
	return { -- 399
		success = true, -- 400
		taskId = taskId, -- 401
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 402
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 403
		files = files, -- 404
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 405
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 406
	} -- 406
end -- 406
function decodeHandoffEvidence(value) -- 410
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 410
		return nil -- 411
	end -- 411
	local row = value -- 412
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 413
		__TS__ArrayFilter( -- 414
			row.modifiedFiles, -- 414
			function(____, item) return type(item) == "string" end -- 414
		), -- 414
		function(____, item) return sanitizeUTF8(item) end -- 414
	) or ({}) -- 414
	local lastBuild = nil -- 416
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 416
		local build = row.lastBuild -- 418
		lastBuild = { -- 419
			result = build.result == "passed" and "passed" or "failed", -- 420
			path = sanitizeUTF8(toStr(build.path)), -- 421
			evidence = takeUtf8Head( -- 422
				sanitizeUTF8(toStr(build.evidence)), -- 422
				600 -- 422
			) -- 422
		} -- 422
	end -- 422
	local commands = {} -- 425
	if __TS__ArrayIsArray(row.commands) then -- 425
		do -- 425
			local i = 0 -- 427
			while i < #row.commands and #commands < 8 do -- 427
				do -- 427
					local raw = row.commands[i + 1] -- 428
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 428
						goto __continue34 -- 429
					end -- 429
					local item = raw -- 430
					commands[#commands + 1] = { -- 431
						mode = sanitizeUTF8(toStr(item.mode)), -- 432
						command = takeUtf8Head( -- 433
							sanitizeUTF8(toStr(item.command)), -- 433
							600 -- 433
						), -- 433
						result = item.result == "passed" and "passed" or "failed", -- 434
						evidence = takeUtf8Head( -- 435
							sanitizeUTF8(toStr(item.evidence)), -- 435
							600 -- 435
						) -- 435
					} -- 435
				end -- 435
				::__continue34:: -- 435
				i = i + 1 -- 427
			end -- 427
		end -- 427
	end -- 427
	local authoritativeSources = {} -- 439
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 439
		do -- 439
			local i = 0 -- 441
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 441
				do -- 441
					local raw = row.authoritativeSources[i + 1] -- 442
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 442
						goto __continue38 -- 443
					end -- 443
					local item = raw -- 444
					authoritativeSources[#authoritativeSources + 1] = { -- 445
						tool = "search_dora_doc", -- 446
						query = takeUtf8Head( -- 447
							sanitizeUTF8(toStr(item.query)), -- 447
							300 -- 447
						), -- 447
						source = sanitizeUTF8(toStr(item.source)), -- 448
						result = item.result == "passed" and "passed" or "failed" -- 449
					} -- 449
				end -- 449
				::__continue38:: -- 449
				i = i + 1 -- 441
			end -- 441
		end -- 441
	end -- 441
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 453
end -- 453
function takeUtf8Head(text, maxChars) -- 456
	if maxChars <= 0 or text == "" then -- 456
		return "" -- 457
	end -- 457
	local nextPos = utf8.offset(text, maxChars + 1) -- 458
	if nextPos == nil then -- 458
		return text -- 459
	end -- 459
	return string.sub(text, 1, nextPos - 1) -- 460
end -- 460
function normalizeMemoryEntryEvidence(value) -- 463
	local evidence = {} -- 464
	if not __TS__ArrayIsArray(value) then -- 464
		return evidence -- 465
	end -- 465
	do -- 465
		local i = 0 -- 466
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 466
			do -- 466
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 467
				if item == "" then -- 467
					goto __continue46 -- 468
				end -- 468
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 468
					evidence[#evidence + 1] = item -- 470
				end -- 470
			end -- 470
			::__continue46:: -- 470
			i = i + 1 -- 466
		end -- 466
	end -- 466
	return evidence -- 473
end -- 473
function decodeSubAgentMemoryEntry(value) -- 476
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 476
		return nil -- 477
	end -- 477
	local row = value -- 478
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 479
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 480
	local content = takeUtf8Head( -- 481
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 481
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 481
	) -- 481
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 481
		return nil -- 482
	end -- 482
	return { -- 483
		sourceSessionId = sourceSessionId, -- 484
		sourceTaskId = sourceTaskId, -- 485
		content = content, -- 486
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 487
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 488
	} -- 488
end -- 488
function getTaskChangeSetSummary(taskId) -- 492
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 493
	return summary.success and summary or nil -- 494
end -- 494
function summarizeHandoffResult(result) -- 497
	local candidates = {result.output, result.message, result.state, result.phase} -- 498
	do -- 498
		local i = 0 -- 499
		while i < #candidates do -- 499
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 500
			if text ~= "" then -- 500
				return takeUtf8Head(text, 600) -- 501
			end -- 501
			i = i + 1 -- 499
		end -- 499
	end -- 499
	local messages = result.messages -- 503
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 503
		local parts = {} -- 505
		do -- 505
			local i = 0 -- 506
			while i < #messages and #parts < 4 do -- 506
				do -- 506
					local row = messages[i + 1] -- 507
					if not row or type(row) ~= "table" then -- 507
						goto __continue59 -- 508
					end -- 508
					local item = row -- 509
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 510
					local ____toStr_2 = toStr -- 510
					local ____item_message_0 = item.message -- 510
					if ____item_message_0 == nil then -- 510
						____item_message_0 = item.error -- 510
					end -- 510
					local ____item_message_0_1 = ____item_message_0 -- 510
					if ____item_message_0_1 == nil then -- 510
						____item_message_0_1 = item.file -- 510
					end -- 510
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 510
					if text ~= "" then -- 510
						parts[#parts + 1] = text -- 511
					end -- 511
				end -- 511
				::__continue59:: -- 511
				i = i + 1 -- 506
			end -- 506
		end -- 506
		if #parts > 0 then -- 506
			return takeUtf8Head( -- 513
				table.concat(parts, "; "), -- 513
				600 -- 513
			) -- 513
		end -- 513
	end -- 513
	return result.success == true and "tool result success=true" or "tool result success=false" -- 515
end -- 515
function getTaskHandoffEvidence(taskId, changeSet) -- 518
	local ____opt_4 = changeSet -- 518
	local evidence = { -- 519
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 520
			changeSet and changeSet.files, -- 520
			function(____, item) return item.path end -- 520
		) or ({}), -- 520
		commands = {}, -- 521
		authoritativeSources = {} -- 522
	} -- 522
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 524
	do -- 524
		local i = 0 -- 529
		while i < #rows do -- 529
			local tool = toStr(rows[i + 1][1]) -- 530
			local status = toStr(rows[i + 1][2]) -- 531
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 532
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 533
			local passed = status == "DONE" and result.success == true -- 534
			if tool == "build" then -- 534
				evidence.lastBuild = { -- 536
					result = passed and "passed" or "failed", -- 537
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 538
					evidence = summarizeHandoffResult(result) -- 539
				} -- 539
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 539
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 542
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 543
				local ____evidence_commands_8 = evidence.commands -- 543
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 544
					mode = mode, -- 545
					command = takeUtf8Head( -- 546
						__TS__StringTrim(sanitizeUTF8(command)), -- 546
						600 -- 546
					), -- 546
					result = passed and "passed" or "failed", -- 547
					evidence = summarizeHandoffResult(result) -- 548
				} -- 548
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 548
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 548
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 551
					tool = "search_dora_doc", -- 552
					query = takeUtf8Head( -- 553
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 553
						300 -- 553
					), -- 553
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 554
					result = passed and "passed" or "failed" -- 555
				} -- 555
			end -- 555
			i = i + 1 -- 529
		end -- 529
	end -- 529
	return evidence -- 559
end -- 559
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 562
	local lastBuild = evidence.lastBuild -- 566
	if not lastBuild or lastBuild.result ~= "failed" then -- 566
		return completion -- 567
	end -- 567
	local validation = __TS__ArraySlice(completion.validation) -- 568
	local foundBuild = false -- 569
	do -- 569
		local i = 0 -- 570
		while i < #validation do -- 570
			do -- 570
				if validation[i + 1].kind ~= "build" then -- 570
					goto __continue73 -- 571
				end -- 571
				foundBuild = true -- 572
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 573
			end -- 573
			::__continue73:: -- 573
			i = i + 1 -- 570
		end -- 570
	end -- 570
	if not foundBuild then -- 570
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 580
	end -- 580
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 582
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 583
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 583
		knownIssues[#knownIssues + 1] = issue -- 584
	end -- 584
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 585
end -- 585
function isValidProjectRoot(path) -- 593
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 594
end -- 594
function rowToSession(row) -- 597
	return { -- 598
		id = row[1], -- 599
		projectRoot = toStr(row[2]), -- 600
		title = toStr(row[3]), -- 601
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 602
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 603
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 604
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 605
		status = toStr(row[8]), -- 606
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 607
		currentTaskStatus = toStr(row[10]), -- 608
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 609
		createdAt = row[11], -- 610
		updatedAt = row[12], -- 611
		metrics = decodeJsonObject(toStr(row[13])), -- 612
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 613
	} -- 613
end -- 613
function rowToMessage(row) -- 617
	local message = { -- 618
		id = row[1], -- 619
		sessionId = row[2], -- 620
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 621
		role = toStr(row[4]), -- 622
		content = toStr(row[5]), -- 623
		createdAt = row[7], -- 624
		updatedAt = row[8] -- 625
	} -- 625
	local displayContent = toStr(row[6]) -- 627
	if displayContent ~= "" then -- 627
		message.displayContent = displayContent -- 628
	end -- 628
	return message -- 629
end -- 629
function rowToStep(row) -- 632
	return { -- 633
		id = row[1], -- 634
		sessionId = row[2], -- 635
		taskId = row[3], -- 636
		step = row[4], -- 637
		tool = toStr(row[5]), -- 638
		status = toStr(row[6]), -- 639
		reason = toStr(row[7]), -- 640
		reasoningContent = toStr(row[8]), -- 641
		params = decodeJsonObject(toStr(row[9])), -- 642
		result = decodeJsonObject(toStr(row[10])), -- 643
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 644
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 645
		files = decodeJsonFiles(toStr(row[13])), -- 646
		createdAt = row[14], -- 647
		updatedAt = row[15] -- 648
	} -- 648
end -- 648
function getQuestionnairePath(projectRoot) -- 652
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 653
end -- 653
function decodeQuestionnaireFile(text) -- 656
	local value = decodeJsonObject(text) -- 657
	if not value then -- 657
		return nil -- 658
	end -- 658
	local schema = value.schema -- 659
	local id = type(value.id) == "number" and value.id or 0 -- 660
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 661
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 662
	local step = type(value.step) == "number" and value.step or 0 -- 663
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 664
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 664
		return nil -- 666
	end -- 666
	return { -- 668
		id = id, -- 668
		sessionId = sessionId, -- 668
		taskId = taskId, -- 668
		step = step, -- 668
		status = "PENDING", -- 668
		schema = schema, -- 668
		createdAt = createdAt -- 668
	} -- 668
end -- 668
function getPendingQuestionnaire(sessionId) -- 671
	local session = getSessionItem(sessionId) -- 672
	if not session or session.kind ~= "main" then -- 672
		return nil -- 673
	end -- 673
	local path = getQuestionnairePath(session.projectRoot) -- 674
	if not Content:exist(path) then -- 674
		return nil -- 675
	end -- 675
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 676
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 677
end -- 677
function restorePendingQuestionnaireState(session) -- 680
	local questionnaire = getPendingQuestionnaire(session.id) -- 681
	if not questionnaire then -- 681
		return {session = session} -- 682
	end -- 682
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 682
		local t = now() -- 689
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 690
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 696
		local restored = getSessionItem(session.id) -- 697
		if restored then -- 697
			session = restored -- 698
		end -- 698
	end -- 698
	return {session = session, questionnaire = questionnaire} -- 700
end -- 700
function savePendingQuestionnaire(projectRoot, questionnaire) -- 703
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 704
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 704
		return false -- 705
	end -- 705
	local path = getQuestionnairePath(projectRoot) -- 706
	local tempPath = path .. ".tmp" -- 707
	local backupPath = path .. ".bak" -- 708
	Content:remove(tempPath) -- 709
	Content:remove(backupPath) -- 710
	if not Content:save( -- 710
		tempPath, -- 711
		encodeJson(questionnaire) -- 711
	) then -- 711
		return false -- 711
	end -- 711
	local hadOriginal = Content:exist(path) -- 712
	if hadOriginal and not Content:move(path, backupPath) then -- 712
		Content:remove(tempPath) -- 714
		return false -- 715
	end -- 715
	if Content:move(tempPath, path) then -- 715
		Content:remove(backupPath) -- 718
		Tools.sendWebIDEFileUpdate( -- 719
			path, -- 719
			true, -- 719
			encodeJson(questionnaire) -- 719
		) -- 719
		return true -- 720
	end -- 720
	Content:remove(tempPath) -- 722
	if hadOriginal and Content:exist(backupPath) then -- 722
		Content:move(backupPath, path) -- 724
	end -- 724
	return false -- 726
end -- 726
function removePendingQuestionnaire(session) -- 729
	local path = getQuestionnairePath(session.projectRoot) -- 730
	if not Content:exist(path) then -- 730
		return true -- 731
	end -- 731
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 732
	if questionnaire and questionnaire.sessionId ~= session.id then -- 732
		return false -- 733
	end -- 733
	if not Content:remove(path) then -- 733
		return false -- 734
	end -- 734
	Tools.sendWebIDEFileUpdate(path, false, "") -- 735
	return true -- 736
end -- 736
function publishQuestionnaire(request) -- 739
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 739
		local session = getSessionItem(request.sessionId) -- 745
		if not session or session.kind ~= "main" then -- 745
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 745
		end -- 745
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 747
		if Content:exist(pendingPath) then -- 747
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 747
		end -- 747
		local questionnaire = { -- 749
			id = request.taskId, -- 750
			sessionId = request.sessionId, -- 751
			taskId = request.taskId, -- 752
			step = request.step, -- 753
			status = "PENDING", -- 754
			schema = request.schema, -- 755
			createdAt = now() -- 756
		} -- 756
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 756
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 756
		end -- 756
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 756
	end) -- 756
end -- 756
function getMessageItem(messageId) -- 764
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 765
	return row and rowToMessage(row) or nil -- 771
end -- 771
function getStepItem(sessionId, taskId, step) -- 774
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 775
	return row and rowToStep(row) or nil -- 781
end -- 781
function deleteMessageSteps(sessionId, taskId) -- 784
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 785
	local ids = {} -- 790
	do -- 790
		local i = 0 -- 791
		while i < #rows do -- 791
			local row = rows[i + 1] -- 792
			if type(row[1]) == "number" then -- 792
				ids[#ids + 1] = row[1] -- 794
			end -- 794
			i = i + 1 -- 791
		end -- 791
	end -- 791
	if #ids > 0 then -- 791
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 798
	end -- 798
	return ids -- 804
end -- 804
function normalizeDisabledAgentTools(value) -- 807
	if not __TS__ArrayIsArray(value) then -- 807
		return {} -- 808
	end -- 808
	local tools = {} -- 809
	do -- 809
		local i = 0 -- 810
		while i < #value do -- 810
			do -- 810
				local name = value[i + 1] -- 811
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 811
					goto __continue117 -- 812
				end -- 812
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 812
					tools[#tools + 1] = name -- 813
				end -- 813
			end -- 813
			::__continue117:: -- 813
			i = i + 1 -- 810
		end -- 810
	end -- 810
	return tools -- 815
end -- 815
function normalizeWorkMode(value, fallback) -- 818
	if fallback == nil then -- 818
		fallback = "code" -- 818
	end -- 818
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 819
end -- 819
function getSessionRow(sessionId) -- 822
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 823
end -- 823
function getSessionItem(sessionId) -- 831
	local row = getSessionRow(sessionId) -- 832
	return row and rowToSession(row) or nil -- 833
end -- 833
function getTaskPrompt(taskId) -- 836
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 837
	if not row or type(row[1]) ~= "string" then -- 837
		return nil -- 838
	end -- 838
	return toStr(row[1]) -- 839
end -- 839
function getLatestMainSessionByProjectRoot(projectRoot) -- 842
	if not isValidProjectRoot(projectRoot) then -- 842
		return nil -- 843
	end -- 843
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 844
	return row and rowToSession(row) or nil -- 852
end -- 852
function countRunningSubSessions(rootSessionId) -- 855
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 856
	local count = 0 -- 863
	do -- 863
		local i = 0 -- 864
		while i < #rows do -- 864
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 865
			if session.currentTaskStatus == "RUNNING" then -- 865
				count = count + 1 -- 867
			end -- 867
			i = i + 1 -- 864
		end -- 864
	end -- 864
	return count -- 870
end -- 870
function deleteSessionRecords(sessionId, preserveArtifacts) -- 873
	if preserveArtifacts == nil then -- 873
		preserveArtifacts = false -- 873
	end -- 873
	local session = getSessionItem(sessionId) -- 874
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 875
	local taskIds = {} -- 883
	do -- 883
		local i = 0 -- 884
		while i < #taskRows do -- 884
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 885
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 885
				taskIds[#taskIds + 1] = taskId -- 887
				local stopToken = activeStopTokens[taskId] -- 888
				if stopToken ~= nil then -- 888
					stopToken.stopped = true -- 890
					stopToken.reason = "session deleted" -- 891
				end -- 891
			end -- 891
			i = i + 1 -- 884
		end -- 884
	end -- 884
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 895
	do -- 895
		local i = 0 -- 896
		while i < #children do -- 896
			local row = children[i + 1] -- 897
			if type(row[1]) == "number" and row[1] > 0 then -- 897
				deleteSessionRecords(row[1], preserveArtifacts) -- 899
			end -- 899
			i = i + 1 -- 896
		end -- 896
	end -- 896
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 902
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 903
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 904
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 905
	if session and session.kind == "main" then -- 905
		removePendingQuestionnaire(session) -- 907
	end -- 907
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 907
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 907
			Tools.sendWebIDERefreshTree() -- 911
		end -- 911
	end -- 911
	do -- 911
		local i = 0 -- 914
		while i < #taskIds do -- 914
			cleanupTaskHeavyData(taskIds[i + 1]) -- 915
			i = i + 1 -- 914
		end -- 914
	end -- 914
end -- 914
function getSessionRootId(session) -- 919
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 920
end -- 920
function getRootSessionItem(sessionId) -- 923
	local session = getSessionItem(sessionId) -- 924
	if not session then -- 924
		return nil -- 925
	end -- 925
	return getSessionItem(getSessionRootId(session)) or session -- 926
end -- 926
function listRelatedSessions(sessionId) -- 929
	local root = getRootSessionItem(sessionId) -- 930
	if not root then -- 930
		return {} -- 931
	end -- 931
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 932
	return __TS__ArrayMap( -- 941
		rows, -- 941
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 941
	) -- 941
end -- 941
function getSessionSpawnInfo(session) -- 944
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 945
	if not info then -- 945
		return nil -- 946
	end -- 946
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 948
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 949
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 950
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 951
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 952
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 953
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 954
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 955
		__TS__ArrayFilter( -- 956
			info.filesHint, -- 956
			function(____, item) return type(item) == "string" end -- 956
		), -- 956
		function(____, item) return sanitizeUTF8(item) end -- 956
	) or nil -- 956
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 958
	local ____temp_13 -- 961
	if info.success == true then -- 961
		____temp_13 = true -- 961
	else -- 961
		local ____temp_12 -- 961
		if info.success == false then -- 961
			____temp_12 = false -- 961
		else -- 961
			____temp_12 = nil -- 961
		end -- 961
		____temp_13 = ____temp_12 -- 961
	end -- 961
	local ____temp_14 -- 962
	if info.cleared == true then -- 962
		____temp_14 = true -- 962
	else -- 962
		____temp_14 = nil -- 962
	end -- 962
	return { -- 947
		sessionId = ____temp_15, -- 948
		rootSessionId = ____temp_16, -- 949
		parentSessionId = ____temp_17, -- 950
		title = ____temp_18, -- 951
		prompt = ____temp_19, -- 952
		goal = ____temp_20, -- 953
		expectedOutput = ____temp_21, -- 954
		filesHint = ____temp_22, -- 955
		status = ____temp_23, -- 958
		success = ____temp_13, -- 961
		cleared = ____temp_14, -- 962
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 963
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 964
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 965
		changeSet = decodeChangeSetSummary(info.changeSet), -- 966
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 967
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 968
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 969
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 970
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 973
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 974
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 975
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 976
	} -- 976
end -- 976
function ensureDirRecursive(dir) -- 993
	if not dir or dir == "" then -- 993
		return false -- 994
	end -- 994
	if Content:exist(dir) then -- 994
		return Content:isdir(dir) -- 995
	end -- 995
	local parent = Path:getPath(dir) -- 996
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 996
		if not ensureDirRecursive(parent) then -- 996
			return false -- 999
		end -- 999
	end -- 999
	return Content:mkdir(dir) -- 1002
end -- 1002
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1005
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1006
	if not Content:exist(dir) then -- 1006
		ensureDirRecursive(dir) -- 1008
	end -- 1008
	local path = Path(dir, SPAWN_INFO_FILE) -- 1010
	local text = safeJsonEncode(value) -- 1011
	if not text then -- 1011
		return false -- 1012
	end -- 1012
	local content = text .. "\n" -- 1013
	if not Content:save(path, content) then -- 1013
		return false -- 1015
	end -- 1015
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1017
	return true -- 1018
end -- 1018
function readSpawnInfo(projectRoot, memoryScope) -- 1021
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1022
	if not Content:exist(path) then -- 1022
		return nil -- 1023
	end -- 1023
	local text = Content:load(path) -- 1024
	if not text or __TS__StringTrim(text) == "" then -- 1024
		return nil -- 1025
	end -- 1025
	local value = safeJsonDecode(text) -- 1026
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1026
		return value -- 1028
	end -- 1028
	return nil -- 1030
end -- 1030
function getArtifactRelativeDir(memoryScope) -- 1033
	return Path(".agent", memoryScope) -- 1034
end -- 1034
function getArtifactDir(projectRoot, memoryScope) -- 1037
	return Path( -- 1038
		projectRoot, -- 1038
		getArtifactRelativeDir(memoryScope) -- 1038
	) -- 1038
end -- 1038
function getResultRelativePath(memoryScope) -- 1041
	return Path( -- 1042
		getArtifactRelativeDir(memoryScope), -- 1042
		RESULT_FILE -- 1042
	) -- 1042
end -- 1042
function getResultPath(projectRoot, memoryScope) -- 1045
	return Path( -- 1046
		projectRoot, -- 1046
		getResultRelativePath(memoryScope) -- 1046
	) -- 1046
end -- 1046
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1049
	if not resultFilePath or resultFilePath == "" then -- 1049
		return "" -- 1050
	end -- 1050
	local path = Path(projectRoot, resultFilePath) -- 1051
	if not Content:exist(path) then -- 1051
		return "" -- 1052
	end -- 1052
	local text = sanitizeUTF8(Content:load(path)) -- 1053
	if not text or __TS__StringTrim(text) == "" then -- 1053
		return "" -- 1054
	end -- 1054
	local marker = "\n## Summary\n" -- 1055
	local start = string.find(text, marker, 1, true) -- 1056
	if start ~= nil then -- 1056
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1058
	end -- 1058
	return __TS__StringTrim(text) -- 1060
end -- 1060
function buildStructuredSubAgentMemoryEntry(record) -- 1063
	local hasPassedValidation = false -- 1064
	do -- 1064
		local i = 0 -- 1065
		while i < #record.completion.validation do -- 1065
			local result = record.completion.validation[i + 1].result -- 1066
			if result == "failed" then -- 1066
				return nil -- 1071
			end -- 1071
			if result == "passed" then -- 1071
				hasPassedValidation = true -- 1073
			end -- 1073
			i = i + 1 -- 1065
		end -- 1065
	end -- 1065
	if not hasPassedValidation then -- 1065
		return nil -- 1076
	end -- 1076
	local candidates = record.completion.learningCandidates -- 1077
	local claims = {} -- 1078
	local evidence = {} -- 1079
	do -- 1079
		local i = 0 -- 1080
		while i < #candidates do -- 1080
			do -- 1080
				local candidate = candidates[i + 1] -- 1081
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1081
					goto __continue188 -- 1082
				end -- 1082
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1083
				do -- 1083
					local j = 0 -- 1084
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1084
						local item = candidate.evidence[j + 1] -- 1085
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1085
							evidence[#evidence + 1] = item -- 1086
						end -- 1086
						j = j + 1 -- 1084
					end -- 1084
				end -- 1084
			end -- 1084
			::__continue188:: -- 1084
			i = i + 1 -- 1080
		end -- 1080
	end -- 1080
	local content = takeUtf8Head( -- 1089
		table.concat(claims, "\n"), -- 1089
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1089
	) -- 1089
	if content == "" then -- 1089
		return nil -- 1090
	end -- 1090
	return { -- 1091
		sourceSessionId = record.sessionId, -- 1092
		sourceTaskId = record.sourceTaskId, -- 1093
		content = content, -- 1094
		evidence = evidence, -- 1095
		createdAt = record.finishedAt -- 1096
	} -- 1096
end -- 1096
function containsNormalizedText(text, query) -- 1100
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1101
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1102
	if normalizedQuery == "" then -- 1102
		return true -- 1103
	end -- 1103
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1104
end -- 1104
function getSubAgentDisplayKey(item) -- 1107
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1113
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1114
	local label = goal ~= "" and goal or title -- 1115
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1116
end -- 1116
function writeSubAgentResultFile(session, record, resultText) -- 1119
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1120
	if not Content:exist(dir) then -- 1120
		ensureDirRecursive(dir) -- 1122
	end -- 1122
	local ____array_32 = __TS__SparseArrayNew( -- 1122
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1125
		"- Status: " .. record.status, -- 1126
		"- Success: " .. (record.success and "true" or "false"), -- 1127
		"- Outcome: " .. record.completion.outcome, -- 1128
		"- Session ID: " .. tostring(record.sessionId), -- 1129
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1130
		"- Goal: " .. record.goal, -- 1131
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1132
	) -- 1132
	__TS__SparseArrayPush( -- 1132
		____array_32, -- 1132
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1133
	) -- 1133
	__TS__SparseArrayPush( -- 1133
		____array_32, -- 1133
		"- Finished At: " .. record.finishedAt, -- 1134
		"", -- 1135
		"## Validation", -- 1136
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1137
			record.completion.validation, -- 1138
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1138
		) or ({"- Not reported"})) -- 1138
	) -- 1138
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1138
	local ____opt_24 = record.handoffEvidence -- 1138
	__TS__SparseArrayPush( -- 1138
		____array_32, -- 1138
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1142
			record.handoffEvidence.modifiedFiles, -- 1143
			function(____, item) return "- modified: " .. item end -- 1143
		) or ({"- modified: none recorded"})) -- 1143
	) -- 1143
	local ____opt_26 = record.handoffEvidence -- 1143
	__TS__SparseArrayPush( -- 1143
		____array_32, -- 1143
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1145
	) -- 1145
	local ____opt_28 = record.handoffEvidence -- 1145
	__TS__SparseArrayPush( -- 1145
		____array_32, -- 1145
		table.unpack(__TS__ArrayMap( -- 1148
			____opt_28 and ____opt_28.commands or ({}), -- 1148
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1148
		)) -- 1148
	) -- 1148
	local ____opt_30 = record.handoffEvidence -- 1148
	__TS__SparseArrayPush( -- 1148
		____array_32, -- 1148
		table.unpack(__TS__ArrayMap( -- 1149
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1149
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1149
		)) -- 1149
	) -- 1149
	__TS__SparseArrayPush( -- 1149
		____array_32, -- 1149
		"", -- 1150
		"## Known Issues", -- 1151
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1152
			record.completion.knownIssues, -- 1152
			function(____, item) return "- " .. item end -- 1152
		) or ({"- None reported"})) -- 1152
	) -- 1152
	__TS__SparseArrayPush( -- 1152
		____array_32, -- 1152
		"", -- 1153
		"## Assumptions", -- 1154
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1155
			record.completion.assumptions, -- 1155
			function(____, item) return "- " .. item end -- 1155
		) or ({"- None reported"})) -- 1155
	) -- 1155
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1155
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1124
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1160
	local content = table.concat(lines, "\n") .. "\n" -- 1161
	if not Content:save(path, content) then -- 1161
		return false -- 1163
	end -- 1163
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1165
	return true -- 1166
end -- 1166
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1169
	local dir = Path(projectRoot, ".agent", "subagents") -- 1170
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1170
		return {} -- 1171
	end -- 1171
	local items = {} -- 1172
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1173
		do -- 1173
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1174
			if not Content:exist(path) or not Content:isdir(path) then -- 1174
				goto __continue208 -- 1175
			end -- 1175
			local info = readSpawnInfo( -- 1176
				projectRoot, -- 1176
				Path( -- 1176
					"subagents", -- 1176
					Path:getFilename(path) -- 1176
				) -- 1176
			) -- 1176
			if not info then -- 1176
				goto __continue208 -- 1177
			end -- 1177
			local sessionId = tonumber(info.sessionId) -- 1178
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1179
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1180
			local status = sanitizeUTF8(toStr(info.status)) -- 1181
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1181
				goto __continue208 -- 1182
			end -- 1182
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1182
				goto __continue208 -- 1183
			end -- 1183
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1184
			items[#items + 1] = { -- 1185
				sessionId = sessionId, -- 1186
				rootSessionId = infoRootSessionId, -- 1187
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1188
				title = sanitizeUTF8(toStr(info.title)), -- 1189
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1190
				goal = sanitizeUTF8(toStr(info.goal)), -- 1191
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1192
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1193
					__TS__ArrayFilter( -- 1194
						info.filesHint, -- 1194
						function(____, item) return type(item) == "string" end -- 1194
					), -- 1194
					function(____, item) return sanitizeUTF8(item) end -- 1194
				) or ({}), -- 1194
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1196
				success = info.success == true, -- 1197
				cleared = info.cleared == true, -- 1198
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1199
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1200
					"subagents", -- 1200
					Path:getFilename(path) -- 1200
				)), -- 1200
				sourceTaskId = sourceTaskId or 0, -- 1201
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1202
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1203
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1204
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1205
				completion = normalizeAgentCompletionReport(info.completion), -- 1206
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1207
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1208
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1209
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1210
			} -- 1210
		end -- 1210
		::__continue208:: -- 1210
	end -- 1210
	__TS__ArraySort( -- 1213
		items, -- 1213
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1213
	) -- 1213
	return items -- 1214
end -- 1214
function getPendingHandoffDir(projectRoot, memoryScope) -- 1217
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1218
end -- 1218
function writePendingHandoff(projectRoot, memoryScope, value) -- 1221
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1222
	if not Content:exist(dir) then -- 1222
		ensureDirRecursive(dir) -- 1224
	end -- 1224
	local path = Path(dir, value.id .. ".json") -- 1226
	local text = safeJsonEncode(value) -- 1227
	if not text then -- 1227
		return false -- 1228
	end -- 1228
	local content = text .. "\n" -- 1229
	if not Content:save(path, content) then -- 1229
		return false -- 1230
	end -- 1230
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1231
	return true -- 1232
end -- 1232
function listPendingHandoffs(projectRoot, memoryScope) -- 1235
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1236
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1236
		return {} -- 1237
	end -- 1237
	local items = {} -- 1238
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1239
		do -- 1239
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1240
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1240
				goto __continue224 -- 1241
			end -- 1241
			local text = Content:load(path) -- 1242
			if not text or __TS__StringTrim(text) == "" then -- 1242
				goto __continue224 -- 1243
			end -- 1243
			local obj = safeJsonDecode(text) -- 1244
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1244
				goto __continue224 -- 1245
			end -- 1245
			local value = obj -- 1246
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1247
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1248
			local id = sanitizeUTF8(toStr(value.id)) -- 1249
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1250
			local message = sanitizeUTF8(toStr(value.message)) -- 1251
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1252
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1253
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1254
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1254
				goto __continue224 -- 1256
			end -- 1256
			items[#items + 1] = { -- 1258
				id = id, -- 1259
				sourceSessionId = sourceSessionId, -- 1260
				sourceTitle = sourceTitle, -- 1261
				sourceTaskId = sourceTaskId, -- 1262
				message = message, -- 1263
				prompt = prompt, -- 1264
				goal = goal, -- 1265
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1266
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1267
					__TS__ArrayFilter( -- 1268
						value.filesHint, -- 1268
						function(____, item) return type(item) == "string" end -- 1268
					), -- 1268
					function(____, item) return sanitizeUTF8(item) end -- 1268
				) or ({}), -- 1268
				success = value.success == true, -- 1270
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1271
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1272
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1273
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1274
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1275
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1276
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1277
				createdAt = createdAt -- 1280
			} -- 1280
		end -- 1280
		::__continue224:: -- 1280
	end -- 1280
	__TS__ArraySort( -- 1283
		items, -- 1283
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1283
	) -- 1283
	return items -- 1284
end -- 1284
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1287
	local path = Path( -- 1288
		getPendingHandoffDir(projectRoot, memoryScope), -- 1288
		id .. ".json" -- 1288
	) -- 1288
	if Content:exist(path) then -- 1288
		if Content:remove(path) then -- 1288
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1291
		end -- 1291
	end -- 1291
end -- 1291
function normalizePromptText(prompt) -- 1296
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1297
end -- 1297
function normalizePromptTextSafe(prompt) -- 1300
	if type(prompt) == "string" then -- 1300
		local normalized = normalizePromptText(prompt) -- 1302
		if normalized ~= "" then -- 1302
			return normalized -- 1303
		end -- 1303
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1304
		if sanitized ~= "" then -- 1304
			return truncateAgentUserPrompt(sanitized) -- 1306
		end -- 1306
		return "" -- 1308
	end -- 1308
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1310
	if text == "" then -- 1310
		return "" -- 1311
	end -- 1311
	return truncateAgentUserPrompt(text) -- 1312
end -- 1312
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1315
	local sections = {} -- 1316
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1317
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1318
	local normalizedFiles = __TS__ArrayFilter( -- 1319
		__TS__ArrayMap( -- 1319
			__TS__ArrayFilter( -- 1319
				filesHint or ({}), -- 1319
				function(____, item) return type(item) == "string" end -- 1320
			), -- 1320
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1321
		), -- 1321
		function(____, item) return item ~= "" end -- 1322
	) -- 1322
	if normalizedTitle ~= "" then -- 1322
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1324
	end -- 1324
	if normalizedExpected ~= "" then -- 1324
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1327
	end -- 1327
	if #normalizedFiles > 0 then -- 1327
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1330
	end -- 1330
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1332
end -- 1332
function normalizeSessionRuntimeState(session) -- 1335
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1335
		return session -- 1337
	end -- 1337
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1337
		return session -- 1340
	end -- 1340
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1342
		session.id, -- 1345
		session.currentTaskId, -- 1345
		"fetch_url", -- 1345
		"execute_command", -- 1345
		"analyze_image" -- 1345
	}) or ({}) -- 1345
	if #pendingToolRows > 0 then -- 1345
		local t = now() -- 1348
		do -- 1348
			local i = 0 -- 1349
			while i < #pendingToolRows do -- 1349
				local row = pendingToolRows[i + 1] -- 1350
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1351
				result.success = false -- 1352
				result.state = "failed" -- 1353
				result.interrupted = true -- 1354
				result.message = "tool call was interrupted because the program exited before it completed." -- 1355
				DB:exec( -- 1356
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1356
					{ -- 1358
						encodeJson(result), -- 1358
						t, -- 1358
						row[1] -- 1358
					} -- 1358
				) -- 1358
				i = i + 1 -- 1349
			end -- 1349
		end -- 1349
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1361
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1362
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1363
	end -- 1363
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1370
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1371
	return __TS__ObjectAssign( -- 1372
		{}, -- 1372
		session, -- 1373
		{ -- 1372
			status = "STOPPED", -- 1374
			currentTaskStatus = "STOPPED", -- 1375
			updatedAt = now() -- 1376
		} -- 1376
	) -- 1376
end -- 1376
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1380
	DB:exec( -- 1381
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1381
		{ -- 1385
			status, -- 1386
			currentTaskId or 0, -- 1387
			currentTaskStatus or status, -- 1388
			now(), -- 1389
			sessionId -- 1390
		} -- 1390
	) -- 1390
end -- 1390
function mergeAgentMetrics(current, next) -- 1395
	return __TS__ObjectAssign({}, current or ({}), next) -- 1396
end -- 1396
function updateSessionMetrics(sessionId, metrics) -- 1402
	local session = getSessionItem(sessionId) -- 1403
	if not session then -- 1403
		return nil -- 1404
	end -- 1404
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1405
	DB:exec( -- 1406
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1406
		{ -- 1410
			encodeJson(merged), -- 1411
			now(), -- 1412
			sessionId -- 1413
		} -- 1413
	) -- 1413
	return merged -- 1416
end -- 1416
function clearSessionTokenUsage(sessionId) -- 1419
	local session = getSessionItem(sessionId) -- 1420
	if not session then -- 1420
		return nil -- 1421
	end -- 1421
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1422
	__TS__Delete(metrics, "usage") -- 1423
	__TS__Delete(metrics, "visionUsage") -- 1424
	DB:exec( -- 1425
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1425
		{ -- 1429
			encodeJson(metrics), -- 1430
			now(), -- 1431
			sessionId -- 1432
		} -- 1432
	) -- 1432
	return metrics -- 1435
end -- 1435
function getInitialTokenUsage(session) -- 1438
	local ____opt_33 = session.metrics -- 1438
	local usage = ____opt_33 and ____opt_33.usage -- 1439
	if not usage or (usage.requestCount or 0) <= 0 then -- 1439
		return nil -- 1440
	end -- 1440
	return { -- 1441
		inputTokens = usage.inputTokens or 0, -- 1442
		outputTokens = usage.outputTokens or 0, -- 1443
		totalTokens = usage.totalTokens, -- 1444
		cachedInputTokens = usage.cachedInputTokens, -- 1445
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1446
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1447
		requestCount = usage.requestCount or 0, -- 1448
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1449
		model = usage.model or "", -- 1450
		phase = usage.phase or "", -- 1451
		step = usage.step or 0, -- 1452
		updatedAt = usage.updatedAt or now() -- 1453
	} -- 1453
end -- 1453
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1457
	if taskId == nil or taskId <= 0 then -- 1457
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1459
		return -- 1460
	end -- 1460
	local row = getSessionRow(sessionId) -- 1462
	if not row then -- 1462
		return -- 1463
	end -- 1463
	local session = rowToSession(row) -- 1464
	if session.currentTaskId ~= taskId then -- 1464
		Log( -- 1466
			"Info", -- 1466
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1466
		) -- 1466
		return -- 1467
	end -- 1467
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1469
end -- 1469
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1472
	local t = now() -- 1473
	DB:exec( -- 1474
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1474
		{ -- 1477
			sessionId, -- 1478
			taskId or 0, -- 1479
			role, -- 1480
			sanitizeUTF8(content), -- 1481
			displayContent and sanitizeUTF8(displayContent) or "", -- 1482
			t, -- 1483
			t -- 1484
		} -- 1484
	) -- 1484
	return getLastInsertRowId() -- 1487
end -- 1487
function updateMessage(messageId, content) -- 1490
	DB:exec( -- 1491
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1491
		{ -- 1493
			sanitizeUTF8(content), -- 1493
			now(), -- 1493
			messageId -- 1493
		} -- 1493
	) -- 1493
end -- 1493
function updateUserMessageForTask(messageId, content, taskId) -- 1497
	DB:exec( -- 1498
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1498
		{ -- 1502
			sanitizeUTF8(content), -- 1502
			taskId, -- 1502
			now(), -- 1502
			messageId -- 1502
		} -- 1502
	) -- 1502
end -- 1502
function removeContinuableTaskSummary(session) -- 1559
	local taskId = session.currentTaskId -- 1560
	if taskId == nil then -- 1560
		return -- 1561
	end -- 1561
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1562
end -- 1562
function upsertAssistantMessage(sessionId, taskId, content) -- 1574
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1575
	if row and type(row[1]) == "number" then -- 1575
		updateMessage(row[1], content) -- 1582
		return row[1] -- 1583
	end -- 1583
	return insertMessage(sessionId, "assistant", content, taskId) -- 1585
end -- 1585
function upsertStep(sessionId, taskId, step, tool, patch) -- 1588
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1598
	local reason = sanitizeUTF8(patch.reason or "") -- 1602
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1603
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1604
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1605
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1606
	local statusPatch = patch.status or "" -- 1607
	local status = patch.status or "PENDING" -- 1608
	if not row then -- 1608
		local t = now() -- 1610
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1611
			sessionId, -- 1615
			taskId, -- 1616
			step, -- 1617
			tool, -- 1618
			status, -- 1619
			reason, -- 1620
			reasoningContent, -- 1621
			paramsJson, -- 1622
			resultJson, -- 1623
			patch.checkpointId or 0, -- 1624
			patch.checkpointSeq or 0, -- 1625
			filesJson, -- 1626
			t, -- 1627
			t -- 1628
		}) -- 1628
		return -- 1631
	end -- 1631
	DB:exec( -- 1633
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1633
		{ -- 1645
			tool, -- 1646
			statusPatch, -- 1647
			status, -- 1648
			reason, -- 1649
			reason, -- 1650
			reasoningContent, -- 1651
			reasoningContent, -- 1652
			paramsJson, -- 1653
			paramsJson, -- 1654
			resultJson, -- 1655
			resultJson, -- 1656
			patch.checkpointId or 0, -- 1657
			patch.checkpointId or 0, -- 1658
			patch.checkpointSeq or 0, -- 1659
			patch.checkpointSeq or 0, -- 1660
			filesJson, -- 1661
			filesJson, -- 1662
			now(), -- 1663
			row[1] -- 1664
		} -- 1664
	) -- 1664
end -- 1664
function getNextStepNumber(sessionId, taskId) -- 1669
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1670
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1674
	return math.max(0, current) + 1 -- 1675
end -- 1675
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1716
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1724
	local t = now() -- 1725
	local sqls = { -- 1726
		{ -- 1727
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1727
			{{ -- 1730
				sessionId, -- 1731
				ownerTaskId, -- 1732
				step, -- 1733
				"sub_agent_handoff", -- 1734
				"DONE", -- 1735
				sanitizeUTF8(reason), -- 1736
				encodeJson(params), -- 1737
				encodeJson(result), -- 1738
				t, -- 1739
				t -- 1740
			}} -- 1740
		}, -- 1740
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1743
	} -- 1743
	if not DB:transaction(sqls) then -- 1743
		return nil -- 1749
	end -- 1749
	return getStepItem(sessionId, ownerTaskId, step) -- 1750
end -- 1750
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1753
	if taskId <= 0 then -- 1753
		return -- 1754
	end -- 1754
	if finalSteps ~= nil and finalSteps >= 0 then -- 1754
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1756
	end -- 1756
	if not finalStatus then -- 1756
		return -- 1762
	end -- 1762
	if finalSteps ~= nil and finalSteps >= 0 then -- 1762
		DB:exec( -- 1764
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1764
			{ -- 1768
				finalStatus, -- 1768
				now(), -- 1768
				sessionId, -- 1768
				taskId, -- 1768
				finalSteps -- 1768
			} -- 1768
		) -- 1768
		return -- 1770
	end -- 1770
	DB:exec( -- 1772
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1772
		{ -- 1776
			finalStatus, -- 1776
			now(), -- 1776
			sessionId, -- 1776
			taskId -- 1776
		} -- 1776
	) -- 1776
end -- 1776
function emitAgentSessionPatch(sessionId, patch) -- 1803
	if HttpServer.wsConnectionCount == 0 then -- 1803
		return -- 1805
	end -- 1805
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1807
	if not text then -- 1807
		return -- 1812
	end -- 1812
	emit("AppWS", "Send", text) -- 1813
end -- 1813
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1816
	emitAgentSessionPatch( -- 1817
		sessionId, -- 1817
		{ -- 1817
			sessionDeleted = true, -- 1818
			relatedSessions = listRelatedSessions(rootSessionId) -- 1819
		} -- 1819
	) -- 1819
	local rootSession = getSessionItem(rootSessionId) -- 1821
	if rootSession then -- 1821
		emitAgentSessionPatch( -- 1823
			rootSessionId, -- 1823
			{ -- 1823
				session = rootSession, -- 1824
				relatedSessions = listRelatedSessions(rootSessionId) -- 1825
			} -- 1825
		) -- 1825
	end -- 1825
end -- 1825
function flushPendingSubAgentHandoffs(rootSession) -- 1830
	if rootSession.kind ~= "main" then -- 1830
		return -- 1831
	end -- 1831
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1831
		return -- 1833
	end -- 1833
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1835
	if #items == 0 then -- 1835
		return -- 1836
	end -- 1836
	local handoffTaskId = 0 -- 1837
	local previousTaskId = rootSession.currentTaskId -- 1838
	local ____rootSession_currentTaskId_37 -- 1839
	if rootSession.currentTaskId then -- 1839
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1839
	else -- 1839
		____rootSession_currentTaskId_37 = nil -- 1839
	end -- 1839
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1839
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1839
		handoffTaskId = rootSession.currentTaskId -- 1847
	else -- 1847
		local taskRes = Tools.createTask( -- 1849
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1849
			"code" -- 1849
		) -- 1849
		if not taskRes.success then -- 1849
			Log( -- 1851
				"Warn", -- 1851
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1851
			) -- 1851
			return -- 1852
		end -- 1852
		handoffTaskId = taskRes.taskId -- 1854
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1855
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1856
		emitAgentSessionPatch( -- 1857
			rootSession.id, -- 1857
			{session = getSessionItem(rootSession.id)} -- 1857
		) -- 1857
	end -- 1857
	do -- 1857
		local i = 0 -- 1861
		while i < #items do -- 1861
			local item = items[i + 1] -- 1862
			local step = appendHandoffSystemStep( -- 1863
				rootSession.id, -- 1864
				handoffTaskId, -- 1865
				item.sourceTaskId, -- 1866
				item.message, -- 1867
				{ -- 1868
					sourceSessionId = item.sourceSessionId, -- 1869
					sourceTitle = item.sourceTitle, -- 1870
					sourceTaskId = item.sourceTaskId, -- 1871
					success = item.success == true, -- 1872
					summary = item.message, -- 1873
					resultFilePath = item.resultFilePath or "", -- 1874
					artifactDir = item.artifactDir or "", -- 1875
					finishedAt = item.finishedAt or "", -- 1876
					changeSet = item.changeSet, -- 1877
					handoffEvidence = item.handoffEvidence, -- 1878
					memoryEntry = item.memoryEntry, -- 1879
					completion = item.completion -- 1880
				}, -- 1880
				{ -- 1882
					sourceSessionId = item.sourceSessionId, -- 1883
					sourceTitle = item.sourceTitle, -- 1884
					sourceTaskId = item.sourceTaskId, -- 1885
					prompt = item.prompt, -- 1886
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1887
					expectedOutput = item.expectedOutput or "", -- 1888
					filesHint = item.filesHint or ({}), -- 1889
					resultFilePath = item.resultFilePath or "", -- 1890
					artifactDir = item.artifactDir or "", -- 1891
					changeSet = item.changeSet, -- 1892
					handoffEvidence = item.handoffEvidence, -- 1893
					memoryEntry = item.memoryEntry, -- 1894
					completion = item.completion -- 1895
				} -- 1895
			) -- 1895
			if step then -- 1895
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1899
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1900
			else -- 1900
				Log( -- 1902
					"Warn", -- 1902
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1902
				) -- 1902
			end -- 1902
			i = i + 1 -- 1861
		end -- 1861
	end -- 1861
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1861
		cleanupTaskHeavyData(previousTaskId) -- 1906
	end -- 1906
end -- 1906
function applyEvent(sessionId, event) -- 1918
	if not getSessionItem(sessionId) then -- 1918
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1918
			__TS__Delete(activeStopTokens, event.taskId) -- 1921
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1922
		end -- 1922
		return -- 1924
	end -- 1924
	repeat -- 1924
		local ____switch317 = event.type -- 1924
		local metrics, startedSession -- 1924
		local ____cond317 = ____switch317 == "task_started" -- 1924
		if ____cond317 then -- 1924
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1928
			local ____event_resumed_40 -- 1929
			if event.resumed then -- 1929
				local ____opt_38 = getSessionItem(sessionId) -- 1929
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1930
			else -- 1930
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1931
			end -- 1931
			metrics = ____event_resumed_40 -- 1929
			startedSession = getSessionItem(sessionId) -- 1932
			emitAgentSessionPatch( -- 1933
				sessionId, -- 1933
				{ -- 1933
					session = startedSession, -- 1934
					metrics = metrics, -- 1935
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1936
				} -- 1936
			) -- 1936
			break -- 1940
		end -- 1940
		____cond317 = ____cond317 or ____switch317 == "decision_made" -- 1940
		if ____cond317 then -- 1940
			upsertStep( -- 1942
				sessionId, -- 1942
				event.taskId, -- 1942
				event.step, -- 1942
				event.tool, -- 1942
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1942
			) -- 1942
			emitAgentSessionPatch( -- 1950
				sessionId, -- 1950
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1950
			) -- 1950
			break -- 1953
		end -- 1953
		____cond317 = ____cond317 or ____switch317 == "tool_started" -- 1953
		if ____cond317 then -- 1953
			upsertStep( -- 1955
				sessionId, -- 1955
				event.taskId, -- 1955
				event.step, -- 1955
				event.tool, -- 1955
				{status = "RUNNING"} -- 1955
			) -- 1955
			emitAgentSessionPatch( -- 1958
				sessionId, -- 1958
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1958
			) -- 1958
			break -- 1961
		end -- 1961
		____cond317 = ____cond317 or ____switch317 == "tool_finished" -- 1961
		if ____cond317 then -- 1961
			do -- 1961
				local ____temp_43 = event.result.success ~= true -- 1963
				if ____temp_43 then -- 1963
					local ____opt_41 = activeStopTokens[event.taskId] -- 1963
					____temp_43 = (____opt_41 and ____opt_41.stopped) == true -- 1963
				end -- 1963
				local stopped = ____temp_43 -- 1963
				upsertStep( -- 1965
					sessionId, -- 1965
					event.taskId, -- 1965
					event.step, -- 1965
					event.tool, -- 1965
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1965
				) -- 1965
				emitAgentSessionPatch( -- 1973
					sessionId, -- 1973
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1973
				) -- 1973
				break -- 1976
			end -- 1976
		end -- 1976
		____cond317 = ____cond317 or ____switch317 == "tool_progress" -- 1976
		if ____cond317 then -- 1976
			do -- 1976
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1980
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1980
					break -- 1982
				end -- 1982
			end -- 1982
			upsertStep( -- 1985
				sessionId, -- 1985
				event.taskId, -- 1985
				event.step, -- 1985
				event.tool, -- 1985
				{status = "RUNNING", result = event.result} -- 1985
			) -- 1985
			emitAgentSessionPatch( -- 1989
				sessionId, -- 1989
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1989
			) -- 1989
			break -- 1992
		end -- 1992
		____cond317 = ____cond317 or ____switch317 == "checkpoint_created" -- 1992
		if ____cond317 then -- 1992
			upsertStep( -- 1994
				sessionId, -- 1994
				event.taskId, -- 1994
				event.step, -- 1994
				event.tool, -- 1994
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1994
			) -- 1994
			emitAgentSessionPatch( -- 1999
				sessionId, -- 1999
				{ -- 1999
					step = getStepItem(sessionId, event.taskId, event.step), -- 2000
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2001
				} -- 2001
			) -- 2001
			break -- 2003
		end -- 2003
		____cond317 = ____cond317 or ____switch317 == "memory_compression_started" -- 2003
		if ____cond317 then -- 2003
			upsertStep( -- 2005
				sessionId, -- 2005
				event.taskId, -- 2005
				event.step, -- 2005
				event.tool, -- 2005
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2005
			) -- 2005
			emitAgentSessionPatch( -- 2010
				sessionId, -- 2010
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2010
			) -- 2010
			break -- 2013
		end -- 2013
		____cond317 = ____cond317 or ____switch317 == "memory_compression_finished" -- 2013
		if ____cond317 then -- 2013
			upsertStep( -- 2015
				sessionId, -- 2015
				event.taskId, -- 2015
				event.step, -- 2015
				event.tool, -- 2015
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2015
			) -- 2015
			emitAgentSessionPatch( -- 2020
				sessionId, -- 2020
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2020
			) -- 2020
			break -- 2023
		end -- 2023
		____cond317 = ____cond317 or ____switch317 == "metrics_updated" -- 2023
		if ____cond317 then -- 2023
			do -- 2023
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2025
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2026
				break -- 2029
			end -- 2029
		end -- 2029
		____cond317 = ____cond317 or ____switch317 == "assistant_message_updated" -- 2029
		if ____cond317 then -- 2029
			do -- 2029
				upsertStep( -- 2032
					sessionId, -- 2032
					event.taskId, -- 2032
					event.step, -- 2032
					"message", -- 2032
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2032
				) -- 2032
				emitAgentSessionPatch( -- 2037
					sessionId, -- 2037
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2037
				) -- 2037
				break -- 2040
			end -- 2040
		end -- 2040
		____cond317 = ____cond317 or ____switch317 == "assistant_message_finished" -- 2040
		if ____cond317 then -- 2040
			do -- 2040
				upsertStep( -- 2043
					sessionId, -- 2043
					event.taskId, -- 2043
					event.step, -- 2043
					"message", -- 2043
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2043
				) -- 2043
				emitAgentSessionPatch( -- 2049
					sessionId, -- 2049
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2049
				) -- 2049
				break -- 2052
			end -- 2052
		end -- 2052
		____cond317 = ____cond317 or ____switch317 == "task_waiting_for_user" -- 2052
		if ____cond317 then -- 2052
			do -- 2052
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2055
				__TS__Delete(activeStopTokens, event.taskId) -- 2056
				emitAgentSessionPatch( -- 2057
					sessionId, -- 2057
					{ -- 2057
						session = getSessionItem(sessionId), -- 2058
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2059
					} -- 2059
				) -- 2059
				break -- 2061
			end -- 2061
		end -- 2061
		____cond317 = ____cond317 or ____switch317 == "task_finished" -- 2061
		if ____cond317 then -- 2061
			do -- 2061
				local session = getSessionItem(sessionId) -- 2064
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2064
					__TS__Delete(activeStopTokens, event.taskId) -- 2066
					Log( -- 2067
						"Info", -- 2067
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2067
					) -- 2067
					break -- 2068
				end -- 2068
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2068
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2070
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2072
				local isSubSession = (session and session.kind) == "sub" -- 2075
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2076
				if isSubSession and event.taskId ~= nil then -- 2076
					finalizingSubSessionTaskIds[event.taskId] = true -- 2078
				end -- 2078
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2080
				if event.taskId ~= nil then -- 2080
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2082
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2083
					local ____array_49 = __TS__SparseArrayNew( -- 2083
						sessionId, -- 2084
						event.taskId, -- 2085
						type(event.steps) == "number" and math.max( -- 2086
							0, -- 2086
							math.floor(event.steps) -- 2086
						) or nil -- 2086
					) -- 2086
					local ____event_success_48 -- 2087
					if event.success then -- 2087
						____event_success_48 = nil -- 2087
					else -- 2087
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2087
					end -- 2087
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2087
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2083
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2089
					if not isSubSession then -- 2089
						__TS__Delete(activeStopTokens, event.taskId) -- 2091
					end -- 2091
					emitAgentSessionPatch( -- 2093
						sessionId, -- 2093
						{ -- 2093
							session = getSessionItem(sessionId), -- 2094
							message = getMessageItem(messageId), -- 2095
							removedStepIds = removedStepIds -- 2096
						} -- 2096
					) -- 2096
				end -- 2096
				if session and session.kind == "main" then -- 2096
					flushPendingSubAgentHandoffs(session) -- 2100
				end -- 2100
				break -- 2102
			end -- 2102
		end -- 2102
	until true -- 2102
end -- 2102
function ____exports.createSession(projectRoot, title) -- 2107
	if title == nil then -- 2107
		title = "" -- 2107
	end -- 2107
	local storage = requireAgentStorage() -- 2108
	if not storage.success then -- 2108
		return storage -- 2109
	end -- 2109
	if not isValidProjectRoot(projectRoot) then -- 2109
		return {success = false, message = "invalid projectRoot"} -- 2111
	end -- 2111
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2113
	if row then -- 2113
		return { -- 2122
			success = true, -- 2122
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2122
		} -- 2122
	end -- 2122
	local t = now() -- 2124
	DB:exec( -- 2125
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2125
		{ -- 2128
			projectRoot, -- 2128
			title ~= "" and title or Path:getFilename(projectRoot), -- 2128
			t, -- 2128
			t -- 2128
		} -- 2128
	) -- 2128
	local sessionId = getLastInsertRowId() -- 2130
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2131
	local session = getSessionItem(sessionId) -- 2132
	if not session then -- 2132
		return {success = false, message = "failed to create session"} -- 2134
	end -- 2134
	return {success = true, session = session} -- 2136
end -- 2107
function ____exports.createSubSession(parentSessionId, title) -- 2139
	if title == nil then -- 2139
		title = "" -- 2139
	end -- 2139
	local storage = requireAgentStorage() -- 2140
	if not storage.success then -- 2140
		return storage -- 2141
	end -- 2141
	local parent = getSessionItem(parentSessionId) -- 2142
	if not parent then -- 2142
		return {success = false, message = "parent session not found"} -- 2144
	end -- 2144
	local rootId = getSessionRootId(parent) -- 2146
	local t = now() -- 2147
	DB:exec( -- 2148
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2148
		{ -- 2151
			parent.projectRoot, -- 2151
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2151
			rootId, -- 2151
			parent.id, -- 2151
			t, -- 2151
			t -- 2151
		} -- 2151
	) -- 2151
	local sessionId = getLastInsertRowId() -- 2153
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2154
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2155
	local session = getSessionItem(sessionId) -- 2156
	if not session then -- 2156
		return {success = false, message = "failed to create sub session"} -- 2158
	end -- 2158
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2160
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2161
	subStorage:writeMemory(parentStorage:readMemory()) -- 2162
	return {success = true, session = session} -- 2163
end -- 2139
function spawnSubAgentSession(request) -- 2166
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2166
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2179
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2180
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2181
		if normalizedPrompt == "" then -- 2181
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2183
		end -- 2183
		if normalizedPrompt == "" then -- 2183
			local ____Log_56 = Log -- 2190
			local ____temp_53 = #normalizedTitle -- 2190
			local ____temp_54 = #rawPrompt -- 2190
			local ____temp_55 = #toStr(request.expectedOutput) -- 2190
			local ____opt_51 = request.filesHint -- 2190
			____Log_56( -- 2190
				"Warn", -- 2190
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2190
			) -- 2190
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2190
		end -- 2190
		Log( -- 2193
			"Info", -- 2193
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2193
		) -- 2193
		local parentSessionId = request.parentSessionId -- 2194
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2194
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2196
			if not fallbackParent then -- 2196
				local createdMain = ____exports.createSession(request.projectRoot) -- 2198
				if createdMain.success then -- 2198
					fallbackParent = createdMain.session -- 2200
				end -- 2200
			end -- 2200
			if fallbackParent then -- 2200
				Log( -- 2204
					"Warn", -- 2204
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2204
				) -- 2204
				parentSessionId = fallbackParent.id -- 2205
			end -- 2205
		end -- 2205
		local parentSession = getSessionItem(parentSessionId) -- 2208
		if not parentSession then -- 2208
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2208
		end -- 2208
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2212
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2212
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2212
		end -- 2212
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2216
		if not created.success then -- 2216
			return ____awaiter_resolve(nil, created) -- 2216
		end -- 2216
		writeSpawnInfo( -- 2220
			created.session.projectRoot, -- 2220
			created.session.memoryScope, -- 2220
			{ -- 2220
				sessionId = created.session.id, -- 2221
				rootSessionId = created.session.rootSessionId, -- 2222
				parentSessionId = created.session.parentSessionId, -- 2223
				title = created.session.title, -- 2224
				prompt = normalizedPrompt, -- 2225
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2226
				expectedOutput = request.expectedOutput or "", -- 2227
				filesHint = request.filesHint or ({}), -- 2228
				status = "RUNNING", -- 2229
				success = false, -- 2230
				resultFilePath = "", -- 2231
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2232
				sourceTaskId = 0, -- 2233
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2234
				createdAtTs = created.session.createdAt, -- 2235
				finishedAt = "", -- 2236
				finishedAtTs = 0 -- 2237
			} -- 2237
		) -- 2237
		local sent = ____exports.sendPrompt( -- 2239
			created.session.id, -- 2239
			normalizedPrompt, -- 2239
			request.disabledAgentTools, -- 2239
			nil, -- 2239
			nil, -- 2239
			request.llmConfig -- 2239
		) -- 2239
		if not sent.success then -- 2239
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2239
		end -- 2239
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2239
	end) -- 2239
end -- 2239
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2360
	local rootSession = getRootSessionItem(session.id) -- 2361
	if not rootSession then -- 2361
		return -- 2362
	end -- 2362
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2363
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2364
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2365
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2366
	local queueResult = writePendingHandoff( -- 2367
		rootSession.projectRoot, -- 2367
		rootSession.memoryScope, -- 2367
		{ -- 2367
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2368
			sourceSessionId = session.id, -- 2369
			sourceTitle = session.title, -- 2370
			sourceTaskId = taskId, -- 2371
			message = summary, -- 2372
			prompt = result.prompt, -- 2373
			goal = result.goal, -- 2374
			expectedOutput = result.expectedOutput or "", -- 2375
			filesHint = result.filesHint or ({}), -- 2376
			success = result.success, -- 2377
			resultFilePath = result.resultFilePath, -- 2378
			artifactDir = result.artifactDir, -- 2379
			finishedAt = result.finishedAt, -- 2380
			changeSet = changeSet, -- 2381
			handoffEvidence = result.handoffEvidence, -- 2382
			memoryEntry = result.memoryEntry, -- 2383
			completion = result.completion, -- 2384
			createdAt = createdAt -- 2385
		} -- 2385
	) -- 2385
	if not queueResult then -- 2385
		Log( -- 2388
			"Warn", -- 2388
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2388
		) -- 2388
		return -- 2389
	end -- 2389
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2389
		addTaskReference(rootSession.currentTaskId, taskId) -- 2392
	end -- 2392
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2392
		flushPendingSubAgentHandoffs(rootSession) -- 2395
	end -- 2395
end -- 2395
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2399
	if forceHandoff == nil then -- 2399
		forceHandoff = false -- 2405
	end -- 2405
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2405
		local rootSessionId = getSessionRootId(session) -- 2407
		local rootSession = getRootSessionItem(session.id) -- 2408
		if not rootSession then -- 2408
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2408
		end -- 2408
		local spawnInfo = getSessionSpawnInfo(session) -- 2412
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2413
		local finishedAtTs = now() -- 2414
		local resultText = sanitizeUTF8(message) -- 2415
		local changeSet = getTaskChangeSetSummary(taskId) -- 2416
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2417
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2418
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2422
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2422
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2424
		end -- 2424
		local completed = success and completionReport.outcome == "completed" -- 2432
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2433
		local record = { -- 2436
			sessionId = session.id, -- 2437
			rootSessionId = rootSessionId, -- 2438
			parentSessionId = session.parentSessionId, -- 2439
			title = session.title, -- 2440
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2441
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2442
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2443
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2444
			status = recordStatus, -- 2445
			success = completed, -- 2446
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2447
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2448
			sourceTaskId = taskId, -- 2449
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2450
			finishedAt = finishedAt, -- 2451
			createdAtTs = session.createdAt, -- 2452
			finishedAtTs = finishedAtTs, -- 2453
			changeSet = changeSet, -- 2454
			handoffEvidence = handoffEvidence, -- 2455
			completion = completionReport -- 2456
		} -- 2456
		local ____record_success_73 -- 2458
		if record.success then -- 2458
			____record_success_73 = buildStructuredSubAgentMemoryEntry(record) -- 2458
		else -- 2458
			____record_success_73 = nil -- 2458
		end -- 2458
		record.memoryEntry = ____record_success_73 -- 2458
		if not writeSubAgentResultFile(session, record, resultText) then -- 2458
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2458
		end -- 2458
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2458
			sessionId = record.sessionId, -- 2463
			rootSessionId = record.rootSessionId, -- 2464
			parentSessionId = record.parentSessionId, -- 2465
			title = record.title, -- 2466
			prompt = record.prompt, -- 2467
			goal = record.goal, -- 2468
			expectedOutput = record.expectedOutput or "", -- 2469
			filesHint = record.filesHint or ({}), -- 2470
			status = record.status, -- 2471
			success = record.success, -- 2472
			resultFilePath = record.resultFilePath, -- 2473
			artifactDir = record.artifactDir, -- 2474
			sourceTaskId = record.sourceTaskId, -- 2475
			createdAt = record.createdAt, -- 2476
			finishedAt = record.finishedAt, -- 2477
			createdAtTs = record.createdAtTs, -- 2478
			finishedAtTs = record.finishedAtTs, -- 2479
			changeSet = record.changeSet, -- 2480
			handoffEvidence = record.handoffEvidence, -- 2481
			memoryEntry = record.memoryEntry, -- 2482
			memoryEntryError = record.memoryEntryError, -- 2483
			completion = record.completion -- 2484
		}) then -- 2484
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2484
		end -- 2484
		if success or forceHandoff then -- 2484
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2489
			deleteSessionRecords(session.id, true) -- 2490
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2491
		end -- 2491
		return ____awaiter_resolve(nil, {success = true}) -- 2491
	end) -- 2491
end -- 2491
function stopClearedSubSession(session, taskId) -- 2496
	local spawnInfo = getSessionSpawnInfo(session) -- 2497
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2498
	local rootSessionId = getSessionRootId(session) -- 2499
	Tools.setTaskStatus(taskId, "STOPPED") -- 2500
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2501
	if not writeSpawnInfo( -- 2501
		session.projectRoot, -- 2502
		session.memoryScope, -- 2502
		{ -- 2502
			sessionId = session.id, -- 2503
			rootSessionId = rootSessionId, -- 2504
			parentSessionId = session.parentSessionId, -- 2505
			title = session.title, -- 2506
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2507
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2508
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2509
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2510
			status = "STOPPED", -- 2511
			success = false, -- 2512
			cleared = true, -- 2513
			resultFilePath = "", -- 2514
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2515
			sourceTaskId = taskId, -- 2516
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2517
			finishedAt = finishedAt, -- 2518
			createdAtTs = session.createdAt, -- 2519
			finishedAtTs = now() -- 2520
		} -- 2520
	) then -- 2520
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2522
	end -- 2522
	deleteSessionRecords(session.id, true) -- 2524
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2525
	return {success = true} -- 2526
end -- 2526
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2529
	local session = getSessionItem(sessionId) -- 2530
	if not session then -- 2530
		return {success = false, message = "session not found"} -- 2532
	end -- 2532
	if getPendingQuestionnaire(sessionId) then -- 2532
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2534
	end -- 2534
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2534
		return {success = false, message = "session task is finalizing"} -- 2536
	end -- 2536
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2536
		return {success = false, message = "session task is still running"} -- 2539
	end -- 2539
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2541
	if normalizedPrompt == "" and session.kind == "sub" then -- 2541
		local spawnInfo = getSessionSpawnInfo(session) -- 2543
		if spawnInfo then -- 2543
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2545
			if normalizedPrompt == "" then -- 2545
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2547
			end -- 2547
		end -- 2547
	end -- 2547
	if normalizedPrompt == "" then -- 2547
		return {success = false, message = "prompt is empty"} -- 2556
	end -- 2556
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2558
	if session.workMode ~= nextWorkMode then -- 2558
		DB:exec( -- 2560
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2560
			{ -- 2560
				nextWorkMode, -- 2560
				now(), -- 2560
				session.id -- 2560
			} -- 2560
		) -- 2560
		session.workMode = nextWorkMode -- 2561
	end -- 2561
	return startPromptTask( -- 2563
		session, -- 2563
		normalizedPrompt, -- 2563
		nil, -- 2563
		normalizeDisabledAgentTools(disabledAgentTools), -- 2563
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2563
	) -- 2563
end -- 2529
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2616
	if disabledAgentTools == nil then -- 2616
		disabledAgentTools = {} -- 2620
	end -- 2620
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2623
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2624
	if not llmConfigRes.success then -- 2624
		return {success = false, message = llmConfigRes.message} -- 2628
	end -- 2628
	local llmConfig = llmConfigRes.config -- 2630
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2631
	if not llmConfigValidation.success then -- 2631
		return llmConfigValidation -- 2633
	end -- 2633
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2635
	if not taskRes.success then -- 2635
		return {success = false, message = taskRes.message} -- 2638
	end -- 2638
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2638
		removeContinuableTaskSummary(session) -- 2640
	end -- 2640
	local taskId = taskRes.taskId -- 2642
	local ____temp_94 -- 2643
	if (options and options.existingTaskId) == nil then -- 2643
		____temp_94 = session.currentTaskId -- 2643
	else -- 2643
		____temp_94 = nil -- 2643
	end -- 2643
	local previousTaskId = ____temp_94 -- 2643
	local useChineseResponse = getDefaultUseChineseResponse() -- 2644
	if existingUserMessageId ~= nil then -- 2644
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2646
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2646
		insertMessage( -- 2648
			session.id, -- 2648
			"user", -- 2648
			normalizedPrompt, -- 2648
			taskId, -- 2648
			options and options.displayContent -- 2648
		) -- 2648
	end -- 2648
	local stopToken = {stopped = false} -- 2650
	activeStopTokens[taskId] = stopToken -- 2651
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2652
	if previousTaskId and previousTaskId ~= taskId then -- 2652
		cleanupTaskHeavyData(previousTaskId) -- 2654
	end -- 2654
	local ____runCodingAgent_123 = runCodingAgent -- 2656
	local ____normalizedPrompt_116 = normalizedPrompt -- 2657
	local ____temp_117 = options and options.resumeConversation -- 2658
	local ____temp_118 = (options and options.existingTaskId) ~= nil -- 2659
	local ____temp_119 = options and options.initialStep -- 2660
	local ____temp_120 = options and options.initialAgentStepCount -- 2661
	local ____temp_111 -- 2662
	if (options and options.existingTaskId) ~= nil then -- 2662
		____temp_111 = getInitialTokenUsage(session) -- 2662
	else -- 2662
		____temp_111 = nil -- 2662
	end -- 2662
	____runCodingAgent_123( -- 2656
		{ -- 2656
			prompt = ____normalizedPrompt_116, -- 2657
			resumeConversation = ____temp_117, -- 2658
			resumeTask = ____temp_118, -- 2659
			initialStep = ____temp_119, -- 2660
			initialAgentStepCount = ____temp_120, -- 2661
			initialTokenUsage = ____temp_111, -- 2662
			workDir = session.projectRoot, -- 2663
			useChineseResponse = useChineseResponse, -- 2664
			taskId = taskId, -- 2665
			sessionId = session.id, -- 2666
			memoryScope = session.memoryScope, -- 2667
			role = session.kind, -- 2668
			maxSteps = options and options.maxSteps, -- 2669
			disabledAgentTools = disabledAgentTools, -- 2670
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2671
			llmConfig = llmConfig, -- 2672
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2673
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2676
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2679
			stopToken = stopToken, -- 2680
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2681
		}, -- 2681
		function(result) -- 2682
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2682
				local nextSession = getSessionItem(session.id) -- 2683
				if nextSession and nextSession.kind == "sub" then -- 2683
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2683
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2686
						if not stopped.success then -- 2686
							Log( -- 2688
								"Warn", -- 2688
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2688
							) -- 2688
							emitAgentSessionPatch( -- 2689
								session.id, -- 2689
								{session = getSessionItem(session.id)} -- 2689
							) -- 2689
						end -- 2689
						__TS__Delete(activeStopTokens, taskId) -- 2693
						return ____awaiter_resolve(nil) -- 2693
					end -- 2693
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2696
					emitAgentSessionPatch( -- 2697
						session.id, -- 2697
						{session = getSessionItem(session.id)} -- 2697
					) -- 2697
					local finalized = __TS__Await(finalizeSubSession( -- 2700
						nextSession, -- 2701
						taskId, -- 2702
						result.success, -- 2703
						result.message, -- 2704
						result.completion, -- 2705
						(options and options.forceSubAgentHandoff) == true -- 2706
					)) -- 2706
					if not finalized.success then -- 2706
						Log( -- 2709
							"Warn", -- 2709
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2709
						) -- 2709
					end -- 2709
					local finalizedSession = getSessionItem(session.id) -- 2711
					if finalizedSession then -- 2711
						local stopped = stopToken.stopped == true -- 2713
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2714
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2717
						emitAgentSessionPatch( -- 2718
							session.id, -- 2718
							{session = getSessionItem(session.id)} -- 2718
						) -- 2718
					end -- 2718
					__TS__Delete(activeStopTokens, taskId) -- 2722
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2723
				end -- 2723
				local fallbackSession = getSessionItem(session.id) -- 2725
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2725
					applyEvent(session.id, { -- 2731
						type = "task_finished", -- 2732
						sessionId = session.id, -- 2733
						taskId = result.taskId, -- 2734
						success = false, -- 2735
						message = result.message, -- 2736
						steps = result.steps -- 2737
					}) -- 2737
				end -- 2737
			end) -- 2737
		end -- 2682
	) -- 2682
	return {success = true, sessionId = session.id, taskId = taskId} -- 2741
end -- 2741
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2893
	local lines = {} -- 2894
	do -- 2894
		local i = 0 -- 2895
		while i < #questionnaire.schema.questions do -- 2895
			local question = questionnaire.schema.questions[i + 1] -- 2896
			local answer = __TS__ArrayFind( -- 2897
				answers, -- 2897
				function(____, item) return item.questionId == question.id end -- 2897
			) -- 2897
			local answerText = "已跳过" -- 2898
			if answer and answer.status == "answered" then -- 2898
				local parts = {} -- 2900
				do -- 2900
					local j = 0 -- 2901
					while j < #(answer.selectedOptionIds or ({})) do -- 2901
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2902
						local option = __TS__ArrayFind( -- 2903
							question.options or ({}), -- 2903
							function(____, item) return item.id == optionId end -- 2903
						) -- 2903
						if option then -- 2903
							parts[#parts + 1] = option.label -- 2904
						end -- 2904
						j = j + 1 -- 2901
					end -- 2901
				end -- 2901
				if answer.otherText then -- 2901
					parts[#parts + 1] = answer.otherText -- 2906
				end -- 2906
				if answer.text then -- 2906
					parts[#parts + 1] = answer.text -- 2907
				end -- 2907
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2908
			end -- 2908
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2910
			i = i + 1 -- 2895
		end -- 2895
	end -- 2895
	return table.concat(lines, "\n\n") -- 2912
end -- 2912
function ____exports.listRunningSubAgents(request) -- 3156
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3156
		local session = getSessionItem(request.sessionId) -- 3164
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3164
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3166
		end -- 3166
		if not session then -- 3166
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3166
		end -- 3166
		local rootSession = getRootSessionItem(session.id) -- 3171
		if not rootSession then -- 3171
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3171
		end -- 3171
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3175
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3176
		local limit = math.max( -- 3177
			1, -- 3177
			math.floor(tonumber(request.limit) or 5) -- 3177
		) -- 3177
		local offset = math.max( -- 3178
			0, -- 3178
			math.floor(tonumber(request.offset) or 0) -- 3178
		) -- 3178
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3179
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3180
		local runningSessions = {} -- 3187
		do -- 3187
			local i = 0 -- 3188
			while i < #rows do -- 3188
				do -- 3188
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3189
					if current.currentTaskStatus ~= "RUNNING" then -- 3189
						goto __continue517 -- 3191
					end -- 3191
					local spawnInfo = getSessionSpawnInfo(current) -- 3193
					runningSessions[#runningSessions + 1] = { -- 3194
						sessionId = current.id, -- 3195
						title = current.title, -- 3196
						parentSessionId = current.parentSessionId, -- 3197
						rootSessionId = current.rootSessionId, -- 3198
						status = "RUNNING", -- 3199
						currentTaskId = current.currentTaskId, -- 3200
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3201
						goal = spawnInfo and spawnInfo.goal, -- 3202
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3203
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3204
						createdAt = current.createdAt, -- 3205
						updatedAt = current.updatedAt -- 3206
					} -- 3206
				end -- 3206
				::__continue517:: -- 3206
				i = i + 1 -- 3188
			end -- 3188
		end -- 3188
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3209
		local completedSessions = __TS__ArrayMap( -- 3210
			completedRecords, -- 3210
			function(____, record) return { -- 3210
				sessionId = record.sessionId, -- 3211
				title = record.title, -- 3212
				parentSessionId = record.parentSessionId, -- 3213
				rootSessionId = record.rootSessionId, -- 3214
				status = record.status, -- 3215
				goal = record.goal, -- 3216
				expectedOutput = record.expectedOutput, -- 3217
				filesHint = record.filesHint, -- 3218
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3219
				success = record.success, -- 3220
				cleared = record.cleared, -- 3221
				resultFilePath = record.resultFilePath, -- 3222
				artifactDir = record.artifactDir, -- 3223
				finishedAt = record.finishedAt, -- 3224
				createdAt = record.createdAtTs, -- 3225
				updatedAt = record.finishedAtTs -- 3226
			} end -- 3226
		) -- 3226
		local merged = {} -- 3228
		if status == "running" then -- 3228
			merged = runningSessions -- 3230
		elseif status == "done" then -- 3230
			merged = __TS__ArrayFilter( -- 3232
				completedSessions, -- 3232
				function(____, item) return item.status == "DONE" end -- 3232
			) -- 3232
		elseif status == "failed" then -- 3232
			merged = __TS__ArrayFilter( -- 3234
				completedSessions, -- 3234
				function(____, item) return item.status == "FAILED" end -- 3234
			) -- 3234
		elseif status == "stopped" then -- 3234
			merged = __TS__ArrayFilter( -- 3236
				completedSessions, -- 3236
				function(____, item) return item.status == "STOPPED" end -- 3236
			) -- 3236
		elseif status == "all" then -- 3236
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3238
		else -- 3238
			local runningKeys = {} -- 3240
			do -- 3240
				local i = 0 -- 3241
				while i < #runningSessions do -- 3241
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3242
					i = i + 1 -- 3241
				end -- 3241
			end -- 3241
			local latestCompletedByKey = {} -- 3244
			do -- 3244
				local i = 0 -- 3245
				while i < #completedSessions do -- 3245
					do -- 3245
						local item = completedSessions[i + 1] -- 3246
						local key = getSubAgentDisplayKey(item) -- 3247
						if runningKeys[key] then -- 3247
							goto __continue532 -- 3249
						end -- 3249
						local current = latestCompletedByKey[key] -- 3251
						if not current or item.updatedAt > current.updatedAt then -- 3251
							latestCompletedByKey[key] = item -- 3253
						end -- 3253
					end -- 3253
					::__continue532:: -- 3253
					i = i + 1 -- 3245
				end -- 3245
			end -- 3245
			local latestCompleted = {} -- 3256
			for ____, item in pairs(latestCompletedByKey) do -- 3257
				latestCompleted[#latestCompleted + 1] = item -- 3258
			end -- 3258
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3260
		end -- 3260
		if query ~= "" then -- 3260
			merged = __TS__ArrayFilter( -- 3263
				merged, -- 3263
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3263
			) -- 3263
		end -- 3263
		__TS__ArraySort( -- 3269
			merged, -- 3269
			function(____, a, b) -- 3269
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3269
					return -1 -- 3270
				end -- 3270
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3270
					return 1 -- 3271
				end -- 3271
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3271
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3273
				end -- 3273
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3275
			end -- 3269
		) -- 3269
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3277
		return ____awaiter_resolve(nil, { -- 3277
			success = true, -- 3279
			rootSessionId = rootSession.id, -- 3280
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3281
			status = status, -- 3282
			limit = limit, -- 3283
			offset = offset, -- 3284
			hasMore = offset + limit < #merged, -- 3285
			sessions = paged -- 3286
		}) -- 3286
	end) -- 3286
end -- 3156
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 272
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 273
SPAWN_INFO_FILE = "SPAWN.json" -- 274
RESULT_FILE = "RESULT.md" -- 275
PENDING_HANDOFF_DIR = "pending-handoffs" -- 276
MAX_CONCURRENT_SUB_AGENTS = 4 -- 277
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 278
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 279
activeStopTokens = {} -- 329
finalizingSubSessionTaskIds = {} -- 330
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 331
now = function() return os.time() end -- 332
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 980
	if projectRoot == oldRoot then -- 980
		return newRoot -- 982
	end -- 982
	for ____, separator in ipairs({"/", "\\"}) do -- 984
		local prefix = oldRoot .. separator -- 985
		if __TS__StringStartsWith(projectRoot, prefix) then -- 985
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 987
		end -- 987
	end -- 987
	return nil -- 990
end -- 980
local function clearSessionAfterMessage(sessionId, message) -- 1506
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1507
	local removedStepIds = {} -- 1515
	do -- 1515
		local i = 0 -- 1516
		while i < #removedStepRows do -- 1516
			local row = removedStepRows[i + 1] -- 1517
			if type(row[1]) == "number" then -- 1517
				removedStepIds[#removedStepIds + 1] = row[1] -- 1519
			end -- 1519
			i = i + 1 -- 1516
		end -- 1516
	end -- 1516
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1522
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1530
	return removedStepIds -- 1535
end -- 1506
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1538
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1539
	local persisted = storage:readSessionState() -- 1540
	local userIndex = -1 -- 1541
	do -- 1541
		local i = #persisted.messages - 1 -- 1542
		while i >= 0 do -- 1542
			if persisted.messages[i + 1].role == "user" then -- 1542
				userIndex = i -- 1544
				break -- 1545
			end -- 1545
			i = i - 1 -- 1542
		end -- 1542
	end -- 1542
	if userIndex < 0 then -- 1542
		return -- 1548
	end -- 1548
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1549
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1550
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1551
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1556
end -- 1538
local function listCurrentTaskCheckpoints(sessionId) -- 1568
	local session = getSessionItem(sessionId) -- 1569
	local taskId = session and session.currentTaskId -- 1570
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1571
end -- 1568
local function getAgentStepCount(sessionId, taskId) -- 1678
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1679
		sessionId, -- 1684
		taskId, -- 1685
		"compress_memory", -- 1686
		"merge_memory", -- 1687
		"sub_agent_handoff", -- 1688
		"questionnaire_answer", -- 1689
		"message" -- 1690
	}) -- 1690
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1693
end -- 1678
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1696
	if status == nil then -- 1696
		status = "DONE" -- 1704
	end -- 1704
	local step = getNextStepNumber(sessionId, taskId) -- 1706
	upsertStep( -- 1707
		sessionId, -- 1707
		taskId, -- 1707
		step, -- 1707
		tool, -- 1707
		{status = status, reason = reason, params = params, result = result} -- 1707
	) -- 1707
	return getStepItem(sessionId, taskId, step) -- 1713
end -- 1696
local function sanitizeStoredSteps(sessionId) -- 1780
	DB:exec( -- 1781
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1781
		{ -- 1799
			now(), -- 1799
			sessionId -- 1799
		} -- 1799
	) -- 1799
end -- 1780
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2251
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2251
		return {success = false, message = "invalid projectRoot"} -- 2253
	end -- 2253
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2255
	for ____, row in ipairs(rows) do -- 2256
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2257
		if sessionId > 0 then -- 2257
			deleteSessionRecords(sessionId) -- 2259
		end -- 2259
	end -- 2259
	return {success = true, deleted = #rows} -- 2262
end -- 2251
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2265
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2265
		return {success = false, message = "invalid projectRoot"} -- 2267
	end -- 2267
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2269
	local renamed = 0 -- 2270
	for ____, row in ipairs(rows) do -- 2271
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2272
		local projectRoot = toStr(row[2]) -- 2273
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2274
		if sessionId > 0 and nextProjectRoot then -- 2274
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2276
			DB:exec( -- 2277
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2277
				{ -- 2279
					nextProjectRoot, -- 2279
					Path:getFilename(nextProjectRoot), -- 2279
					now(), -- 2279
					sessionId -- 2279
				} -- 2279
			) -- 2279
			renamed = renamed + 1 -- 2281
		end -- 2281
	end -- 2281
	return {success = true, renamed = renamed} -- 2284
end -- 2265
function ____exports.getSession(sessionId, view) -- 2287
	local session = getSessionItem(sessionId) -- 2288
	if not session then -- 2288
		return {success = false, message = "session not found"} -- 2290
	end -- 2290
	local restored = restorePendingQuestionnaireState(session) -- 2292
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2293
	local relatedSessions = listRelatedSessions(sessionId) -- 2294
	sanitizeStoredSteps(sessionId) -- 2295
	local firstMessageId = 0 -- 2296
	local hasEarlierMessages = false -- 2297
	if view then -- 2297
		local limit = math.max( -- 2299
			1, -- 2299
			math.min( -- 2299
				1000, -- 2299
				math.floor(view.recentRounds) -- 2299
			) -- 2299
		) -- 2299
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2300
		if #requests > limit then -- 2300
			firstMessageId = requests[limit][1] -- 2305
			hasEarlierMessages = true -- 2306
		end -- 2306
	end -- 2306
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2309
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2316
	local ____relatedSessions_62 = relatedSessions -- 2328
	local ____temp_61 -- 2329
	if normalizedSession.kind == "sub" then -- 2329
		____temp_61 = getSessionSpawnInfo(normalizedSession) -- 2329
	else -- 2329
		____temp_61 = nil -- 2329
	end -- 2329
	return { -- 2325
		success = true, -- 2326
		session = normalizedSession, -- 2327
		relatedSessions = ____relatedSessions_62, -- 2328
		spawnInfo = ____temp_61, -- 2329
		messages = __TS__ArrayMap( -- 2330
			messages, -- 2330
			function(____, row) return rowToMessage(row) end -- 2330
		), -- 2330
		hasEarlierMessages = hasEarlierMessages, -- 2331
		steps = __TS__ArrayMap( -- 2332
			steps, -- 2332
			function(____, row) return rowToStep(row) end -- 2332
		), -- 2332
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2333
		pendingQuestionnaire = restored.questionnaire, -- 2334
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2335
	} -- 2335
end -- 2287
function ____exports.setWorkMode(sessionId, workMode) -- 2340
	local session = getSessionItem(sessionId) -- 2341
	if not session then -- 2341
		return {success = false, message = "session not found"} -- 2342
	end -- 2342
	if session.kind ~= "main" then -- 2342
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2343
	end -- 2343
	if workMode ~= "code" and workMode ~= "plan" then -- 2343
		return {success = false, message = "invalid work mode"} -- 2344
	end -- 2344
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2345
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2345
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2347
	end -- 2347
	if getPendingQuestionnaire(sessionId) then -- 2347
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2350
	end -- 2350
	if normalizedSession.workMode ~= workMode then -- 2350
		DB:exec( -- 2353
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2353
			{ -- 2353
				workMode, -- 2353
				now(), -- 2353
				sessionId -- 2353
			} -- 2353
		) -- 2353
	end -- 2353
	local updated = getSessionItem(sessionId) -- 2355
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2356
	return { -- 2357
		success = true, -- 2357
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2357
	} -- 2357
end -- 2340
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2566
	local session = getSessionItem(sessionId) -- 2567
	if not session then -- 2567
		return {success = false, message = "session not found"} -- 2569
	end -- 2569
	if getPendingQuestionnaire(sessionId) then -- 2569
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2571
	end -- 2571
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2571
		return {success = false, message = "session task is finalizing"} -- 2573
	end -- 2573
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2573
		return {success = false, message = "session task is still stopping"} -- 2576
	end -- 2576
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2576
		return {success = false, message = "session task is not continuable"} -- 2579
	end -- 2579
	if session.currentTaskId == nil then -- 2579
		return {success = false, message = "session task not found"} -- 2582
	end -- 2582
	local taskId = session.currentTaskId -- 2584
	return startPromptTask( -- 2585
		session, -- 2586
		"", -- 2587
		nil, -- 2588
		normalizeDisabledAgentTools(disabledAgentTools), -- 2589
		{ -- 2590
			workMode = session.workMode, -- 2591
			persistUserMessage = false, -- 2592
			resumeConversation = true, -- 2593
			existingTaskId = taskId, -- 2594
			initialStep = math.max( -- 2595
				0, -- 2595
				getNextStepNumber(session.id, taskId) - 1 -- 2595
			), -- 2595
			initialAgentStepCount = getAgentStepCount(session.id, taskId), -- 2596
			llmConfigId = llmConfigId -- 2597
		} -- 2597
	) -- 2597
end -- 2566
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2744
	local session = getSessionItem(sessionId) -- 2745
	if not session then -- 2745
		return {success = false, message = "session not found"} -- 2747
	end -- 2747
	if session.kind ~= "sub" then -- 2747
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2750
	end -- 2750
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2750
		return {success = false, message = "session task is finalizing"} -- 2753
	end -- 2753
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2755
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2755
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2760
	end -- 2760
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2760
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2763
	end -- 2763
	local disabledAgentTools = __TS__ArrayFilter( -- 2765
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2765
		function(____, tool) return tool ~= "finish" end -- 2766
	) -- 2766
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2767
	return startPromptTask( -- 2770
		session, -- 2770
		prompt, -- 2770
		nil, -- 2770
		disabledAgentTools, -- 2770
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2770
	) -- 2770
end -- 2744
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2777
	local session = getSessionItem(sessionId) -- 2778
	if not session then -- 2778
		return {success = false, message = "session not found"} -- 2780
	end -- 2780
	if getPendingQuestionnaire(sessionId) then -- 2780
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2782
	end -- 2782
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2782
		return {success = false, message = "session task is finalizing"} -- 2784
	end -- 2784
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2784
		return {success = false, message = "session task is still running"} -- 2787
	end -- 2787
	local message = getMessageItem(messageId) -- 2789
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2789
		return {success = false, message = "message not found"} -- 2791
	end -- 2791
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2793
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2799
	if latestUserMessageId ~= messageId then -- 2799
		return {success = false, message = "only the latest user prompt can be edited"} -- 2801
	end -- 2801
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2803
	if normalizedPrompt == "" then -- 2803
		return {success = false, message = "prompt is empty"} -- 2805
	end -- 2805
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2807
	if session.workMode ~= nextWorkMode then -- 2807
		DB:exec( -- 2809
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2809
			{ -- 2809
				nextWorkMode, -- 2809
				now(), -- 2809
				session.id -- 2809
			} -- 2809
		) -- 2809
		session.workMode = nextWorkMode -- 2810
	end -- 2810
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2812
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2813
	local result = startPromptTask( -- 2814
		session, -- 2814
		normalizedPrompt, -- 2814
		messageId, -- 2814
		normalizeDisabledAgentTools(disabledAgentTools), -- 2814
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2814
	) -- 2814
	if result.success and #removedStepIds > 0 then -- 2814
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2816
	end -- 2816
	return result -- 2818
end -- 2777
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2823
	if status == "dismissed" then -- 2823
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2829
	end -- 2829
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2831
end -- 2823
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2834
	if status == "dismissed" then -- 2834
		return { -- 2840
			success = true, -- 2841
			status = "dismissed", -- 2842
			source = "user", -- 2843
			questionnaireId = questionnaire.id, -- 2844
			title = questionnaire.schema.title, -- 2845
			answers = {}, -- 2846
			responses = {}, -- 2847
			displayText = "用户关闭了调查问卷，未作答。", -- 2848
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2849
		} -- 2849
	end -- 2849
	local responses = {} -- 2852
	do -- 2852
		local i = 0 -- 2853
		while i < #questionnaire.schema.questions do -- 2853
			do -- 2853
				local question = questionnaire.schema.questions[i + 1] -- 2854
				local answer = __TS__ArrayFind( -- 2855
					answers, -- 2855
					function(____, item) return item.questionId == question.id end -- 2855
				) -- 2855
				if not answer or answer.status == "skipped" then -- 2855
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2857
					goto __continue443 -- 2862
				end -- 2862
				local selectedOptionLabels = {} -- 2864
				do -- 2864
					local j = 0 -- 2865
					while j < #(answer.selectedOptionIds or ({})) do -- 2865
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2866
						local option = __TS__ArrayFind( -- 2867
							question.options or ({}), -- 2867
							function(____, item) return item.id == optionId end -- 2867
						) -- 2867
						if option then -- 2867
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2868
						end -- 2868
						j = j + 1 -- 2865
					end -- 2865
				end -- 2865
				responses[#responses + 1] = { -- 2870
					questionId = question.id, -- 2871
					prompt = question.prompt, -- 2872
					status = "answered", -- 2873
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2874
					selectedOptionLabels = selectedOptionLabels, -- 2875
					otherText = answer.otherText, -- 2876
					text = answer.text -- 2877
				} -- 2877
			end -- 2877
			::__continue443:: -- 2877
			i = i + 1 -- 2853
		end -- 2853
	end -- 2853
	return { -- 2880
		success = true, -- 2881
		status = "answered", -- 2882
		source = "user", -- 2883
		questionnaireId = questionnaire.id, -- 2884
		title = questionnaire.schema.title, -- 2885
		answers = answers, -- 2886
		responses = responses, -- 2887
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2888
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2889
	} -- 2889
end -- 2834
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2915
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2921
	local persisted = storage:readSessionState() -- 2922
	local messages = __TS__ArraySlice(persisted.messages) -- 2923
	local toolResultIndex = -1 -- 2924
	local existingResult -- 2925
	do -- 2925
		local i = #messages - 1 -- 2926
		while i >= 0 do -- 2926
			do -- 2926
				local message = messages[i + 1] -- 2927
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2927
					goto __continue463 -- 2928
				end -- 2928
				local decoded = safeJsonDecode(message.content) -- 2929
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2929
					goto __continue463 -- 2930
				end -- 2930
				local row = decoded -- 2931
				if row.questionnaireId ~= questionnaire.id then -- 2931
					goto __continue463 -- 2932
				end -- 2932
				toolResultIndex = i -- 2933
				existingResult = row -- 2934
				break -- 2935
			end -- 2935
			::__continue463:: -- 2935
			i = i - 1 -- 2926
		end -- 2926
	end -- 2926
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2937
	local guidance = {} -- 2938
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2938
		guidance[#guidance + 1] = existingResult.guidance -- 2940
	end -- 2940
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2940
		guidance[#guidance + 1] = result.guidance -- 2943
	end -- 2943
	result.guidance = table.concat(guidance, "\n") -- 2945
	if toolResultIndex < 0 then -- 2945
		messages[#messages + 1] = { -- 2947
			role = "user", -- 2948
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 2949
		} -- 2949
		toolResultIndex = #messages - 1 -- 2951
	else -- 2951
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2953
			{}, -- 2953
			messages[toolResultIndex + 1], -- 2954
			{content = encodeJson(result)} -- 2953
		) -- 2953
	end -- 2953
	local pairStartIndex = toolResultIndex -- 2959
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2960
	if toolCallId and toolCallId ~= "" then -- 2960
		do -- 2960
			local i = toolResultIndex - 1 -- 2962
			while i >= 0 do -- 2962
				do -- 2962
					local message = messages[i + 1] -- 2963
					if message.role ~= "assistant" or not message.tool_calls then -- 2963
						goto __continue473 -- 2964
					end -- 2964
					if __TS__ArraySome( -- 2964
						message.tool_calls, -- 2965
						function(____, call) return call.id == toolCallId end -- 2965
					) then -- 2965
						pairStartIndex = i -- 2966
						break -- 2967
					end -- 2967
				end -- 2967
				::__continue473:: -- 2967
				i = i - 1 -- 2962
			end -- 2962
		end -- 2962
	end -- 2962
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2971
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2974
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2978
	upsertStep( -- 2980
		session.id, -- 2980
		questionnaire.taskId, -- 2980
		questionnaire.step, -- 2980
		"ask_user", -- 2980
		{status = "DONE", result = result} -- 2980
	) -- 2980
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2984
	upsertStep( -- 2985
		session.id, -- 2985
		questionnaire.taskId, -- 2985
		answerStep, -- 2985
		"questionnaire_answer", -- 2985
		{status = "DONE", result = result} -- 2985
	) -- 2985
	return {success = true, answerStep = answerStep, result = result} -- 2989
end -- 2915
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2992
	local session = getSessionItem(sessionId) -- 2993
	if not session then -- 2993
		return {success = false, message = "session not found"} -- 2994
	end -- 2994
	if session.kind ~= "main" then -- 2994
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2995
	end -- 2995
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2996
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2996
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2998
	end -- 2998
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3000
	if not llmConfigRes.success then -- 3000
		return {success = false, message = llmConfigRes.message} -- 3001
	end -- 3001
	if not removePendingQuestionnaire(session) then -- 3001
		return {success = false, message = "failed to consume questionnaire file"} -- 3002
	end -- 3002
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3003
	if not replaced.success then -- 3003
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3005
		return replaced -- 3006
	end -- 3006
	local t = now() -- 3008
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3009
	session.workMode = "plan" -- 3010
	local result = startPromptTask( -- 3011
		session, -- 3011
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3011
		nil, -- 3011
		{}, -- 3011
		{ -- 3011
			workMode = "plan", -- 3012
			persistUserMessage = false, -- 3013
			resumeConversation = true, -- 3014
			existingTaskId = questionnaire.taskId, -- 3015
			initialStep = replaced.answerStep, -- 3016
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3017
			llmConfig = llmConfigRes.config -- 3018
		} -- 3018
	) -- 3018
	if not result.success then -- 3018
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3021
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3022
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3023
		emitAgentSessionPatch( -- 3024
			session.id, -- 3024
			{ -- 3024
				session = getSessionItem(session.id), -- 3025
				pendingQuestionnaire = questionnaire -- 3026
			} -- 3026
		) -- 3026
		return result -- 3028
	end -- 3028
	emitAgentSessionPatch( -- 3030
		sessionId, -- 3030
		{ -- 3030
			session = getSessionItem(sessionId), -- 3031
			pendingQuestionnaire = false -- 3032
		} -- 3032
	) -- 3032
	return result -- 3034
end -- 2992
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3037
	local session = getSessionItem(sessionId) -- 3038
	if not session then -- 3038
		return {success = false, message = "session not found"} -- 3039
	end -- 3039
	if session.kind ~= "main" then -- 3039
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3040
	end -- 3040
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3041
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3041
		return {success = false, message = "pending questionnaire not found"} -- 3042
	end -- 3042
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3043
	if not validated.success then -- 3043
		return validated -- 3044
	end -- 3044
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3045
	if not llmConfigRes.success then -- 3045
		return {success = false, message = llmConfigRes.message} -- 3046
	end -- 3046
	local t = now() -- 3047
	if not removePendingQuestionnaire(session) then -- 3047
		return {success = false, message = "failed to consume questionnaire file"} -- 3048
	end -- 3048
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3049
	if not replaced.success then -- 3049
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3051
		return replaced -- 3052
	end -- 3052
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3054
	session.workMode = "plan" -- 3055
	local result = startPromptTask( -- 3056
		session, -- 3056
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3056
		nil, -- 3056
		{}, -- 3056
		{ -- 3056
			workMode = "plan", -- 3057
			persistUserMessage = false, -- 3058
			resumeConversation = true, -- 3059
			existingTaskId = questionnaire.taskId, -- 3060
			initialStep = replaced.answerStep, -- 3061
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3062
			llmConfig = llmConfigRes.config -- 3063
		} -- 3063
	) -- 3063
	if not result.success then -- 3063
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3066
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3067
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3068
		emitAgentSessionPatch( -- 3069
			session.id, -- 3069
			{ -- 3069
				session = getSessionItem(session.id), -- 3070
				pendingQuestionnaire = questionnaire -- 3071
			} -- 3071
		) -- 3071
		return result -- 3073
	end -- 3073
	emitAgentSessionPatch( -- 3075
		sessionId, -- 3075
		{ -- 3075
			session = getSessionItem(sessionId), -- 3076
			pendingQuestionnaire = false -- 3077
		} -- 3077
	) -- 3077
	return result -- 3079
end -- 3037
function ____exports.stopSessionTask(sessionId) -- 3082
	local session = getSessionItem(sessionId) -- 3083
	if not session or session.currentTaskId == nil then -- 3083
		return {success = false, message = "session task not found"} -- 3085
	end -- 3085
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3085
		return {success = false, message = "session task is finalizing"} -- 3088
	end -- 3088
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3090
	local stopToken = activeStopTokens[session.currentTaskId] -- 3091
	if not stopToken then -- 3091
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3091
			return {success = true, recovered = true} -- 3094
		end -- 3094
		return {success = false, message = "task is not running"} -- 3096
	end -- 3096
	if stopToken.stopped then -- 3096
		return {success = true, stopping = true} -- 3099
	end -- 3099
	stopToken.stopped = true -- 3101
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3102
	return {success = true, stopping = true} -- 3106
end -- 3082
function ____exports.getCurrentTaskId(sessionId) -- 3109
	local ____opt_126 = getSessionItem(sessionId) -- 3109
	return ____opt_126 and ____opt_126.currentTaskId -- 3110
end -- 3109
function ____exports.validateTaskAccess(sessionId, taskId) -- 3113
	local session = getSessionItem(sessionId) -- 3114
	if not session then -- 3114
		return {success = false, message = "session not found"} -- 3115
	end -- 3115
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3115
		getSessionOperableTaskIds(sessionId), -- 3116
		taskId -- 3116
	) < 0 then -- 3116
		return {success = false, message = "task is not operable for this session"} -- 3117
	end -- 3117
	return {success = true, session = session} -- 3119
end -- 3113
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3122
	if checkpointId <= 0 then -- 3122
		return {success = false, message = "invalid checkpointId"} -- 3124
	end -- 3124
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3126
	if not checkpoint then -- 3126
		return {success = false, message = "checkpoint not found"} -- 3128
	end -- 3128
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3130
	if not taskAccess.success then -- 3130
		return taskAccess -- 3131
	end -- 3131
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3132
end -- 3122
function ____exports.listRunningSessions() -- 3135
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3136
	local sessions = {} -- 3143
	do -- 3143
		local i = 0 -- 3144
		while i < #rows do -- 3144
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3145
			if session.currentTaskStatus == "RUNNING" then -- 3145
				sessions[#sessions + 1] = session -- 3147
			end -- 3147
			i = i + 1 -- 3144
		end -- 3144
	end -- 3144
	return {success = true, sessions = sessions} -- 3150
end -- 3135
return ____exports -- 3135