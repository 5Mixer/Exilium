package;

import kha.Framebuffer;
import kha.Scheduler;


class Project {
	var frame = 0;

	var lastTime:Float;
	var realLastTime:Float;
	var lastRenderTime:Float;

	public static var states:Array<states.State> = [];

	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		AudioManager.init();
		
		// var mainMusicChannel = kha.audio1.Audio.play(kha.Assets.sounds.Synthwave_Beta_4,true);
		// mainMusicChannel.volume = .6;
		

		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
		lastRenderTime = Scheduler.time();
		
		states.push(new states.Play());
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		var realDelta = Scheduler.realTime() - realLastTime;

		states[states.length-1].update(realDelta);
		
		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
	}
	function render(framebuffer: Framebuffer): Void {
		frame++;

		states[states.length-1].render(framebuffer);		

	}
}
