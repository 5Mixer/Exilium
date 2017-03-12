package;

import kha.Framebuffer;
import kha.Scheduler;


class Project {
	var frame = 0;

	var lastTime:Float;
	var realLastTime:Float;
	var lastRenderTime:Float;

	public var states:Array<states.State> = [];

	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
	

		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
		lastRenderTime = Scheduler.time();
		
		states.push(new states.Play());
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		var realDelta = Scheduler.realTime() - realLastTime;

		for (state in states)
			state.update(delta);
		
		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
	}
	function render(framebuffer: Framebuffer): Void {
		frame++;

		for (state in states)
			state.render(framebuffer);		

	}
}
