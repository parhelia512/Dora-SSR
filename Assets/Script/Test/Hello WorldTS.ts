import { WindowFlag, SetCond } from "ImGui";
import * as ImGui from "ImGui";
import { App, Node, Slot, Vec2, once, sleep, threadLoop } from "dora";

const node = Node();
node.slot(Slot.Enter, () => {
	print("on enter event");
});
node.slot(Slot.Exit, () => {
	print("on exit event");
});
node.slot(Slot.Cleanup, () => {
	print("on node destoyed event");
});
node.schedule(once(() => {
	for (let i = 5; i >= 1; i--) {
		print(i);
		sleep(1);
	}
	print("Hello World!");
}));

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const size = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Hello World", windowFlags, () => {
		ImGui.Text("Hello World");
		ImGui.Separator();
		ImGui.TextWrapped("Basic Dora schedule and signal function usage. Written in Teal. View outputs in log window!");
	});
	return false;
});