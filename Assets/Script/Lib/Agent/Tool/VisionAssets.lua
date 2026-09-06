-- [ts]: VisionAssets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local DB = ____Dora.DB -- 2
local ____Utils = require("Agent.Utils") -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local ____Workspace = require("Agent.Tool.Workspace") -- 4
local ensureDirPath = ____Workspace.ensureDirPath -- 4
____exports.VISION_MAX_IMAGE_BYTES = 4 * 1024 * 1024 -- 28
function ____exports.visionRoot() -- 29
	return Path(Content.appPath, "agent-vision") -- 29
end -- 29
local verifiedAssets = {} -- 35
local verifiedOrder = {} -- 36
local function rememberVerifiedAsset(asset) -- 37
	if verifiedAssets[asset.assetId] == nil then -- 37
		verifiedOrder[#verifiedOrder + 1] = asset.assetId -- 39
		while #verifiedOrder > 3 do -- 39
			__TS__Delete( -- 41
				verifiedAssets, -- 41
				table.remove(verifiedOrder, 1) -- 41
			) -- 41
		end -- 41
	end -- 41
	verifiedAssets[asset.assetId] = { -- 44
		data = asset.data, -- 44
		checksum = asset.checksum, -- 44
		width = asset.width, -- 44
		height = asset.height, -- 44
		bytes = asset.bytes -- 44
	} -- 44
end -- 37
function ____exports.visionOwner(req) -- 46
	if not req.sessionId then -- 46
		return "task-" .. tostring(req.taskId) -- 47
	end -- 47
	local rows = DB:query("SELECT root_session_id, project_root FROM agent.AgentSession WHERE id=?", {req.sessionId}) -- 48
	if not rows or #rows ~= 1 or rows[1][2] ~= req.workingDir then -- 48
		error("vision session does not belong to this project") -- 49
	end -- 49
	local rootId = __TS__Number(rows[1][1]) -- 50
	return "session-" .. tostring(rootId > 0 and rootId or req.sessionId) -- 51
end -- 46
function ____exports.visionAssetPath(id, suffix) -- 53
	if suffix == nil then -- 53
		suffix = "png" -- 53
	end -- 53
	if (string.match(id, "^%d+%-%d+$")) == nil then -- 53
		error("invalid vision asset ID") -- 54
	end -- 54
	return Path( -- 55
		____exports.visionRoot(), -- 55
		(id .. ".") .. suffix -- 55
	) -- 55
end -- 53
function ____exports.inspectVisionPNG(data) -- 57
	if #data < 33 or #data > ____exports.VISION_MAX_IMAGE_BYTES or (string.byte(data, 1) ~= 137 or string.sub(data, 2, 8) ~= "PNG\r\n\n") then -- 57
		error("invalid or oversized PNG asset") -- 58
	end -- 58
	local function integer(offset) -- 59
		local a, b, c, d = string.byte(data, offset, offset + 3) -- 60
		return ((a * 256 + b) * 256 + c) * 256 + d -- 61
	end -- 59
	local width = integer(17) -- 63
	local height = integer(21) -- 63
	if width < 1 or height < 1 or width > 1280 or height > 1280 then -- 63
		error("invalid vision image dimensions") -- 64
	end -- 64
	local a = 1 -- 66
	local b = 0 -- 66
	do -- 66
		local i = 1 -- 67
		while i <= #data do -- 67
			a = (a + string.byte(data, i)) % 65521 -- 67
			b = (b + a) % 65521 -- 67
			i = i + 1 -- 67
		end -- 67
	end -- 67
	return { -- 68
		width = width, -- 68
		height = height, -- 68
		checksum = (tostring(b) .. "-") .. tostring(a) -- 68
	} -- 68
end -- 57
function ____exports.publishVisionAsset(req, metadata) -- 70
	local path = ____exports.visionAssetPath(metadata.assetId) -- 71
	local data = Content:load(path) -- 72
	if not data then -- 72
		error("capture image is missing") -- 73
	end -- 73
	local asset = __TS__ObjectAssign( -- 74
		{}, -- 74
		metadata, -- 74
		____exports.inspectVisionPNG(data), -- 74
		{ -- 74
			bytes = #data, -- 74
			owner = ____exports.visionOwner(req), -- 74
			projectRoot = req.workingDir, -- 74
			taskId = req.taskId, -- 74
			mimeType = "image/png", -- 74
			scope = "game" -- 74
		} -- 74
	) -- 74
	if asset.sourceWidth ~= nil or asset.sourceHeight ~= nil then -- 74
		if not asset.sourceWidth or not asset.sourceHeight or not __TS__NumberIsFinite(asset.sourceWidth) or not __TS__NumberIsFinite(asset.sourceHeight) or asset.sourceWidth ~= math.floor(asset.sourceWidth) or asset.sourceHeight ~= math.floor(asset.sourceHeight) or asset.sourceWidth < asset.width or asset.sourceHeight < asset.height then -- 74
			error("invalid capture source dimensions") -- 76
		end -- 76
		asset.scaleX = asset.width / asset.sourceWidth -- 77
		asset.scaleY = asset.height / asset.sourceHeight -- 78
	end -- 78
	local encoded = safeJsonEncode(asset) -- 80
	local temp = ____exports.visionAssetPath(asset.assetId, "json.tmp") -- 81
	local final = ____exports.visionAssetPath(asset.assetId, "json") -- 81
	if not encoded or not Content:save(temp, encoded) or not Content:move(temp, final) then -- 81
		error("failed to publish vision asset metadata") -- 82
	end -- 82
	rememberVerifiedAsset({ -- 83
		assetId = asset.assetId, -- 83
		data = data, -- 83
		checksum = asset.checksum, -- 83
		width = asset.width, -- 83
		height = asset.height, -- 83
		bytes = asset.bytes -- 83
	}) -- 83
	return asset -- 84
end -- 70
function ____exports.readVisionAsset(req, id) -- 86
	local text = Content:load(____exports.visionAssetPath(id, "json")) -- 87
	local decoded = safeJsonDecode(text or "") -- 88
	if type(decoded) ~= "table" then -- 88
		error("vision asset metadata is invalid") -- 89
	end -- 89
	local asset = decoded -- 90
	if not asset or asset.assetId ~= id or asset.projectRoot ~= req.workingDir or asset.owner ~= ____exports.visionOwner(req) then -- 90
		error("vision asset is unavailable or belongs to another session") -- 91
	end -- 91
	local size = Content:getAttr(____exports.visionAssetPath(id)) -- 92
	if size ~= asset.bytes or size > ____exports.VISION_MAX_IMAGE_BYTES then -- 92
		error("vision asset is missing or damaged") -- 93
	end -- 93
	local data = Content:load(____exports.visionAssetPath(id)) -- 94
	if not data then -- 94
		error("vision asset is missing") -- 95
	end -- 95
	local cached = verifiedAssets[id] -- 96
	if cached == nil or cached.data ~= data or cached.checksum ~= asset.checksum or cached.width ~= asset.width or cached.height ~= asset.height or cached.bytes ~= asset.bytes then -- 96
		local png = ____exports.inspectVisionPNG(data) -- 98
		if png.checksum ~= asset.checksum or png.width ~= asset.width or png.height ~= asset.height then -- 98
			error("vision asset checksum mismatch") -- 99
		end -- 99
		rememberVerifiedAsset({ -- 100
			assetId = id, -- 100
			data = data, -- 100
			checksum = png.checksum, -- 100
			width = png.width, -- 100
			height = png.height, -- 100
			bytes = #data -- 100
		}) -- 100
	end -- 100
	return {asset = asset, data = data} -- 102
end -- 86
function ____exports.readSessionVisionAsset(sessionId, assetId) -- 106
	if type(sessionId) ~= "number" or sessionId < 1 or sessionId ~= math.floor(sessionId) or type(assetId) ~= "string" then -- 106
		error("invalid vision asset request") -- 107
	end -- 107
	local rows = DB:query("SELECT project_root FROM agent.AgentSession WHERE id=?", {sessionId}) -- 108
	if not rows or #rows ~= 1 or type(rows[1][1]) ~= "string" then -- 108
		error("vision session is unavailable") -- 109
	end -- 109
	return ____exports.readVisionAsset({workingDir = rows[1][1], sessionId = sessionId, taskId = 0}, assetId) -- 110
end -- 106
function ____exports.getSessionVisionImage(sessionId, assetId) -- 113
	do -- 113
		local function ____catch(_) -- 113
			return true, {success = false, message = "Vision image is unavailable, damaged, or belongs to another session"} -- 121
		end -- 121
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 121
			local ____exports_readSessionVisionAsset_result_0 = ____exports.readSessionVisionAsset(sessionId, assetId) -- 115
			local asset = ____exports_readSessionVisionAsset_result_0.asset -- 115
			local data = ____exports_readSessionVisionAsset_result_0.data -- 115
			local mime = require("mime") -- 116
			local encoded = mime.b64(data) -- 117
			if not encoded then -- 117
				error("Unable to encode vision image") -- 118
			end -- 118
			return true, {success = true, asset = asset, dataUrl = "data:image/png;base64," .. encoded} -- 119
		end) -- 119
		if not ____try then -- 119
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 119
		end -- 119
		if ____hasReturned then -- 119
			return ____returnValue -- 114
		end -- 114
	end -- 114
end -- 113
--- Bounded metadata recovery for a new task or a compressed conversation.
function ____exports.listVisionAssetReferences(req) -- 126
	local owner = ____exports.visionOwner(req) -- 127
	if not Content:exist(____exports.visionRoot()) then -- 127
		return {} -- 128
	end -- 128
	local assets = {} -- 129
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 130
		do -- 130
			if not __TS__StringEndsWith(file, ".json") then -- 130
				goto __continue38 -- 131
			end -- 131
			local decoded = safeJsonDecode(Content:load(Path( -- 132
				____exports.visionRoot(), -- 132
				file -- 132
			)) or "") -- 132
			if type(decoded) ~= "table" then -- 132
				goto __continue38 -- 133
			end -- 133
			local asset = decoded -- 134
			if asset.owner ~= owner or asset.projectRoot ~= req.workingDir or type(asset.assetId) ~= "string" then -- 134
				goto __continue38 -- 135
			end -- 135
			if (string.match(asset.assetId, "^%d+%-%d+$")) == nil or file ~= asset.assetId .. ".json" then -- 135
				goto __continue38 -- 136
			end -- 136
			if not Content:exist(____exports.visionAssetPath(asset.assetId)) then -- 136
				goto __continue38 -- 137
			end -- 137
			assets[#assets + 1] = asset -- 138
		end -- 138
		::__continue38:: -- 138
	end -- 138
	__TS__ArraySort( -- 140
		assets, -- 140
		function(____, a, b) -- 140
			local time = __TS__Number(__TS__StringSplit(b.assetId, "-")[1]) - __TS__Number(__TS__StringSplit(a.assetId, "-")[1]) -- 141
			return time ~= 0 and time or b.capturedAt - a.capturedAt -- 142
		end -- 140
	) -- 140
	return __TS__ArrayMap( -- 144
		__TS__ArraySlice(assets, 0, 6), -- 144
		function(____, asset) return { -- 144
			assetId = asset.assetId, -- 144
			entry = asset.entry, -- 144
			runId = asset.runId, -- 144
			capturedAt = asset.capturedAt, -- 145
			elapsedSeconds = asset.elapsedSeconds, -- 145
			width = asset.width, -- 145
			height = asset.height -- 145
		} end -- 145
	) -- 145
end -- 126
function ____exports.ensureVisionQuota(req, count) -- 148
	if not ensureDirPath(____exports.visionRoot()) then -- 148
		error("failed to create vision storage") -- 149
	end -- 149
	local owner = ____exports.visionOwner(req) -- 150
	local total = 0 -- 151
	local bytes = 0 -- 151
	local globalBytes = 0 -- 151
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 152
		do -- 152
			local timestamp = string.match(file, "^(%d+)%-%d+%.") -- 155
			local stale = timestamp ~= nil and os.time() - __TS__Number(timestamp) > 3600 -- 156
			local path = Path( -- 157
				____exports.visionRoot(), -- 157
				file -- 157
			) -- 157
			if __TS__StringEndsWith(file, ".png") then -- 157
				local metadata = Path:replaceExt(path, "json") -- 159
				if stale and not Content:exist(metadata) then -- 159
					Content:remove(path) -- 160
					goto __continue49 -- 160
				end -- 160
				local size = Content:getAttr(path) -- 161
				globalBytes = globalBytes + (size or 0) -- 162
				goto __continue49 -- 163
			end -- 163
			if __TS__StringEndsWith(file, ".json.tmp") and stale then -- 163
				Content:remove(path) -- 165
				goto __continue49 -- 165
			end -- 165
			if not __TS__StringEndsWith(file, ".json") then -- 165
				goto __continue49 -- 166
			end -- 166
			local value = safeJsonDecode(Content:load(path) or "") -- 167
			if type(value) ~= "table" then -- 167
				goto __continue49 -- 168
			end -- 168
			local asset = value -- 169
			if (asset and asset.owner) == owner then -- 169
				total = total + 1 -- 170
				bytes = bytes + (type(asset.bytes) == "number" and math.max(0, asset.bytes) or ____exports.VISION_MAX_IMAGE_BYTES) -- 170
			end -- 170
		end -- 170
		::__continue49:: -- 170
	end -- 170
	if total + count > 60 or bytes + count * ____exports.VISION_MAX_IMAGE_BYTES > 80 * 1024 * 1024 then -- 170
		error("vision session storage budget exhausted") -- 172
	end -- 172
	if globalBytes + count * ____exports.VISION_MAX_IMAGE_BYTES > 256 * 1024 * 1024 then -- 172
		error("vision storage budget exhausted; remove unneeded sessions before capturing more images") -- 173
	end -- 173
end -- 148
function ____exports.removeVisionSessionAssets(rootSessionId) -- 176
	if not Content:exist(____exports.visionRoot()) then -- 176
		return -- 177
	end -- 177
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 178
		do -- 178
			if not __TS__StringEndsWith(file, ".json") then -- 178
				goto __continue61 -- 179
			end -- 179
			local decoded = safeJsonDecode(Content:load(Path( -- 180
				____exports.visionRoot(), -- 180
				file -- 180
			)) or "") -- 180
			if type(decoded) ~= "table" then -- 180
				goto __continue61 -- 181
			end -- 181
			local asset = decoded -- 182
			if asset.owner ~= "session-" .. tostring(rootSessionId) or type(asset.assetId) ~= "string" then -- 182
				goto __continue61 -- 183
			end -- 183
			if file ~= asset.assetId .. ".json" or (string.match(asset.assetId, "^%d+%-%d+$")) == nil then -- 183
				goto __continue61 -- 185
			end -- 185
			Content:remove(____exports.visionAssetPath(asset.assetId, "json")) -- 186
			Content:remove(____exports.visionAssetPath(asset.assetId)) -- 187
		end -- 187
		::__continue61:: -- 187
	end -- 187
end -- 176
--- Keep stored evidence readable when its owning project is renamed. Idempotent on retry.
function ____exports.renameVisionSessionAssets(rootSessionId, oldRoot, newRoot) -- 192
	if not Content:exist(____exports.visionRoot()) then -- 192
		return true -- 193
	end -- 193
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 194
		do -- 194
			if not __TS__StringEndsWith(file, ".json") then -- 194
				goto __continue69 -- 195
			end -- 195
			local decoded = safeJsonDecode(Content:load(Path( -- 196
				____exports.visionRoot(), -- 196
				file -- 196
			)) or "") -- 196
			if type(decoded) ~= "table" then -- 196
				goto __continue69 -- 197
			end -- 197
			local asset = decoded -- 198
			if asset.owner ~= "session-" .. tostring(rootSessionId) or asset.projectRoot ~= oldRoot or type(asset.assetId) ~= "string" then -- 198
				goto __continue69 -- 199
			end -- 199
			if file ~= asset.assetId .. ".json" or (string.match(asset.assetId, "^%d+%-%d+$")) == nil then -- 199
				goto __continue69 -- 200
			end -- 200
			local encoded = safeJsonEncode(__TS__ObjectAssign({}, asset, {projectRoot = newRoot})) -- 201
			local temp = ____exports.visionAssetPath(asset.assetId, "json.tmp") -- 202
			if not encoded or not Content:save(temp, encoded) or not Content:move( -- 202
				temp, -- 203
				____exports.visionAssetPath(asset.assetId, "json") -- 203
			) then -- 203
				return false -- 203
			end -- 203
		end -- 203
		::__continue69:: -- 203
	end -- 203
	return true -- 205
end -- 192
return ____exports -- 192