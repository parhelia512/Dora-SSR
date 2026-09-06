-- [ts]: EntryLease.ts
local ____exports = {} -- 1
local owner = "" -- 18
local runId -- 19
function ____exports.acquireEntryLease(id, entry) -- 20
	if owner ~= "" and owner ~= id then -- 20
		error("Dora entry runtime is busy with another Agent tool") -- 21
	end -- 21
	local status = entry.getCurrentEntryStatus() -- 22
	if status.running and (owner ~= id or status.runId ~= runId) then -- 22
		error("Dora entry runtime is in use; stop the current game before previewing") -- 23
	end -- 23
	owner = id -- 24
end -- 20
function ____exports.recordEntryLeaseRun(id, entry) -- 26
	if owner == id then -- 26
		runId = (entry.getCurrentEntryStatus().runId or 0) + 1 -- 27
	end -- 27
end -- 26
function ____exports.ownsEntryLease(id, entry) -- 29
	local status = entry.getCurrentEntryStatus() -- 30
	return owner == id and status.running and runId ~= nil and status.runId == runId -- 31
end -- 29
function ____exports.releaseEntryLease(id, entry) -- 33
	if owner ~= id then -- 33
		return nil -- 34
	end -- 34
	local cleanupError -- 35
	do -- 35
		local function ____catch(e) -- 35
			cleanupError = "failed to stop Agent preview: " .. tostring(e) -- 37
		end -- 37
		local ____try, ____hasReturned = pcall(function() -- 37
			if ____exports.ownsEntryLease(id, entry) and not entry.stop() then -- 37
				error("entry refused to stop") -- 36
			end -- 36
		end) -- 36
		if not ____try then -- 36
			____catch(____hasReturned) -- 36
		end -- 36
	end -- 36
	owner = "" -- 38
	runId = nil -- 38
	return cleanupError -- 39
end -- 33
return ____exports -- 33