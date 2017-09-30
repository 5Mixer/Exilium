package;

import kha.Framebuffer;
import kha.Scheduler;


class Project {
	var frame = 0;

	var lastTime:Float;
	var realLastTime:Float;
	var lastRenderTime:Float;

	public static var states:Array<states.State> = [];

	public static var mainMusicChannel:kha.audio1.AudioChannel;


	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		
		

		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
		lastRenderTime = Scheduler.time();
		
		kha.Assets.loadEverything(function(){
			AudioManager.init();
			mainMusicChannel = kha.audio1.Audio.play(kha.Assets.sounds.Synthwave_Beta_4,true);
			mainMusicChannel.volume = .6;

			states.push(new states.Menu());
		});
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		var realDelta = Scheduler.realTime() - realLastTime;

		if (kha.Assets.progress >= 1)
			states[states.length-1].update(realDelta);
		
		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
	}
	function render(framebuffer: Framebuffer): Void {
		frame++;

		if (kha.Assets.progress >= 1){
			states[states.length-1].render(framebuffer);		
		}else{
			var g = framebuffer.g2;
			g.begin();
			g.color = kha.Color.White;
			var height = 10 + Math.sin(frame/30)*10;
			g.fillRect(10,kha.System.windowHeight()/2 - height/2,(kha.System.windowWidth()-20) * kha.Assets.progress,height);
			g.end();
		}
	}
}
