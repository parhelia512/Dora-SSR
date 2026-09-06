-- [ts]: VisionAssets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local ____Workspace = require("Agent.Tool.Workspace") -- 4
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 4
____exports.VISION_MAX_IMAGE_BYTES = 4 * 1024 * 1024 -- 6
--- Identify a PNG or JPEG payload within the size budget; PNG also yields dimensions.
function ____exports.inspectImage(data) -- 9
	if #data < 12 or #data > ____exports.VISION_MAX_IMAGE_BYTES then -- 9
		error("invalid or oversized image") -- 10
	end -- 10
	if string.byte(data, 1) == 255 and string.byte(data, 2) == 216 and string.byte(data, 3) == 255 then -- 10
		return {format = "jpeg"} -- 12
	end -- 12
	if string.byte(data, 1) == 137 and string.sub(data, 2, 8) == "PNG\r\n\n" then -- 12
		if #data < 33 then -- 12
			error("invalid PNG image") -- 15
		end -- 15
		local function integer(offset) -- 16
			local a, b, c, d = string.byte(data, offset, offset + 3) -- 17
			return ((a * 256 + b) * 256 + c) * 256 + d -- 18
		end -- 16
		local width = integer(17) -- 20
		local height = integer(21) -- 20
		if width < 1 or height < 1 then -- 20
			error("invalid PNG dimensions") -- 21
		end -- 21
		return {format = "png", width = width, height = height} -- 22
	end -- 22
	error("unsupported image format; use PNG or JPEG") -- 24
end -- 9
function ____exports.projectVisionDir(workDir) -- 27
	return Path(workDir, ".agent", "vision") -- 28
end -- 27
--- Recent capture files under .agent/vision for resume/compression context.
function ____exports.listRecentProjectImages(workDir) -- 32
	local dir = ____exports.projectVisionDir(workDir) -- 33
	if not Content:exist(dir) then -- 33
		return {} -- 34
	end -- 34
	local files = {} -- 35
	for ____, file in ipairs(Content:getFiles(dir)) do -- 36
		if __TS__StringEndsWith(file, ".png") or __TS__StringEndsWith(file, ".jpg") or __TS__StringEndsWith(file, ".jpeg") then -- 36
			files[#files + 1] = file -- 37
		end -- 37
	end -- 37
	__TS__ArraySort( -- 39
		files, -- 39
		function(____, a, b) return a < b and 1 or (a > b and -1 or 0) end -- 39
	) -- 39
	return __TS__ArrayMap( -- 40
		__TS__ArraySlice(files, 0, 6), -- 40
		function(____, file) return {path = ".agent/vision/" .. file} end -- 40
	) -- 40
end -- 32
local function encodeDataUrl(data) -- 43
	local mime = require("mime") -- 44
	local encoded = mime.b64(data) -- 45
	if not encoded then -- 45
		error("Unable to encode image") -- 46
	end -- 46
	local inspected = ____exports.inspectImage(data) -- 47
	local prefix = inspected.format == "jpeg" and "data:image/jpeg;base64," or "data:image/png;base64," -- 48
	return prefix .. encoded -- 49
end -- 43
local function sessionProjectRoot(sessionId) -- 53
	if type(sessionId) ~= "number" or sessionId < 1 or sessionId ~= math.floor(sessionId) then -- 53
		error("invalid session") -- 54
	end -- 54
	local rows = DB:query("SELECT project_root FROM agent.AgentSession WHERE id=?", {sessionId}) -- 55
	if not rows or #rows ~= 1 or type(rows[1][1]) ~= "string" then -- 55
		error("vision session is unavailable") -- 56
	end -- 56
	return rows[1][1] -- 57
end -- 53
--- Load any project-relative PNG/JPEG image for UI display.
function ____exports.getSessionVisionImageFromPath(sessionId, path) -- 61
	do -- 61
		local function ____catch(_) -- 61
			return true, {success = false, message = "Vision image is unavailable, invalid, or outside the project"} -- 72
		end -- 72
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 72
			if type(path) ~= "string" or __TS__StringTrim(path) == "" then -- 72
				error("invalid image path") -- 63
			end -- 63
			local projectRoot = sessionProjectRoot(sessionId) -- 64
			local fullPath = resolveWorkspaceFilePath( -- 65
				projectRoot, -- 65
				__TS__StringTrim(path) -- 65
			) -- 65
			if not fullPath then -- 65
				error("path escapes the project") -- 66
			end -- 66
			local data = Content:load(fullPath) -- 67
			if not data then -- 67
				error("image is unavailable") -- 68
			end -- 68
			local inspected = ____exports.inspectImage(data) -- 69
			return true, { -- 70
				success = true, -- 70
				path = __TS__StringTrim(path), -- 70
				format = inspected.format, -- 70
				width = inspected.width, -- 70
				height = inspected.height, -- 70
				dataUrl = encodeDataUrl(data) -- 70
			} -- 70
		end) -- 70
		if not ____try then -- 70
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 70
		end -- 70
		if ____hasReturned then -- 70
			return ____returnValue -- 62
		end -- 62
	end -- 62
end -- 61
local verifiedAssets = {} -- 86
local function legacyAssetPath(id, suffix) -- 88
	if suffix == nil then -- 88
		suffix = "png" -- 88
	end -- 88
	if (string.match(id, "^%d+%-%d+$")) == nil then -- 88
		error("invalid vision asset ID") -- 89
	end -- 89
	return Path(Content.appPath, "agent-vision", (id .. ".") .. suffix) -- 90
end -- 88
local function readLegacyVisionAsset(req, id) -- 93
	local text = Content:load(legacyAssetPath(id, "json")) -- 94
	local decoded = safeJsonDecode(text or "") -- 95
	if type(decoded) ~= "table" then -- 95
		error("vision asset metadata is invalid") -- 96
	end -- 96
	local asset = decoded -- 97
	if not asset or asset.assetId ~= id or asset.projectRoot ~= req.workingDir then -- 97
		error("vision asset is unavailable or belongs to another session") -- 98
	end -- 98
	local size = Content:getAttr(legacyAssetPath(id)) -- 99
	if size ~= asset.bytes or size > ____exports.VISION_MAX_IMAGE_BYTES then -- 99
		error("vision asset is missing or damaged") -- 100
	end -- 100
	local data = Content:load(legacyAssetPath(id)) -- 101
	if not data then -- 101
		error("vision asset is missing") -- 102
	end -- 102
	local cached = verifiedAssets[id] -- 103
	if cached == nil or cached.data ~= data or cached.checksum ~= asset.checksum or cached.width ~= asset.width or cached.height ~= asset.height or cached.bytes ~= asset.bytes then -- 103
		local a = 1 -- 105
		local b = 0 -- 105
		do -- 105
			local i = 1 -- 106
			while i <= #data do -- 106
				a = (a + string.byte(data, i)) % 65521 -- 106
				b = (b + a) % 65521 -- 106
				i = i + 1 -- 106
			end -- 106
		end -- 106
		if (tostring(b) .. "-") .. tostring(a) ~= asset.checksum then -- 106
			error("vision asset checksum mismatch") -- 107
		end -- 107
		verifiedAssets[id] = { -- 108
			data = data, -- 108
			checksum = asset.checksum, -- 108
			width = asset.width, -- 108
			height = asset.height, -- 108
			bytes = #data -- 108
		} -- 108
	end -- 108
	return {asset = asset, data = data} -- 110
end -- 93
function ____exports.getSessionVisionImage(sessionId, assetId) -- 113
	do -- 113
		local function ____catch(_) -- 113
			return true, {success = false, message = "Vision image is unavailable, damaged, or belongs to another session"} -- 119
		end -- 119
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 119
			local projectRoot = sessionProjectRoot(sessionId) -- 115
			local ____readLegacyVisionAsset_result_0 = readLegacyVisionAsset({workingDir = projectRoot, sessionId = sessionId}, assetId) -- 116
			local asset = ____readLegacyVisionAsset_result_0.asset -- 116
			local data = ____readLegacyVisionAsset_result_0.data -- 116
			return true, { -- 117
				success = true, -- 117
				asset = asset, -- 117
				dataUrl = encodeDataUrl(data) -- 117
			} -- 117
		end) -- 117
		if not ____try then -- 117
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 117
		end -- 117
		if ____hasReturned then -- 117
			return ____returnValue -- 114
		end -- 114
	end -- 114
end -- 113
return ____exports -- 113