package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Project {
	var level:Level;
	var camera:Camera;
	var frame = 0;
	var player:Player;
	var input:Input;

	var lastTime:Float;

	public function new() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		input = new Input();

		level = new Level();
		camera = new Camera();
		player = new Player(input);

		lastTime = Scheduler.time();
		
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		player.update(delta);

		lastTime = Scheduler.time();
		
	}

	function render(framebuffer: Framebuffer): Void {
		frame++;


		var g = framebuffer.g2;
		g.begin();
		g.imageScaleQuality = kha.graphics2.ImageScaleQuality.Low;
		
		camera.pos = new kha.math.Vector2(player.pos.x-kha.System.windowWidth()/2/camera.scale.x,player.pos.y-kha.System.windowHeight()/2/camera.scale.y);


		camera.transform(g);
		level.draw(g);
		player.draw(g);
		camera.restore(g);
		g.end();
	}
}
