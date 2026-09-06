-- [ts]: RemixTranscript.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayPushArray = ____lualib.__TS__ArrayPushArray -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Color3 = ____Dora.Color3 -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 2
local ____Utils = require("Agent.Utils") -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local ____RemixModel = require("Dev.Mobile.RemixModel") -- 5
local compactAgentActivity = ____RemixModel.compactAgentActivity -- 5
local ____LightMarkdown = require("Dev.Mobile.LightMarkdown") -- 6
local parseLightMarkdown = ____LightMarkdown.parseLightMarkdown -- 6
local ____RemixHistory = require("Dev.Mobile.RemixHistory") -- 7
local remixHistory = ____RemixHistory.remixHistory -- 7
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS -- 7
local ____VisionAssets = require("Agent.Tool.VisionAssets") -- 8
local readSessionVisionAsset = ____VisionAssets.readSessionVisionAsset -- 8
local visionAssetPath = ____VisionAssets.visionAssetPath -- 8
local font = "sarasa-mono-sc-regular" -- 22
function ____exports.remixDisplayRevision(detail) -- 25
	if not detail.success then -- 25
		return detail.message -- 26
	end -- 26
	local history = remixHistory(detail) -- 27
	return (safeJsonEncode({ -- 28
		status = detail.session.status, -- 29
		mode = detail.session.workMode, -- 29
		plan = detail.hasActivePlan, -- 29
		finalizing = detail.session.currentTaskFinalizing, -- 30
		questionnaire = detail.pendingQuestionnaire, -- 30
		currentTaskId = detail.session.currentTaskId, -- 31
		currentTaskStatus = detail.session.currentTaskStatus, -- 31
		hasEarlierMessages = history.hasEarlierMessages, -- 32
		messages = __TS__ArrayMap( -- 33
			history.messages, -- 33
			function(____, m) return {m.id, m.taskId or 0, m.role, m.displayContent or m.content} end -- 33
		), -- 33
		steps = __TS__ArrayMap( -- 34
			history.steps, -- 34
			function(____, s) -- 34
				local ____array_12 = __TS__SparseArrayNew(s.id, s.tool, s.status, s.reason) -- 34
				local ____opt_0 = s.result -- 34
				__TS__SparseArrayPush(____array_12, ____opt_0 and ____opt_0.progress) -- 34
				local ____opt_2 = s.result -- 34
				__TS__SparseArrayPush(____array_12, ____opt_2 and ____opt_2.stage) -- 34
				local ____opt_4 = s.result -- 34
				__TS__SparseArrayPush(____array_12, ____opt_4 and ____opt_4.message) -- 34
				local ____opt_6 = s.result -- 34
				__TS__SparseArrayPush(____array_12, ____opt_6 and ____opt_6.assets) -- 34
				local ____opt_8 = s.result -- 34
				__TS__SparseArrayPush(____array_12, ____opt_8 and ____opt_8.report) -- 34
				local ____opt_10 = s.result -- 34
				__TS__SparseArrayPush(____array_12, ____opt_10 and ____opt_10.model) -- 34
				return {__TS__SparseArraySpread(____array_12)} -- 34
			end -- 34
		) -- 34
	})) or "" -- 34
end -- 25
local function itemsFor(detail, zh, actions) -- 38
	if not detail.success then -- 38
		return {} -- 39
	end -- 39
	local items = {} -- 40
	local history = remixHistory(detail) -- 41
	if history.hasEarlierMessages then -- 41
		items[#items + 1] = { -- 42
			id = "remix-history-limit", -- 42
			title = zh and "历史记录" or "History", -- 42
			text = zh and ("仅展示最近 " .. tostring(REMIX_HISTORY_ROUNDS)) .. " 轮，更早记录可在 Web IDE 查看。" or ("Showing the latest " .. tostring(REMIX_HISTORY_ROUNDS)) .. " rounds. View earlier messages in Web IDE.", -- 43
			user = false, -- 44
			activity = true -- 44
		} -- 44
	end -- 44
	local activities = __TS__ArrayMap( -- 45
		history.steps, -- 45
		function(____, s) -- 45
			local state = s.status == "DONE" and (zh and "已完成" or "Done") or (s.status == "FAILED" and (zh and "失败" or "Failed") or (s.status == "STOPPED" and (zh and "已停止" or "Stopped") or (s.status == "PENDING" and (zh and "等待中" or "Pending") or (zh and "进行中" or "Working")))) -- 46
			local ____temp_15 = s.status == "RUNNING" -- 50
			if ____temp_15 then -- 50
				local ____opt_13 = s.result -- 50
				____temp_15 = type(____opt_13 and ____opt_13.progress) == "number" -- 50
			end -- 50
			local progress = ____temp_15 and (" · " .. tostring(math.floor(s.result.progress * 100))) .. "%" or "" -- 50
			local vision = s.tool == "preview_game" or s.tool == "analyze_image" -- 51
			local ____temp_18 = s.status == "RUNNING" or vision -- 52
			if ____temp_18 then -- 52
				local ____opt_16 = s.result -- 52
				____temp_18 = type(____opt_16 and ____opt_16.message) == "string" -- 52
			end -- 52
			local message = ____temp_18 and s.result.message or "" -- 52
			local ____vision_21 = vision -- 53
			if ____vision_21 then -- 53
				local ____opt_19 = s.result -- 53
				____vision_21 = type(____opt_19 and ____opt_19.report) == "string" -- 53
			end -- 53
			local report = ____vision_21 and s.result.report or "" -- 53
			local ____vision_24 = vision -- 54
			if ____vision_24 then -- 54
				local ____opt_22 = s.result -- 54
				____vision_24 = type(____opt_22 and ____opt_22.model) == "string" -- 54
			end -- 54
			local model = ____vision_24 and s.result.model or "" -- 54
			local ____vision_28 = vision -- 55
			if ____vision_28 then -- 55
				local ____type_27 = type -- 55
				local ____opt_25 = s.result -- 55
				____vision_28 = ____type_27(____opt_25 and ____opt_25.assets) == "table" -- 55
			end -- 55
			local assets = ____vision_28 and s.result.assets or ({}) -- 55
			local assetIds = __TS__ArrayMap( -- 56
				__TS__ArraySlice( -- 56
					__TS__ArrayFilter( -- 56
						assets, -- 56
						function(____, a) return type(a.assetId) == "string" end -- 56
					), -- 56
					0, -- 56
					3 -- 56
				), -- 56
				function(____, a) return a.assetId end -- 56
			) -- 56
			local title = compactAgentActivity(s.tool, "", zh, s.status == "RUNNING") -- 57
			return { -- 58
				id = "step-" .. tostring(s.id), -- 58
				title = ((state .. progress) .. " · ") .. title, -- 58
				text = ((s.reason .. (message ~= "" and "\n" .. message or "")) .. (model ~= "" and (("\n" .. (zh and "看图模型" or "Vision model")) .. ": ") .. model or "")) .. (report ~= "" and "\n" .. report or ""), -- 59
				sessionId = s.sessionId, -- 60
				assetIds = assetIds, -- 60
				user = false, -- 60
				activity = true -- 60
			} -- 60
		end -- 45
	) -- 45
	local inserted = false -- 62
	for ____, m in ipairs(history.messages) do -- 63
		if not inserted and m.role == "assistant" and m.taskId == detail.session.currentTaskId then -- 63
			__TS__ArrayPushArray(items, activities) -- 66
			inserted = true -- 66
		end -- 66
		items[#items + 1] = { -- 68
			id = "message-" .. tostring(m.id), -- 68
			title = m.role == "user" and (zh and "你" or "You") or "Dora", -- 68
			text = m.displayContent or m.content, -- 69
			user = m.role == "user", -- 69
			activity = false -- 69
		} -- 69
	end -- 69
	if not inserted then -- 69
		__TS__ArrayPushArray(items, activities) -- 71
	end -- 71
	if #actions > 0 then -- 71
		items[#items + 1] = { -- 72
			id = "remix-terminal-actions", -- 72
			title = "", -- 72
			text = "", -- 72
			user = false, -- 72
			activity = true, -- 72
			actions = actions -- 72
		} -- 72
	end -- 72
	return items -- 73
end -- 38
local function drawCapsule(target, width, height, color, inset) -- 76
	if inset == nil then -- 76
		inset = 0 -- 76
	end -- 76
	local radius = height / 2 - inset -- 77
	local left = height / 2 -- 78
	local right = width - height / 2 -- 79
	target:drawPolygon( -- 80
		{ -- 80
			Vec2(left, inset), -- 80
			Vec2(right, inset), -- 80
			Vec2(right, height - inset), -- 80
			Vec2(left, height - inset) -- 80
		}, -- 80
		Color(color) -- 80
	) -- 80
	target:drawDot( -- 81
		Vec2(left, height / 2), -- 81
		radius, -- 81
		Color(color) -- 81
	) -- 81
	target:drawDot( -- 82
		Vec2(right, height / 2), -- 82
		radius, -- 82
		Color(color) -- 82
	) -- 82
end -- 76
local function makeActionRow(actions, width, scale) -- 85
	local card = Node() -- 86
	card.tag = "remix-terminal-actions" -- 87
	card.anchor = Vec2(0, 1) -- 88
	card.width = width -- 89
	card.height = 44 -- 90
	local gap = 10 -- 91
	local buttonWidth = #actions > 1 and math.min((width - gap) / 2, 184) or math.min(width, 184) -- 92
	do -- 92
		local i = 0 -- 93
		while i < #actions do -- 93
			local action = actions[i + 1] -- 94
			local button = Node() -- 95
			button.tag = "remix-action-" .. action.id -- 96
			button.anchor = Vec2.zero -- 97
			button.position = Vec2(i * (buttonWidth + gap), 3) -- 98
			button.size = Size(buttonWidth, 38) -- 99
			button.touchEnabled = true -- 100
			button.swallowTouches = true -- 101
			button:onTapped(action.onTapped) -- 102
			local bg = DrawNode() -- 103
			if action.primary then -- 103
				drawCapsule(bg, buttonWidth, 38, 4294954035) -- 104
			else -- 104
				drawCapsule(bg, buttonWidth, 38, 4282798180) -- 106
				drawCapsule( -- 107
					bg, -- 107
					buttonWidth, -- 107
					38, -- 107
					4279704614, -- 107
					1 -- 107
				) -- 107
			end -- 107
			button:addChild(bg) -- 109
			local label = Label( -- 110
				font, -- 110
				math.floor(14 * scale), -- 110
				true -- 110
			) -- 110
			if label then -- 110
				label.position = Vec2(buttonWidth / 2, 19) -- 112
				label.color3 = Color3(action.primary and 1512202 or 16052712) -- 113
				label.text = action.text -- 114
				button:addChild(label) -- 115
			end -- 115
			card:addChild(button) -- 117
			i = i + 1 -- 93
		end -- 93
	end -- 93
	return card -- 119
end -- 85
local function makeCard(item, width, scale, zh) -- 122
	if item.actions then -- 122
		return makeActionRow(item.actions, width, scale) -- 123
	end -- 123
	local card = Node() -- 124
	card.tag = item.id -- 125
	card.anchor = Vec2(0, 1) -- 126
	card.width = width -- 127
	local labels = {} -- 128
	local images = {} -- 129
	local top = 12 -- 130
	local function add(text, size, color) -- 131
		local l = Label( -- 132
			font, -- 132
			math.floor(size * scale), -- 132
			true -- 132
		) -- 132
		if not l then -- 132
			return -- 133
		end -- 133
		l.anchor = Vec2(0, 1) -- 134
		l.x = 14 -- 134
		l.textWidth = math.max(20, width - 28) -- 134
		l.alignment = "Left" -- 135
		l.lineGap = 4 -- 135
		l.color3 = Color3(color) -- 135
		l.text = text -- 135
		labels[#labels + 1] = {label = l, top = top} -- 136
		top = top + (l.height + 8) -- 136
	end -- 131
	add(item.title, 13, (item.user or item.activity) and 16763955 or 11055037) -- 138
	for ____, block in ipairs(parseLightMarkdown(item.text)) do -- 139
		add(block.text, block.kind == "heading1" and 17 or (block.kind == "heading2" and 16 or 14), block.kind == "code" and 16763955 or 16052712) -- 140
	end -- 140
	local enlarged -- 143
	card:onCleanup(function() -- 144
		if enlarged ~= nil then -- 144
			enlarged:removeFromParent(true) -- 144
		end -- 144
		enlarged = nil -- 144
	end) -- 144
	for ____, assetId in ipairs(item.assetIds or ({})) do -- 145
		do -- 145
			local function ____catch(_) -- 145
				add(zh and "截图不可用或已清理" or "Capture unavailable or removed", 13, 11055037) -- 175
			end -- 175
			local ____try, ____hasReturned = pcall(function() -- 175
				readSessionVisionAsset(item.sessionId or 0, assetId) -- 147
				local picture = Sprite(visionAssetPath(assetId)) -- 148
				if not picture then -- 148
					error("Image unavailable") -- 149
				end -- 149
				local factor = math.min((width - 28) / picture.width, 160 / picture.height) -- 150
				picture.scaleX = factor -- 151
				picture.scaleY = factor -- 151
				picture.anchor = Vec2(0, 1) -- 152
				picture.x = 14 -- 152
				picture.touchEnabled = true -- 153
				picture:onTapped(function() -- 154
					if enlarged ~= nil then -- 154
						enlarged:removeFromParent(true) -- 155
					end -- 155
					local toolRoot = card -- 158
					while toolRoot.parent and toolRoot.parent ~= Director.systemUI do -- 158
						toolRoot = toolRoot.parent -- 159
					end -- 159
					local overlay = Node() -- 160
					enlarged = overlay -- 160
					overlay.tag = "remix-vision-enlarged" -- 161
					overlay.order = 10000 -- 161
					overlay.size = App.visualSize -- 162
					overlay.touchEnabled = true -- 162
					overlay.swallowTouches = true -- 162
					local ____App_visualSize_33 = App.visualSize -- 163
					local w = ____App_visualSize_33.width -- 163
					local h = ____App_visualSize_33.height -- 163
					local shade = DrawNode() -- 164
					shade:drawPolygon( -- 165
						{ -- 165
							Vec2.zero, -- 165
							Vec2(w, 0), -- 165
							Vec2(w, h), -- 165
							Vec2(0, h) -- 165
						}, -- 165
						Color(4111537436) -- 165
					) -- 165
					overlay:addChild(shade) -- 166
					local full = Sprite(visionAssetPath(assetId)) -- 167
					if full then -- 167
						local s = math.min((w - 24) / full.width, (h - 72) / full.height) -- 168
						full.scaleX = s -- 168
						full.scaleY = s -- 168
						full.position = Vec2(w / 2, h / 2) -- 168
						overlay:addChild(full) -- 168
					end -- 168
					local close = Label(font, 14, true) -- 169
					if close then -- 169
						close.text = zh and "点击关闭" or "Tap to close" -- 170
						close.position = Vec2(w / 2, h - 28) -- 170
						overlay:addChild(close) -- 170
					end -- 170
					overlay:onTapped(function() -- 171
						overlay:removeFromParent(true) -- 171
						enlarged = nil -- 171
					end) -- 171
					overlay:addTo(toolRoot) -- 172
				end) -- 154
				images[#images + 1] = {node = picture, top = top} -- 174
				top = top + (picture.height * factor + 8) -- 174
			end) -- 174
			if not ____try then -- 174
				____catch(____hasReturned) -- 174
			end -- 174
		end -- 174
	end -- 174
	if not item.user and not item.activity then -- 174
		add(zh and "复制全文" or "Copy message", 13, 16763955) -- 178
		local ____opt_34 = labels[#labels] -- 178
		local copy = ____opt_34 and ____opt_34.label -- 179
		if copy ~= nil then -- 179
			copy.tag = "remix-copy" -- 180
			copy.touchEnabled = true -- 180
			copy:onTapped(function() return App:setClipboardText(item.text) end) -- 180
		end -- 180
	end -- 180
	card.height = top + 4 -- 182
	local bg = DrawNode() -- 183
	bg:drawPolygon( -- 184
		{ -- 184
			Vec2.zero, -- 184
			Vec2(width, 0), -- 184
			Vec2(width, card.height), -- 184
			Vec2(0, card.height) -- 184
		}, -- 184
		Color(item.user and 4280297010 or 4279704614), -- 185
		1, -- 185
		Color(4281613128) -- 185
	) -- 185
	card:addChild(bg) -- 186
	for ____, row in ipairs(labels) do -- 187
		row.label.y = card.height - row.top -- 187
		card:addChild(row.label) -- 187
	end -- 187
	for ____, row in ipairs(images) do -- 188
		row.node.y = card.height - row.top -- 188
		card:addChild(row.node) -- 188
	end -- 188
	return card -- 189
end -- 122
function ____exports.createRemixTranscript() -- 192
	local node = Node() -- 193
	node.tag = "remix-transcript" -- 193
	node.anchor = Vec2.zero -- 193
	local scroll = ScrollArea({ -- 194
		width = 1, -- 194
		height = 1, -- 194
		paddingX = 0, -- 194
		paddingY = 40, -- 194
		scrollBar = false -- 194
	}) -- 194
	scroll.tag = "remix-scroll" -- 195
	scroll:addTo(node) -- 195
	local latest = Label(font, 14, true) -- 196
	latest.tag = "remix-latest" -- 197
	latest.color3 = Color3(16763955) -- 197
	latest.touchEnabled = true -- 197
	local hintBackground = DrawNode() -- 198
	hintBackground.order = 1 -- 198
	hintBackground:addTo(node) -- 198
	latest.order = 2 -- 199
	latest:addTo(node) -- 200
	local width = 1 -- 201
	local height = 1 -- 201
	local scale = 1 -- 201
	local zh = true -- 201
	local total = 0 -- 201
	local following = true -- 202
	local touching = false -- 202
	local layingOut = false -- 202
	local unread = false -- 202
	local rows = {} -- 203
	local function maxOffset() -- 204
		return math.max(0, total - height) -- 204
	end -- 204
	local function updateHint() -- 205
		latest.visible = unread and not following -- 206
		latest.text = zh and "有新内容 · 回到最新 ↓" or "New activity · Latest ↓" -- 207
		hintBackground.visible = latest.visible -- 208
		hintBackground:clear() -- 209
		local half = math.min(width / 2, latest.width / 2 + 10) -- 210
		hintBackground:drawPolygon( -- 211
			{ -- 211
				Vec2(width / 2 - half, 0), -- 211
				Vec2(width / 2 + half, 0), -- 211
				Vec2(width / 2 + half, 28), -- 211
				Vec2(width / 2 - half, 28) -- 211
			}, -- 211
			Color(4280297010) -- 211
		) -- 211
	end -- 205
	scroll:slot( -- 213
		"ScrollTouchBegan", -- 213
		function() -- 213
			touching = true -- 213
		end -- 213
	) -- 213
	scroll:slot( -- 214
		"ScrollTouchEnded", -- 214
		function() -- 214
			touching = false -- 214
			following = maxOffset() - scroll.offset.y <= 24 -- 214
			updateHint() -- 214
		end -- 214
	) -- 214
	scroll:slot( -- 215
		"Scrolled", -- 215
		function() -- 215
			if layingOut then -- 215
				return -- 216
			end -- 216
			following = maxOffset() - scroll.offset.y <= 24 -- 217
			if following then -- 217
				unread = false -- 218
			end -- 218
			updateHint() -- 219
		end -- 215
	) -- 215
	latest:onTapped(function() -- 221
		scroll:unschedule() -- 222
		touching = false -- 222
		following = true -- 222
		unread = false -- 222
		scroll.offset = Vec2( -- 223
			0, -- 223
			maxOffset() -- 223
		) -- 223
		updateHint() -- 223
	end) -- 221
	return { -- 225
		node = node, -- 226
		scrollBy = function(self, amount) -- 227
			scroll:unschedule() -- 228
			following = false -- 229
			scroll.offset = Vec2( -- 230
				0, -- 230
				math.max( -- 230
					0, -- 230
					math.min( -- 230
						maxOffset(), -- 230
						scroll.offset.y + amount -- 230
					) -- 230
				) -- 230
			) -- 230
			scroll.view:moveAndCullItems(Vec2.zero) -- 231
			following = maxOffset() - scroll.offset.y <= 24 -- 232
			if following then -- 232
				unread = false -- 233
			end -- 233
			updateHint() -- 234
		end, -- 227
		update = function(self, detail, w, h, fontScale, chinese, actions) -- 236
			if actions == nil then -- 236
				actions = {} -- 236
			end -- 236
			local anchor = __TS__ArrayFind( -- 237
				rows, -- 237
				function(____, row) return row.node.y > 0 and row.node.y - row.node.height < height end -- 237
			) -- 237
			local anchorY = anchor and anchor.node.y -- 238
			local oldOffset = scroll.offset.y -- 239
			local layoutChanged = width ~= w or height ~= h or scale ~= fontScale or zh ~= chinese -- 240
			width = w -- 241
			height = h -- 241
			scale = fontScale -- 241
			zh = chinese -- 241
			node.size = Size(width, height) -- 242
			scroll.position = Vec2(width / 2, height / 2) -- 242
			latest.position = Vec2(width / 2, 14) -- 243
			local previous = rows -- 244
			local changed = layoutChanged -- 245
			rows = __TS__ArrayMap( -- 246
				itemsFor(detail, zh, actions), -- 246
				function(____, item) -- 246
					local ____safeJsonEncode_47 = safeJsonEncode -- 247
					local ____item_id_40 = item.id -- 247
					local ____item_title_41 = item.title -- 247
					local ____item_text_42 = item.text -- 247
					local ____item_user_43 = item.user -- 247
					local ____item_activity_44 = item.activity -- 248
					local ____item_sessionId_45 = item.sessionId -- 248
					local ____item_assetIds_46 = item.assetIds -- 248
					local ____opt_38 = item.actions -- 248
					local signature = (____safeJsonEncode_47({ -- 247
						id = ____item_id_40, -- 247
						title = ____item_title_41, -- 247
						text = ____item_text_42, -- 247
						user = ____item_user_43, -- 247
						activity = ____item_activity_44, -- 248
						sessionId = ____item_sessionId_45, -- 248
						assetIds = ____item_assetIds_46, -- 248
						actions = ____opt_38 and __TS__ArrayMap( -- 248
							item.actions, -- 248
							function(____, action) return {action.id, action.text, action.primary == true} end -- 248
						) -- 248
					})) or "" -- 248
					local existing = __TS__ArrayFind( -- 249
						previous, -- 249
						function(____, row) return row.id == item.id end -- 249
					) -- 249
					if not layoutChanged and (existing and existing.signature) == signature then -- 249
						return existing -- 250
					end -- 250
					changed = true -- 251
					local card = makeCard(item, width, scale, zh) -- 252
					scroll.view:addChild(card) -- 252
					return {id = item.id, signature = signature, node = card} -- 253
				end -- 246
			) -- 246
			for ____, row in ipairs(previous) do -- 255
				if not __TS__ArraySome( -- 255
					rows, -- 255
					function(____, next) return next.node == row.node end -- 255
				) then -- 255
					row.node:removeFromParent(true) -- 255
					changed = true -- 255
				end -- 255
			end -- 255
			if not changed then -- 255
				return -- 256
			end -- 256
			layingOut = true -- 257
			scroll.offset = Vec2.zero -- 258
			total = 0 -- 259
			for ____, row in ipairs(rows) do -- 260
				row.node.position = Vec2(0, height - total) -- 260
				total = total + (row.node.height + 10) -- 260
			end -- 260
			if #rows > 0 then -- 260
				total = total - 10 -- 261
			end -- 261
			scroll:resetSize(width, height, width, total) -- 262
			local pinned = following and not touching -- 263
			local ____anchor_50 -- 264
			if anchor then -- 264
				____anchor_50 = __TS__ArrayFind( -- 264
					rows, -- 264
					function(____, row) return row.id == anchor.id end -- 264
				) -- 264
			else -- 264
				____anchor_50 = nil -- 264
			end -- 264
			local replacement = ____anchor_50 -- 264
			local offset = pinned and maxOffset() or (replacement and anchorY ~= nil and anchorY - replacement.node.y or oldOffset) -- 265
			scroll.offset = Vec2( -- 266
				0, -- 266
				math.max( -- 266
					0, -- 266
					math.min( -- 266
						maxOffset(), -- 266
						offset -- 266
					) -- 266
				) -- 266
			) -- 266
			scroll.view:moveAndCullItems(Vec2.zero) -- 267
			layingOut = false -- 268
			if not pinned then -- 268
				unread = true -- 269
			end -- 269
			updateHint() -- 270
		end -- 236
	} -- 236
end -- 192
return ____exports -- 192