// @preview-file off clear
import { App, Content, Director, Path, once, sleep, Object as DoraObject } from 'Dora';
import * as Config from 'Agent/Config';
import { acquireEntryLease, recordEntryLeaseRun, ownsEntryLease, releaseEntryLease, type DevEntryModule } from 'Agent/Tool/EntryLease';
import { isValidWorkspacePath } from 'Agent/Tool/Workspace';
import { createOperationId } from 'Agent/Tool/Operation';
import { ensureVisionQuota, publishVisionAsset, visionAssetPath, type VisionAsset, type VisionOwner } from 'Agent/Tool/VisionAssets';
import { validateAgentToolInput } from 'Agent/Tool/Validation';

export async function previewGame(req: VisionOwner & {entry?:string;captureAtSeconds?:number[];isCancelled:()=>boolean}): Promise<Record<string,unknown>> {
	const validation = validateAgentToolInput("preview_game", {entry:req.entry, captureAtSeconds:req.captureAtSeconds});
	if (!validation.success) return {success:false,message:validation.message};
	const file=req.entry ?? "init.lua", times=req.captureAtSeconds ?? [0.5];
	if (!isValidWorkspacePath(file) || !file || (Path.getExt(file)!=="lua" && Path.getExt(file)!==""))return {success:false,message:"preview_game requires a built project-relative Lua entry"};
	if (times.length<1 || times.length>3 || times.some((t,i)=>typeof t!=="number" || t<0 || t>10 || t!==t || (i>0 && t<=times[i-1])))return {success:false,message:"Choose 1–3 increasing capture times between 0 and 10 seconds"};
	const full=Path.replaceExt(Path(req.workingDir,file),"lua");
	if (!Content.exist(full))return {success:false,message:"Build the entry before preview_game"};
	const entry=require("Script.Dev.Entry") as DevEntryModule;
	const operationId=createOperationId(), assets:VisionAsset[]=[];
	let scope=false, leased=false, complete=false;
	return new Promise(resolve=>{
		Director.systemScheduler.schedule(once(()=>{
			let result:Record<string,unknown>={success:false,message:"Preview did not complete"};
			const pendingPaths:string[]=[];
			try {
				if(req.isCancelled())error("Preview cancelled");
				ensureVisionQuota(req,times.length);
				acquireEntryLease(operationId,entry);leased=true;
				entry.allClear();
				scope=Director.beginGameCapture();
				if(!scope)error("Game capture is unavailable or busy");
				const objects=DoraObject.count, refs=DoraObject.luaRefCount;
				recordEntryLeaseRun(operationId,entry);
				const [previousHook, previousMask, previousCount] = debug.gethook();
				try {
					debug.sethook(() => {
						if (req.isCancelled()) error("Preview cancelled during startup");
						if (App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds) error("Preview startup exceeded the game frame time budget");
						if (DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth || DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth) error("Preview startup exceeded the game object budget");
					}, "", Config.AGENT_LIMITS.executeCommandHookInstructionCount);
					const [ok,message]=entry.enterEntryAsync({entryName:Path.getName(full),fileName:Path.replaceExt(full,""),workDir:req.workingDir,projectRoot:req.workingDir,runKind:"agent_test"});
					if(!ok)error(message ?? "Game entry failed");
				} finally {
					if (previousHook !== undefined && previousMask !== undefined && previousCount !== undefined) {
						debug.sethook(previousHook as (event: "call" | "tail call" | "return" | "line" | "count", line?: number) => unknown, previousMask, previousCount);
					} else debug.sethook();
				}
				const started=App.runningTime;
				const check=()=>{
					if(req.isCancelled())error("Preview cancelled");
					if(!ownsEntryLease(operationId,entry))error("Preview lost ownership of the running game");
					if(App.runningTime-started>30)error("Preview timed out");
					if(DoraObject.count-objects>Config.AGENT_LIMITS.executeCommandMaxObjectGrowth || DoraObject.luaRefCount-refs>Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth)error("Preview exceeded the game object budget");
				};
				for(const time of times) {
					while(App.runningTime-started<time){check();sleep();}
					check();
					const assetId=createOperationId();
					const path=visionAssetPath(assetId);
					pendingPaths.push(path);
					let done=false,saved=false,capturedAt=0,sourceWidth=0,sourceHeight=0;
					if(!Director.captureGameAsync(path,(success,frameTime,sourceSize)=>{
						if(complete){Content.remove(path);return;}
						saved=success;capturedAt=frameTime;sourceWidth=sourceSize.width;sourceHeight=sourceSize.height;done=true;
					}))error("Capture request was rejected");
					while(!done){check();sleep();}
					check();
					if(!saved)error("Game capture could not be saved");
					assets.push(publishVisionAsset(req,{assetId,entry:file,runId:entry.getCurrentEntryStatus().runId ?? 0,capturedAt,elapsedSeconds:capturedAt-started,sourceWidth,sourceHeight}));
				}
				const cleanupError=releaseEntryLease(operationId,entry);leased=false;
				if(cleanupError)error(cleanupError);
				result={success:true,operationId,assets,scope:"game",entry:file};
			} catch(e) {result={success:false,operationId,assets,cancelled:req.isCancelled(),message:tostring(e)};}
			finally {
				complete=true;
				if(scope)Director.endGameCapture();
				if(leased){const cleanupError=releaseEntryLease(operationId,entry);if(cleanupError)result={...result,success:false,cleanupError};}
				for(const path of pendingPaths){if(!assets.some(a=>visionAssetPath(a.assetId)===path))Content.remove(path);}
			}
			resolve(result);
		}));
	});
}
