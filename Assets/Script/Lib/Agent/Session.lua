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
local ____VisionAssets = require("Agent.Tool.VisionAssets") -- 7
local removeVisionSessionAssets = ____VisionAssets.removeVisionSessionAssets -- 7
local renameVisionSessionAssets = ____VisionAssets.renameVisionSessionAssets -- 7
local AgentToolRegistry = require("Agent.Tool.Registry") -- 8
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 9
local Tools = require("Agent.Tools") -- 10
local ____Database = require("Agent.Storage.Database") -- 11
local TABLE_SESSION = ____Database.TABLE_SESSION -- 12
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 13
local TABLE_STEP = ____Database.TABLE_STEP -- 14
local TABLE_TASK = ____Database.TABLE_TASK -- 15
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 16
local addTaskReference = ____Database.addTaskReference -- 17
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 18
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 19
local requireAgentStorage = ____Database.requireAgentStorage -- 20
local ____Memory = require("Agent.Memory") -- 22
local DualLayerStorage = ____Memory.DualLayerStorage -- 22
local ____Utils = require("Agent.Utils") -- 23
local Log = ____Utils.Log -- 23
local getLLMConfig = ____Utils.getLLMConfig -- 23
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 23
local safeJsonDecode = ____Utils.safeJsonDecode -- 23
local safeJsonEncode = ____Utils.safeJsonEncode -- 23
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 23
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 23
local ____Questionnaire = require("Agent.Questionnaire") -- 27
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 27
local ____Support = require("Agent.Storage.Support") -- 29
local getLastInsertRowId = ____Support.getLastInsertRowId -- 29
local queryOne = ____Support.queryOne -- 29
local queryRows = ____Support.queryRows -- 29
local toStr = ____Support.toStr -- 29
function getDefaultUseChineseResponse() -- 335
	local zh = string.match(App.locale, "^zh") -- 336
	return zh ~= nil -- 337
end -- 337
function encodeJson(value) -- 340
	local text = safeJsonEncode(value) -- 341
	return text or "" -- 342
end -- 342
function decodeJsonObject(text) -- 345
	if not text or text == "" then -- 345
		return nil -- 346
	end -- 346
	local value = safeJsonDecode(text) -- 347
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 347
		return value -- 349
	end -- 349
	return nil -- 351
end -- 351
function decodeJsonFiles(text) -- 354
	if not text or text == "" then -- 354
		return nil -- 355
	end -- 355
	local value = safeJsonDecode(text) -- 356
	if not value or not __TS__ArrayIsArray(value) then -- 356
		return nil -- 357
	end -- 357
	local files = {} -- 358
	do -- 358
		local i = 0 -- 359
		while i < #value do -- 359
			do -- 359
				local item = value[i + 1] -- 360
				if type(item) ~= "table" then -- 360
					goto __continue12 -- 361
				end -- 361
				files[#files + 1] = { -- 362
					path = sanitizeUTF8(toStr(item.path)), -- 363
					op = sanitizeUTF8(toStr(item.op)) -- 364
				} -- 364
			end -- 364
			::__continue12:: -- 364
			i = i + 1 -- 359
		end -- 359
	end -- 359
	return files -- 367
end -- 367
function decodeChangeSetSummary(value) -- 370
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 370
		return nil -- 371
	end -- 371
	local row = value -- 372
	if row.success ~= true then -- 372
		return nil -- 373
	end -- 373
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 374
	if taskId <= 0 then -- 374
		return nil -- 375
	end -- 375
	local files = {} -- 376
	if __TS__ArrayIsArray(row.files) then -- 376
		do -- 376
			local i = 0 -- 378
			while i < #row.files do -- 378
				do -- 378
					local file = row.files[i + 1] -- 379
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 379
						goto __continue20 -- 380
					end -- 380
					local fileRow = file -- 381
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 382
					if path == "" then -- 382
						goto __continue20 -- 383
					end -- 383
					local checkpointIds = {} -- 384
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 384
						do -- 384
							local j = 0 -- 386
							while j < #fileRow.checkpointIds do -- 386
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 387
								if checkpointId > 0 then -- 387
									checkpointIds[#checkpointIds + 1] = checkpointId -- 388
								end -- 388
								j = j + 1 -- 386
							end -- 386
						end -- 386
					end -- 386
					local op = toStr(fileRow.op) -- 391
					files[#files + 1] = { -- 392
						path = path, -- 393
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 394
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 395
						checkpointIds = checkpointIds -- 396
					} -- 396
				end -- 396
				::__continue20:: -- 396
				i = i + 1 -- 378
			end -- 378
		end -- 378
	end -- 378
	return { -- 400
		success = true, -- 401
		taskId = taskId, -- 402
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 403
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 404
		files = files, -- 405
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 406
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 407
	} -- 407
end -- 407
function decodeHandoffEvidence(value) -- 411
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 411
		return nil -- 412
	end -- 412
	local row = value -- 413
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 414
		__TS__ArrayFilter( -- 415
			row.modifiedFiles, -- 415
			function(____, item) return type(item) == "string" end -- 415
		), -- 415
		function(____, item) return sanitizeUTF8(item) end -- 415
	) or ({}) -- 415
	local lastBuild = nil -- 417
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 417
		local build = row.lastBuild -- 419
		lastBuild = { -- 420
			result = build.result == "passed" and "passed" or "failed", -- 421
			path = sanitizeUTF8(toStr(build.path)), -- 422
			evidence = takeUtf8Head( -- 423
				sanitizeUTF8(toStr(build.evidence)), -- 423
				600 -- 423
			) -- 423
		} -- 423
	end -- 423
	local commands = {} -- 426
	if __TS__ArrayIsArray(row.commands) then -- 426
		do -- 426
			local i = 0 -- 428
			while i < #row.commands and #commands < 8 do -- 428
				do -- 428
					local raw = row.commands[i + 1] -- 429
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 429
						goto __continue34 -- 430
					end -- 430
					local item = raw -- 431
					commands[#commands + 1] = { -- 432
						mode = sanitizeUTF8(toStr(item.mode)), -- 433
						command = takeUtf8Head( -- 434
							sanitizeUTF8(toStr(item.command)), -- 434
							600 -- 434
						), -- 434
						result = item.result == "passed" and "passed" or "failed", -- 435
						evidence = takeUtf8Head( -- 436
							sanitizeUTF8(toStr(item.evidence)), -- 436
							600 -- 436
						) -- 436
					} -- 436
				end -- 436
				::__continue34:: -- 436
				i = i + 1 -- 428
			end -- 428
		end -- 428
	end -- 428
	local authoritativeSources = {} -- 440
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 440
		do -- 440
			local i = 0 -- 442
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 442
				do -- 442
					local raw = row.authoritativeSources[i + 1] -- 443
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 443
						goto __continue38 -- 444
					end -- 444
					local item = raw -- 445
					authoritativeSources[#authoritativeSources + 1] = { -- 446
						tool = "search_dora_doc", -- 447
						query = takeUtf8Head( -- 448
							sanitizeUTF8(toStr(item.query)), -- 448
							300 -- 448
						), -- 448
						source = sanitizeUTF8(toStr(item.source)), -- 449
						result = item.result == "passed" and "passed" or "failed" -- 450
					} -- 450
				end -- 450
				::__continue38:: -- 450
				i = i + 1 -- 442
			end -- 442
		end -- 442
	end -- 442
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 454
end -- 454
function takeUtf8Head(text, maxChars) -- 457
	if maxChars <= 0 or text == "" then -- 457
		return "" -- 458
	end -- 458
	local nextPos = utf8.offset(text, maxChars + 1) -- 459
	if nextPos == nil then -- 459
		return text -- 460
	end -- 460
	return string.sub(text, 1, nextPos - 1) -- 461
end -- 461
function normalizeMemoryEntryEvidence(value) -- 464
	local evidence = {} -- 465
	if not __TS__ArrayIsArray(value) then -- 465
		return evidence -- 466
	end -- 466
	do -- 466
		local i = 0 -- 467
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 467
			do -- 467
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 468
				if item == "" then -- 468
					goto __continue46 -- 469
				end -- 469
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 469
					evidence[#evidence + 1] = item -- 471
				end -- 471
			end -- 471
			::__continue46:: -- 471
			i = i + 1 -- 467
		end -- 467
	end -- 467
	return evidence -- 474
end -- 474
function decodeSubAgentMemoryEntry(value) -- 477
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 477
		return nil -- 478
	end -- 478
	local row = value -- 479
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 480
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 481
	local content = takeUtf8Head( -- 482
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 482
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 482
	) -- 482
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 482
		return nil -- 483
	end -- 483
	return { -- 484
		sourceSessionId = sourceSessionId, -- 485
		sourceTaskId = sourceTaskId, -- 486
		content = content, -- 487
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 488
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 489
	} -- 489
end -- 489
function getTaskChangeSetSummary(taskId) -- 493
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 494
	return summary.success and summary or nil -- 495
end -- 495
function summarizeHandoffResult(result) -- 498
	local candidates = {result.output, result.message, result.state, result.phase} -- 499
	do -- 499
		local i = 0 -- 500
		while i < #candidates do -- 500
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 501
			if text ~= "" then -- 501
				return takeUtf8Head(text, 600) -- 502
			end -- 502
			i = i + 1 -- 500
		end -- 500
	end -- 500
	local messages = result.messages -- 504
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 504
		local parts = {} -- 506
		do -- 506
			local i = 0 -- 507
			while i < #messages and #parts < 4 do -- 507
				do -- 507
					local row = messages[i + 1] -- 508
					if not row or type(row) ~= "table" then -- 508
						goto __continue59 -- 509
					end -- 509
					local item = row -- 510
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 511
					local ____toStr_2 = toStr -- 511
					local ____item_message_0 = item.message -- 511
					if ____item_message_0 == nil then -- 511
						____item_message_0 = item.error -- 511
					end -- 511
					local ____item_message_0_1 = ____item_message_0 -- 511
					if ____item_message_0_1 == nil then -- 511
						____item_message_0_1 = item.file -- 511
					end -- 511
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 511
					if text ~= "" then -- 511
						parts[#parts + 1] = text -- 512
					end -- 512
				end -- 512
				::__continue59:: -- 512
				i = i + 1 -- 507
			end -- 507
		end -- 507
		if #parts > 0 then -- 507
			return takeUtf8Head( -- 514
				table.concat(parts, "; "), -- 514
				600 -- 514
			) -- 514
		end -- 514
	end -- 514
	return result.success == true and "tool result success=true" or "tool result success=false" -- 516
end -- 516
function getTaskHandoffEvidence(taskId, changeSet) -- 519
	local ____opt_4 = changeSet -- 519
	local evidence = { -- 520
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 521
			changeSet and changeSet.files, -- 521
			function(____, item) return item.path end -- 521
		) or ({}), -- 521
		commands = {}, -- 522
		authoritativeSources = {} -- 523
	} -- 523
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 525
	do -- 525
		local i = 0 -- 530
		while i < #rows do -- 530
			local tool = toStr(rows[i + 1][1]) -- 531
			local status = toStr(rows[i + 1][2]) -- 532
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 533
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 534
			local passed = status == "DONE" and result.success == true -- 535
			if tool == "build" then -- 535
				evidence.lastBuild = { -- 537
					result = passed and "passed" or "failed", -- 538
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 539
					evidence = summarizeHandoffResult(result) -- 540
				} -- 540
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 540
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 543
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 544
				local ____evidence_commands_8 = evidence.commands -- 544
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 545
					mode = mode, -- 546
					command = takeUtf8Head( -- 547
						__TS__StringTrim(sanitizeUTF8(command)), -- 547
						600 -- 547
					), -- 547
					result = passed and "passed" or "failed", -- 548
					evidence = summarizeHandoffResult(result) -- 549
				} -- 549
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 549
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 549
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 552
					tool = "search_dora_doc", -- 553
					query = takeUtf8Head( -- 554
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 554
						300 -- 554
					), -- 554
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 555
					result = passed and "passed" or "failed" -- 556
				} -- 556
			end -- 556
			i = i + 1 -- 530
		end -- 530
	end -- 530
	return evidence -- 560
end -- 560
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 563
	local lastBuild = evidence.lastBuild -- 567
	if not lastBuild or lastBuild.result ~= "failed" then -- 567
		return completion -- 568
	end -- 568
	local validation = __TS__ArraySlice(completion.validation) -- 569
	local foundBuild = false -- 570
	do -- 570
		local i = 0 -- 571
		while i < #validation do -- 571
			do -- 571
				if validation[i + 1].kind ~= "build" then -- 571
					goto __continue73 -- 572
				end -- 572
				foundBuild = true -- 573
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 574
			end -- 574
			::__continue73:: -- 574
			i = i + 1 -- 571
		end -- 571
	end -- 571
	if not foundBuild then -- 571
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 581
	end -- 581
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 583
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 584
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 584
		knownIssues[#knownIssues + 1] = issue -- 585
	end -- 585
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 586
end -- 586
function isValidProjectRoot(path) -- 594
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 595
end -- 595
function rowToSession(row) -- 598
	return { -- 599
		id = row[1], -- 600
		projectRoot = toStr(row[2]), -- 601
		title = toStr(row[3]), -- 602
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 603
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 604
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 605
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 606
		status = toStr(row[8]), -- 607
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 608
		currentTaskStatus = toStr(row[10]), -- 609
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 610
		createdAt = row[11], -- 611
		updatedAt = row[12], -- 612
		metrics = decodeJsonObject(toStr(row[13])), -- 613
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 614
	} -- 614
end -- 614
function rowToMessage(row) -- 618
	local message = { -- 619
		id = row[1], -- 620
		sessionId = row[2], -- 621
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 622
		role = toStr(row[4]), -- 623
		content = toStr(row[5]), -- 624
		createdAt = row[7], -- 625
		updatedAt = row[8] -- 626
	} -- 626
	local displayContent = toStr(row[6]) -- 628
	if displayContent ~= "" then -- 628
		message.displayContent = displayContent -- 629
	end -- 629
	return message -- 630
end -- 630
function rowToStep(row) -- 633
	return { -- 634
		id = row[1], -- 635
		sessionId = row[2], -- 636
		taskId = row[3], -- 637
		step = row[4], -- 638
		tool = toStr(row[5]), -- 639
		status = toStr(row[6]), -- 640
		reason = toStr(row[7]), -- 641
		reasoningContent = toStr(row[8]), -- 642
		params = decodeJsonObject(toStr(row[9])), -- 643
		result = decodeJsonObject(toStr(row[10])), -- 644
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 645
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 646
		files = decodeJsonFiles(toStr(row[13])), -- 647
		createdAt = row[14], -- 648
		updatedAt = row[15] -- 649
	} -- 649
end -- 649
function getQuestionnairePath(projectRoot) -- 653
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 654
end -- 654
function decodeQuestionnaireFile(text) -- 657
	local value = decodeJsonObject(text) -- 658
	if not value then -- 658
		return nil -- 659
	end -- 659
	local schema = value.schema -- 660
	local id = type(value.id) == "number" and value.id or 0 -- 661
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 662
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 663
	local step = type(value.step) == "number" and value.step or 0 -- 664
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 665
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 665
		return nil -- 667
	end -- 667
	return { -- 669
		id = id, -- 669
		sessionId = sessionId, -- 669
		taskId = taskId, -- 669
		step = step, -- 669
		status = "PENDING", -- 669
		schema = schema, -- 669
		createdAt = createdAt -- 669
	} -- 669
end -- 669
function getPendingQuestionnaire(sessionId) -- 672
	local session = getSessionItem(sessionId) -- 673
	if not session or session.kind ~= "main" then -- 673
		return nil -- 674
	end -- 674
	local path = getQuestionnairePath(session.projectRoot) -- 675
	if not Content:exist(path) then -- 675
		return nil -- 676
	end -- 676
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 677
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 678
end -- 678
function restorePendingQuestionnaireState(session) -- 681
	local questionnaire = getPendingQuestionnaire(session.id) -- 682
	if not questionnaire then -- 682
		return {session = session} -- 683
	end -- 683
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 683
		local t = now() -- 690
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 691
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 697
		local restored = getSessionItem(session.id) -- 698
		if restored then -- 698
			session = restored -- 699
		end -- 699
	end -- 699
	return {session = session, questionnaire = questionnaire} -- 701
end -- 701
function savePendingQuestionnaire(projectRoot, questionnaire) -- 704
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 705
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 705
		return false -- 706
	end -- 706
	local path = getQuestionnairePath(projectRoot) -- 707
	local tempPath = path .. ".tmp" -- 708
	local backupPath = path .. ".bak" -- 709
	Content:remove(tempPath) -- 710
	Content:remove(backupPath) -- 711
	if not Content:save( -- 711
		tempPath, -- 712
		encodeJson(questionnaire) -- 712
	) then -- 712
		return false -- 712
	end -- 712
	local hadOriginal = Content:exist(path) -- 713
	if hadOriginal and not Content:move(path, backupPath) then -- 713
		Content:remove(tempPath) -- 715
		return false -- 716
	end -- 716
	if Content:move(tempPath, path) then -- 716
		Content:remove(backupPath) -- 719
		Tools.sendWebIDEFileUpdate( -- 720
			path, -- 720
			true, -- 720
			encodeJson(questionnaire) -- 720
		) -- 720
		return true -- 721
	end -- 721
	Content:remove(tempPath) -- 723
	if hadOriginal and Content:exist(backupPath) then -- 723
		Content:move(backupPath, path) -- 725
	end -- 725
	return false -- 727
end -- 727
function removePendingQuestionnaire(session) -- 730
	local path = getQuestionnairePath(session.projectRoot) -- 731
	if not Content:exist(path) then -- 731
		return true -- 732
	end -- 732
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 733
	if questionnaire and questionnaire.sessionId ~= session.id then -- 733
		return false -- 734
	end -- 734
	if not Content:remove(path) then -- 734
		return false -- 735
	end -- 735
	Tools.sendWebIDEFileUpdate(path, false, "") -- 736
	return true -- 737
end -- 737
function publishQuestionnaire(request) -- 740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 740
		local session = getSessionItem(request.sessionId) -- 746
		if not session or session.kind ~= "main" then -- 746
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 746
		end -- 746
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 748
		if Content:exist(pendingPath) then -- 748
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 748
		end -- 748
		local questionnaire = { -- 750
			id = request.taskId, -- 751
			sessionId = request.sessionId, -- 752
			taskId = request.taskId, -- 753
			step = request.step, -- 754
			status = "PENDING", -- 755
			schema = request.schema, -- 756
			createdAt = now() -- 757
		} -- 757
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 757
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 757
		end -- 757
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 757
	end) -- 757
end -- 757
function getMessageItem(messageId) -- 765
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 766
	return row and rowToMessage(row) or nil -- 772
end -- 772
function getStepItem(sessionId, taskId, step) -- 775
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 776
	return row and rowToStep(row) or nil -- 782
end -- 782
function deleteMessageSteps(sessionId, taskId) -- 785
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 786
	local ids = {} -- 791
	do -- 791
		local i = 0 -- 792
		while i < #rows do -- 792
			local row = rows[i + 1] -- 793
			if type(row[1]) == "number" then -- 793
				ids[#ids + 1] = row[1] -- 795
			end -- 795
			i = i + 1 -- 792
		end -- 792
	end -- 792
	if #ids > 0 then -- 792
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 799
	end -- 799
	return ids -- 805
end -- 805
function normalizeDisabledAgentTools(value) -- 808
	if not __TS__ArrayIsArray(value) then -- 808
		return {} -- 809
	end -- 809
	local tools = {} -- 810
	do -- 810
		local i = 0 -- 811
		while i < #value do -- 811
			do -- 811
				local name = value[i + 1] -- 812
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 812
					goto __continue117 -- 813
				end -- 813
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 813
					tools[#tools + 1] = name -- 814
				end -- 814
			end -- 814
			::__continue117:: -- 814
			i = i + 1 -- 811
		end -- 811
	end -- 811
	return tools -- 816
end -- 816
function normalizeWorkMode(value, fallback) -- 819
	if fallback == nil then -- 819
		fallback = "code" -- 819
	end -- 819
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 820
end -- 820
function getSessionRow(sessionId) -- 823
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 824
end -- 824
function getSessionItem(sessionId) -- 832
	local row = getSessionRow(sessionId) -- 833
	return row and rowToSession(row) or nil -- 834
end -- 834
function getTaskPrompt(taskId) -- 837
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 838
	if not row or type(row[1]) ~= "string" then -- 838
		return nil -- 839
	end -- 839
	return toStr(row[1]) -- 840
end -- 840
function getLatestMainSessionByProjectRoot(projectRoot) -- 843
	if not isValidProjectRoot(projectRoot) then -- 843
		return nil -- 844
	end -- 844
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 845
	return row and rowToSession(row) or nil -- 853
end -- 853
function countRunningSubSessions(rootSessionId) -- 856
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 857
	local count = 0 -- 864
	do -- 864
		local i = 0 -- 865
		while i < #rows do -- 865
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 866
			if session.currentTaskStatus == "RUNNING" then -- 866
				count = count + 1 -- 868
			end -- 868
			i = i + 1 -- 865
		end -- 865
	end -- 865
	return count -- 871
end -- 871
function deleteSessionRecords(sessionId, preserveArtifacts) -- 874
	if preserveArtifacts == nil then -- 874
		preserveArtifacts = false -- 874
	end -- 874
	local session = getSessionItem(sessionId) -- 875
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 876
	local taskIds = {} -- 884
	do -- 884
		local i = 0 -- 885
		while i < #taskRows do -- 885
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 886
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 886
				taskIds[#taskIds + 1] = taskId -- 888
				local stopToken = activeStopTokens[taskId] -- 889
				if stopToken ~= nil then -- 889
					stopToken.stopped = true -- 891
					stopToken.reason = "session deleted" -- 892
				end -- 892
			end -- 892
			i = i + 1 -- 885
		end -- 885
	end -- 885
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 896
	do -- 896
		local i = 0 -- 897
		while i < #children do -- 897
			local row = children[i + 1] -- 898
			if type(row[1]) == "number" and row[1] > 0 then -- 898
				deleteSessionRecords(row[1], preserveArtifacts) -- 900
			end -- 900
			i = i + 1 -- 897
		end -- 897
	end -- 897
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 903
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 904
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 905
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 906
	if session and session.kind == "main" then -- 906
		removePendingQuestionnaire(session) -- 908
		if not preserveArtifacts then -- 908
			removeVisionSessionAssets(session.rootSessionId > 0 and session.rootSessionId or session.id) -- 909
		end -- 909
	end -- 909
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 909
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 909
			Tools.sendWebIDERefreshTree() -- 913
		end -- 913
	end -- 913
	do -- 913
		local i = 0 -- 916
		while i < #taskIds do -- 916
			cleanupTaskHeavyData(taskIds[i + 1]) -- 917
			i = i + 1 -- 916
		end -- 916
	end -- 916
end -- 916
function getSessionRootId(session) -- 921
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 922
end -- 922
function getRootSessionItem(sessionId) -- 925
	local session = getSessionItem(sessionId) -- 926
	if not session then -- 926
		return nil -- 927
	end -- 927
	return getSessionItem(getSessionRootId(session)) or session -- 928
end -- 928
function listRelatedSessions(sessionId) -- 931
	local root = getRootSessionItem(sessionId) -- 932
	if not root then -- 932
		return {} -- 933
	end -- 933
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 934
	return __TS__ArrayMap( -- 943
		rows, -- 943
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 943
	) -- 943
end -- 943
function getSessionSpawnInfo(session) -- 946
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 947
	if not info then -- 947
		return nil -- 948
	end -- 948
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 950
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 951
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 952
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 953
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 954
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 955
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 956
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 957
		__TS__ArrayFilter( -- 958
			info.filesHint, -- 958
			function(____, item) return type(item) == "string" end -- 958
		), -- 958
		function(____, item) return sanitizeUTF8(item) end -- 958
	) or nil -- 958
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 960
	local ____temp_13 -- 963
	if info.success == true then -- 963
		____temp_13 = true -- 963
	else -- 963
		local ____temp_12 -- 963
		if info.success == false then -- 963
			____temp_12 = false -- 963
		else -- 963
			____temp_12 = nil -- 963
		end -- 963
		____temp_13 = ____temp_12 -- 963
	end -- 963
	local ____temp_14 -- 964
	if info.cleared == true then -- 964
		____temp_14 = true -- 964
	else -- 964
		____temp_14 = nil -- 964
	end -- 964
	return { -- 949
		sessionId = ____temp_15, -- 950
		rootSessionId = ____temp_16, -- 951
		parentSessionId = ____temp_17, -- 952
		title = ____temp_18, -- 953
		prompt = ____temp_19, -- 954
		goal = ____temp_20, -- 955
		expectedOutput = ____temp_21, -- 956
		filesHint = ____temp_22, -- 957
		status = ____temp_23, -- 960
		success = ____temp_13, -- 963
		cleared = ____temp_14, -- 964
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 965
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 966
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 967
		changeSet = decodeChangeSetSummary(info.changeSet), -- 968
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 969
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 970
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 971
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 972
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 975
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 976
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 977
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 978
	} -- 978
end -- 978
function ensureDirRecursive(dir) -- 995
	if not dir or dir == "" then -- 995
		return false -- 996
	end -- 996
	if Content:exist(dir) then -- 996
		return Content:isdir(dir) -- 997
	end -- 997
	local parent = Path:getPath(dir) -- 998
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 998
		if not ensureDirRecursive(parent) then -- 998
			return false -- 1001
		end -- 1001
	end -- 1001
	return Content:mkdir(dir) -- 1004
end -- 1004
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1007
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1008
	if not Content:exist(dir) then -- 1008
		ensureDirRecursive(dir) -- 1010
	end -- 1010
	local path = Path(dir, SPAWN_INFO_FILE) -- 1012
	local text = safeJsonEncode(value) -- 1013
	if not text then -- 1013
		return false -- 1014
	end -- 1014
	local content = text .. "\n" -- 1015
	if not Content:save(path, content) then -- 1015
		return false -- 1017
	end -- 1017
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1019
	return true -- 1020
end -- 1020
function readSpawnInfo(projectRoot, memoryScope) -- 1023
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1024
	if not Content:exist(path) then -- 1024
		return nil -- 1025
	end -- 1025
	local text = Content:load(path) -- 1026
	if not text or __TS__StringTrim(text) == "" then -- 1026
		return nil -- 1027
	end -- 1027
	local value = safeJsonDecode(text) -- 1028
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1028
		return value -- 1030
	end -- 1030
	return nil -- 1032
end -- 1032
function getArtifactRelativeDir(memoryScope) -- 1035
	return Path(".agent", memoryScope) -- 1036
end -- 1036
function getArtifactDir(projectRoot, memoryScope) -- 1039
	return Path( -- 1040
		projectRoot, -- 1040
		getArtifactRelativeDir(memoryScope) -- 1040
	) -- 1040
end -- 1040
function getResultRelativePath(memoryScope) -- 1043
	return Path( -- 1044
		getArtifactRelativeDir(memoryScope), -- 1044
		RESULT_FILE -- 1044
	) -- 1044
end -- 1044
function getResultPath(projectRoot, memoryScope) -- 1047
	return Path( -- 1048
		projectRoot, -- 1048
		getResultRelativePath(memoryScope) -- 1048
	) -- 1048
end -- 1048
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1051
	if not resultFilePath or resultFilePath == "" then -- 1051
		return "" -- 1052
	end -- 1052
	local path = Path(projectRoot, resultFilePath) -- 1053
	if not Content:exist(path) then -- 1053
		return "" -- 1054
	end -- 1054
	local text = sanitizeUTF8(Content:load(path)) -- 1055
	if not text or __TS__StringTrim(text) == "" then -- 1055
		return "" -- 1056
	end -- 1056
	local marker = "\n## Summary\n" -- 1057
	local start = string.find(text, marker, 1, true) -- 1058
	if start ~= nil then -- 1058
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1060
	end -- 1060
	return __TS__StringTrim(text) -- 1062
end -- 1062
function buildStructuredSubAgentMemoryEntry(record) -- 1065
	local hasPassedValidation = false -- 1066
	do -- 1066
		local i = 0 -- 1067
		while i < #record.completion.validation do -- 1067
			local result = record.completion.validation[i + 1].result -- 1068
			if result == "failed" then -- 1068
				return nil -- 1073
			end -- 1073
			if result == "passed" then -- 1073
				hasPassedValidation = true -- 1075
			end -- 1075
			i = i + 1 -- 1067
		end -- 1067
	end -- 1067
	if not hasPassedValidation then -- 1067
		return nil -- 1078
	end -- 1078
	local candidates = record.completion.learningCandidates -- 1079
	local claims = {} -- 1080
	local evidence = {} -- 1081
	do -- 1081
		local i = 0 -- 1082
		while i < #candidates do -- 1082
			do -- 1082
				local candidate = candidates[i + 1] -- 1083
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1083
					goto __continue189 -- 1084
				end -- 1084
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1085
				do -- 1085
					local j = 0 -- 1086
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1086
						local item = candidate.evidence[j + 1] -- 1087
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1087
							evidence[#evidence + 1] = item -- 1088
						end -- 1088
						j = j + 1 -- 1086
					end -- 1086
				end -- 1086
			end -- 1086
			::__continue189:: -- 1086
			i = i + 1 -- 1082
		end -- 1082
	end -- 1082
	local content = takeUtf8Head( -- 1091
		table.concat(claims, "\n"), -- 1091
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1091
	) -- 1091
	if content == "" then -- 1091
		return nil -- 1092
	end -- 1092
	return { -- 1093
		sourceSessionId = record.sessionId, -- 1094
		sourceTaskId = record.sourceTaskId, -- 1095
		content = content, -- 1096
		evidence = evidence, -- 1097
		createdAt = record.finishedAt -- 1098
	} -- 1098
end -- 1098
function containsNormalizedText(text, query) -- 1102
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1103
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1104
	if normalizedQuery == "" then -- 1104
		return true -- 1105
	end -- 1105
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1106
end -- 1106
function getSubAgentDisplayKey(item) -- 1109
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1115
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1116
	local label = goal ~= "" and goal or title -- 1117
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1118
end -- 1118
function writeSubAgentResultFile(session, record, resultText) -- 1121
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1122
	if not Content:exist(dir) then -- 1122
		ensureDirRecursive(dir) -- 1124
	end -- 1124
	local ____array_32 = __TS__SparseArrayNew( -- 1124
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1127
		"- Status: " .. record.status, -- 1128
		"- Success: " .. (record.success and "true" or "false"), -- 1129
		"- Outcome: " .. record.completion.outcome, -- 1130
		"- Session ID: " .. tostring(record.sessionId), -- 1131
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1132
		"- Goal: " .. record.goal, -- 1133
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1134
	) -- 1134
	__TS__SparseArrayPush( -- 1134
		____array_32, -- 1134
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1135
	) -- 1135
	__TS__SparseArrayPush( -- 1135
		____array_32, -- 1135
		"- Finished At: " .. record.finishedAt, -- 1136
		"", -- 1137
		"## Validation", -- 1138
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1139
			record.completion.validation, -- 1140
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1140
		) or ({"- Not reported"})) -- 1140
	) -- 1140
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1140
	local ____opt_24 = record.handoffEvidence -- 1140
	__TS__SparseArrayPush( -- 1140
		____array_32, -- 1140
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1144
			record.handoffEvidence.modifiedFiles, -- 1145
			function(____, item) return "- modified: " .. item end -- 1145
		) or ({"- modified: none recorded"})) -- 1145
	) -- 1145
	local ____opt_26 = record.handoffEvidence -- 1145
	__TS__SparseArrayPush( -- 1145
		____array_32, -- 1145
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1147
	) -- 1147
	local ____opt_28 = record.handoffEvidence -- 1147
	__TS__SparseArrayPush( -- 1147
		____array_32, -- 1147
		table.unpack(__TS__ArrayMap( -- 1150
			____opt_28 and ____opt_28.commands or ({}), -- 1150
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1150
		)) -- 1150
	) -- 1150
	local ____opt_30 = record.handoffEvidence -- 1150
	__TS__SparseArrayPush( -- 1150
		____array_32, -- 1150
		table.unpack(__TS__ArrayMap( -- 1151
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1151
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1151
		)) -- 1151
	) -- 1151
	__TS__SparseArrayPush( -- 1151
		____array_32, -- 1151
		"", -- 1152
		"## Known Issues", -- 1153
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1154
			record.completion.knownIssues, -- 1154
			function(____, item) return "- " .. item end -- 1154
		) or ({"- None reported"})) -- 1154
	) -- 1154
	__TS__SparseArrayPush( -- 1154
		____array_32, -- 1154
		"", -- 1155
		"## Assumptions", -- 1156
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1157
			record.completion.assumptions, -- 1157
			function(____, item) return "- " .. item end -- 1157
		) or ({"- None reported"})) -- 1157
	) -- 1157
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1157
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1126
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1162
	local content = table.concat(lines, "\n") .. "\n" -- 1163
	if not Content:save(path, content) then -- 1163
		return false -- 1165
	end -- 1165
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1167
	return true -- 1168
end -- 1168
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1171
	local dir = Path(projectRoot, ".agent", "subagents") -- 1172
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1172
		return {} -- 1173
	end -- 1173
	local items = {} -- 1174
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1175
		do -- 1175
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1176
			if not Content:exist(path) or not Content:isdir(path) then -- 1176
				goto __continue209 -- 1177
			end -- 1177
			local info = readSpawnInfo( -- 1178
				projectRoot, -- 1178
				Path( -- 1178
					"subagents", -- 1178
					Path:getFilename(path) -- 1178
				) -- 1178
			) -- 1178
			if not info then -- 1178
				goto __continue209 -- 1179
			end -- 1179
			local sessionId = tonumber(info.sessionId) -- 1180
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1181
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1182
			local status = sanitizeUTF8(toStr(info.status)) -- 1183
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1183
				goto __continue209 -- 1184
			end -- 1184
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1184
				goto __continue209 -- 1185
			end -- 1185
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1186
			items[#items + 1] = { -- 1187
				sessionId = sessionId, -- 1188
				rootSessionId = infoRootSessionId, -- 1189
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1190
				title = sanitizeUTF8(toStr(info.title)), -- 1191
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1192
				goal = sanitizeUTF8(toStr(info.goal)), -- 1193
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1194
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1195
					__TS__ArrayFilter( -- 1196
						info.filesHint, -- 1196
						function(____, item) return type(item) == "string" end -- 1196
					), -- 1196
					function(____, item) return sanitizeUTF8(item) end -- 1196
				) or ({}), -- 1196
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1198
				success = info.success == true, -- 1199
				cleared = info.cleared == true, -- 1200
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1201
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1202
					"subagents", -- 1202
					Path:getFilename(path) -- 1202
				)), -- 1202
				sourceTaskId = sourceTaskId or 0, -- 1203
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1204
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1205
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1206
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1207
				completion = normalizeAgentCompletionReport(info.completion), -- 1208
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1209
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1210
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1211
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1212
			} -- 1212
		end -- 1212
		::__continue209:: -- 1212
	end -- 1212
	__TS__ArraySort( -- 1215
		items, -- 1215
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1215
	) -- 1215
	return items -- 1216
end -- 1216
function getPendingHandoffDir(projectRoot, memoryScope) -- 1219
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1220
end -- 1220
function writePendingHandoff(projectRoot, memoryScope, value) -- 1223
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1224
	if not Content:exist(dir) then -- 1224
		ensureDirRecursive(dir) -- 1226
	end -- 1226
	local path = Path(dir, value.id .. ".json") -- 1228
	local text = safeJsonEncode(value) -- 1229
	if not text then -- 1229
		return false -- 1230
	end -- 1230
	local content = text .. "\n" -- 1231
	if not Content:save(path, content) then -- 1231
		return false -- 1232
	end -- 1232
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1233
	return true -- 1234
end -- 1234
function listPendingHandoffs(projectRoot, memoryScope) -- 1237
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1238
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1238
		return {} -- 1239
	end -- 1239
	local items = {} -- 1240
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1241
		do -- 1241
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1242
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1242
				goto __continue225 -- 1243
			end -- 1243
			local text = Content:load(path) -- 1244
			if not text or __TS__StringTrim(text) == "" then -- 1244
				goto __continue225 -- 1245
			end -- 1245
			local obj = safeJsonDecode(text) -- 1246
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1246
				goto __continue225 -- 1247
			end -- 1247
			local value = obj -- 1248
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1249
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1250
			local id = sanitizeUTF8(toStr(value.id)) -- 1251
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1252
			local message = sanitizeUTF8(toStr(value.message)) -- 1253
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1254
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1255
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1256
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1256
				goto __continue225 -- 1258
			end -- 1258
			items[#items + 1] = { -- 1260
				id = id, -- 1261
				sourceSessionId = sourceSessionId, -- 1262
				sourceTitle = sourceTitle, -- 1263
				sourceTaskId = sourceTaskId, -- 1264
				message = message, -- 1265
				prompt = prompt, -- 1266
				goal = goal, -- 1267
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1268
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1269
					__TS__ArrayFilter( -- 1270
						value.filesHint, -- 1270
						function(____, item) return type(item) == "string" end -- 1270
					), -- 1270
					function(____, item) return sanitizeUTF8(item) end -- 1270
				) or ({}), -- 1270
				success = value.success == true, -- 1272
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1273
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1274
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1275
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1276
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1277
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1278
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1279
				createdAt = createdAt -- 1282
			} -- 1282
		end -- 1282
		::__continue225:: -- 1282
	end -- 1282
	__TS__ArraySort( -- 1285
		items, -- 1285
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1285
	) -- 1285
	return items -- 1286
end -- 1286
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1289
	local path = Path( -- 1290
		getPendingHandoffDir(projectRoot, memoryScope), -- 1290
		id .. ".json" -- 1290
	) -- 1290
	if Content:exist(path) then -- 1290
		if Content:remove(path) then -- 1290
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1293
		end -- 1293
	end -- 1293
end -- 1293
function normalizePromptText(prompt) -- 1298
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1299
end -- 1299
function normalizePromptTextSafe(prompt) -- 1302
	if type(prompt) == "string" then -- 1302
		local normalized = normalizePromptText(prompt) -- 1304
		if normalized ~= "" then -- 1304
			return normalized -- 1305
		end -- 1305
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1306
		if sanitized ~= "" then -- 1306
			return truncateAgentUserPrompt(sanitized) -- 1308
		end -- 1308
		return "" -- 1310
	end -- 1310
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1312
	if text == "" then -- 1312
		return "" -- 1313
	end -- 1313
	return truncateAgentUserPrompt(text) -- 1314
end -- 1314
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1317
	local sections = {} -- 1318
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1319
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1320
	local normalizedFiles = __TS__ArrayFilter( -- 1321
		__TS__ArrayMap( -- 1321
			__TS__ArrayFilter( -- 1321
				filesHint or ({}), -- 1321
				function(____, item) return type(item) == "string" end -- 1322
			), -- 1322
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1323
		), -- 1323
		function(____, item) return item ~= "" end -- 1324
	) -- 1324
	if normalizedTitle ~= "" then -- 1324
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1326
	end -- 1326
	if normalizedExpected ~= "" then -- 1326
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1329
	end -- 1329
	if #normalizedFiles > 0 then -- 1329
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1332
	end -- 1332
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1334
end -- 1334
function normalizeSessionRuntimeState(session) -- 1337
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1337
		return session -- 1339
	end -- 1339
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1339
		return session -- 1342
	end -- 1342
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1344
		session.id, -- 1347
		session.currentTaskId, -- 1347
		"fetch_url", -- 1347
		"execute_command", -- 1347
		"preview_game", -- 1347
		"analyze_image" -- 1347
	}) or ({}) -- 1347
	if #pendingToolRows > 0 then -- 1347
		local t = now() -- 1350
		do -- 1350
			local i = 0 -- 1351
			while i < #pendingToolRows do -- 1351
				local row = pendingToolRows[i + 1] -- 1352
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1353
				result.success = false -- 1354
				result.state = "failed" -- 1355
				result.interrupted = true -- 1356
				result.message = "tool call was interrupted because the program exited before it completed." -- 1357
				DB:exec( -- 1358
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1358
					{ -- 1360
						encodeJson(result), -- 1360
						t, -- 1360
						row[1] -- 1360
					} -- 1360
				) -- 1360
				i = i + 1 -- 1351
			end -- 1351
		end -- 1351
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1363
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1364
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1365
	end -- 1365
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1372
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1373
	return __TS__ObjectAssign( -- 1374
		{}, -- 1374
		session, -- 1375
		{ -- 1374
			status = "STOPPED", -- 1376
			currentTaskStatus = "STOPPED", -- 1377
			updatedAt = now() -- 1378
		} -- 1378
	) -- 1378
end -- 1378
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1382
	DB:exec( -- 1383
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1383
		{ -- 1387
			status, -- 1388
			currentTaskId or 0, -- 1389
			currentTaskStatus or status, -- 1390
			now(), -- 1391
			sessionId -- 1392
		} -- 1392
	) -- 1392
end -- 1392
function mergeAgentMetrics(current, next) -- 1397
	return __TS__ObjectAssign({}, current or ({}), next) -- 1398
end -- 1398
function updateSessionMetrics(sessionId, metrics) -- 1404
	local session = getSessionItem(sessionId) -- 1405
	if not session then -- 1405
		return nil -- 1406
	end -- 1406
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1407
	DB:exec( -- 1408
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1408
		{ -- 1412
			encodeJson(merged), -- 1413
			now(), -- 1414
			sessionId -- 1415
		} -- 1415
	) -- 1415
	return merged -- 1418
end -- 1418
function clearSessionTokenUsage(sessionId) -- 1421
	local session = getSessionItem(sessionId) -- 1422
	if not session then -- 1422
		return nil -- 1423
	end -- 1423
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1424
	__TS__Delete(metrics, "usage") -- 1425
	__TS__Delete(metrics, "visionUsage") -- 1426
	DB:exec( -- 1427
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1427
		{ -- 1431
			encodeJson(metrics), -- 1432
			now(), -- 1433
			sessionId -- 1434
		} -- 1434
	) -- 1434
	return metrics -- 1437
end -- 1437
function getInitialTokenUsage(session) -- 1440
	local ____opt_33 = session.metrics -- 1440
	local usage = ____opt_33 and ____opt_33.usage -- 1441
	if not usage or (usage.requestCount or 0) <= 0 then -- 1441
		return nil -- 1442
	end -- 1442
	return { -- 1443
		inputTokens = usage.inputTokens or 0, -- 1444
		outputTokens = usage.outputTokens or 0, -- 1445
		totalTokens = usage.totalTokens, -- 1446
		cachedInputTokens = usage.cachedInputTokens, -- 1447
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1448
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1449
		requestCount = usage.requestCount or 0, -- 1450
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1451
		model = usage.model or "", -- 1452
		phase = usage.phase or "", -- 1453
		step = usage.step or 0, -- 1454
		updatedAt = usage.updatedAt or now() -- 1455
	} -- 1455
end -- 1455
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1459
	if taskId == nil or taskId <= 0 then -- 1459
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1461
		return -- 1462
	end -- 1462
	local row = getSessionRow(sessionId) -- 1464
	if not row then -- 1464
		return -- 1465
	end -- 1465
	local session = rowToSession(row) -- 1466
	if session.currentTaskId ~= taskId then -- 1466
		Log( -- 1468
			"Info", -- 1468
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1468
		) -- 1468
		return -- 1469
	end -- 1469
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1471
end -- 1471
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1474
	local t = now() -- 1475
	DB:exec( -- 1476
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1476
		{ -- 1479
			sessionId, -- 1480
			taskId or 0, -- 1481
			role, -- 1482
			sanitizeUTF8(content), -- 1483
			displayContent and sanitizeUTF8(displayContent) or "", -- 1484
			t, -- 1485
			t -- 1486
		} -- 1486
	) -- 1486
	return getLastInsertRowId() -- 1489
end -- 1489
function updateMessage(messageId, content) -- 1492
	DB:exec( -- 1493
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1493
		{ -- 1495
			sanitizeUTF8(content), -- 1495
			now(), -- 1495
			messageId -- 1495
		} -- 1495
	) -- 1495
end -- 1495
function updateUserMessageForTask(messageId, content, taskId) -- 1499
	DB:exec( -- 1500
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1500
		{ -- 1504
			sanitizeUTF8(content), -- 1504
			taskId, -- 1504
			now(), -- 1504
			messageId -- 1504
		} -- 1504
	) -- 1504
end -- 1504
function removeContinuableTaskSummary(session) -- 1561
	local taskId = session.currentTaskId -- 1562
	if taskId == nil then -- 1562
		return -- 1563
	end -- 1563
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1564
end -- 1564
function upsertAssistantMessage(sessionId, taskId, content) -- 1576
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1577
	if row and type(row[1]) == "number" then -- 1577
		updateMessage(row[1], content) -- 1584
		return row[1] -- 1585
	end -- 1585
	return insertMessage(sessionId, "assistant", content, taskId) -- 1587
end -- 1587
function upsertStep(sessionId, taskId, step, tool, patch) -- 1590
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1600
	local reason = sanitizeUTF8(patch.reason or "") -- 1604
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1605
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1606
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1607
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1608
	local statusPatch = patch.status or "" -- 1609
	local status = patch.status or "PENDING" -- 1610
	if not row then -- 1610
		local t = now() -- 1612
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1613
			sessionId, -- 1617
			taskId, -- 1618
			step, -- 1619
			tool, -- 1620
			status, -- 1621
			reason, -- 1622
			reasoningContent, -- 1623
			paramsJson, -- 1624
			resultJson, -- 1625
			patch.checkpointId or 0, -- 1626
			patch.checkpointSeq or 0, -- 1627
			filesJson, -- 1628
			t, -- 1629
			t -- 1630
		}) -- 1630
		return -- 1633
	end -- 1633
	DB:exec( -- 1635
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1635
		{ -- 1647
			tool, -- 1648
			statusPatch, -- 1649
			status, -- 1650
			reason, -- 1651
			reason, -- 1652
			reasoningContent, -- 1653
			reasoningContent, -- 1654
			paramsJson, -- 1655
			paramsJson, -- 1656
			resultJson, -- 1657
			resultJson, -- 1658
			patch.checkpointId or 0, -- 1659
			patch.checkpointId or 0, -- 1660
			patch.checkpointSeq or 0, -- 1661
			patch.checkpointSeq or 0, -- 1662
			filesJson, -- 1663
			filesJson, -- 1664
			now(), -- 1665
			row[1] -- 1666
		} -- 1666
	) -- 1666
end -- 1666
function getNextStepNumber(sessionId, taskId) -- 1671
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1672
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1676
	return math.max(0, current) + 1 -- 1677
end -- 1677
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1718
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1726
	local t = now() -- 1727
	local sqls = { -- 1728
		{ -- 1729
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1729
			{{ -- 1732
				sessionId, -- 1733
				ownerTaskId, -- 1734
				step, -- 1735
				"sub_agent_handoff", -- 1736
				"DONE", -- 1737
				sanitizeUTF8(reason), -- 1738
				encodeJson(params), -- 1739
				encodeJson(result), -- 1740
				t, -- 1741
				t -- 1742
			}} -- 1742
		}, -- 1742
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1745
	} -- 1745
	if not DB:transaction(sqls) then -- 1745
		return nil -- 1751
	end -- 1751
	return getStepItem(sessionId, ownerTaskId, step) -- 1752
end -- 1752
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1755
	if taskId <= 0 then -- 1755
		return -- 1756
	end -- 1756
	if finalSteps ~= nil and finalSteps >= 0 then -- 1756
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1758
	end -- 1758
	if not finalStatus then -- 1758
		return -- 1764
	end -- 1764
	if finalSteps ~= nil and finalSteps >= 0 then -- 1764
		DB:exec( -- 1766
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1766
			{ -- 1770
				finalStatus, -- 1770
				now(), -- 1770
				sessionId, -- 1770
				taskId, -- 1770
				finalSteps -- 1770
			} -- 1770
		) -- 1770
		return -- 1772
	end -- 1772
	DB:exec( -- 1774
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1774
		{ -- 1778
			finalStatus, -- 1778
			now(), -- 1778
			sessionId, -- 1778
			taskId -- 1778
		} -- 1778
	) -- 1778
end -- 1778
function emitAgentSessionPatch(sessionId, patch) -- 1805
	if HttpServer.wsConnectionCount == 0 then -- 1805
		return -- 1807
	end -- 1807
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1809
	if not text then -- 1809
		return -- 1814
	end -- 1814
	emit("AppWS", "Send", text) -- 1815
end -- 1815
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1818
	emitAgentSessionPatch( -- 1819
		sessionId, -- 1819
		{ -- 1819
			sessionDeleted = true, -- 1820
			relatedSessions = listRelatedSessions(rootSessionId) -- 1821
		} -- 1821
	) -- 1821
	local rootSession = getSessionItem(rootSessionId) -- 1823
	if rootSession then -- 1823
		emitAgentSessionPatch( -- 1825
			rootSessionId, -- 1825
			{ -- 1825
				session = rootSession, -- 1826
				relatedSessions = listRelatedSessions(rootSessionId) -- 1827
			} -- 1827
		) -- 1827
	end -- 1827
end -- 1827
function flushPendingSubAgentHandoffs(rootSession) -- 1832
	if rootSession.kind ~= "main" then -- 1832
		return -- 1833
	end -- 1833
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1833
		return -- 1835
	end -- 1835
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1837
	if #items == 0 then -- 1837
		return -- 1838
	end -- 1838
	local handoffTaskId = 0 -- 1839
	local previousTaskId = rootSession.currentTaskId -- 1840
	local ____rootSession_currentTaskId_37 -- 1841
	if rootSession.currentTaskId then -- 1841
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1841
	else -- 1841
		____rootSession_currentTaskId_37 = nil -- 1841
	end -- 1841
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1841
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1841
		handoffTaskId = rootSession.currentTaskId -- 1849
	else -- 1849
		local taskRes = Tools.createTask( -- 1851
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1851
			"code" -- 1851
		) -- 1851
		if not taskRes.success then -- 1851
			Log( -- 1853
				"Warn", -- 1853
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1853
			) -- 1853
			return -- 1854
		end -- 1854
		handoffTaskId = taskRes.taskId -- 1856
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1857
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1858
		emitAgentSessionPatch( -- 1859
			rootSession.id, -- 1859
			{session = getSessionItem(rootSession.id)} -- 1859
		) -- 1859
	end -- 1859
	do -- 1859
		local i = 0 -- 1863
		while i < #items do -- 1863
			local item = items[i + 1] -- 1864
			local step = appendHandoffSystemStep( -- 1865
				rootSession.id, -- 1866
				handoffTaskId, -- 1867
				item.sourceTaskId, -- 1868
				item.message, -- 1869
				{ -- 1870
					sourceSessionId = item.sourceSessionId, -- 1871
					sourceTitle = item.sourceTitle, -- 1872
					sourceTaskId = item.sourceTaskId, -- 1873
					success = item.success == true, -- 1874
					summary = item.message, -- 1875
					resultFilePath = item.resultFilePath or "", -- 1876
					artifactDir = item.artifactDir or "", -- 1877
					finishedAt = item.finishedAt or "", -- 1878
					changeSet = item.changeSet, -- 1879
					handoffEvidence = item.handoffEvidence, -- 1880
					memoryEntry = item.memoryEntry, -- 1881
					completion = item.completion -- 1882
				}, -- 1882
				{ -- 1884
					sourceSessionId = item.sourceSessionId, -- 1885
					sourceTitle = item.sourceTitle, -- 1886
					sourceTaskId = item.sourceTaskId, -- 1887
					prompt = item.prompt, -- 1888
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1889
					expectedOutput = item.expectedOutput or "", -- 1890
					filesHint = item.filesHint or ({}), -- 1891
					resultFilePath = item.resultFilePath or "", -- 1892
					artifactDir = item.artifactDir or "", -- 1893
					changeSet = item.changeSet, -- 1894
					handoffEvidence = item.handoffEvidence, -- 1895
					memoryEntry = item.memoryEntry, -- 1896
					completion = item.completion -- 1897
				} -- 1897
			) -- 1897
			if step then -- 1897
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1901
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1902
			else -- 1902
				Log( -- 1904
					"Warn", -- 1904
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1904
				) -- 1904
			end -- 1904
			i = i + 1 -- 1863
		end -- 1863
	end -- 1863
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1863
		cleanupTaskHeavyData(previousTaskId) -- 1908
	end -- 1908
end -- 1908
function applyEvent(sessionId, event) -- 1920
	if not getSessionItem(sessionId) then -- 1920
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1920
			__TS__Delete(activeStopTokens, event.taskId) -- 1923
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1924
		end -- 1924
		return -- 1926
	end -- 1926
	repeat -- 1926
		local ____switch318 = event.type -- 1926
		local metrics, startedSession -- 1926
		local ____cond318 = ____switch318 == "task_started" -- 1926
		if ____cond318 then -- 1926
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1930
			local ____event_resumed_40 -- 1931
			if event.resumed then -- 1931
				local ____opt_38 = getSessionItem(sessionId) -- 1931
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1932
			else -- 1932
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1933
			end -- 1933
			metrics = ____event_resumed_40 -- 1931
			startedSession = getSessionItem(sessionId) -- 1934
			emitAgentSessionPatch( -- 1935
				sessionId, -- 1935
				{ -- 1935
					session = startedSession, -- 1936
					metrics = metrics, -- 1937
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1938
				} -- 1938
			) -- 1938
			break -- 1942
		end -- 1942
		____cond318 = ____cond318 or ____switch318 == "decision_made" -- 1942
		if ____cond318 then -- 1942
			upsertStep( -- 1944
				sessionId, -- 1944
				event.taskId, -- 1944
				event.step, -- 1944
				event.tool, -- 1944
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1944
			) -- 1944
			emitAgentSessionPatch( -- 1952
				sessionId, -- 1952
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1952
			) -- 1952
			break -- 1955
		end -- 1955
		____cond318 = ____cond318 or ____switch318 == "tool_started" -- 1955
		if ____cond318 then -- 1955
			upsertStep( -- 1957
				sessionId, -- 1957
				event.taskId, -- 1957
				event.step, -- 1957
				event.tool, -- 1957
				{status = "RUNNING"} -- 1957
			) -- 1957
			emitAgentSessionPatch( -- 1960
				sessionId, -- 1960
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1960
			) -- 1960
			break -- 1963
		end -- 1963
		____cond318 = ____cond318 or ____switch318 == "tool_finished" -- 1963
		if ____cond318 then -- 1963
			do -- 1963
				local ____temp_43 = event.result.success ~= true -- 1965
				if ____temp_43 then -- 1965
					local ____opt_41 = activeStopTokens[event.taskId] -- 1965
					____temp_43 = (____opt_41 and ____opt_41.stopped) == true -- 1965
				end -- 1965
				local stopped = ____temp_43 -- 1965
				upsertStep( -- 1967
					sessionId, -- 1967
					event.taskId, -- 1967
					event.step, -- 1967
					event.tool, -- 1967
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1967
				) -- 1967
				emitAgentSessionPatch( -- 1975
					sessionId, -- 1975
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1975
				) -- 1975
				break -- 1978
			end -- 1978
		end -- 1978
		____cond318 = ____cond318 or ____switch318 == "tool_progress" -- 1978
		if ____cond318 then -- 1978
			do -- 1978
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1982
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1982
					break -- 1984
				end -- 1984
			end -- 1984
			upsertStep( -- 1987
				sessionId, -- 1987
				event.taskId, -- 1987
				event.step, -- 1987
				event.tool, -- 1987
				{status = "RUNNING", result = event.result} -- 1987
			) -- 1987
			emitAgentSessionPatch( -- 1991
				sessionId, -- 1991
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1991
			) -- 1991
			break -- 1994
		end -- 1994
		____cond318 = ____cond318 or ____switch318 == "checkpoint_created" -- 1994
		if ____cond318 then -- 1994
			upsertStep( -- 1996
				sessionId, -- 1996
				event.taskId, -- 1996
				event.step, -- 1996
				event.tool, -- 1996
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1996
			) -- 1996
			emitAgentSessionPatch( -- 2001
				sessionId, -- 2001
				{ -- 2001
					step = getStepItem(sessionId, event.taskId, event.step), -- 2002
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2003
				} -- 2003
			) -- 2003
			break -- 2005
		end -- 2005
		____cond318 = ____cond318 or ____switch318 == "memory_compression_started" -- 2005
		if ____cond318 then -- 2005
			upsertStep( -- 2007
				sessionId, -- 2007
				event.taskId, -- 2007
				event.step, -- 2007
				event.tool, -- 2007
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2007
			) -- 2007
			emitAgentSessionPatch( -- 2012
				sessionId, -- 2012
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2012
			) -- 2012
			break -- 2015
		end -- 2015
		____cond318 = ____cond318 or ____switch318 == "memory_compression_finished" -- 2015
		if ____cond318 then -- 2015
			upsertStep( -- 2017
				sessionId, -- 2017
				event.taskId, -- 2017
				event.step, -- 2017
				event.tool, -- 2017
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2017
			) -- 2017
			emitAgentSessionPatch( -- 2022
				sessionId, -- 2022
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2022
			) -- 2022
			break -- 2025
		end -- 2025
		____cond318 = ____cond318 or ____switch318 == "metrics_updated" -- 2025
		if ____cond318 then -- 2025
			do -- 2025
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2027
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2028
				break -- 2031
			end -- 2031
		end -- 2031
		____cond318 = ____cond318 or ____switch318 == "assistant_message_updated" -- 2031
		if ____cond318 then -- 2031
			do -- 2031
				upsertStep( -- 2034
					sessionId, -- 2034
					event.taskId, -- 2034
					event.step, -- 2034
					"message", -- 2034
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2034
				) -- 2034
				emitAgentSessionPatch( -- 2039
					sessionId, -- 2039
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2039
				) -- 2039
				break -- 2042
			end -- 2042
		end -- 2042
		____cond318 = ____cond318 or ____switch318 == "assistant_message_finished" -- 2042
		if ____cond318 then -- 2042
			do -- 2042
				upsertStep( -- 2045
					sessionId, -- 2045
					event.taskId, -- 2045
					event.step, -- 2045
					"message", -- 2045
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2045
				) -- 2045
				emitAgentSessionPatch( -- 2051
					sessionId, -- 2051
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2051
				) -- 2051
				break -- 2054
			end -- 2054
		end -- 2054
		____cond318 = ____cond318 or ____switch318 == "task_waiting_for_user" -- 2054
		if ____cond318 then -- 2054
			do -- 2054
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2057
				__TS__Delete(activeStopTokens, event.taskId) -- 2058
				emitAgentSessionPatch( -- 2059
					sessionId, -- 2059
					{ -- 2059
						session = getSessionItem(sessionId), -- 2060
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2061
					} -- 2061
				) -- 2061
				break -- 2063
			end -- 2063
		end -- 2063
		____cond318 = ____cond318 or ____switch318 == "task_finished" -- 2063
		if ____cond318 then -- 2063
			do -- 2063
				local session = getSessionItem(sessionId) -- 2066
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2066
					__TS__Delete(activeStopTokens, event.taskId) -- 2068
					Log( -- 2069
						"Info", -- 2069
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2069
					) -- 2069
					break -- 2070
				end -- 2070
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2070
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2072
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2074
				local isSubSession = (session and session.kind) == "sub" -- 2077
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2078
				if isSubSession and event.taskId ~= nil then -- 2078
					finalizingSubSessionTaskIds[event.taskId] = true -- 2080
				end -- 2080
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2082
				if event.taskId ~= nil then -- 2082
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2084
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2085
					local ____array_49 = __TS__SparseArrayNew( -- 2085
						sessionId, -- 2086
						event.taskId, -- 2087
						type(event.steps) == "number" and math.max( -- 2088
							0, -- 2088
							math.floor(event.steps) -- 2088
						) or nil -- 2088
					) -- 2088
					local ____event_success_48 -- 2089
					if event.success then -- 2089
						____event_success_48 = nil -- 2089
					else -- 2089
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2089
					end -- 2089
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2089
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2085
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2091
					if not isSubSession then -- 2091
						__TS__Delete(activeStopTokens, event.taskId) -- 2093
					end -- 2093
					emitAgentSessionPatch( -- 2095
						sessionId, -- 2095
						{ -- 2095
							session = getSessionItem(sessionId), -- 2096
							message = getMessageItem(messageId), -- 2097
							removedStepIds = removedStepIds -- 2098
						} -- 2098
					) -- 2098
				end -- 2098
				if session and session.kind == "main" then -- 2098
					flushPendingSubAgentHandoffs(session) -- 2102
				end -- 2102
				break -- 2104
			end -- 2104
		end -- 2104
	until true -- 2104
end -- 2104
function ____exports.createSession(projectRoot, title) -- 2109
	if title == nil then -- 2109
		title = "" -- 2109
	end -- 2109
	local storage = requireAgentStorage() -- 2110
	if not storage.success then -- 2110
		return storage -- 2111
	end -- 2111
	if not isValidProjectRoot(projectRoot) then -- 2111
		return {success = false, message = "invalid projectRoot"} -- 2113
	end -- 2113
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2115
	if row then -- 2115
		return { -- 2124
			success = true, -- 2124
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2124
		} -- 2124
	end -- 2124
	local t = now() -- 2126
	DB:exec( -- 2127
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2127
		{ -- 2130
			projectRoot, -- 2130
			title ~= "" and title or Path:getFilename(projectRoot), -- 2130
			t, -- 2130
			t -- 2130
		} -- 2130
	) -- 2130
	local sessionId = getLastInsertRowId() -- 2132
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2133
	local session = getSessionItem(sessionId) -- 2134
	if not session then -- 2134
		return {success = false, message = "failed to create session"} -- 2136
	end -- 2136
	return {success = true, session = session} -- 2138
end -- 2109
function ____exports.createSubSession(parentSessionId, title) -- 2141
	if title == nil then -- 2141
		title = "" -- 2141
	end -- 2141
	local storage = requireAgentStorage() -- 2142
	if not storage.success then -- 2142
		return storage -- 2143
	end -- 2143
	local parent = getSessionItem(parentSessionId) -- 2144
	if not parent then -- 2144
		return {success = false, message = "parent session not found"} -- 2146
	end -- 2146
	local rootId = getSessionRootId(parent) -- 2148
	local t = now() -- 2149
	DB:exec( -- 2150
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2150
		{ -- 2153
			parent.projectRoot, -- 2153
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2153
			rootId, -- 2153
			parent.id, -- 2153
			t, -- 2153
			t -- 2153
		} -- 2153
	) -- 2153
	local sessionId = getLastInsertRowId() -- 2155
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2156
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2157
	local session = getSessionItem(sessionId) -- 2158
	if not session then -- 2158
		return {success = false, message = "failed to create sub session"} -- 2160
	end -- 2160
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2162
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2163
	subStorage:writeMemory(parentStorage:readMemory()) -- 2164
	return {success = true, session = session} -- 2165
end -- 2141
function spawnSubAgentSession(request) -- 2168
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2168
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2181
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2182
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2183
		if normalizedPrompt == "" then -- 2183
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2185
		end -- 2185
		if normalizedPrompt == "" then -- 2185
			local ____Log_56 = Log -- 2192
			local ____temp_53 = #normalizedTitle -- 2192
			local ____temp_54 = #rawPrompt -- 2192
			local ____temp_55 = #toStr(request.expectedOutput) -- 2192
			local ____opt_51 = request.filesHint -- 2192
			____Log_56( -- 2192
				"Warn", -- 2192
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2192
			) -- 2192
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2192
		end -- 2192
		Log( -- 2195
			"Info", -- 2195
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2195
		) -- 2195
		local parentSessionId = request.parentSessionId -- 2196
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2196
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2198
			if not fallbackParent then -- 2198
				local createdMain = ____exports.createSession(request.projectRoot) -- 2200
				if createdMain.success then -- 2200
					fallbackParent = createdMain.session -- 2202
				end -- 2202
			end -- 2202
			if fallbackParent then -- 2202
				Log( -- 2206
					"Warn", -- 2206
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2206
				) -- 2206
				parentSessionId = fallbackParent.id -- 2207
			end -- 2207
		end -- 2207
		local parentSession = getSessionItem(parentSessionId) -- 2210
		if not parentSession then -- 2210
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2210
		end -- 2210
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2214
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2214
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2214
		end -- 2214
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2218
		if not created.success then -- 2218
			return ____awaiter_resolve(nil, created) -- 2218
		end -- 2218
		writeSpawnInfo( -- 2222
			created.session.projectRoot, -- 2222
			created.session.memoryScope, -- 2222
			{ -- 2222
				sessionId = created.session.id, -- 2223
				rootSessionId = created.session.rootSessionId, -- 2224
				parentSessionId = created.session.parentSessionId, -- 2225
				title = created.session.title, -- 2226
				prompt = normalizedPrompt, -- 2227
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2228
				expectedOutput = request.expectedOutput or "", -- 2229
				filesHint = request.filesHint or ({}), -- 2230
				status = "RUNNING", -- 2231
				success = false, -- 2232
				resultFilePath = "", -- 2233
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2234
				sourceTaskId = 0, -- 2235
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2236
				createdAtTs = created.session.createdAt, -- 2237
				finishedAt = "", -- 2238
				finishedAtTs = 0 -- 2239
			} -- 2239
		) -- 2239
		local sent = ____exports.sendPrompt( -- 2241
			created.session.id, -- 2241
			normalizedPrompt, -- 2241
			request.disabledAgentTools, -- 2241
			nil, -- 2241
			nil, -- 2241
			request.llmConfig -- 2241
		) -- 2241
		if not sent.success then -- 2241
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2241
		end -- 2241
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2241
	end) -- 2241
end -- 2241
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2365
	local rootSession = getRootSessionItem(session.id) -- 2366
	if not rootSession then -- 2366
		return -- 2367
	end -- 2367
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2368
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2369
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2370
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2371
	local queueResult = writePendingHandoff( -- 2372
		rootSession.projectRoot, -- 2372
		rootSession.memoryScope, -- 2372
		{ -- 2372
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2373
			sourceSessionId = session.id, -- 2374
			sourceTitle = session.title, -- 2375
			sourceTaskId = taskId, -- 2376
			message = summary, -- 2377
			prompt = result.prompt, -- 2378
			goal = result.goal, -- 2379
			expectedOutput = result.expectedOutput or "", -- 2380
			filesHint = result.filesHint or ({}), -- 2381
			success = result.success, -- 2382
			resultFilePath = result.resultFilePath, -- 2383
			artifactDir = result.artifactDir, -- 2384
			finishedAt = result.finishedAt, -- 2385
			changeSet = changeSet, -- 2386
			handoffEvidence = result.handoffEvidence, -- 2387
			memoryEntry = result.memoryEntry, -- 2388
			completion = result.completion, -- 2389
			createdAt = createdAt -- 2390
		} -- 2390
	) -- 2390
	if not queueResult then -- 2390
		Log( -- 2393
			"Warn", -- 2393
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2393
		) -- 2393
		return -- 2394
	end -- 2394
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2394
		addTaskReference(rootSession.currentTaskId, taskId) -- 2397
	end -- 2397
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2397
		flushPendingSubAgentHandoffs(rootSession) -- 2400
	end -- 2400
end -- 2400
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2404
	if forceHandoff == nil then -- 2404
		forceHandoff = false -- 2410
	end -- 2410
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2410
		local rootSessionId = getSessionRootId(session) -- 2412
		local rootSession = getRootSessionItem(session.id) -- 2413
		if not rootSession then -- 2413
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2413
		end -- 2413
		local spawnInfo = getSessionSpawnInfo(session) -- 2417
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2418
		local finishedAtTs = now() -- 2419
		local resultText = sanitizeUTF8(message) -- 2420
		local changeSet = getTaskChangeSetSummary(taskId) -- 2421
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2422
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2423
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2427
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2427
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2429
		end -- 2429
		local completed = success and completionReport.outcome == "completed" -- 2437
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2438
		local record = { -- 2441
			sessionId = session.id, -- 2442
			rootSessionId = rootSessionId, -- 2443
			parentSessionId = session.parentSessionId, -- 2444
			title = session.title, -- 2445
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2446
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2447
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2448
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2449
			status = recordStatus, -- 2450
			success = completed, -- 2451
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2452
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2453
			sourceTaskId = taskId, -- 2454
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2455
			finishedAt = finishedAt, -- 2456
			createdAtTs = session.createdAt, -- 2457
			finishedAtTs = finishedAtTs, -- 2458
			changeSet = changeSet, -- 2459
			handoffEvidence = handoffEvidence, -- 2460
			completion = completionReport -- 2461
		} -- 2461
		local ____record_success_73 -- 2463
		if record.success then -- 2463
			____record_success_73 = buildStructuredSubAgentMemoryEntry(record) -- 2463
		else -- 2463
			____record_success_73 = nil -- 2463
		end -- 2463
		record.memoryEntry = ____record_success_73 -- 2463
		if not writeSubAgentResultFile(session, record, resultText) then -- 2463
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2463
		end -- 2463
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2463
			sessionId = record.sessionId, -- 2468
			rootSessionId = record.rootSessionId, -- 2469
			parentSessionId = record.parentSessionId, -- 2470
			title = record.title, -- 2471
			prompt = record.prompt, -- 2472
			goal = record.goal, -- 2473
			expectedOutput = record.expectedOutput or "", -- 2474
			filesHint = record.filesHint or ({}), -- 2475
			status = record.status, -- 2476
			success = record.success, -- 2477
			resultFilePath = record.resultFilePath, -- 2478
			artifactDir = record.artifactDir, -- 2479
			sourceTaskId = record.sourceTaskId, -- 2480
			createdAt = record.createdAt, -- 2481
			finishedAt = record.finishedAt, -- 2482
			createdAtTs = record.createdAtTs, -- 2483
			finishedAtTs = record.finishedAtTs, -- 2484
			changeSet = record.changeSet, -- 2485
			handoffEvidence = record.handoffEvidence, -- 2486
			memoryEntry = record.memoryEntry, -- 2487
			memoryEntryError = record.memoryEntryError, -- 2488
			completion = record.completion -- 2489
		}) then -- 2489
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2489
		end -- 2489
		if success or forceHandoff then -- 2489
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2494
			deleteSessionRecords(session.id, true) -- 2495
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2496
		end -- 2496
		return ____awaiter_resolve(nil, {success = true}) -- 2496
	end) -- 2496
end -- 2496
function stopClearedSubSession(session, taskId) -- 2501
	local spawnInfo = getSessionSpawnInfo(session) -- 2502
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2503
	local rootSessionId = getSessionRootId(session) -- 2504
	Tools.setTaskStatus(taskId, "STOPPED") -- 2505
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2506
	if not writeSpawnInfo( -- 2506
		session.projectRoot, -- 2507
		session.memoryScope, -- 2507
		{ -- 2507
			sessionId = session.id, -- 2508
			rootSessionId = rootSessionId, -- 2509
			parentSessionId = session.parentSessionId, -- 2510
			title = session.title, -- 2511
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2512
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2513
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2514
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2515
			status = "STOPPED", -- 2516
			success = false, -- 2517
			cleared = true, -- 2518
			resultFilePath = "", -- 2519
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2520
			sourceTaskId = taskId, -- 2521
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2522
			finishedAt = finishedAt, -- 2523
			createdAtTs = session.createdAt, -- 2524
			finishedAtTs = now() -- 2525
		} -- 2525
	) then -- 2525
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2527
	end -- 2527
	deleteSessionRecords(session.id, true) -- 2529
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2530
	return {success = true} -- 2531
end -- 2531
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2534
	local session = getSessionItem(sessionId) -- 2535
	if not session then -- 2535
		return {success = false, message = "session not found"} -- 2537
	end -- 2537
	if getPendingQuestionnaire(sessionId) then -- 2537
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2539
	end -- 2539
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2539
		return {success = false, message = "session task is finalizing"} -- 2541
	end -- 2541
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2541
		return {success = false, message = "session task is still running"} -- 2544
	end -- 2544
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2546
	if normalizedPrompt == "" and session.kind == "sub" then -- 2546
		local spawnInfo = getSessionSpawnInfo(session) -- 2548
		if spawnInfo then -- 2548
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2550
			if normalizedPrompt == "" then -- 2550
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2552
			end -- 2552
		end -- 2552
	end -- 2552
	if normalizedPrompt == "" then -- 2552
		return {success = false, message = "prompt is empty"} -- 2561
	end -- 2561
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2563
	if session.workMode ~= nextWorkMode then -- 2563
		DB:exec( -- 2565
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2565
			{ -- 2565
				nextWorkMode, -- 2565
				now(), -- 2565
				session.id -- 2565
			} -- 2565
		) -- 2565
		session.workMode = nextWorkMode -- 2566
	end -- 2566
	return startPromptTask( -- 2568
		session, -- 2568
		normalizedPrompt, -- 2568
		nil, -- 2568
		normalizeDisabledAgentTools(disabledAgentTools), -- 2568
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2568
	) -- 2568
end -- 2534
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2621
	if disabledAgentTools == nil then -- 2621
		disabledAgentTools = {} -- 2625
	end -- 2625
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2628
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2629
	if not llmConfigRes.success then -- 2629
		return {success = false, message = llmConfigRes.message} -- 2633
	end -- 2633
	local llmConfig = llmConfigRes.config -- 2635
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2636
	if not llmConfigValidation.success then -- 2636
		return llmConfigValidation -- 2638
	end -- 2638
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2640
	if not taskRes.success then -- 2640
		return {success = false, message = taskRes.message} -- 2643
	end -- 2643
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2643
		removeContinuableTaskSummary(session) -- 2645
	end -- 2645
	local taskId = taskRes.taskId -- 2647
	local ____temp_94 -- 2648
	if (options and options.existingTaskId) == nil then -- 2648
		____temp_94 = session.currentTaskId -- 2648
	else -- 2648
		____temp_94 = nil -- 2648
	end -- 2648
	local previousTaskId = ____temp_94 -- 2648
	local useChineseResponse = getDefaultUseChineseResponse() -- 2649
	if existingUserMessageId ~= nil then -- 2649
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2651
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2651
		insertMessage( -- 2653
			session.id, -- 2653
			"user", -- 2653
			normalizedPrompt, -- 2653
			taskId, -- 2653
			options and options.displayContent -- 2653
		) -- 2653
	end -- 2653
	local stopToken = {stopped = false} -- 2655
	activeStopTokens[taskId] = stopToken -- 2656
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2657
	if previousTaskId and previousTaskId ~= taskId then -- 2657
		cleanupTaskHeavyData(previousTaskId) -- 2659
	end -- 2659
	local ____runCodingAgent_123 = runCodingAgent -- 2661
	local ____normalizedPrompt_116 = normalizedPrompt -- 2662
	local ____temp_117 = options and options.resumeConversation -- 2663
	local ____temp_118 = (options and options.existingTaskId) ~= nil -- 2664
	local ____temp_119 = options and options.initialStep -- 2665
	local ____temp_120 = options and options.initialAgentStepCount -- 2666
	local ____temp_111 -- 2667
	if (options and options.existingTaskId) ~= nil then -- 2667
		____temp_111 = getInitialTokenUsage(session) -- 2667
	else -- 2667
		____temp_111 = nil -- 2667
	end -- 2667
	____runCodingAgent_123( -- 2661
		{ -- 2661
			prompt = ____normalizedPrompt_116, -- 2662
			resumeConversation = ____temp_117, -- 2663
			resumeTask = ____temp_118, -- 2664
			initialStep = ____temp_119, -- 2665
			initialAgentStepCount = ____temp_120, -- 2666
			initialTokenUsage = ____temp_111, -- 2667
			workDir = session.projectRoot, -- 2668
			useChineseResponse = useChineseResponse, -- 2669
			taskId = taskId, -- 2670
			sessionId = session.id, -- 2671
			memoryScope = session.memoryScope, -- 2672
			role = session.kind, -- 2673
			maxSteps = options and options.maxSteps, -- 2674
			disabledAgentTools = disabledAgentTools, -- 2675
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2676
			llmConfig = llmConfig, -- 2677
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2678
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2681
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2684
			stopToken = stopToken, -- 2685
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2686
		}, -- 2686
		function(result) -- 2687
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2687
				local nextSession = getSessionItem(session.id) -- 2688
				if nextSession and nextSession.kind == "sub" then -- 2688
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2688
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2691
						if not stopped.success then -- 2691
							Log( -- 2693
								"Warn", -- 2693
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2693
							) -- 2693
							emitAgentSessionPatch( -- 2694
								session.id, -- 2694
								{session = getSessionItem(session.id)} -- 2694
							) -- 2694
						end -- 2694
						__TS__Delete(activeStopTokens, taskId) -- 2698
						return ____awaiter_resolve(nil) -- 2698
					end -- 2698
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2701
					emitAgentSessionPatch( -- 2702
						session.id, -- 2702
						{session = getSessionItem(session.id)} -- 2702
					) -- 2702
					local finalized = __TS__Await(finalizeSubSession( -- 2705
						nextSession, -- 2706
						taskId, -- 2707
						result.success, -- 2708
						result.message, -- 2709
						result.completion, -- 2710
						(options and options.forceSubAgentHandoff) == true -- 2711
					)) -- 2711
					if not finalized.success then -- 2711
						Log( -- 2714
							"Warn", -- 2714
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2714
						) -- 2714
					end -- 2714
					local finalizedSession = getSessionItem(session.id) -- 2716
					if finalizedSession then -- 2716
						local stopped = stopToken.stopped == true -- 2718
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2719
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2722
						emitAgentSessionPatch( -- 2723
							session.id, -- 2723
							{session = getSessionItem(session.id)} -- 2723
						) -- 2723
					end -- 2723
					__TS__Delete(activeStopTokens, taskId) -- 2727
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2728
				end -- 2728
				local fallbackSession = getSessionItem(session.id) -- 2730
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2730
					applyEvent(session.id, { -- 2736
						type = "task_finished", -- 2737
						sessionId = session.id, -- 2738
						taskId = result.taskId, -- 2739
						success = false, -- 2740
						message = result.message, -- 2741
						steps = result.steps -- 2742
					}) -- 2742
				end -- 2742
			end) -- 2742
		end -- 2687
	) -- 2687
	return {success = true, sessionId = session.id, taskId = taskId} -- 2746
end -- 2746
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2898
	local lines = {} -- 2899
	do -- 2899
		local i = 0 -- 2900
		while i < #questionnaire.schema.questions do -- 2900
			local question = questionnaire.schema.questions[i + 1] -- 2901
			local answer = __TS__ArrayFind( -- 2902
				answers, -- 2902
				function(____, item) return item.questionId == question.id end -- 2902
			) -- 2902
			local answerText = "已跳过" -- 2903
			if answer and answer.status == "answered" then -- 2903
				local parts = {} -- 2905
				do -- 2905
					local j = 0 -- 2906
					while j < #(answer.selectedOptionIds or ({})) do -- 2906
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2907
						local option = __TS__ArrayFind( -- 2908
							question.options or ({}), -- 2908
							function(____, item) return item.id == optionId end -- 2908
						) -- 2908
						if option then -- 2908
							parts[#parts + 1] = option.label -- 2909
						end -- 2909
						j = j + 1 -- 2906
					end -- 2906
				end -- 2906
				if answer.otherText then -- 2906
					parts[#parts + 1] = answer.otherText -- 2911
				end -- 2911
				if answer.text then -- 2911
					parts[#parts + 1] = answer.text -- 2912
				end -- 2912
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2913
			end -- 2913
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2915
			i = i + 1 -- 2900
		end -- 2900
	end -- 2900
	return table.concat(lines, "\n\n") -- 2917
end -- 2917
function ____exports.listRunningSubAgents(request) -- 3161
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3161
		local session = getSessionItem(request.sessionId) -- 3169
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3169
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3171
		end -- 3171
		if not session then -- 3171
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3171
		end -- 3171
		local rootSession = getRootSessionItem(session.id) -- 3176
		if not rootSession then -- 3176
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3176
		end -- 3176
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3180
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3181
		local limit = math.max( -- 3182
			1, -- 3182
			math.floor(tonumber(request.limit) or 5) -- 3182
		) -- 3182
		local offset = math.max( -- 3183
			0, -- 3183
			math.floor(tonumber(request.offset) or 0) -- 3183
		) -- 3183
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3184
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3185
		local runningSessions = {} -- 3192
		do -- 3192
			local i = 0 -- 3193
			while i < #rows do -- 3193
				do -- 3193
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3194
					if current.currentTaskStatus ~= "RUNNING" then -- 3194
						goto __continue519 -- 3196
					end -- 3196
					local spawnInfo = getSessionSpawnInfo(current) -- 3198
					runningSessions[#runningSessions + 1] = { -- 3199
						sessionId = current.id, -- 3200
						title = current.title, -- 3201
						parentSessionId = current.parentSessionId, -- 3202
						rootSessionId = current.rootSessionId, -- 3203
						status = "RUNNING", -- 3204
						currentTaskId = current.currentTaskId, -- 3205
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3206
						goal = spawnInfo and spawnInfo.goal, -- 3207
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3208
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3209
						createdAt = current.createdAt, -- 3210
						updatedAt = current.updatedAt -- 3211
					} -- 3211
				end -- 3211
				::__continue519:: -- 3211
				i = i + 1 -- 3193
			end -- 3193
		end -- 3193
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3214
		local completedSessions = __TS__ArrayMap( -- 3215
			completedRecords, -- 3215
			function(____, record) return { -- 3215
				sessionId = record.sessionId, -- 3216
				title = record.title, -- 3217
				parentSessionId = record.parentSessionId, -- 3218
				rootSessionId = record.rootSessionId, -- 3219
				status = record.status, -- 3220
				goal = record.goal, -- 3221
				expectedOutput = record.expectedOutput, -- 3222
				filesHint = record.filesHint, -- 3223
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3224
				success = record.success, -- 3225
				cleared = record.cleared, -- 3226
				resultFilePath = record.resultFilePath, -- 3227
				artifactDir = record.artifactDir, -- 3228
				finishedAt = record.finishedAt, -- 3229
				createdAt = record.createdAtTs, -- 3230
				updatedAt = record.finishedAtTs -- 3231
			} end -- 3231
		) -- 3231
		local merged = {} -- 3233
		if status == "running" then -- 3233
			merged = runningSessions -- 3235
		elseif status == "done" then -- 3235
			merged = __TS__ArrayFilter( -- 3237
				completedSessions, -- 3237
				function(____, item) return item.status == "DONE" end -- 3237
			) -- 3237
		elseif status == "failed" then -- 3237
			merged = __TS__ArrayFilter( -- 3239
				completedSessions, -- 3239
				function(____, item) return item.status == "FAILED" end -- 3239
			) -- 3239
		elseif status == "stopped" then -- 3239
			merged = __TS__ArrayFilter( -- 3241
				completedSessions, -- 3241
				function(____, item) return item.status == "STOPPED" end -- 3241
			) -- 3241
		elseif status == "all" then -- 3241
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3243
		else -- 3243
			local runningKeys = {} -- 3245
			do -- 3245
				local i = 0 -- 3246
				while i < #runningSessions do -- 3246
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3247
					i = i + 1 -- 3246
				end -- 3246
			end -- 3246
			local latestCompletedByKey = {} -- 3249
			do -- 3249
				local i = 0 -- 3250
				while i < #completedSessions do -- 3250
					do -- 3250
						local item = completedSessions[i + 1] -- 3251
						local key = getSubAgentDisplayKey(item) -- 3252
						if runningKeys[key] then -- 3252
							goto __continue534 -- 3254
						end -- 3254
						local current = latestCompletedByKey[key] -- 3256
						if not current or item.updatedAt > current.updatedAt then -- 3256
							latestCompletedByKey[key] = item -- 3258
						end -- 3258
					end -- 3258
					::__continue534:: -- 3258
					i = i + 1 -- 3250
				end -- 3250
			end -- 3250
			local latestCompleted = {} -- 3261
			for ____, item in pairs(latestCompletedByKey) do -- 3262
				latestCompleted[#latestCompleted + 1] = item -- 3263
			end -- 3263
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3265
		end -- 3265
		if query ~= "" then -- 3265
			merged = __TS__ArrayFilter( -- 3268
				merged, -- 3268
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3268
			) -- 3268
		end -- 3268
		__TS__ArraySort( -- 3274
			merged, -- 3274
			function(____, a, b) -- 3274
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3274
					return -1 -- 3275
				end -- 3275
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3275
					return 1 -- 3276
				end -- 3276
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3276
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3278
				end -- 3278
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3280
			end -- 3274
		) -- 3274
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3282
		return ____awaiter_resolve(nil, { -- 3282
			success = true, -- 3284
			rootSessionId = rootSession.id, -- 3285
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3286
			status = status, -- 3287
			limit = limit, -- 3288
			offset = offset, -- 3289
			hasMore = offset + limit < #merged, -- 3290
			sessions = paged -- 3291
		}) -- 3291
	end) -- 3291
end -- 3161
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 273
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 274
SPAWN_INFO_FILE = "SPAWN.json" -- 275
RESULT_FILE = "RESULT.md" -- 276
PENDING_HANDOFF_DIR = "pending-handoffs" -- 277
MAX_CONCURRENT_SUB_AGENTS = 4 -- 278
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 279
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 280
activeStopTokens = {} -- 330
finalizingSubSessionTaskIds = {} -- 331
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 332
now = function() return os.time() end -- 333
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 982
	if projectRoot == oldRoot then -- 982
		return newRoot -- 984
	end -- 984
	for ____, separator in ipairs({"/", "\\"}) do -- 986
		local prefix = oldRoot .. separator -- 987
		if __TS__StringStartsWith(projectRoot, prefix) then -- 987
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 989
		end -- 989
	end -- 989
	return nil -- 992
end -- 982
local function clearSessionAfterMessage(sessionId, message) -- 1508
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1509
	local removedStepIds = {} -- 1517
	do -- 1517
		local i = 0 -- 1518
		while i < #removedStepRows do -- 1518
			local row = removedStepRows[i + 1] -- 1519
			if type(row[1]) == "number" then -- 1519
				removedStepIds[#removedStepIds + 1] = row[1] -- 1521
			end -- 1521
			i = i + 1 -- 1518
		end -- 1518
	end -- 1518
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1524
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1532
	return removedStepIds -- 1537
end -- 1508
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1540
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1541
	local persisted = storage:readSessionState() -- 1542
	local userIndex = -1 -- 1543
	do -- 1543
		local i = #persisted.messages - 1 -- 1544
		while i >= 0 do -- 1544
			if persisted.messages[i + 1].role == "user" then -- 1544
				userIndex = i -- 1546
				break -- 1547
			end -- 1547
			i = i - 1 -- 1544
		end -- 1544
	end -- 1544
	if userIndex < 0 then -- 1544
		return -- 1550
	end -- 1550
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1551
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1552
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1553
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1558
end -- 1540
local function listCurrentTaskCheckpoints(sessionId) -- 1570
	local session = getSessionItem(sessionId) -- 1571
	local taskId = session and session.currentTaskId -- 1572
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1573
end -- 1570
local function getAgentStepCount(sessionId, taskId) -- 1680
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1681
		sessionId, -- 1686
		taskId, -- 1687
		"compress_memory", -- 1688
		"merge_memory", -- 1689
		"sub_agent_handoff", -- 1690
		"questionnaire_answer", -- 1691
		"message" -- 1692
	}) -- 1692
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1695
end -- 1680
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1698
	if status == nil then -- 1698
		status = "DONE" -- 1706
	end -- 1706
	local step = getNextStepNumber(sessionId, taskId) -- 1708
	upsertStep( -- 1709
		sessionId, -- 1709
		taskId, -- 1709
		step, -- 1709
		tool, -- 1709
		{status = status, reason = reason, params = params, result = result} -- 1709
	) -- 1709
	return getStepItem(sessionId, taskId, step) -- 1715
end -- 1698
local function sanitizeStoredSteps(sessionId) -- 1782
	DB:exec( -- 1783
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1783
		{ -- 1801
			now(), -- 1801
			sessionId -- 1801
		} -- 1801
	) -- 1801
end -- 1782
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2253
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2253
		return {success = false, message = "invalid projectRoot"} -- 2255
	end -- 2255
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2257
	for ____, row in ipairs(rows) do -- 2258
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2259
		if sessionId > 0 then -- 2259
			deleteSessionRecords(sessionId) -- 2261
		end -- 2261
	end -- 2261
	return {success = true, deleted = #rows} -- 2264
end -- 2253
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2267
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2267
		return {success = false, message = "invalid projectRoot"} -- 2269
	end -- 2269
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2271
	local renamed = 0 -- 2272
	for ____, row in ipairs(rows) do -- 2273
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2274
		local projectRoot = toStr(row[2]) -- 2275
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2276
		if sessionId > 0 and nextProjectRoot then -- 2276
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2278
			if not renameVisionSessionAssets(rootSessionId, projectRoot, nextProjectRoot) then -- 2278
				return {success = false, message = "failed to move vision evidence metadata", renamed = renamed} -- 2280
			end -- 2280
			DB:exec( -- 2282
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2282
				{ -- 2284
					nextProjectRoot, -- 2284
					Path:getFilename(nextProjectRoot), -- 2284
					now(), -- 2284
					sessionId -- 2284
				} -- 2284
			) -- 2284
			renamed = renamed + 1 -- 2286
		end -- 2286
	end -- 2286
	return {success = true, renamed = renamed} -- 2289
end -- 2267
function ____exports.getSession(sessionId, view) -- 2292
	local session = getSessionItem(sessionId) -- 2293
	if not session then -- 2293
		return {success = false, message = "session not found"} -- 2295
	end -- 2295
	local restored = restorePendingQuestionnaireState(session) -- 2297
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2298
	local relatedSessions = listRelatedSessions(sessionId) -- 2299
	sanitizeStoredSteps(sessionId) -- 2300
	local firstMessageId = 0 -- 2301
	local hasEarlierMessages = false -- 2302
	if view then -- 2302
		local limit = math.max( -- 2304
			1, -- 2304
			math.min( -- 2304
				1000, -- 2304
				math.floor(view.recentRounds) -- 2304
			) -- 2304
		) -- 2304
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2305
		if #requests > limit then -- 2305
			firstMessageId = requests[limit][1] -- 2310
			hasEarlierMessages = true -- 2311
		end -- 2311
	end -- 2311
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2314
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2321
	local ____relatedSessions_62 = relatedSessions -- 2333
	local ____temp_61 -- 2334
	if normalizedSession.kind == "sub" then -- 2334
		____temp_61 = getSessionSpawnInfo(normalizedSession) -- 2334
	else -- 2334
		____temp_61 = nil -- 2334
	end -- 2334
	return { -- 2330
		success = true, -- 2331
		session = normalizedSession, -- 2332
		relatedSessions = ____relatedSessions_62, -- 2333
		spawnInfo = ____temp_61, -- 2334
		messages = __TS__ArrayMap( -- 2335
			messages, -- 2335
			function(____, row) return rowToMessage(row) end -- 2335
		), -- 2335
		hasEarlierMessages = hasEarlierMessages, -- 2336
		steps = __TS__ArrayMap( -- 2337
			steps, -- 2337
			function(____, row) return rowToStep(row) end -- 2337
		), -- 2337
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2338
		pendingQuestionnaire = restored.questionnaire, -- 2339
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2340
	} -- 2340
end -- 2292
function ____exports.setWorkMode(sessionId, workMode) -- 2345
	local session = getSessionItem(sessionId) -- 2346
	if not session then -- 2346
		return {success = false, message = "session not found"} -- 2347
	end -- 2347
	if session.kind ~= "main" then -- 2347
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2348
	end -- 2348
	if workMode ~= "code" and workMode ~= "plan" then -- 2348
		return {success = false, message = "invalid work mode"} -- 2349
	end -- 2349
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2350
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2350
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2352
	end -- 2352
	if getPendingQuestionnaire(sessionId) then -- 2352
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2355
	end -- 2355
	if normalizedSession.workMode ~= workMode then -- 2355
		DB:exec( -- 2358
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2358
			{ -- 2358
				workMode, -- 2358
				now(), -- 2358
				sessionId -- 2358
			} -- 2358
		) -- 2358
	end -- 2358
	local updated = getSessionItem(sessionId) -- 2360
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2361
	return { -- 2362
		success = true, -- 2362
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2362
	} -- 2362
end -- 2345
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2571
	local session = getSessionItem(sessionId) -- 2572
	if not session then -- 2572
		return {success = false, message = "session not found"} -- 2574
	end -- 2574
	if getPendingQuestionnaire(sessionId) then -- 2574
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2576
	end -- 2576
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2576
		return {success = false, message = "session task is finalizing"} -- 2578
	end -- 2578
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2578
		return {success = false, message = "session task is still stopping"} -- 2581
	end -- 2581
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2581
		return {success = false, message = "session task is not continuable"} -- 2584
	end -- 2584
	if session.currentTaskId == nil then -- 2584
		return {success = false, message = "session task not found"} -- 2587
	end -- 2587
	local taskId = session.currentTaskId -- 2589
	return startPromptTask( -- 2590
		session, -- 2591
		"", -- 2592
		nil, -- 2593
		normalizeDisabledAgentTools(disabledAgentTools), -- 2594
		{ -- 2595
			workMode = session.workMode, -- 2596
			persistUserMessage = false, -- 2597
			resumeConversation = true, -- 2598
			existingTaskId = taskId, -- 2599
			initialStep = math.max( -- 2600
				0, -- 2600
				getNextStepNumber(session.id, taskId) - 1 -- 2600
			), -- 2600
			initialAgentStepCount = getAgentStepCount(session.id, taskId), -- 2601
			llmConfigId = llmConfigId -- 2602
		} -- 2602
	) -- 2602
end -- 2571
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2749
	local session = getSessionItem(sessionId) -- 2750
	if not session then -- 2750
		return {success = false, message = "session not found"} -- 2752
	end -- 2752
	if session.kind ~= "sub" then -- 2752
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2755
	end -- 2755
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2755
		return {success = false, message = "session task is finalizing"} -- 2758
	end -- 2758
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2760
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2760
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2765
	end -- 2765
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2765
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2768
	end -- 2768
	local disabledAgentTools = __TS__ArrayFilter( -- 2770
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2770
		function(____, tool) return tool ~= "finish" end -- 2771
	) -- 2771
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2772
	return startPromptTask( -- 2775
		session, -- 2775
		prompt, -- 2775
		nil, -- 2775
		disabledAgentTools, -- 2775
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2775
	) -- 2775
end -- 2749
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2782
	local session = getSessionItem(sessionId) -- 2783
	if not session then -- 2783
		return {success = false, message = "session not found"} -- 2785
	end -- 2785
	if getPendingQuestionnaire(sessionId) then -- 2785
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2787
	end -- 2787
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2787
		return {success = false, message = "session task is finalizing"} -- 2789
	end -- 2789
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2789
		return {success = false, message = "session task is still running"} -- 2792
	end -- 2792
	local message = getMessageItem(messageId) -- 2794
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2794
		return {success = false, message = "message not found"} -- 2796
	end -- 2796
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2798
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2804
	if latestUserMessageId ~= messageId then -- 2804
		return {success = false, message = "only the latest user prompt can be edited"} -- 2806
	end -- 2806
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2808
	if normalizedPrompt == "" then -- 2808
		return {success = false, message = "prompt is empty"} -- 2810
	end -- 2810
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2812
	if session.workMode ~= nextWorkMode then -- 2812
		DB:exec( -- 2814
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2814
			{ -- 2814
				nextWorkMode, -- 2814
				now(), -- 2814
				session.id -- 2814
			} -- 2814
		) -- 2814
		session.workMode = nextWorkMode -- 2815
	end -- 2815
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2817
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2818
	local result = startPromptTask( -- 2819
		session, -- 2819
		normalizedPrompt, -- 2819
		messageId, -- 2819
		normalizeDisabledAgentTools(disabledAgentTools), -- 2819
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2819
	) -- 2819
	if result.success and #removedStepIds > 0 then -- 2819
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2821
	end -- 2821
	return result -- 2823
end -- 2782
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2828
	if status == "dismissed" then -- 2828
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2834
	end -- 2834
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2836
end -- 2828
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2839
	if status == "dismissed" then -- 2839
		return { -- 2845
			success = true, -- 2846
			status = "dismissed", -- 2847
			source = "user", -- 2848
			questionnaireId = questionnaire.id, -- 2849
			title = questionnaire.schema.title, -- 2850
			answers = {}, -- 2851
			responses = {}, -- 2852
			displayText = "用户关闭了调查问卷，未作答。", -- 2853
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2854
		} -- 2854
	end -- 2854
	local responses = {} -- 2857
	do -- 2857
		local i = 0 -- 2858
		while i < #questionnaire.schema.questions do -- 2858
			do -- 2858
				local question = questionnaire.schema.questions[i + 1] -- 2859
				local answer = __TS__ArrayFind( -- 2860
					answers, -- 2860
					function(____, item) return item.questionId == question.id end -- 2860
				) -- 2860
				if not answer or answer.status == "skipped" then -- 2860
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2862
					goto __continue445 -- 2867
				end -- 2867
				local selectedOptionLabels = {} -- 2869
				do -- 2869
					local j = 0 -- 2870
					while j < #(answer.selectedOptionIds or ({})) do -- 2870
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2871
						local option = __TS__ArrayFind( -- 2872
							question.options or ({}), -- 2872
							function(____, item) return item.id == optionId end -- 2872
						) -- 2872
						if option then -- 2872
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2873
						end -- 2873
						j = j + 1 -- 2870
					end -- 2870
				end -- 2870
				responses[#responses + 1] = { -- 2875
					questionId = question.id, -- 2876
					prompt = question.prompt, -- 2877
					status = "answered", -- 2878
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2879
					selectedOptionLabels = selectedOptionLabels, -- 2880
					otherText = answer.otherText, -- 2881
					text = answer.text -- 2882
				} -- 2882
			end -- 2882
			::__continue445:: -- 2882
			i = i + 1 -- 2858
		end -- 2858
	end -- 2858
	return { -- 2885
		success = true, -- 2886
		status = "answered", -- 2887
		source = "user", -- 2888
		questionnaireId = questionnaire.id, -- 2889
		title = questionnaire.schema.title, -- 2890
		answers = answers, -- 2891
		responses = responses, -- 2892
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2893
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2894
	} -- 2894
end -- 2839
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2920
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2926
	local persisted = storage:readSessionState() -- 2927
	local messages = __TS__ArraySlice(persisted.messages) -- 2928
	local toolResultIndex = -1 -- 2929
	local existingResult -- 2930
	do -- 2930
		local i = #messages - 1 -- 2931
		while i >= 0 do -- 2931
			do -- 2931
				local message = messages[i + 1] -- 2932
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2932
					goto __continue465 -- 2933
				end -- 2933
				local decoded = safeJsonDecode(message.content) -- 2934
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2934
					goto __continue465 -- 2935
				end -- 2935
				local row = decoded -- 2936
				if row.questionnaireId ~= questionnaire.id then -- 2936
					goto __continue465 -- 2937
				end -- 2937
				toolResultIndex = i -- 2938
				existingResult = row -- 2939
				break -- 2940
			end -- 2940
			::__continue465:: -- 2940
			i = i - 1 -- 2931
		end -- 2931
	end -- 2931
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2942
	local guidance = {} -- 2943
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2943
		guidance[#guidance + 1] = existingResult.guidance -- 2945
	end -- 2945
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2945
		guidance[#guidance + 1] = result.guidance -- 2948
	end -- 2948
	result.guidance = table.concat(guidance, "\n") -- 2950
	if toolResultIndex < 0 then -- 2950
		messages[#messages + 1] = { -- 2952
			role = "user", -- 2953
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 2954
		} -- 2954
		toolResultIndex = #messages - 1 -- 2956
	else -- 2956
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2958
			{}, -- 2958
			messages[toolResultIndex + 1], -- 2959
			{content = encodeJson(result)} -- 2958
		) -- 2958
	end -- 2958
	local pairStartIndex = toolResultIndex -- 2964
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2965
	if toolCallId and toolCallId ~= "" then -- 2965
		do -- 2965
			local i = toolResultIndex - 1 -- 2967
			while i >= 0 do -- 2967
				do -- 2967
					local message = messages[i + 1] -- 2968
					if message.role ~= "assistant" or not message.tool_calls then -- 2968
						goto __continue475 -- 2969
					end -- 2969
					if __TS__ArraySome( -- 2969
						message.tool_calls, -- 2970
						function(____, call) return call.id == toolCallId end -- 2970
					) then -- 2970
						pairStartIndex = i -- 2971
						break -- 2972
					end -- 2972
				end -- 2972
				::__continue475:: -- 2972
				i = i - 1 -- 2967
			end -- 2967
		end -- 2967
	end -- 2967
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2976
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2979
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2983
	upsertStep( -- 2985
		session.id, -- 2985
		questionnaire.taskId, -- 2985
		questionnaire.step, -- 2985
		"ask_user", -- 2985
		{status = "DONE", result = result} -- 2985
	) -- 2985
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2989
	upsertStep( -- 2990
		session.id, -- 2990
		questionnaire.taskId, -- 2990
		answerStep, -- 2990
		"questionnaire_answer", -- 2990
		{status = "DONE", result = result} -- 2990
	) -- 2990
	return {success = true, answerStep = answerStep, result = result} -- 2994
end -- 2920
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2997
	local session = getSessionItem(sessionId) -- 2998
	if not session then -- 2998
		return {success = false, message = "session not found"} -- 2999
	end -- 2999
	if session.kind ~= "main" then -- 2999
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3000
	end -- 3000
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3001
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3001
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3003
	end -- 3003
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3005
	if not llmConfigRes.success then -- 3005
		return {success = false, message = llmConfigRes.message} -- 3006
	end -- 3006
	if not removePendingQuestionnaire(session) then -- 3006
		return {success = false, message = "failed to consume questionnaire file"} -- 3007
	end -- 3007
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3008
	if not replaced.success then -- 3008
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3010
		return replaced -- 3011
	end -- 3011
	local t = now() -- 3013
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3014
	session.workMode = "plan" -- 3015
	local result = startPromptTask( -- 3016
		session, -- 3016
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3016
		nil, -- 3016
		{}, -- 3016
		{ -- 3016
			workMode = "plan", -- 3017
			persistUserMessage = false, -- 3018
			resumeConversation = true, -- 3019
			existingTaskId = questionnaire.taskId, -- 3020
			initialStep = replaced.answerStep, -- 3021
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3022
			llmConfig = llmConfigRes.config -- 3023
		} -- 3023
	) -- 3023
	if not result.success then -- 3023
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3026
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3027
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3028
		emitAgentSessionPatch( -- 3029
			session.id, -- 3029
			{ -- 3029
				session = getSessionItem(session.id), -- 3030
				pendingQuestionnaire = questionnaire -- 3031
			} -- 3031
		) -- 3031
		return result -- 3033
	end -- 3033
	emitAgentSessionPatch( -- 3035
		sessionId, -- 3035
		{ -- 3035
			session = getSessionItem(sessionId), -- 3036
			pendingQuestionnaire = false -- 3037
		} -- 3037
	) -- 3037
	return result -- 3039
end -- 2997
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3042
	local session = getSessionItem(sessionId) -- 3043
	if not session then -- 3043
		return {success = false, message = "session not found"} -- 3044
	end -- 3044
	if session.kind ~= "main" then -- 3044
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3045
	end -- 3045
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3046
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3046
		return {success = false, message = "pending questionnaire not found"} -- 3047
	end -- 3047
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3048
	if not validated.success then -- 3048
		return validated -- 3049
	end -- 3049
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3050
	if not llmConfigRes.success then -- 3050
		return {success = false, message = llmConfigRes.message} -- 3051
	end -- 3051
	local t = now() -- 3052
	if not removePendingQuestionnaire(session) then -- 3052
		return {success = false, message = "failed to consume questionnaire file"} -- 3053
	end -- 3053
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3054
	if not replaced.success then -- 3054
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3056
		return replaced -- 3057
	end -- 3057
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3059
	session.workMode = "plan" -- 3060
	local result = startPromptTask( -- 3061
		session, -- 3061
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3061
		nil, -- 3061
		{}, -- 3061
		{ -- 3061
			workMode = "plan", -- 3062
			persistUserMessage = false, -- 3063
			resumeConversation = true, -- 3064
			existingTaskId = questionnaire.taskId, -- 3065
			initialStep = replaced.answerStep, -- 3066
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3067
			llmConfig = llmConfigRes.config -- 3068
		} -- 3068
	) -- 3068
	if not result.success then -- 3068
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3071
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3072
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3073
		emitAgentSessionPatch( -- 3074
			session.id, -- 3074
			{ -- 3074
				session = getSessionItem(session.id), -- 3075
				pendingQuestionnaire = questionnaire -- 3076
			} -- 3076
		) -- 3076
		return result -- 3078
	end -- 3078
	emitAgentSessionPatch( -- 3080
		sessionId, -- 3080
		{ -- 3080
			session = getSessionItem(sessionId), -- 3081
			pendingQuestionnaire = false -- 3082
		} -- 3082
	) -- 3082
	return result -- 3084
end -- 3042
function ____exports.stopSessionTask(sessionId) -- 3087
	local session = getSessionItem(sessionId) -- 3088
	if not session or session.currentTaskId == nil then -- 3088
		return {success = false, message = "session task not found"} -- 3090
	end -- 3090
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3090
		return {success = false, message = "session task is finalizing"} -- 3093
	end -- 3093
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3095
	local stopToken = activeStopTokens[session.currentTaskId] -- 3096
	if not stopToken then -- 3096
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3096
			return {success = true, recovered = true} -- 3099
		end -- 3099
		return {success = false, message = "task is not running"} -- 3101
	end -- 3101
	if stopToken.stopped then -- 3101
		return {success = true, stopping = true} -- 3104
	end -- 3104
	stopToken.stopped = true -- 3106
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3107
	return {success = true, stopping = true} -- 3111
end -- 3087
function ____exports.getCurrentTaskId(sessionId) -- 3114
	local ____opt_126 = getSessionItem(sessionId) -- 3114
	return ____opt_126 and ____opt_126.currentTaskId -- 3115
end -- 3114
function ____exports.validateTaskAccess(sessionId, taskId) -- 3118
	local session = getSessionItem(sessionId) -- 3119
	if not session then -- 3119
		return {success = false, message = "session not found"} -- 3120
	end -- 3120
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3120
		getSessionOperableTaskIds(sessionId), -- 3121
		taskId -- 3121
	) < 0 then -- 3121
		return {success = false, message = "task is not operable for this session"} -- 3122
	end -- 3122
	return {success = true, session = session} -- 3124
end -- 3118
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3127
	if checkpointId <= 0 then -- 3127
		return {success = false, message = "invalid checkpointId"} -- 3129
	end -- 3129
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3131
	if not checkpoint then -- 3131
		return {success = false, message = "checkpoint not found"} -- 3133
	end -- 3133
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3135
	if not taskAccess.success then -- 3135
		return taskAccess -- 3136
	end -- 3136
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3137
end -- 3127
function ____exports.listRunningSessions() -- 3140
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3141
	local sessions = {} -- 3148
	do -- 3148
		local i = 0 -- 3149
		while i < #rows do -- 3149
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3150
			if session.currentTaskStatus == "RUNNING" then -- 3150
				sessions[#sessions + 1] = session -- 3152
			end -- 3152
			i = i + 1 -- 3149
		end -- 3149
	end -- 3149
	return {success = true, sessions = sessions} -- 3155
end -- 3140
return ____exports -- 3140