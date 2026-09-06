-- [tsx]: Remix.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local toNode = ____DoraX.toNode -- 1
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 2
local attachGamepad = ____Gamepad.attachGamepad -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local DB = ____Dora.DB -- 3
local Director = ____Dora.Director -- 3
local Ease = ____Dora.Ease -- 3
local HttpServer = ____Dora.HttpServer -- 3
local Label = ____Dora.Label -- 3
local Move = ____Dora.Move -- 3
local Node = ____Dora.Node -- 3
local sleep = ____Dora.sleep -- 3
local thread = ____Dora.thread -- 3
local Vec2 = ____Dora.Vec2 -- 3
local AgentSession = require("Agent.Session") -- 4
local ____Utils = require("Agent.Utils") -- 5
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 5
local getLLMConfig = ____Utils.getLLMConfig -- 5
local getLLMConfigSummaries = ____Utils.getLLMConfigSummaries -- 5
local safeJsonEncode = ____Utils.safeJsonEncode -- 5
local ____RemixModel = require("Dev.Mobile.RemixModel") -- 8
local buildQuestionnaireAnswers = ____RemixModel.buildQuestionnaireAnswers -- 8
local canLeaveRemix = ____RemixModel.canLeaveRemix -- 8
local isQuestionAnswered = ____RemixModel.isQuestionAnswered -- 8
local resolveRemixPhase = ____RemixModel.resolveRemixPhase -- 8
local resolveRemixThinkingStatus = ____RemixModel.resolveRemixThinkingStatus -- 8
local resolveRemixWorkMode = ____RemixModel.resolveRemixWorkMode -- 8
local ____Mascot = require("Dev.Mobile.Mascot") -- 9
local DoraMascot = ____Mascot.DoraMascot -- 9
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 10
local mobileFontScale = ____Accessibility.mobileFontScale -- 10
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 11
local resolveFeedGesture = ____FeedModel.resolveFeedGesture -- 11
local ____RemixTranscript = require("Dev.Mobile.RemixTranscript") -- 12
local createRemixTranscript = ____RemixTranscript.createRemixTranscript -- 12
local remixDisplayRevision = ____RemixTranscript.remixDisplayRevision -- 12
local ____RemixHistory = require("Dev.Mobile.RemixHistory") -- 13
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS -- 13
local ____TextInput = require("Dev.Mobile.TextInput") -- 14
local createTextInput = ____TextInput.createTextInput -- 14
local inputLength = ____TextInput.inputLength -- 14
local inputSlice = ____TextInput.inputSlice -- 14
local ____LLMSetup = require("Dev.Mobile.LLMSetup") -- 15
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager -- 15
local ____PackagePanel = require("Dev.Mobile.PackagePanel") -- 16
local startPackagePanel = ____PackagePanel.startPackagePanel -- 16
local ____Visual = require("Dev.Mobile.Visual") -- 17
local RoundedSurface = ____Visual.RoundedSurface -- 17
local VerticalGradient = ____Visual.VerticalGradient -- 17
local fontName = "sarasa-mono-sc-regular" -- 49
local colors = { -- 50
	background = 4278914322, -- 50
	panel = 4279704614, -- 50
	text = 4294242792, -- 50
	muted = 4289245117, -- 50
	brand = 4294954035, -- 50
	border = 4281613128, -- 50
	danger = 4294929259 -- 50
} -- 50
local composerGap = 12 -- 52
local composerBottom = 76 -- 53
local composerHeight = 60 -- 54
local composerActionWidth = 82 -- 55
local modeBottom = composerBottom + composerHeight + composerGap -- 56
local composerTop = modeBottom + 40 -- 57
local transcriptBottom = composerTop + composerGap -- 58
local statusHeight = 64 -- 59
local function ellipsizeSingleLine(text, width, fontSize) -- 61
	if text == "" then -- 61
		return "" -- 62
	end -- 62
	local measure = Label(fontName, fontSize, true) -- 63
	if not measure then -- 63
		return text -- 64
	end -- 64
	measure.visible = false -- 65
	measure.textWidth = -1 -- 66
	local function fits(value) -- 67
		measure.text = value -- 67
		return measure.width <= width -- 67
	end -- 67
	if fits(text) then -- 67
		measure:cleanup() -- 68
		return text -- 68
	end -- 68
	local low = 0 -- 69
	local high = inputLength(text) -- 69
	while low < high do -- 69
		local middle = math.floor((low + high + 1) / 2) -- 71
		if fits(inputSlice(text, 0, middle) .. "…") then -- 71
			low = middle -- 72
		else -- 72
			high = middle - 1 -- 73
		end -- 73
	end -- 73
	local result = inputSlice(text, 0, low) .. "…" -- 75
	measure:cleanup() -- 76
	return result -- 77
end -- 61
local function measureWrappedTextHeight(text, width, fontSize) -- 80
	local measure = Label(fontName, fontSize, true) -- 81
	if not measure then -- 81
		return fontSize -- 82
	end -- 82
	measure.visible = false -- 83
	measure.textWidth = width -- 84
	measure.alignment = "Left" -- 85
	measure.text = text -- 86
	local height = measure.height -- 87
	measure:cleanup() -- 88
	return height -- 89
end -- 80
local function ActionButton(props) -- 92
	local height = props.height or 46 -- 93
	return React.createElement( -- 94
		"node", -- 94
		{ -- 94
			tag = props.tag, -- 94
			x = props.x, -- 94
			y = props.y, -- 94
			width = props.width, -- 94
			height = height, -- 94
			anchorX = 0, -- 94
			anchorY = 0, -- 94
			opacity = props.disabled and 0.45 or 1, -- 94
			touchEnabled = not props.disabled, -- 94
			swallowTouches = true, -- 94
			onTapped = props.onTapped -- 94
		}, -- 94
		React.createElement(RoundedSurface, { -- 94
			width = props.width, -- 94
			height = height, -- 94
			radius = 14, -- 94
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 94
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279704871), -- 94
			borderWidth = 1, -- 94
			borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border), -- 94
			shadow = props.primary or props.danger -- 94
		}), -- 94
		React.createElement("label", { -- 94
			x = props.width / 2, -- 94
			y = height / 2, -- 94
			fontName = fontName, -- 94
			fontSize = 15, -- 94
			text = props.text, -- 94
			color3 = props.primary and 1512202 or 16052712 -- 94
		}) -- 94
	) -- 94
end -- 92
local function ChoiceButton(props) -- 103
	local ____React_createElement_5 = React.createElement -- 103
	local ____temp_3 = { -- 103
		tag = props.tag, -- 103
		x = props.x, -- 103
		y = props.y, -- 103
		width = props.width, -- 103
		height = 40, -- 103
		anchorX = 0, -- 103
		anchorY = 0, -- 103
		opacity = props.disabled and 0.45 or 1, -- 103
		touchEnabled = not props.disabled, -- 103
		swallowTouches = true, -- 103
		onTapped = props.onTapped -- 103
	} -- 103
	local ____React_createElement_result_4 = React.createElement(RoundedSurface, { -- 103
		width = props.width, -- 103
		height = 40, -- 103
		radius = 12, -- 103
		topColor = props.selected and 4294958955 or 4280297526, -- 103
		bottomColor = props.selected and 4294950190 or 4279244061, -- 103
		borderWidth = 1, -- 103
		borderColor = props.selected and 4294958435 or colors.border -- 103
	}) -- 103
	local ____React_createElement_2 = React.createElement -- 103
	local ____array_1 = __TS__SparseArrayNew( -- 103
		"draw-node", -- 103
		{tag = props.tag and props.tag .. "-radio" or nil, x = 17, y = 20}, -- 103
		React.createElement("dot-shape", {radius = 7, color = props.selected and 4279702282 or 4289245117}), -- 103
		React.createElement("dot-shape", {radius = 5, color = props.selected and 4294954824 or 4279704614}) -- 103
	) -- 103
	local ____props_selected_0 -- 112
	if props.selected then -- 112
		____props_selected_0 = React.createElement( -- 112
			"draw-node", -- 112
			{tag = props.tag and props.tag .. "-radio-dot" or nil}, -- 112
			React.createElement("dot-shape", {radius = 2.5, color = 4279702282}) -- 112
		) -- 112
	else -- 112
		____props_selected_0 = nil -- 112
	end -- 112
	__TS__SparseArrayPush(____array_1, ____props_selected_0) -- 112
	return ____React_createElement_5( -- 104
		"node", -- 104
		____temp_3, -- 104
		____React_createElement_result_4, -- 104
		____React_createElement_2(__TS__SparseArraySpread(____array_1)), -- 104
		React.createElement("label", { -- 104
			x = 32, -- 104
			y = 20, -- 104
			anchorX = 0, -- 104
			fontName = fontName, -- 104
			fontSize = 14, -- 104
			text = props.text, -- 104
			textWidth = props.width - 44, -- 104
			alignment = "Left", -- 104
			color3 = props.selected and 1512202 or 16052712 -- 104
		}) -- 104
	) -- 104
end -- 103
function ____exports.startMobileRemix(options) -- 118
	local host, send, getTranscriptActions, render -- 118
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 119
	local onBack = options.onBack -- 120
	local onPlay = options.onPlay -- 121
	local packagePanel -- 122
	local services = options.services or ({ -- 123
		createSession = AgentSession.createSession, -- 124
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end, -- 125
		setWorkMode = AgentSession.setWorkMode, -- 126
		sendPrompt = AgentSession.sendPrompt, -- 127
		respondQuestionnaire = AgentSession.respondQuestionnaire, -- 128
		stopSessionTask = AgentSession.stopSessionTask, -- 129
		continuePrompt = AgentSession.continuePrompt, -- 130
		getActiveLLMConfig = getActiveLLMConfig, -- 131
		getLLMConfig = getLLMConfig, -- 132
		getLLMConfigSummaries = getLLMConfigSummaries -- 133
	}) -- 133
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 135
	local projectRoot = options.entry.workDir or "" -- 136
	local created = services.createSession(projectRoot, options.entry.title) -- 137
	local sessionId = created.success and created.session.id or 0 -- 138
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message}) -- 139
	local draft = "" -- 142
	local ____error = created.success and "" or created.message -- 143
	local backNoticeUntil = 0 -- 144
	local pollElapsed = 0 -- 145
	local stopRequested = false -- 146
	local selectedLLMConfigId = 0 -- 147
	local questionnaireId = 0 -- 148
	local questionIndex = 0 -- 149
	local llmConfigs = services.getLLMConfigSummaries() -- 150
	local taskLLMConfigId = 0 -- 151
	local needsLLMSetup = false -- 152
	local questionnaireSelections = {} -- 153
	local questionnaireTexts = {} -- 154
	local inputRef = reference() -- 155
	local disposed = false -- 156
	local dismissedComposition = false -- 157
	local swipeBackPending = false -- 158
	local swipeDragging = false -- 159
	local swipeRevision = 0 -- 160
	local projectChangeNotified = false -- 161
	local function currentQuestion() -- 162
		local ____detail_success_8 -- 162
		if detail.success then -- 162
			local ____opt_6 = detail.pendingQuestionnaire -- 162
			____detail_success_8 = ____opt_6 and ____opt_6.schema.questions[questionIndex + 1] -- 162
		else -- 162
			____detail_success_8 = nil -- 162
		end -- 162
		return ____detail_success_8 -- 162
	end -- 162
	local promptInput = createTextInput({ -- 163
		fontSize = math.floor(16 * mobileFontScale), -- 164
		getText = function() -- 165
			local question = currentQuestion() -- 165
			return question and (questionnaireTexts[question.id] or "") or draft -- 165
		end, -- 165
		setText = function(text) -- 166
			local question = currentQuestion() -- 166
			if question then -- 166
				questionnaireTexts[question.id] = text -- 166
			else -- 166
				draft = text -- 166
			end -- 166
		end, -- 166
		getPlaceholder = function() -- 167
			local question = currentQuestion() -- 168
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 169
		end, -- 167
		isEnabled = function() return not packagePanel and not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end, -- 171
		onReturn = function(modified) -- 172
			if modified and not currentQuestion() then -- 172
				send() -- 172
				return true -- 172
			end -- 172
			return false -- 172
		end -- 172
	}) -- 172
	local blurInput = promptInput.blur -- 174
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 175
	local ____temp_11 -- 176
	if rememberedRows and #rememberedRows > 0 then -- 176
		____temp_11 = tonumber(rememberedRows[1][1]) -- 176
	else -- 176
		____temp_11 = nil -- 176
	end -- 176
	local rememberedId = ____temp_11 -- 176
	if rememberedId and __TS__ArraySome( -- 176
		llmConfigs, -- 177
		function(____, item) return item.id == rememberedId end -- 177
	) then -- 177
		selectedLLMConfigId = rememberedId -- 177
	elseif #llmConfigs > 0 then -- 177
		selectedLLMConfigId = llmConfigs[1].id -- 178
	else -- 178
		local activeConfig = services.getActiveLLMConfig() -- 180
		if activeConfig.success then -- 180
			selectedLLMConfigId = activeConfig.id -- 181
		else -- 181
			needsLLMSetup = true -- 182
		end -- 182
	end -- 182
	host = Node() -- 185
	host.tag = "mobile-remix" -- 186
	host.scaleX = App.devicePixelRatio -- 187
	host.scaleY = App.devicePixelRatio -- 188
	host:addTo(Director.systemUI) -- 189
	local transcript = createRemixTranscript() -- 190
	local displayRevision = "" -- 191
	local shellRevision = "" -- 192
	local inputLayout = "" -- 193
	local mascotAnimationState -- 194
	local mascotAnimationStartedAt = App.runningTime -- 195
	local compactHeaderStatusActive = false -- 196
	local errorLabel -- 197
	local layoutTranscriptBottom = transcriptBottom -- 198
	local function getLayoutArea() -- 199
		return App.safeArea -- 199
	end -- 199
	local function getTranscriptBottom() -- 200
		return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 200
	end -- 200
	local function hasTranscriptContent() -- 201
		return detail.success and (#detail.messages > 0 or #detail.steps > 0) -- 201
	end -- 201
	local function getHeaderY(safe) -- 202
		local landscapeTopLift = safe.width >= 760 and safe.height < 500 and 28 or 0 -- 203
		return safe.y + safe.height - 56 + landscapeTopLift -- 204
	end -- 202
	local function useCompactHeaderStatus(safe) -- 206
		return safe.width >= 760 and safe.height < 500 and hasTranscriptContent() -- 206
	end -- 206
	local function useCompactStandaloneStatus(safe) -- 207
		return safe.height >= 500 and hasTranscriptContent() -- 207
	end -- 207
	local function getTranscriptHeight(safe) -- 208
		local statusInset = useCompactHeaderStatus(safe) and composerGap or statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) and 24 or 0) -- 209
		local available = math.max( -- 211
			40, -- 211
			getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset -- 211
		) -- 211
		return safe.width >= 760 and safe.height < 500 and not hasTranscriptContent() and 8 or available -- 212
	end -- 208
	local function getShellRevision() -- 214
		local ____detail_success_15 -- 214
		if detail.success then -- 214
			local ____safeJsonEncode_14 = safeJsonEncode -- 214
			local ____array_13 = __TS__SparseArrayNew( -- 214
				detail.session.status, -- 215
				detail.session.workMode, -- 215
				detail.hasActivePlan, -- 215
				detail.pendingQuestionnaire or false, -- 215
				detail.session.currentTaskStatus or "" -- 216
			) -- 216
			local ____detail_session_currentTaskFinalizing_12 = detail.session.currentTaskFinalizing -- 216
			if ____detail_session_currentTaskFinalizing_12 == nil then -- 216
				____detail_session_currentTaskFinalizing_12 = false -- 216
			end -- 216
			__TS__SparseArrayPush( -- 216
				____array_13, -- 216
				____detail_session_currentTaskFinalizing_12, -- 216
				stopRequested, -- 216
				hasTranscriptContent(), -- 216
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or "" -- 217
			) -- 217
			____detail_success_15 = (____safeJsonEncode_14({__TS__SparseArraySpread(____array_13)})) or "" -- 214
		else -- 214
			____detail_success_15 = detail.message -- 218
		end -- 218
		return ____detail_success_15 -- 214
	end -- 214
	local function updateTranscript() -- 219
		local safe = getLayoutArea() -- 220
		transcript:update( -- 221
			detail, -- 221
			math.max(60, safe.width - 32), -- 221
			getTranscriptHeight(safe), -- 221
			mobileFontScale, -- 221
			zh, -- 221
			getTranscriptActions() -- 221
		) -- 221
		displayRevision = remixDisplayRevision(detail) -- 222
	end -- 219
	local function hasActiveTask() -- 225
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 225
	end -- 225
	local function notifyProjectChanged() -- 228
		if projectChangeNotified or not detail.success or not options.onProjectChanged then -- 228
			return -- 229
		end -- 229
		if not __TS__ArraySome( -- 229
			detail.steps, -- 230
			function(____, step) return step.files ~= nil and #step.files > 0 end -- 230
		) then -- 230
			return -- 230
		end -- 230
		projectChangeNotified = true -- 231
		options.onProjectChanged(options.entry) -- 232
	end -- 228
	local function refresh() -- 234
		if sessionId > 0 then -- 234
			detail = services.getSession(sessionId) -- 235
		end -- 235
		if detail.success and not hasActiveTask() then -- 235
			stopRequested = false -- 236
		end -- 236
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 236
			questionnaireId = detail.pendingQuestionnaire.id -- 238
			questionIndex = 0 -- 239
		end -- 239
	end -- 234
	local function canSubmit() -- 242
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 242
	end -- 242
	local function resolveLLMConfig() -- 245
		return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 245
	end -- 245
	local function configureLLM() -- 246
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 246
			return -- 247
		end -- 247
		blurInput() -- 248
		startMobileLLMManager({ -- 249
			coveredNode = host, -- 250
			selectedId = selectedLLMConfigId, -- 251
			taskRunning = hasActiveTask(), -- 252
			runningId = taskLLMConfigId, -- 253
			onSelected = function(id) -- 254
				if disposed or not host.parent then -- 254
					return -- 255
				end -- 255
				llmConfigs = services.getLLMConfigSummaries() -- 256
				selectedLLMConfigId = id -- 257
				needsLLMSetup = #llmConfigs == 0 -- 258
				____error = "" -- 259
				render() -- 260
			end, -- 254
			onClose = function() -- 262
				if not disposed and host.parent then -- 262
					render() -- 262
				end -- 262
			end -- 262
		}) -- 262
	end -- 246
	local function changeWorkMode(workMode) -- 265
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 265
			return -- 266
		end -- 266
		refresh() -- 267
		if not canSubmit() or not detail.success then -- 267
			return -- 268
		end -- 268
		if resolveRemixWorkMode(detail.session) == workMode then -- 268
			return -- 269
		end -- 269
		local result = services.setWorkMode(sessionId, workMode) -- 270
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 271
		refresh() -- 272
		render() -- 273
	end -- 265
	send = function() -- 275
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 275
			return -- 276
		end -- 276
		refresh() -- 277
		if not canSubmit() or not detail.success or promptInput.isComposing() then -- 277
			return -- 278
		end -- 278
		local workMode = resolveRemixWorkMode(detail.session) -- 279
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 282
		if sessionId <= 0 or text == "" then -- 282
			return -- 283
		end -- 283
		local config = resolveLLMConfig() -- 284
		if not config.success then -- 284
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 286
			render() -- 287
			configureLLM() -- 288
			return -- 289
		end -- 289
		selectedLLMConfigId = config.id -- 291
		local result = services.sendPrompt( -- 292
			sessionId, -- 292
			text, -- 292
			nil, -- 292
			workMode, -- 292
			config.id, -- 292
			config.config -- 292
		) -- 292
		if not result.success then -- 292
			____error = result.message -- 293
		else -- 293
			taskLLMConfigId = config.id -- 294
			draft = "" -- 294
			____error = "" -- 294
		end -- 294
		refresh() -- 295
		render() -- 296
	end -- 275
	local function continueTask() -- 298
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 298
			return -- 299
		end -- 299
		refresh() -- 300
		if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then -- 300
			return -- 302
		end -- 302
		local config = resolveLLMConfig() -- 303
		if not config.success then -- 303
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 305
			render() -- 306
			configureLLM() -- 307
			return -- 308
		end -- 308
		if not services.continuePrompt then -- 308
			____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable" -- 311
			render() -- 312
			return -- 313
		end -- 313
		selectedLLMConfigId = config.id -- 315
		local result = services.continuePrompt(sessionId, nil, config.id) -- 316
		____error = result.success and "" or result.message -- 317
		if result.success then -- 317
			taskLLMConfigId = config.id -- 318
			stopRequested = false -- 318
		end -- 318
		refresh() -- 319
		render() -- 320
	end -- 298
	local function startDevelopment() -- 322
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 322
			return -- 323
		end -- 323
		refresh() -- 324
		if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then -- 324
			return -- 325
		end -- 325
		local modeResult = services.setWorkMode(sessionId, "code") -- 326
		if not modeResult.success then -- 326
			____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode") -- 328
			render() -- 329
			return -- 330
		end -- 330
		local config = resolveLLMConfig() -- 332
		if not config.success then -- 332
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 334
			refresh() -- 335
			render() -- 336
			configureLLM() -- 337
			return -- 338
		end -- 338
		selectedLLMConfigId = config.id -- 340
		local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated." -- 341
		local result = services.sendPrompt( -- 344
			sessionId, -- 344
			prompt, -- 344
			nil, -- 344
			"code", -- 344
			config.id, -- 344
			config.config -- 344
		) -- 344
		____error = result.success and "" or result.message -- 345
		if result.success then -- 345
			taskLLMConfigId = config.id -- 346
		end -- 346
		refresh() -- 347
		render() -- 348
	end -- 322
	getTranscriptActions = function() -- 350
		if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery( -- 350
			detail.messages, -- 351
			function(____, message) return message.role ~= "assistant" end -- 351
		) then -- 351
			return {} -- 351
		end -- 351
		local actions = {} -- 352
		if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then -- 352
			actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask} -- 354
		end -- 354
		if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then -- 354
			actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment} -- 356
		end -- 356
		return actions -- 357
	end -- 350
	local function stop() -- 359
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 359
			return -- 360
		end -- 360
		refresh() -- 361
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 361
			return -- 363
		end -- 363
		local result = services.stopSessionTask(sessionId) -- 364
		if (result and result.success) == false then -- 364
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 365
		else -- 365
			stopRequested = true -- 366
			____error = "" -- 366
		end -- 366
		refresh() -- 367
		render() -- 368
	end -- 359
	local function advanceQuestionnaire(skipCurrent) -- 370
		if skipCurrent == nil then -- 370
			skipCurrent = false -- 370
		end -- 370
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 370
			return -- 371
		end -- 371
		if not detail.success or not detail.pendingQuestionnaire then -- 371
			return -- 372
		end -- 372
		local pending = detail.pendingQuestionnaire -- 373
		local questions = pending.schema.questions -- 374
		local question = questions[questionIndex + 1] -- 375
		if not question then -- 375
			return -- 376
		end -- 376
		local selected = questionnaireSelections[question.id] or ({}) -- 377
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 378
		if skipCurrent then -- 378
			if question.required then -- 378
				return -- 380
			end -- 380
			questionnaireSelections[question.id] = {} -- 381
			questionnaireTexts[question.id] = "" -- 382
		elseif not isQuestionAnswered(question, selected, text) then -- 382
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 384
			render() -- 385
			return -- 386
		end -- 386
		if questionIndex + 1 < #questions then -- 386
			questionIndex = questionIndex + 1 -- 389
			____error = "" -- 390
			render() -- 391
			return -- 392
		end -- 392
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 394
		if selectedLLMConfigId <= 0 then -- 394
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 396
			render() -- 397
			return -- 398
		end -- 398
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 400
		if not result.success then -- 400
			____error = result.message -- 401
		else -- 401
			taskLLMConfigId = selectedLLMConfigId -- 402
			____error = "" -- 402
		end -- 402
		refresh() -- 403
		render() -- 404
	end -- 370
	local function goBack() -- 406
		if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 406
			return -- 407
		end -- 407
		if detail.success and not canLeaveRemix(detail.session.status) then -- 407
			____error = "" -- 409
			backNoticeUntil = App.runningTime + 3 -- 410
			render() -- 411
			return -- 412
		end -- 412
		blurInput() -- 414
		notifyProjectChanged() -- 415
		host.visible = false -- 416
		host:removeFromParent(true) -- 417
		onBack() -- 418
	end -- 406
	render = function() -- 421
		local visibleError = ____error ~= "" and ____error or (backNoticeUntil > App.runningTime and (zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back") or "") -- 422
		errorLabel = nil -- 424
		swipeRevision = swipeRevision + 1 -- 426
		swipeDragging = false -- 427
		swipeBackPending = false -- 428
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 429
		local ____temp_20 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire) -- 431
		if ____temp_20 then -- 431
			local ____opt_18 = inputRef.current -- 431
			____temp_20 = (____opt_18 and ____opt_18.tag) == "remix-input" -- 431
		end -- 431
		local keptInput = ____temp_20 and inputRef.current or nil -- 431
		if keptInput ~= nil then -- 431
			keptInput:removeFromParent(false) -- 433
		end -- 433
		transcript.node:removeFromParent(false) -- 434
		local restoreInputFocus = promptInput.isFocused() -- 435
		if not keptInput then -- 435
			promptInput.unmount() -- 437
			inputRef = reference() -- 438
		end -- 438
		host:removeAllChildren() -- 440
		inputLayout = layout -- 441
		host.scaleX = App.devicePixelRatio -- 442
		host.scaleY = App.devicePixelRatio -- 443
		local ____App_visualSize_23 = App.visualSize -- 444
		local width = ____App_visualSize_23.width -- 444
		local height = ____App_visualSize_23.height -- 444
		local safe = getLayoutArea() -- 445
		local left = safe.x -- 446
		local bottom = safe.y -- 447
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 448
		local state = detail.success and detail.session or nil -- 449
		local workMode = resolveRemixWorkMode(state) -- 450
		local stopping = hasActiveTask() -- 451
		local ____detail_success_24 -- 452
		if detail.success then -- 452
			____detail_success_24 = detail.hasActivePlan -- 452
		else -- 452
			____detail_success_24 = false -- 452
		end -- 452
		local hasActivePlan = ____detail_success_24 -- 452
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 453
		local layoutComposerBottom = 24 -- 454
		local layoutComposerHeight = composerHeight -- 455
		local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap -- 456
		local layoutComposerTop = layoutModeBottom + 40 -- 457
		layoutTranscriptBottom = layoutComposerTop + composerGap + (phase == "done" and 48 or 0) -- 458
		local contentWidth = safe.width - 32 -- 459
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 460
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 461
		local modeStartX = left + 16 -- 462
		local modeCodeWidth = contentWidth - modeWidth - composerGap -- 463
		local playWidth = canShare and (contentWidth - composerGap) / 2 or contentWidth -- 464
		local playX = canShare and modeStartX + playWidth + composerGap or modeStartX -- 465
		local ____detail_success_25 -- 466
		if detail.success then -- 466
			____detail_success_25 = detail.pendingQuestionnaire -- 466
		else -- 466
			____detail_success_25 = nil -- 466
		end -- 466
		local questionnaire = ____detail_success_25 -- 466
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 467
		local questionPromptWidth = contentWidth - 32 -- 468
		local questionPromptHeight = question and measureWrappedTextHeight(question.prompt, questionPromptWidth, 16) or 0 -- 469
		local questionOptions = question and question.type ~= "text" and __TS__ArraySlice(question.options or ({}), 0, 8) or ({}) -- 472
		local questionAnswerHeight = #questionOptions > 0 and 40 + 43 * (#questionOptions - 1) or 92 -- 473
		local questionCardMinHeight = safe.height - 330 -- 474
		local questionCardMaxHeight = math.max(questionCardMinHeight, safe.height - 164 - 72) -- 475
		local questionCardHeight = math.min( -- 476
			math.max(questionCardMinHeight, 75 + questionPromptHeight / 2 + 14 + questionAnswerHeight + 16 + 40 + 12), -- 477
			questionCardMaxHeight -- 478
		) -- 478
		local questionAnswerTop = questionCardHeight - 75 - questionPromptHeight / 2 - 14 -- 480
		local questionHasBack = questionIndex > 0 -- 481
		local questionCanSkip = question ~= nil and not question.required -- 482
		local questionActionGap = 8 -- 483
		local questionBackWidth = 76 -- 484
		local questionSkipWidth = 64 -- 485
		local questionSkipX = 16 + (questionHasBack and questionBackWidth + questionActionGap or 0) -- 486
		local questionSubmitX = questionSkipX + (questionCanSkip and questionSkipWidth + questionActionGap or 0) -- 487
		local fontScale = mobileFontScale -- 488
		local headerY = getHeaderY(safe) -- 489
		local compactHeaderStatus = useCompactHeaderStatus(safe) -- 490
		compactHeaderStatusActive = compactHeaderStatus -- 491
		local headerStatusWidth = 168 -- 492
		local modelButtonWidth = shortLandscape and 92 or 72 -- 493
		local backText = zh and "返回 ›" or "Back ›" -- 494
		local backMeasure = Label(fontName, 18, true) -- 495
		backMeasure.text = backText -- 496
		local backWidth = math.max(44, backMeasure.width) -- 497
		backMeasure:cleanup() -- 498
		local headerBackX = left + safe.width - 16 - backWidth -- 499
		local headerSettingsX = headerBackX - composerGap - modelButtonWidth -- 500
		local headerStatusX = headerSettingsX - 8 - headerStatusWidth -- 501
		local headerTitleWidth = compactHeaderStatus and math.max(120, headerStatusX - (left + 16) - composerGap) or math.max(120, headerSettingsX - (left + 16) - composerGap) -- 502
		local selectedConfig = __TS__ArrayFind( -- 505
			llmConfigs, -- 505
			function(____, item) return item.id == selectedLLMConfigId end -- 505
		) -- 505
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId -- 506
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI") -- 507
		local modelNameLimit = shortLandscape and 10 or 6 -- 508
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName -- 509
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 14, 11) -- 510
		local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId) -- 511
		local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game"))))))) -- 512
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 519
		if mascotAnimationState ~= mascotState then -- 519
			mascotAnimationState = mascotState -- 526
			mascotAnimationStartedAt = App.runningTime -- 527
		end -- 527
		local emptyLandscape = shortLandscape and not hasTranscriptContent() -- 529
		local emptyStatusBottom = bottom + layoutTranscriptBottom -- 530
		local emptyStatusTop = headerY - composerGap - statusHeight -- 531
		local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2 -- 532
		local mascotSize = shortLandscape and 42 or 52 -- 535
		local compactStandaloneStatus = useCompactStandaloneStatus(safe) -- 536
		local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14) -- 537
		local mascotX = shortLandscape and left + 40 or left + 66 -- 538
		local statusTextX = shortLandscape and left + 76 or left + 104 -- 539
		local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84 -- 540
		local renderedStatusX = compactHeaderStatus and 36 or statusTextX -- 541
		local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift -- 542
		local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth -- 543
		local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale) -- 544
		local thinkingRightPadding = compactHeaderStatus and 8 or 20 -- 545
		local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize) -- 546
		local swipeStart = Vec2.zero -- 547
		local swipeAxis = "none" -- 548
		local pageRef = reference() -- 549
		local hitsTranscriptButton -- 550
		hitsTranscriptButton = function(node, world) -- 550
			if not node.visible then -- 550
				return false -- 551
			end -- 551
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then -- 551
				local p = node:convertToNodeSpace(world) -- 553
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 553
					return true -- 554
				end -- 554
			end -- 554
			local hit = false -- 556
			node:eachChild(function(child) -- 557
				hit = hitsTranscriptButton(child, world) -- 557
				return hit -- 557
			end) -- 557
			return hit -- 558
		end -- 550
		local ____toNode_70 = toNode -- 560
		local ____React_createElement_69 = React.createElement -- 560
		local ____array_68 = __TS__SparseArrayNew( -- 560
			"node", -- 560
			{ -- 560
				tag = "remix-scene", -- 560
				x = -width / 2, -- 560
				y = -height / 2, -- 560
				width = width, -- 560
				height = height, -- 560
				anchorX = 0, -- 560
				anchorY = 0 -- 560
			}, -- 560
			React.createElement( -- 560
				"node", -- 560
				{ -- 560
					tag = "remix-focus-observer", -- 560
					order = 1000, -- 560
					width = width, -- 560
					height = height, -- 560
					anchorX = 0, -- 560
					anchorY = 0, -- 560
					touchEnabled = true, -- 560
					swallowTouches = false, -- 560
					swallowMouseWheel = false, -- 560
					onTapFilter = function(touch) -- 560
						touch.enabled = false -- 564
						if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 564
							return -- 565
						end -- 565
						local input = inputRef.current -- 566
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 567
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 568
						dismissedComposition = not inside and promptInput.isComposing() -- 569
						if not inside then -- 569
							blurInput() -- 570
						end -- 570
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 570
							touch.enabled = true -- 575
						end -- 575
					end, -- 563
					onTapBegan = function(touch) -- 563
						swipeStart = touch.location -- 579
						swipeAxis = "none" -- 579
						swipeDragging = true -- 579
						local ____opt_34 = pageRef.current -- 579
						if ____opt_34 ~= nil then -- 579
							____opt_34:stopAllActions() -- 580
						end -- 580
					end, -- 578
					onTapMoved = function(touch) -- 578
						local delta = touch.location:sub(swipeStart) -- 583
						if swipeAxis == "none" and math.max( -- 583
							math.abs(delta.x), -- 584
							math.abs(delta.y) -- 584
						) >= 12 then -- 584
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 585
						end -- 585
						if pageRef.current then -- 585
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 587
						end -- 587
					end, -- 582
					onTapEnded = function(touch) -- 582
						local delta = touch.location:sub(swipeStart) -- 590
						swipeDragging = false -- 591
						if swipeBackPending then -- 591
							return -- 592
						end -- 592
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 593
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 594
						local page = pageRef.current -- 595
						if not page or not requested and page.x == 0 then -- 595
							return -- 596
						end -- 596
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 597
						local revision = swipeRevision -- 598
						swipeBackPending = true -- 599
						if not leaving then -- 599
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 601
						end -- 601
						thread(function() -- 603
							sleep(duration) -- 604
							if disposed or revision ~= swipeRevision or not host.parent then -- 604
								return -- 605
							end -- 605
							swipeBackPending = false -- 606
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 606
								refresh() -- 607
								goBack() -- 607
							else -- 607
								page.position = Vec2.zero -- 608
							end -- 608
						end) -- 603
					end -- 589
				} -- 589
			), -- 589
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 589
		) -- 589
		local ____React_createElement_67 = React.createElement -- 589
		local ____array_66 = __TS__SparseArrayNew( -- 589
			"node", -- 589
			{tag = "remix-page", ref = pageRef}, -- 589
			React.createElement( -- 589
				"clip-node", -- 589
				{ -- 589
					x = left + 16, -- 589
					y = headerY, -- 589
					width = headerTitleWidth, -- 589
					height = 44, -- 589
					anchorX = 0, -- 589
					anchorY = 0, -- 589
					stencil = React.createElement( -- 589
						"draw-node", -- 589
						{x = headerTitleWidth / 2, y = 22}, -- 589
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295}) -- 589
					) -- 589
				}, -- 589
				React.createElement("label", { -- 589
					tag = "remix-title", -- 589
					x = 0, -- 589
					y = 22, -- 589
					anchorX = 0, -- 589
					fontName = fontName, -- 589
					fontSize = 20, -- 589
					text = "REMIX · " .. options.entry.title, -- 589
					color3 = 16052712 -- 589
				}) -- 589
			), -- 589
			React.createElement( -- 589
				"node", -- 589
				{ -- 589
					tag = "remix-back", -- 589
					x = headerBackX, -- 589
					y = headerY, -- 589
					width = backWidth, -- 589
					height = 44, -- 589
					anchorX = 0, -- 589
					anchorY = 0, -- 589
					touchEnabled = true, -- 589
					swallowTouches = true, -- 589
					onTapped = goBack -- 589
				}, -- 589
				React.createElement("label", { -- 589
					x = backWidth, -- 589
					y = 22, -- 589
					anchorX = 1, -- 589
					fontName = fontName, -- 589
					fontSize = 18, -- 589
					text = backText, -- 589
					color3 = 16763955 -- 589
				}) -- 589
			) -- 589
		) -- 589
		local ____React_createElement_38 = React.createElement -- 589
		local ____array_37 = __TS__SparseArrayNew( -- 589
			"node", -- 589
			{ -- 589
				tag = "remix-model-config", -- 589
				x = headerSettingsX, -- 589
				y = headerY + 6, -- 589
				width = modelButtonWidth, -- 589
				height = 32, -- 589
				anchorX = 0, -- 589
				anchorY = 0, -- 589
				touchEnabled = true, -- 589
				swallowTouches = true, -- 589
				onTapped = configureLLM -- 589
			}, -- 589
			React.createElement(RoundedSurface, { -- 589
				width = modelButtonWidth, -- 589
				height = 32, -- 589
				radius = 16, -- 589
				topColor = 858534978, -- 589
				bottomColor = 856824097, -- 589
				borderWidth = 1, -- 589
				borderColor = needsLLMSetup and colors.brand or colors.border -- 589
			}), -- 589
			React.createElement("label", { -- 589
				x = modelButtonWidth / 2, -- 589
				y = 16, -- 589
				fontName = fontName, -- 589
				fontSize = 11, -- 589
				text = modelLabel, -- 589
				color3 = (needsLLMSetup or switchPending) and 16763955 or 11055037 -- 589
			}) -- 589
		) -- 589
		local ____needsLLMSetup_36 -- 626
		if needsLLMSetup then -- 626
			____needsLLMSetup_36 = React.createElement( -- 626
				"draw-node", -- 626
				{x = modelButtonWidth - 4, y = 28}, -- 626
				React.createElement("dot-shape", {radius = 3, color = 4294954035}) -- 626
			) -- 626
		else -- 626
			____needsLLMSetup_36 = nil -- 626
		end -- 626
		__TS__SparseArrayPush(____array_37, ____needsLLMSetup_36) -- 626
		__TS__SparseArrayPush( -- 626
			____array_66, -- 626
			____React_createElement_38(__TS__SparseArraySpread(____array_37)), -- 626
			React.createElement( -- 626
				"node", -- 626
				{ -- 626
					tag = "remix-status", -- 626
					x = compactHeaderStatus and headerStatusX or 0, -- 626
					y = compactHeaderStatus and headerY or messageTop - statusHeight / 2, -- 626
					width = compactHeaderStatus and headerStatusWidth or width, -- 626
					height = compactHeaderStatus and 44 or statusHeight, -- 626
					anchorX = 0, -- 626
					anchorY = 0 -- 626
				}, -- 626
				React.createElement(DoraMascot, { -- 626
					state = mascotState, -- 626
					x = compactHeaderStatus and 16 or mascotX, -- 626
					y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, -- 626
					size = compactHeaderStatus and 30 or mascotSize, -- 626
					animationStartedAt = mascotAnimationStartedAt -- 626
				}), -- 626
				React.createElement( -- 626
					"clip-node", -- 626
					{ -- 626
						tag = "remix-status-clip", -- 626
						x = renderedStatusX, -- 626
						y = renderedStatusY - 22, -- 626
						width = renderedStatusWidth, -- 626
						height = 44, -- 626
						anchorX = 0, -- 626
						anchorY = 0, -- 626
						stencil = React.createElement( -- 626
							"draw-node", -- 626
							{x = renderedStatusWidth / 2, y = 22}, -- 626
							React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295}) -- 626
						) -- 626
					}, -- 626
					React.createElement( -- 626
						"label", -- 626
						{ -- 626
							tag = "remix-status-text", -- 626
							x = 0, -- 626
							y = 22, -- 626
							anchorX = 0, -- 626
							fontName = fontName, -- 626
							fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale), -- 626
							text = statusText, -- 626
							textWidth = -1, -- 626
							alignment = "Left", -- 626
							color3 = phase == "failed" and 16739179 or 16763955 -- 626
						} -- 626
					), -- 626
					React.createElement("label", { -- 626
						tag = "remix-thinking-text", -- 626
						x = 0, -- 626
						y = 6, -- 626
						anchorX = 0, -- 626
						fontName = fontName, -- 626
						fontSize = thinkingFontSize, -- 626
						text = renderedThinkingText, -- 626
						textWidth = -1, -- 626
						alignment = "Left", -- 626
						color3 = colors.muted -- 626
					}) -- 626
				) -- 626
			) -- 626
		) -- 626
		local ____temp_47 -- 642
		if questionnaire and question then -- 642
			local ____React_createElement_46 = React.createElement -- 642
			local ____array_45 = __TS__SparseArrayNew( -- 642
				"node", -- 642
				{ -- 642
					tag = "remix-questionnaire", -- 642
					x = left + 16, -- 642
					y = bottom + 164, -- 642
					width = contentWidth, -- 642
					height = questionCardHeight, -- 642
					anchorX = 0, -- 642
					anchorY = 0 -- 642
				}, -- 642
				React.createElement(RoundedSurface, { -- 642
					width = contentWidth, -- 642
					height = questionCardHeight, -- 642
					radius = 20, -- 642
					topColor = 4280429370, -- 642
					bottomColor = 4279375648, -- 642
					borderWidth = 1, -- 642
					borderColor = 4282469213, -- 642
					shadow = true -- 642
				}), -- 642
				React.createElement( -- 642
					"label", -- 642
					{ -- 642
						x = 16, -- 642
						y = questionCardHeight - 30, -- 642
						anchorX = 0, -- 642
						fontName = fontName, -- 642
						fontSize = 13, -- 642
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 642
						textWidth = contentWidth - 32, -- 642
						alignment = "Left", -- 642
						color3 = 16763955 -- 642
					} -- 642
				), -- 642
				React.createElement("label", { -- 642
					tag = "remix-question-prompt", -- 642
					x = 16, -- 642
					y = questionCardHeight - 75, -- 642
					anchorX = 0, -- 642
					fontName = fontName, -- 642
					fontSize = 16, -- 642
					text = question.prompt, -- 642
					textWidth = questionPromptWidth, -- 642
					alignment = "Left", -- 642
					color3 = 16052712 -- 642
				}), -- 642
				question.type ~= "text" and __TS__ArrayMap( -- 646
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 646
					function(____, option, optionIndex) return React.createElement( -- 646
						ChoiceButton, -- 646
						{ -- 646
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 646
							x = 16, -- 646
							y = questionAnswerTop - 40 - optionIndex * 43, -- 646
							width = contentWidth - 32, -- 646
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 646
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 646
							onTapped = function() -- 646
								local selected = questionnaireSelections[question.id] or ({}) -- 652
								local ____question_id_42 = question.id -- 653
								local ____temp_41 -- 653
								if question.type == "single_choice" then -- 653
									____temp_41 = {option.id} -- 654
								else -- 654
									local ____temp_40 -- 655
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 655
										____temp_40 = __TS__ArrayFilter( -- 655
											selected, -- 655
											function(____, id) return id ~= option.id end -- 655
										) -- 655
									else -- 655
										local ____array_39 = __TS__SparseArrayNew(table.unpack(selected)) -- 655
										__TS__SparseArrayPush(____array_39, option.id) -- 655
										____temp_40 = {__TS__SparseArraySpread(____array_39)} -- 655
									end -- 655
									____temp_41 = ____temp_40 -- 655
								end -- 655
								questionnaireSelections[____question_id_42] = ____temp_41 -- 653
								render() -- 656
							end -- 651
						} -- 651
					) end -- 651
				) or React.createElement("node", { -- 651
					tag = "remix-question-input", -- 651
					ref = inputRef, -- 651
					x = 16, -- 651
					y = questionAnswerTop - 92, -- 651
					width = contentWidth - 32, -- 651
					height = 92, -- 651
					anchorX = 0, -- 651
					anchorY = 0, -- 651
					onMount = promptInput.mount -- 651
				}) -- 651
			) -- 651
			local ____questionHasBack_43 -- 660
			if questionHasBack then -- 660
				____questionHasBack_43 = React.createElement( -- 660
					ActionButton, -- 660
					{ -- 660
						tag = "remix-question-back", -- 660
						x = 16, -- 660
						y = 12, -- 660
						width = questionBackWidth, -- 660
						text = zh and "上一步" or "Back", -- 660
						onTapped = function() -- 660
							questionIndex = questionIndex - 1 -- 660
							render() -- 660
						end -- 660
					} -- 660
				) -- 660
			else -- 660
				____questionHasBack_43 = nil -- 660
			end -- 660
			__TS__SparseArrayPush(____array_45, ____questionHasBack_43) -- 660
			local ____questionCanSkip_44 -- 661
			if questionCanSkip then -- 661
				____questionCanSkip_44 = React.createElement( -- 661
					ActionButton, -- 661
					{ -- 661
						tag = "remix-question-skip", -- 661
						x = questionSkipX, -- 661
						y = 12, -- 661
						width = questionSkipWidth, -- 661
						text = zh and "跳过" or "Skip", -- 661
						onTapped = function() return advanceQuestionnaire(true) end -- 661
					} -- 661
				) -- 661
			else -- 661
				____questionCanSkip_44 = nil -- 661
			end -- 661
			__TS__SparseArrayPush( -- 661
				____array_45, -- 661
				____questionCanSkip_44, -- 661
				React.createElement( -- 661
					ActionButton, -- 662
					{ -- 662
						tag = "remix-question-submit", -- 662
						x = questionSubmitX, -- 662
						y = 12, -- 662
						width = contentWidth - questionSubmitX - 16, -- 662
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 662
						primary = true, -- 662
						onTapped = function() -- 662
							if not dismissedComposition then -- 662
								advanceQuestionnaire() -- 664
							end -- 664
							dismissedComposition = false -- 664
						end -- 664
					} -- 664
				) -- 664
			) -- 664
			____temp_47 = ____React_createElement_46(__TS__SparseArraySpread(____array_45)) -- 664
		else -- 664
			____temp_47 = nil -- 665
		end -- 665
		__TS__SparseArrayPush(____array_66, ____temp_47) -- 665
		local ____temp_48 -- 666
		if visibleError ~= "" then -- 666
			____temp_48 = React.createElement( -- 666
				"label", -- 666
				{ -- 666
					tag = "remix-error", -- 666
					x = left + 20, -- 666
					y = bottom + (questionnaire and 144 or layoutComposerTop + composerGap), -- 666
					anchorX = 0, -- 666
					anchorY = 0, -- 666
					fontName = fontName, -- 666
					fontSize = 13, -- 666
					text = visibleError, -- 666
					textWidth = contentWidth, -- 666
					alignment = "Left", -- 666
					color3 = 16739179, -- 666
					onMount = function(label) -- 666
						errorLabel = label -- 666
					end -- 666
				} -- 666
			) -- 666
		else -- 666
			____temp_48 = nil -- 666
		end -- 666
		__TS__SparseArrayPush(____array_66, ____temp_48) -- 666
		local ____temp_49 -- 667
		if questionnaire == nil then -- 667
			____temp_49 = React.createElement( -- 667
				"node", -- 667
				nil, -- 667
				React.createElement( -- 667
					ChoiceButton, -- 668
					{ -- 668
						tag = "remix-mode-plan", -- 668
						x = modeStartX, -- 668
						y = bottom + layoutModeBottom, -- 668
						width = modeWidth, -- 668
						text = zh and "计划" or "Plan", -- 668
						selected = workMode == "plan", -- 668
						disabled = not canSubmit(), -- 668
						onTapped = function() return changeWorkMode("plan") end -- 668
					} -- 668
				), -- 668
				React.createElement( -- 668
					ChoiceButton, -- 669
					{ -- 669
						tag = "remix-mode-code", -- 669
						x = modeStartX + modeWidth + composerGap, -- 669
						y = bottom + layoutModeBottom, -- 669
						width = modeCodeWidth, -- 669
						text = zh and "执行" or "Code", -- 669
						selected = workMode == "code", -- 669
						disabled = not canSubmit(), -- 669
						onTapped = function() return changeWorkMode("code") end -- 669
					} -- 669
				) -- 669
			) -- 669
		else -- 669
			____temp_49 = nil -- 670
		end -- 670
		__TS__SparseArrayPush(____array_66, ____temp_49) -- 670
		local ____temp_50 -- 671
		if questionnaire == nil and not keptInput then -- 671
			____temp_50 = React.createElement("node", { -- 671
				tag = "remix-input", -- 671
				ref = inputRef, -- 671
				x = left + 16, -- 671
				y = bottom + layoutComposerBottom, -- 671
				width = inputWidth, -- 671
				height = layoutComposerHeight, -- 671
				anchorX = 0, -- 671
				anchorY = 0, -- 671
				onMount = promptInput.mount -- 671
			}) -- 671
		else -- 671
			____temp_50 = nil -- 672
		end -- 672
		__TS__SparseArrayPush(____array_66, ____temp_50) -- 672
		local ____temp_63 -- 673
		if stopping or questionnaire == nil then -- 673
			local ____React_createElement_62 = React.createElement -- 673
			local ____ActionButton_61 = ActionButton -- 673
			local ____temp_56 = stopping and "remix-stop" or "remix-send" -- 673
			local ____temp_57 = left + 16 + inputWidth + composerGap -- 674
			local ____temp_58 = bottom + layoutComposerBottom -- 674
			local ____temp_59 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 675
			local ____temp_60 = not stopping -- 676
			local ____stopping_55 -- 676
			if stopping then -- 676
				____stopping_55 = stopRequested or (state and state.currentTaskFinalizing) == true -- 676
			else -- 676
				____stopping_55 = not canSubmit() -- 676
			end -- 676
			____temp_63 = ____React_createElement_62( -- 676
				____ActionButton_61, -- 673
				{ -- 673
					tag = ____temp_56, -- 673
					x = ____temp_57, -- 673
					y = ____temp_58, -- 673
					width = composerActionWidth, -- 673
					height = layoutComposerHeight, -- 673
					text = ____temp_59, -- 673
					primary = ____temp_60, -- 673
					danger = stopping, -- 673
					disabled = ____stopping_55, -- 673
					onTapped = function() -- 673
						if stopping then -- 673
							stop() -- 677
						elseif not dismissedComposition then -- 677
							send() -- 677
						end -- 677
						dismissedComposition = false -- 677
					end -- 677
				} -- 677
			) -- 677
		else -- 677
			____temp_63 = nil -- 677
		end -- 677
		__TS__SparseArrayPush(____array_66, ____temp_63) -- 677
		local ____temp_64 -- 678
		if phase == "done" and canShare then -- 678
			____temp_64 = React.createElement( -- 678
				ActionButton, -- 678
				{ -- 678
					tag = "remix-share", -- 678
					x = left + 16, -- 678
					y = bottom + layoutModeBottom + 48, -- 678
					width = playWidth, -- 678
					height = 40, -- 678
					text = zh and "分享作品" or "Share game", -- 678
					onTapped = function() -- 678
						if not host.visible or packagePanel or HttpServer.wsConnectionCount > 0 then -- 678
							return -- 679
						end -- 679
						blurInput() -- 680
						notifyProjectChanged() -- 680
						packagePanel = startPackagePanel({ -- 681
							mode = "share", -- 681
							entry = options.entry, -- 681
							onClosed = function() -- 681
								packagePanel = nil -- 681
							end -- 681
						}) -- 681
					end -- 678
				} -- 678
			) -- 678
		else -- 678
			____temp_64 = nil -- 682
		end -- 682
		__TS__SparseArrayPush(____array_66, ____temp_64) -- 682
		local ____temp_65 -- 683
		if phase == "done" then -- 683
			____temp_65 = React.createElement( -- 683
				ActionButton, -- 683
				{ -- 683
					tag = "remix-play", -- 683
					x = playX, -- 683
					y = bottom + layoutModeBottom + 48, -- 683
					width = playWidth, -- 683
					height = 40, -- 683
					text = zh and "立即试玩" or "Play now", -- 683
					primary = true, -- 683
					onTapped = function() -- 683
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 683
							return -- 683
						end -- 683
						blurInput() -- 683
						notifyProjectChanged() -- 683
						host.visible = false -- 683
						onPlay(options.entry) -- 683
					end -- 683
				} -- 683
			) -- 683
		else -- 683
			____temp_65 = nil -- 683
		end -- 683
		__TS__SparseArrayPush(____array_66, ____temp_65) -- 683
		__TS__SparseArrayPush( -- 683
			____array_68, -- 683
			____React_createElement_67(__TS__SparseArraySpread(____array_66)) -- 683
		) -- 683
		local scene = ____toNode_70(____React_createElement_69(__TS__SparseArraySpread(____array_68))) -- 560
		if scene then -- 560
			host:addChild(scene) -- 687
			if keptInput then -- 687
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom) -- 689
				keptInput.width = inputWidth -- 690
				keptInput.height = layoutComposerHeight -- 691
				local ____opt_71 = pageRef.current -- 691
				if ____opt_71 ~= nil then -- 691
					____opt_71:addChild(keptInput) -- 692
				end -- 692
			end -- 692
			if not questionnaire then -- 692
				transcript.node.position = Vec2( -- 695
					left + 16, -- 695
					bottom + getTranscriptBottom() -- 695
				) -- 695
				local ____opt_73 = pageRef.current -- 695
				if ____opt_73 ~= nil then -- 695
					____opt_73:addChild(transcript.node) -- 696
				end -- 696
				updateTranscript() -- 697
			end -- 697
		end -- 697
		if restoreInputFocus and inputRef.current and not keptInput then -- 697
			promptInput.focus(false) -- 700
		end -- 700
		if keptInput then -- 700
			promptInput.refresh() -- 701
		end -- 701
		shellRevision = getShellRevision() -- 702
		displayRevision = remixDisplayRevision(detail) -- 703
	end -- 421
	attachGamepad( -- 706
		host, -- 706
		{ -- 706
			initialTag = "remix-input", -- 707
			onBack = function() -- 708
				if promptInput.isFocused() then -- 708
					blurInput() -- 708
				else -- 708
					goBack() -- 708
				end -- 708
			end, -- 708
			onScroll = function(amount) return transcript:scrollBy(amount) end, -- 709
			onActivate = function(target) -- 710
				if target.tag == "remix-input" or target.tag == "remix-question-input" then -- 710
					target:emit("GamepadActivate") -- 711
				else -- 711
					if promptInput.isComposing() then -- 711
						blurInput() -- 713
						return -- 713
					end -- 713
					blurInput() -- 714
					dismissedComposition = false -- 715
					target:emit("Tapped") -- 716
				end -- 716
			end -- 710
		} -- 710
	) -- 710
	host:schedule(function(dt) -- 720
		pollElapsed = pollElapsed + dt -- 721
		if pollElapsed < 0.25 then -- 721
			return false -- 722
		end -- 722
		pollElapsed = 0 -- 723
		refresh() -- 724
		if swipeDragging or swipeBackPending then -- 724
			return false -- 725
		end -- 725
		if backNoticeUntil > 0 and App.runningTime >= backNoticeUntil then -- 725
			backNoticeUntil = 0 -- 727
			render() -- 728
			return false -- 729
		end -- 729
		local next = remixDisplayRevision(detail) -- 731
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then -- 731
			render() -- 732
		elseif displayRevision ~= next then -- 732
			updateTranscript() -- 733
		end -- 733
		return false -- 734
	end) -- 720
	host:onAppChange(function(setting) -- 736
		if setting == "Locale" then -- 736
			zh = (string.match(App.locale, "^zh")) ~= nil -- 737
		end -- 737
		if setting == "Size" or setting == "Locale" then -- 737
			render() -- 738
		end -- 738
	end) -- 736
	host:onAppEvent(function(event) -- 740
		if event == "BackButton" then -- 740
			if promptInput.isFocused() then -- 740
				blurInput() -- 741
			else -- 741
				goBack() -- 741
			end -- 741
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 741
			blurInput() -- 742
		end -- 742
	end) -- 740
	host:onCleanup(function() -- 744
		if packagePanel ~= nil then -- 744
			packagePanel:removeFromParent(true) -- 745
		end -- 745
		packagePanel = nil -- 746
		disposed = true -- 747
		blurInput() -- 747
	end) -- 744
	host:slot("SuspendLocalUI", blurInput) -- 749
	host:slot( -- 750
		"ResumeLocalUI", -- 750
		function() -- 750
			refresh() -- 750
			render() -- 750
		end -- 750
	) -- 750
	render() -- 751
	if needsLLMSetup then -- 751
		thread(function() -- 752
			sleep(0) -- 752
			if not disposed and host.parent then -- 752
				configureLLM() -- 752
			end -- 752
		end) -- 752
	end -- 752
	return host -- 753
end -- 118
return ____exports -- 118