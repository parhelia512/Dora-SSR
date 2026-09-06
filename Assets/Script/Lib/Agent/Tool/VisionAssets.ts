// @preview-file off clear
import { Content, Path, DB } from 'Dora';
import { safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { ensureDirPath } from 'Agent/Tool/Workspace';

export interface VisionOwner { workingDir: string; taskId: number; sessionId?: number; }
export interface VisionAsset {
	assetId: string;
	projectRoot: string;
	owner: string;
	taskId: number;
	runId: number;
	entry: string;
	capturedAt: number;
	elapsedSeconds: number;
	width: number;
	height: number;
	/** Absent only on assets captured before source-size metadata was introduced. */
	sourceWidth?: number;
	sourceHeight?: number;
	scaleX?: number;
	scaleY?: number;
	bytes: number;
	checksum: string;
	mimeType: "image/png";
	scope: "game";
}
export const VISION_MAX_IMAGE_BYTES = 4 * 1024 * 1024;
export function visionRoot(): string { return Path(Content.appPath, "agent-vision"); }

// Full-file checksum scans are costly for multi-megabyte captures, so keep the
// exact verified data of the most recent assets. Reloading unchanged content
// produces the same interned Lua string, which compares by identity in O(1);
// any changed byte produces a different string and still triggers a full scan.
const verifiedAssets: Record<string, {data: string; checksum: string; width: number; height: number; bytes: number}> = {};
const verifiedOrder: string[] = [];
function rememberVerifiedAsset(asset: {assetId: string; data: string; checksum: string; width: number; height: number; bytes: number}): void {
	if (verifiedAssets[asset.assetId] === undefined) {
		verifiedOrder.push(asset.assetId);
		while (verifiedOrder.length > 3) {
			delete verifiedAssets[verifiedOrder.shift()!];
		}
	}
	verifiedAssets[asset.assetId] = {data: asset.data, checksum: asset.checksum, width: asset.width, height: asset.height, bytes: asset.bytes};
}
export function visionOwner(req: VisionOwner): string {
	if (!req.sessionId) return `task-${req.taskId}`;
	const rows = DB.query("SELECT root_session_id, project_root FROM agent.AgentSession WHERE id=?", [req.sessionId]);
	if (!rows || rows.length !== 1 || rows[0][1] !== req.workingDir) error("vision session does not belong to this project");
	const rootId=Number(rows[0][0]);
	return `session-${rootId > 0 ? rootId : req.sessionId}`;
}
export function visionAssetPath(id: string, suffix = "png"): string {
	if (string.match(id, "^%d+%-%d+$")[0] === undefined) error("invalid vision asset ID");
	return Path(visionRoot(), `${id}.${suffix}`);
}
export function inspectVisionPNG(data: string): { width: number; height: number; checksum: string } {
	if (data.length < 33 || data.length > VISION_MAX_IMAGE_BYTES || (string.byte(data,1) !== 137 || string.sub(data, 2, 8) !== "PNG\r\n\x1a\n")) error("invalid or oversized PNG asset");
	const integer = (offset: number) => {
		const [a,b,c,d] = string.byte(data, offset, offset+3);
		return ((a*256+b)*256+c)*256+d;
	};
	const width = integer(17), height = integer(21);
	if (width < 1 || height < 1 || width > 1280 || height > 1280) error("invalid vision image dimensions");
	// Adler-32 detects damaged/replaced local bytes; this is not an authentication MAC.
	let a = 1, b = 0;
	for (let i=1; i<=data.length; i++) { a = (a + string.byte(data,i)) % 65521; b = (b+a) % 65521; }
	return {width, height, checksum: `${b}-${a}`};
}
export function publishVisionAsset(req: VisionOwner, metadata: Omit<VisionAsset, "owner" | "projectRoot" | "taskId" | "width" | "height" | "bytes" | "checksum" | "mimeType" | "scope">): VisionAsset {
	const path = visionAssetPath(metadata.assetId);
	const data = Content.load(path);
	if (!data) error("capture image is missing");
	const asset: VisionAsset = {...metadata, ...inspectVisionPNG(data), bytes:data.length, owner:visionOwner(req), projectRoot:req.workingDir, taskId:req.taskId, mimeType:"image/png", scope:"game"};
	if (asset.sourceWidth !== undefined || asset.sourceHeight !== undefined) {
		if (!asset.sourceWidth || !asset.sourceHeight || !Number.isFinite(asset.sourceWidth) || !Number.isFinite(asset.sourceHeight) || asset.sourceWidth !== math.floor(asset.sourceWidth) || asset.sourceHeight !== math.floor(asset.sourceHeight) || asset.sourceWidth < asset.width || asset.sourceHeight < asset.height) error("invalid capture source dimensions");
		asset.scaleX = asset.width / asset.sourceWidth;
		asset.scaleY = asset.height / asset.sourceHeight;
	}
	const [encoded] = safeJsonEncode(asset);
	const temp=visionAssetPath(asset.assetId,"json.tmp"), final=visionAssetPath(asset.assetId,"json");
	if (!encoded || !Content.save(temp,encoded) || !Content.move(temp,final)) error("failed to publish vision asset metadata");
	rememberVerifiedAsset({assetId: asset.assetId, data, checksum: asset.checksum, width: asset.width, height: asset.height, bytes: asset.bytes});
	return asset;
}
export function readVisionAsset(req: VisionOwner, id: string): {asset: VisionAsset; data: string} {
	const text = Content.load(visionAssetPath(id,"json"));
	const [decoded] = safeJsonDecode(text ?? "");
	if (type(decoded) !== "table") error("vision asset metadata is invalid");
	const asset = decoded as VisionAsset | undefined;
	if (!asset || asset.assetId !== id || asset.projectRoot !== req.workingDir || asset.owner !== visionOwner(req)) error("vision asset is unavailable or belongs to another session");
	const [size] = Content.getAttr(visionAssetPath(id));
	if (size !== asset.bytes || size > VISION_MAX_IMAGE_BYTES) error("vision asset is missing or damaged");
	const data = Content.load(visionAssetPath(id));
	if (!data) error("vision asset is missing");
	const cached = verifiedAssets[id];
	if (cached === undefined || cached.data !== data || cached.checksum !== asset.checksum || cached.width !== asset.width || cached.height !== asset.height || cached.bytes !== asset.bytes) {
		const png = inspectVisionPNG(data);
		if (png.checksum !== asset.checksum || png.width !== asset.width || png.height !== asset.height) error("vision asset checksum mismatch");
		rememberVerifiedAsset({assetId: id, data, checksum: png.checksum, width: png.width, height: png.height, bytes: data.length});
	}
	return {asset,data};
}

// Resolve the project on the server; clients never supply a filesystem path.
export function readSessionVisionAsset(sessionId: number, assetId: string): {asset: VisionAsset; data: string} {
	if (typeof sessionId !== "number" || sessionId < 1 || sessionId !== math.floor(sessionId) || typeof assetId !== "string") error("invalid vision asset request");
	const rows = DB.query("SELECT project_root FROM agent.AgentSession WHERE id=?", [sessionId]);
	if (!rows || rows.length !== 1 || typeof rows[0][0] !== "string") error("vision session is unavailable");
	return readVisionAsset({workingDir: rows[0][0], sessionId, taskId: 0}, assetId);
}

export function getSessionVisionImage(sessionId: number, assetId: string): Record<string, unknown> {
	try {
		const {asset, data} = readSessionVisionAsset(sessionId, assetId);
		const mime = require("mime") as { b64(this: void, value: string): LuaMultiReturn<[string | undefined, string | undefined]> };
		const [encoded] = mime.b64(data);
		if (!encoded) error("Unable to encode vision image");
		return {success: true, asset, dataUrl: `data:image/png;base64,${encoded}`};
	} catch (_) {
		return {success: false, message: "Vision image is unavailable, damaged, or belongs to another session"};
	}
}

/** Bounded metadata recovery for a new task or a compressed conversation. */
export function listVisionAssetReferences(req: VisionOwner): Record<string, unknown>[] {
	const owner = visionOwner(req);
	if (!Content.exist(visionRoot())) return [];
	const assets: VisionAsset[] = [];
	for (const file of Content.getFiles(visionRoot())) {
		if (!file.endsWith(".json")) continue;
		const [decoded] = safeJsonDecode(Content.load(Path(visionRoot(), file)) ?? "");
		if (type(decoded) !== "table") continue;
		const asset = decoded as VisionAsset;
		if (asset.owner !== owner || asset.projectRoot !== req.workingDir || typeof asset.assetId !== "string") continue;
		if (string.match(asset.assetId, "^%d+%-%d+$")[0] === undefined || file !== `${asset.assetId}.json`) continue;
		if (!Content.exist(visionAssetPath(asset.assetId))) continue;
		assets.push(asset);
	}
	assets.sort((a, b) => {
		const time = Number(b.assetId.split("-")[0]) - Number(a.assetId.split("-")[0]);
		return time !== 0 ? time : b.capturedAt - a.capturedAt;
	});
	return assets.slice(0, 6).map(asset => ({assetId:asset.assetId, entry:asset.entry, runId:asset.runId,
		capturedAt:asset.capturedAt, elapsedSeconds:asset.elapsedSeconds, width:asset.width, height:asset.height}));
}

export function ensureVisionQuota(req: VisionOwner, count: number): void {
	if (!ensureDirPath(visionRoot())) error("failed to create vision storage");
	const owner=visionOwner(req);
	let total=0, bytes=0, globalBytes=0;
	for (const file of Content.getFiles(visionRoot())) {
		// IDs carry their creation time. Only stale uncommitted files are swept;
		// another preview may still be completing its GPU readback and PNG save.
		const [timestamp] = string.match(file, "^(%d+)%-%d+%.");
		const stale = timestamp !== undefined && os.time() - Number(timestamp) > 3600;
		const path = Path(visionRoot(), file);
		if (file.endsWith(".png")) {
			const metadata = Path.replaceExt(path, "json");
			if (stale && !Content.exist(metadata)) { Content.remove(path); continue; }
			const [size] = Content.getAttr(path);
			globalBytes += size ?? 0;
			continue;
		}
		if (file.endsWith(".json.tmp") && stale) { Content.remove(path); continue; }
		if (!file.endsWith(".json")) continue;
		const [value]=safeJsonDecode(Content.load(path) ?? "");
		if (type(value) !== "table") continue;
		const asset=value as VisionAsset | undefined;
		if (asset?.owner === owner) {total++;bytes+=typeof asset.bytes === "number" ? math.max(0, asset.bytes) : VISION_MAX_IMAGE_BYTES;}
	}
	if (total+count>60 || bytes+count*VISION_MAX_IMAGE_BYTES>80*1024*1024) error("vision session storage budget exhausted");
	if (globalBytes+count*VISION_MAX_IMAGE_BYTES>256*1024*1024) error("vision storage budget exhausted; remove unneeded sessions before capturing more images");
}

export function removeVisionSessionAssets(rootSessionId: number): void {
	if (!Content.exist(visionRoot())) return;
	for (const file of Content.getFiles(visionRoot())) {
		if (!file.endsWith(".json")) continue;
		const [decoded] = safeJsonDecode(Content.load(Path(visionRoot(), file)) ?? "");
		if (type(decoded) !== "table") continue;
		const asset = decoded as VisionAsset;
		if (asset.owner !== `session-${rootSessionId}` || typeof asset.assetId !== "string") continue;
		// Match the on-disk name before trusting a metadata-supplied ID.
		if (file !== `${asset.assetId}.json` || string.match(asset.assetId, "^%d+%-%d+$")[0] === undefined) continue;
		Content.remove(visionAssetPath(asset.assetId, "json"));
		Content.remove(visionAssetPath(asset.assetId));
	}
}

/** Keep stored evidence readable when its owning project is renamed. Idempotent on retry. */
export function renameVisionSessionAssets(rootSessionId: number, oldRoot: string, newRoot: string): boolean {
	if (!Content.exist(visionRoot())) return true;
	for (const file of Content.getFiles(visionRoot())) {
		if (!file.endsWith(".json")) continue;
		const [decoded] = safeJsonDecode(Content.load(Path(visionRoot(), file)) ?? "");
		if (type(decoded) !== "table") continue;
		const asset = decoded as VisionAsset;
		if (asset.owner !== `session-${rootSessionId}` || asset.projectRoot !== oldRoot || typeof asset.assetId !== "string") continue;
		if (file !== `${asset.assetId}.json` || string.match(asset.assetId, "^%d+%-%d+$")[0] === undefined) continue;
		const [encoded] = safeJsonEncode({...asset, projectRoot: newRoot});
		const temp = visionAssetPath(asset.assetId, "json.tmp");
		if (!encoded || !Content.save(temp, encoded) || !Content.move(temp, visionAssetPath(asset.assetId, "json"))) return false;
	}
	return true;
}
