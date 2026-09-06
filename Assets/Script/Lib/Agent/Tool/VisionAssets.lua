-- [ts]: VisionAssets.ts
local ____lualib = require("lualib_bundle") -- 1
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
function ____exports.visionOwner(req) -- 30
	if not req.sessionId then -- 30
		return "task-" .. tostring(req.taskId) -- 31
	end -- 31
	local rows = DB:query("SELECT root_session_id, project_root FROM agent.AgentSession WHERE id=?", {req.sessionId}) -- 32
	if not rows or #rows ~= 1 or rows[1][2] ~= req.workingDir then -- 32
		error("vision session does not belong to this project") -- 33
	end -- 33
	local rootId = __TS__Number(rows[1][1]) -- 34
	return "session-" .. tostring(rootId > 0 and rootId or req.sessionId) -- 35
end -- 30
function ____exports.visionAssetPath(id, suffix) -- 37
	if suffix == nil then -- 37
		suffix = "png" -- 37
	end -- 37
	if (string.match(id, "^%d+%-%d+$")) == nil then -- 37
		error("invalid vision asset ID") -- 38
	end -- 38
	return Path( -- 39
		____exports.visionRoot(), -- 39
		(id .. ".") .. suffix -- 39
	) -- 39
end -- 37
function ____exports.inspectVisionPNG(data) -- 41
	if #data < 33 or #data > ____exports.VISION_MAX_IMAGE_BYTES or (string.byte(data, 1) ~= 137 or string.sub(data, 2, 8) ~= "PNG\r\n\n") then -- 41
		error("invalid or oversized PNG asset") -- 42
	end -- 42
	local function integer(offset) -- 43
		local a, b, c, d = string.byte(data, offset, offset + 3) -- 44
		return ((a * 256 + b) * 256 + c) * 256 + d -- 45
	end -- 43
	local width = integer(17) -- 47
	local height = integer(21) -- 47
	if width < 1 or height < 1 or width > 1280 or height > 1280 then -- 47
		error("invalid vision image dimensions") -- 48
	end -- 48
	local a = 1 -- 50
	local b = 0 -- 50
	do -- 50
		local i = 1 -- 51
		while i <= #data do -- 51
			a = (a + string.byte(data, i)) % 65521 -- 51
			b = (b + a) % 65521 -- 51
			i = i + 1 -- 51
		end -- 51
	end -- 51
	return { -- 52
		width = width, -- 52
		height = height, -- 52
		checksum = (tostring(b) .. "-") .. tostring(a) -- 52
	} -- 52
end -- 41
function ____exports.publishVisionAsset(req, metadata) -- 54
	local path = ____exports.visionAssetPath(metadata.assetId) -- 55
	local data = Content:load(path) -- 56
	if not data then -- 56
		error("capture image is missing") -- 57
	end -- 57
	local asset = __TS__ObjectAssign( -- 58
		{}, -- 58
		metadata, -- 58
		____exports.inspectVisionPNG(data), -- 58
		{ -- 58
			bytes = #data, -- 58
			owner = ____exports.visionOwner(req), -- 58
			projectRoot = req.workingDir, -- 58
			taskId = req.taskId, -- 58
			mimeType = "image/png", -- 58
			scope = "game" -- 58
		} -- 58
	) -- 58
	if asset.sourceWidth ~= nil or asset.sourceHeight ~= nil then -- 58
		if not asset.sourceWidth or not asset.sourceHeight or not __TS__NumberIsFinite(asset.sourceWidth) or not __TS__NumberIsFinite(asset.sourceHeight) or asset.sourceWidth ~= math.floor(asset.sourceWidth) or asset.sourceHeight ~= math.floor(asset.sourceHeight) or asset.sourceWidth < asset.width or asset.sourceHeight < asset.height then -- 58
			error("invalid capture source dimensions") -- 60
		end -- 60
		asset.scaleX = asset.width / asset.sourceWidth -- 61
		asset.scaleY = asset.height / asset.sourceHeight -- 62
	end -- 62
	local encoded = safeJsonEncode(asset) -- 64
	local temp = ____exports.visionAssetPath(asset.assetId, "json.tmp") -- 65
	local final = ____exports.visionAssetPath(asset.assetId, "json") -- 65
	if not encoded or not Content:save(temp, encoded) or not Content:move(temp, final) then -- 65
		error("failed to publish vision asset metadata") -- 66
	end -- 66
	return asset -- 67
end -- 54
function ____exports.readVisionAsset(req, id) -- 69
	local text = Content:load(____exports.visionAssetPath(id, "json")) -- 70
	local decoded = safeJsonDecode(text or "") -- 71
	if type(decoded) ~= "table" then -- 71
		error("vision asset metadata is invalid") -- 72
	end -- 72
	local asset = decoded -- 73
	if not asset or asset.assetId ~= id or asset.projectRoot ~= req.workingDir or asset.owner ~= ____exports.visionOwner(req) then -- 73
		error("vision asset is unavailable or belongs to another session") -- 74
	end -- 74
	local size = Content:getAttr(____exports.visionAssetPath(id)) -- 75
	if size ~= asset.bytes or size > ____exports.VISION_MAX_IMAGE_BYTES then -- 75
		error("vision asset is missing or damaged") -- 76
	end -- 76
	local data = Content:load(____exports.visionAssetPath(id)) -- 77
	if not data then -- 77
		error("vision asset is missing") -- 78
	end -- 78
	local png = ____exports.inspectVisionPNG(data) -- 79
	if png.checksum ~= asset.checksum or png.width ~= asset.width or png.height ~= asset.height then -- 79
		error("vision asset checksum mismatch") -- 80
	end -- 80
	return {asset = asset, data = data} -- 81
end -- 69
function ____exports.readSessionVisionAsset(sessionId, assetId) -- 85
	if type(sessionId) ~= "number" or sessionId < 1 or sessionId ~= math.floor(sessionId) or type(assetId) ~= "string" then -- 85
		error("invalid vision asset request") -- 86
	end -- 86
	local rows = DB:query("SELECT project_root FROM agent.AgentSession WHERE id=?", {sessionId}) -- 87
	if not rows or #rows ~= 1 or type(rows[1][1]) ~= "string" then -- 87
		error("vision session is unavailable") -- 88
	end -- 88
	return ____exports.readVisionAsset({workingDir = rows[1][1], sessionId = sessionId, taskId = 0}, assetId) -- 89
end -- 85
function ____exports.getSessionVisionImage(sessionId, assetId) -- 92
	do -- 92
		local function ____catch(_) -- 92
			return true, {success = false, message = "Vision image is unavailable, damaged, or belongs to another session"} -- 100
		end -- 100
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 100
			local ____exports_readSessionVisionAsset_result_0 = ____exports.readSessionVisionAsset(sessionId, assetId) -- 94
			local asset = ____exports_readSessionVisionAsset_result_0.asset -- 94
			local data = ____exports_readSessionVisionAsset_result_0.data -- 94
			local mime = require("mime") -- 95
			local encoded = mime.b64(data) -- 96
			if not encoded then -- 96
				error("Unable to encode vision image") -- 97
			end -- 97
			return true, {success = true, asset = asset, dataUrl = "data:image/png;base64," .. encoded} -- 98
		end) -- 98
		if not ____try then -- 98
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 98
		end -- 98
		if ____hasReturned then -- 98
			return ____returnValue -- 93
		end -- 93
	end -- 93
end -- 92
--- Bounded metadata recovery for a new task or a compressed conversation.
function ____exports.listVisionAssetReferences(req) -- 105
	local owner = ____exports.visionOwner(req) -- 106
	if not Content:exist(____exports.visionRoot()) then -- 106
		return {} -- 107
	end -- 107
	local assets = {} -- 108
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 109
		do -- 109
			if not __TS__StringEndsWith(file, ".json") then -- 109
				goto __continue34 -- 110
			end -- 110
			local decoded = safeJsonDecode(Content:load(Path( -- 111
				____exports.visionRoot(), -- 111
				file -- 111
			)) or "") -- 111
			if type(decoded) ~= "table" then -- 111
				goto __continue34 -- 112
			end -- 112
			local asset = decoded -- 113
			if asset.owner ~= owner or asset.projectRoot ~= req.workingDir or type(asset.assetId) ~= "string" then -- 113
				goto __continue34 -- 114
			end -- 114
			if (string.match(asset.assetId, "^%d+%-%d+$")) == nil or file ~= asset.assetId .. ".json" then -- 114
				goto __continue34 -- 115
			end -- 115
			if not Content:exist(____exports.visionAssetPath(asset.assetId)) then -- 115
				goto __continue34 -- 116
			end -- 116
			assets[#assets + 1] = asset -- 117
		end -- 117
		::__continue34:: -- 117
	end -- 117
	__TS__ArraySort( -- 119
		assets, -- 119
		function(____, a, b) -- 119
			local time = __TS__Number(__TS__StringSplit(b.assetId, "-")[1]) - __TS__Number(__TS__StringSplit(a.assetId, "-")[1]) -- 120
			return time ~= 0 and time or b.capturedAt - a.capturedAt -- 121
		end -- 119
	) -- 119
	return __TS__ArrayMap( -- 123
		__TS__ArraySlice(assets, 0, 6), -- 123
		function(____, asset) return { -- 123
			assetId = asset.assetId, -- 123
			entry = asset.entry, -- 123
			runId = asset.runId, -- 123
			capturedAt = asset.capturedAt, -- 124
			elapsedSeconds = asset.elapsedSeconds, -- 124
			width = asset.width, -- 124
			height = asset.height -- 124
		} end -- 124
	) -- 124
end -- 105
function ____exports.ensureVisionQuota(req, count) -- 127
	if not ensureDirPath(____exports.visionRoot()) then -- 127
		error("failed to create vision storage") -- 128
	end -- 128
	local owner = ____exports.visionOwner(req) -- 129
	local total = 0 -- 130
	local bytes = 0 -- 130
	local globalBytes = 0 -- 130
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 131
		do -- 131
			local timestamp = string.match(file, "^(%d+)%-%d+%.") -- 134
			local stale = timestamp ~= nil and os.time() - __TS__Number(timestamp) > 3600 -- 135
			local path = Path( -- 136
				____exports.visionRoot(), -- 136
				file -- 136
			) -- 136
			if __TS__StringEndsWith(file, ".png") then -- 136
				local metadata = Path:replaceExt(path, "json") -- 138
				if stale and not Content:exist(metadata) then -- 138
					Content:remove(path) -- 139
					goto __continue45 -- 139
				end -- 139
				local size = Content:getAttr(path) -- 140
				globalBytes = globalBytes + (size or 0) -- 141
				goto __continue45 -- 142
			end -- 142
			if __TS__StringEndsWith(file, ".json.tmp") and stale then -- 142
				Content:remove(path) -- 144
				goto __continue45 -- 144
			end -- 144
			if not __TS__StringEndsWith(file, ".json") then -- 144
				goto __continue45 -- 145
			end -- 145
			local value = safeJsonDecode(Content:load(path) or "") -- 146
			if type(value) ~= "table" then -- 146
				goto __continue45 -- 147
			end -- 147
			local asset = value -- 148
			if (asset and asset.owner) == owner then -- 148
				total = total + 1 -- 149
				bytes = bytes + (type(asset.bytes) == "number" and math.max(0, asset.bytes) or ____exports.VISION_MAX_IMAGE_BYTES) -- 149
			end -- 149
		end -- 149
		::__continue45:: -- 149
	end -- 149
	if total + count > 60 or bytes + count * ____exports.VISION_MAX_IMAGE_BYTES > 80 * 1024 * 1024 then -- 149
		error("vision session storage budget exhausted") -- 151
	end -- 151
	if globalBytes + count * ____exports.VISION_MAX_IMAGE_BYTES > 256 * 1024 * 1024 then -- 151
		error("vision storage budget exhausted; remove unneeded sessions before capturing more images") -- 152
	end -- 152
end -- 127
function ____exports.removeVisionSessionAssets(rootSessionId) -- 155
	if not Content:exist(____exports.visionRoot()) then -- 155
		return -- 156
	end -- 156
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 157
		do -- 157
			if not __TS__StringEndsWith(file, ".json") then -- 157
				goto __continue57 -- 158
			end -- 158
			local decoded = safeJsonDecode(Content:load(Path( -- 159
				____exports.visionRoot(), -- 159
				file -- 159
			)) or "") -- 159
			if type(decoded) ~= "table" then -- 159
				goto __continue57 -- 160
			end -- 160
			local asset = decoded -- 161
			if asset.owner ~= "session-" .. tostring(rootSessionId) or type(asset.assetId) ~= "string" then -- 161
				goto __continue57 -- 162
			end -- 162
			if file ~= asset.assetId .. ".json" or (string.match(asset.assetId, "^%d+%-%d+$")) == nil then -- 162
				goto __continue57 -- 164
			end -- 164
			Content:remove(____exports.visionAssetPath(asset.assetId, "json")) -- 165
			Content:remove(____exports.visionAssetPath(asset.assetId)) -- 166
		end -- 166
		::__continue57:: -- 166
	end -- 166
end -- 155
--- Keep stored evidence readable when its owning project is renamed. Idempotent on retry.
function ____exports.renameVisionSessionAssets(rootSessionId, oldRoot, newRoot) -- 171
	if not Content:exist(____exports.visionRoot()) then -- 171
		return true -- 172
	end -- 172
	for ____, file in ipairs(Content:getFiles(____exports.visionRoot())) do -- 173
		do -- 173
			if not __TS__StringEndsWith(file, ".json") then -- 173
				goto __continue65 -- 174
			end -- 174
			local decoded = safeJsonDecode(Content:load(Path( -- 175
				____exports.visionRoot(), -- 175
				file -- 175
			)) or "") -- 175
			if type(decoded) ~= "table" then -- 175
				goto __continue65 -- 176
			end -- 176
			local asset = decoded -- 177
			if asset.owner ~= "session-" .. tostring(rootSessionId) or asset.projectRoot ~= oldRoot or type(asset.assetId) ~= "string" then -- 177
				goto __continue65 -- 178
			end -- 178
			if file ~= asset.assetId .. ".json" or (string.match(asset.assetId, "^%d+%-%d+$")) == nil then -- 178
				goto __continue65 -- 179
			end -- 179
			local encoded = safeJsonEncode(__TS__ObjectAssign({}, asset, {projectRoot = newRoot})) -- 180
			local temp = ____exports.visionAssetPath(asset.assetId, "json.tmp") -- 181
			if not encoded or not Content:save(temp, encoded) or not Content:move( -- 181
				temp, -- 182
				____exports.visionAssetPath(asset.assetId, "json") -- 182
			) then -- 182
				return false -- 182
			end -- 182
		end -- 182
		::__continue65:: -- 182
	end -- 182
	return true -- 184
end -- 171
return ____exports -- 171