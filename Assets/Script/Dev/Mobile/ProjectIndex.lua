-- [tsx]: ProjectIndex.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Color3 = ____Dora.Color3 -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Size = ____Dora.Size -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 3
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 4
local attachGamepad = ____Gamepad.attachGamepad -- 4
local selectGamepadNode = ____Gamepad.selectGamepadNode -- 4
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 5
local groupFeedProjects = ____FeedModel.groupFeedProjects -- 5
local fontName = "sarasa-mono-sc-regular" -- 7
local headerHeight = 72 -- 8
local footerHeight = 36 -- 9
local railWidth = 48 -- 10
local groupHeight = 36 -- 11
local rowHeight = 48 -- 12
local function ellipsize(text, limit) -- 19
	local length = (utf8.len(text)) or 0 -- 20
	if length <= limit then -- 20
		return text -- 21
	end -- 21
	local stop = utf8.offset( -- 22
		text, -- 22
		math.max(2, limit) -- 22
	) or #text -- 22
	return string.sub(text, 1, stop - 1) .. "…" -- 23
end -- 19
local function addLabel(parent, text, size, color, x, y, anchor) -- 26
	if anchor == nil then -- 26
		anchor = Vec2(0, 0.5) -- 26
	end -- 26
	local label = Label(fontName, size, true) -- 27
	label.text = text -- 28
	label.color3 = Color3(color) -- 28
	label.position = Vec2(x, y) -- 28
	label.anchor = anchor -- 28
	label.renderOrder = 15002 -- 29
	label:addTo(parent) -- 30
	return label -- 31
end -- 26
local function roundedVerts(x, y, width, height, radius) -- 34
	local verts = {} -- 35
	local r = math.max( -- 36
		0, -- 36
		math.min(radius, width / 2, height / 2) -- 36
	) -- 36
	local corners = {{x = x + width - r, y = y + r, start = -math.pi / 2}, {x = x + width - r, y = y + height - r, start = 0}, {x = x + r, y = y + height - r, start = math.pi / 2}, {x = x + r, y = y + r, start = math.pi}} -- 37
	for ____, corner in ipairs(corners) do -- 43
		do -- 43
			local step = 0 -- 44
			while step <= 6 do -- 44
				local angle = corner.start + step * math.pi / 12 -- 45
				verts[#verts + 1] = Vec2( -- 46
					corner.x + math.cos(angle) * r, -- 46
					corner.y + math.sin(angle) * r -- 46
				) -- 46
				step = step + 1 -- 44
			end -- 44
		end -- 44
	end -- 44
	return verts -- 49
end -- 34
function ____exports.ProjectIndex(props) -- 52
	local function onCreate() -- 64
		local root = Node() -- 65
		root.tag = "mobile-project-index" -- 66
		root.anchor = Vec2.zero -- 67
		root.size = Size(props.width, props.height) -- 68
		root.renderGroup = true -- 69
		root.renderOrder = 15000 -- 70
		root.touchEnabled = true -- 71
		root.swallowTouches = true -- 72
		local discover = props.kind == "discover" -- 73
		addLabel( -- 74
			root, -- 74
			((discover and (props.zh and "发现作品" or "DISCOVER") or (props.zh and "本地作品" or "LOCAL")) .. " · ") .. tostring(#props.entries), -- 74
			18, -- 74
			4294242792, -- 74
			16, -- 75
			props.height - 34 -- 75
		) -- 75
		local back = Node() -- 76
		back.tag = "mobile-project-index-back" -- 76
		back.anchor = Vec2.zero -- 76
		back.position = Vec2(props.width - 96, props.height - 62) -- 77
		back.size = Size(80, 44) -- 77
		back.touchEnabled = true -- 77
		back.swallowTouches = true -- 77
		back:onTapped(props.onClose) -- 78
		back:addTo(root) -- 78
		addLabel( -- 79
			back, -- 79
			props.zh and "返回 ›" or "Back ›", -- 79
			18, -- 79
			4294954035, -- 79
			80, -- 79
			22, -- 79
			Vec2(1, 0.5) -- 79
		) -- 79
		local groups = groupFeedProjects(props.entries) -- 81
		local listX = railWidth + 8 -- 82
		local listWidth = math.max(40, props.width - listX - 14) -- 83
		local listHeight = math.max(40, props.height - headerHeight - footerHeight) -- 84
		local scroll = ScrollArea({ -- 85
			width = listWidth, -- 85
			height = listHeight, -- 85
			paddingX = 0, -- 85
			paddingY = 28, -- 85
			scrollBar = false -- 85
		}) -- 85
		scroll.tag = "mobile-project-index-scroll" -- 86
		scroll.position = Vec2(listX + listWidth / 2, footerHeight + listHeight / 2) -- 86
		scroll:addTo(root) -- 86
		local flat = {} -- 87
		local groupOffsets = {} -- 88
		local total = 0 -- 89
		do -- 89
			local groupIndex = 0 -- 90
			while groupIndex < #groups do -- 90
				local group = groups[groupIndex + 1] -- 91
				groupOffsets[#groupOffsets + 1] = total -- 92
				local heading = Node() -- 93
				heading.tag = "mobile-project-index-group-" .. group.key -- 93
				heading.anchor = Vec2(0, 1) -- 94
				heading.position = Vec2(0, listHeight - total) -- 94
				heading.size = Size(listWidth, groupHeight) -- 95
				heading:addTo(scroll.view) -- 95
				local groupTitle = group.key == "#" and (props.zh and "其它" or "Other") or group.key -- 96
				local headingBg = DrawNode() -- 97
				headingBg:drawSegment( -- 98
					Vec2(38, 18), -- 98
					Vec2(listWidth - 4, 18), -- 98
					0.5, -- 98
					Color(4281613128) -- 98
				) -- 98
				headingBg:addTo(heading) -- 99
				addLabel( -- 100
					heading, -- 100
					groupTitle, -- 100
					12, -- 100
					4294954035, -- 100
					8, -- 100
					18 -- 100
				) -- 100
				total = total + groupHeight -- 101
				for ____, entry in ipairs(group.entries) do -- 102
					local row = Node() -- 103
					row.tag = "mobile-project-index-entry-" .. tostring(#flat) -- 103
					row.anchor = Vec2(0, 1) -- 103
					row.position = Vec2(0, listHeight - total) -- 104
					row.size = Size(listWidth, rowHeight) -- 104
					row.touchEnabled = true -- 105
					row.swallowTouches = true -- 105
					row:onTapped(function() return props:onSelect(entry) end) -- 105
					row:addTo(scroll.view) -- 105
					local ____temp_4 = entry == props.current -- 106
					if not ____temp_4 then -- 106
						local ____temp_3 = entry.fileName ~= nil -- 106
						if ____temp_3 then -- 106
							local ____entry_fileName_2 = entry.fileName -- 106
							local ____opt_0 = props.current -- 106
							____temp_3 = ____entry_fileName_2 == (____opt_0 and ____opt_0.fileName) -- 106
						end -- 106
						____temp_4 = ____temp_3 -- 106
					end -- 106
					local ____temp_4_9 = ____temp_4 -- 106
					if not ____temp_4_9 then -- 106
						local ____temp_8 = entry.workDir ~= nil -- 107
						if ____temp_8 then -- 107
							local ____entry_workDir_7 = entry.workDir -- 107
							local ____opt_5 = props.current -- 107
							____temp_8 = ____entry_workDir_7 == (____opt_5 and ____opt_5.workDir) -- 107
						end -- 107
						____temp_4_9 = ____temp_8 -- 106
					end -- 106
					local selected = ____temp_4_9 -- 106
					local rowBg = DrawNode() -- 108
					rowBg:drawSegment( -- 109
						Vec2(8, 1), -- 109
						Vec2(listWidth - 8, 1), -- 109
						0.5, -- 109
						Color(4280560439) -- 109
					) -- 109
					if selected then -- 109
						rowBg:drawSegment( -- 110
							Vec2(5, 13), -- 110
							Vec2(5, rowHeight - 13), -- 110
							1.5, -- 110
							Color(4294954035) -- 110
						) -- 110
					end -- 110
					rowBg:addTo(row) -- 111
					addLabel( -- 112
						row, -- 112
						ellipsize( -- 112
							entry.title, -- 112
							math.max( -- 112
								8, -- 112
								math.floor((listWidth - 54) / 9) -- 112
							) -- 112
						), -- 112
						14, -- 112
						selected and 4294954035 or 4294242792, -- 113
						16, -- 113
						rowHeight / 2 -- 113
					) -- 113
					flat[#flat + 1] = {entry = entry, node = row, groupIndex = groupIndex, centerFromTop = total + rowHeight / 2} -- 114
					total = total + rowHeight -- 115
				end -- 115
				groupIndex = groupIndex + 1 -- 90
			end -- 90
		end -- 90
		if #groups == 0 then -- 90
			addLabel( -- 119
				scroll.view, -- 119
				discover and (props.zh and "暂无发现作品" or "No discovered games yet") or (props.zh and "还没有本地作品" or "No local games yet"), -- 119
				14, -- 119
				4286021260, -- 119
				listWidth / 2, -- 120
				listHeight / 2, -- 120
				Vec2(0.5, 0.5) -- 120
			) -- 120
		end -- 120
		scroll:resetSize(listWidth, listHeight, listWidth, total) -- 122
		local function maxOffset() -- 123
			return math.max(0, total - listHeight) -- 123
		end -- 123
		local function scrollTo(centerFromTop) -- 124
			scroll:unschedule() -- 125
			scroll.offset = Vec2( -- 125
				0, -- 125
				math.max( -- 125
					0, -- 125
					math.min( -- 125
						maxOffset(), -- 125
						centerFromTop - listHeight / 2 -- 125
					) -- 125
				) -- 125
			) -- 125
			scroll.view:moveAndCullItems(Vec2.zero) -- 126
		end -- 124
		local selectedIndex = math.max( -- 128
			0, -- 128
			__TS__ArrayFindIndex( -- 128
				flat, -- 128
				function(____, item) -- 128
					local ____temp_14 = item.entry == props.current -- 128
					if not ____temp_14 then -- 128
						local ____temp_13 = item.entry.fileName ~= nil -- 129
						if ____temp_13 then -- 129
							local ____item_entry_fileName_12 = item.entry.fileName -- 129
							local ____opt_10 = props.current -- 129
							____temp_13 = ____item_entry_fileName_12 == (____opt_10 and ____opt_10.fileName) -- 129
						end -- 129
						____temp_14 = ____temp_13 -- 128
					end -- 128
					local ____temp_14_19 = ____temp_14 -- 128
					if not ____temp_14_19 then -- 128
						local ____temp_18 = item.entry.workDir ~= nil -- 130
						if ____temp_18 then -- 130
							local ____item_entry_workDir_17 = item.entry.workDir -- 130
							local ____opt_15 = props.current -- 130
							____temp_18 = ____item_entry_workDir_17 == (____opt_15 and ____opt_15.workDir) -- 130
						end -- 130
						____temp_14_19 = ____temp_18 -- 128
					end -- 128
					return ____temp_14_19 -- 128
				end -- 128
			) -- 128
		) -- 128
		if flat[selectedIndex + 1] ~= nil then -- 128
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 131
		end -- 131
		local popup = Node() -- 133
		popup.visible = false -- 133
		popup.position = Vec2(railWidth + 48, props.height / 2) -- 133
		popup:addTo(root) -- 133
		local popupShape = DrawNode() -- 134
		popupShape:drawPolygon( -- 135
			roundedVerts( -- 135
				-28, -- 135
				-28, -- 135
				56, -- 135
				56, -- 135
				16 -- 135
			), -- 135
			Color(4279704614), -- 135
			1, -- 135
			Color(4286606108) -- 135
		) -- 135
		popupShape:addTo(popup) -- 135
		local popupLabel = addLabel( -- 136
			popup, -- 136
			"", -- 136
			18, -- 136
			4294954035, -- 136
			0, -- 136
			0, -- 136
			Vec2(0.5, 0.5) -- 136
		) -- 136
		popupLabel.tag = "mobile-project-index-popup-label" -- 137
		local rail = Node() -- 138
		rail.tag = "mobile-project-index-rail" -- 138
		rail.anchor = Vec2.zero -- 138
		rail.position = Vec2(0, footerHeight) -- 139
		rail.size = Size(railWidth, listHeight) -- 139
		rail.touchEnabled = #groups > 0 -- 140
		rail.swallowTouches = true -- 140
		rail:addTo(root) -- 140
		local railLabels = {} -- 141
		do -- 141
			local i = 0 -- 142
			while i < #groups do -- 142
				local y = listHeight - (i + 0.5) * listHeight / #groups -- 143
				railLabels[#railLabels + 1] = addLabel( -- 144
					rail, -- 144
					groups[i + 1].key, -- 144
					#groups > 20 and 9 or 11, -- 144
					4286021260, -- 144
					railWidth / 2, -- 144
					y, -- 144
					Vec2(0.5, 0.5) -- 144
				) -- 144
				i = i + 1 -- 142
			end -- 142
		end -- 142
		local ____opt_20 = flat[selectedIndex + 1] -- 142
		local activeGroup = ____opt_20 and ____opt_20.groupIndex or 0 -- 146
		local function selectGroup(groupIndex, showPopup, jump) -- 147
			if jump == nil then -- 147
				jump = true -- 147
			end -- 147
			if #groups == 0 then -- 147
				return -- 148
			end -- 148
			activeGroup = math.max( -- 149
				0, -- 149
				math.min(#groups - 1, groupIndex) -- 149
			) -- 149
			if jump then -- 149
				scroll:unschedule() -- 151
				scroll.offset = Vec2( -- 151
					0, -- 151
					math.max( -- 151
						0, -- 151
						math.min( -- 151
							maxOffset(), -- 151
							groupOffsets[activeGroup + 1] -- 151
						) -- 151
					) -- 151
				) -- 151
				scroll.view:moveAndCullItems(Vec2.zero) -- 152
			end -- 152
			do -- 152
				local i = 0 -- 154
				while i < #railLabels do -- 154
					railLabels[i + 1].color3 = Color3(i == activeGroup and 4294954035 or 7831180) -- 154
					i = i + 1 -- 154
				end -- 154
			end -- 154
			popupLabel.text = groups[activeGroup + 1].key == "#" and (props.zh and "其它" or "Other") or groups[activeGroup + 1].key -- 155
			popup.visible = showPopup -- 156
		end -- 147
		selectGroup(activeGroup, false, false) -- 158
		local function groupAt(worldLocation) -- 159
			if #groups == 0 then -- 159
				return 0 -- 160
			end -- 160
			local point = rail:convertToNodeSpace(worldLocation) -- 161
			popup.y = footerHeight + math.max( -- 162
				32, -- 162
				math.min(listHeight - 32, point.y) -- 162
			) -- 162
			return math.max( -- 163
				0, -- 163
				math.min( -- 163
					#groups - 1, -- 163
					math.floor((listHeight - point.y) / listHeight * #groups) -- 163
				) -- 163
			) -- 163
		end -- 159
		rail:onTapBegan(function(touch) return selectGroup( -- 165
			groupAt(touch.worldLocation), -- 165
			true -- 165
		) end) -- 165
		rail:onTapMoved(function(touch) return selectGroup( -- 166
			groupAt(touch.worldLocation), -- 166
			true -- 166
		) end) -- 166
		rail:onTapEnded(function() -- 167
			popup.visible = false -- 167
		end) -- 167
		local hint = props.zh and "拖动左侧刻度快速定位" or "Drag the index to jump" -- 169
		addLabel( -- 170
			root, -- 170
			hint, -- 170
			9, -- 170
			4286021260, -- 170
			props.width / 2, -- 170
			footerHeight / 2, -- 170
			Vec2(0.5, 0.5) -- 170
		) -- 170
		local function moveSelection(delta) -- 171
			if #flat == 0 then -- 171
				return -- 172
			end -- 172
			selectedIndex = math.max( -- 173
				0, -- 173
				math.min(#flat - 1, selectedIndex + delta) -- 173
			) -- 173
			activeGroup = flat[selectedIndex + 1].groupIndex -- 174
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 174
			selectGroup(activeGroup, false, false) -- 175
			selectGamepadNode(root, flat[selectedIndex + 1].node.tag) -- 175
		end -- 171
		local ____opt_22 = flat[selectedIndex + 1] -- 171
		local gamepadOptions = { -- 177
			initialTag = ____opt_22 and ____opt_22.node.tag or "mobile-project-index-back", -- 178
			onBack = function() return props:onClose() end, -- 179
			onScroll = function(amount) -- 180
				scroll:unschedule() -- 180
				scroll.offset = Vec2( -- 180
					0, -- 180
					math.max( -- 180
						0, -- 180
						math.min( -- 180
							maxOffset(), -- 180
							scroll.offset.y + amount -- 180
						) -- 180
					) -- 180
				) -- 180
				scroll.view:moveAndCullItems(Vec2.zero) -- 180
			end, -- 180
			onButton = function(button) -- 181
				if button == "dpup" then -- 181
					moveSelection(-1) -- 182
					return true -- 182
				end -- 182
				if button == "dpdown" then -- 182
					moveSelection(1) -- 183
					return true -- 183
				end -- 183
				if button == "dpleft" or button == "dpright" then -- 183
					local nextGroup = math.max( -- 185
						0, -- 185
						math.min(#groups - 1, activeGroup + (button == "dpright" and 1 or -1)) -- 185
					) -- 185
					local next = __TS__ArrayFindIndex( -- 186
						flat, -- 186
						function(____, item) return item.groupIndex == nextGroup end -- 186
					) -- 186
					if next >= 0 then -- 186
						selectedIndex = next -- 187
						moveSelection(0) -- 187
					end -- 187
					return true -- 188
				end -- 188
				if button == "a" and flat[selectedIndex + 1] then -- 188
					props:onSelect(flat[selectedIndex + 1].entry) -- 190
					return true -- 190
				end -- 190
				return false -- 191
			end -- 181
		} -- 181
		root:schedule(function() -- 196
			attachGamepad(root, gamepadOptions) -- 196
			return true -- 196
		end) -- 196
		return root -- 197
	end -- 64
	return React.createElement("custom-node", { -- 199
		tag = "mobile-project-index-container", -- 199
		x = props.x, -- 199
		y = props.y, -- 199
		width = props.width, -- 199
		height = props.height, -- 199
		order = 15000, -- 199
		renderOrder = 15000, -- 199
		onCreate = onCreate -- 199
	}) -- 199
end -- 52
return ____exports -- 52