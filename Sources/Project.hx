package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Project {
	public var level:Level;
	public var camera:Camera;
	var frame = 0;
	var player:Player;
	var input:Input;

	var lastTime:Float;
	public var entities:Array<Entity>;

	public function new() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		input = new Input();
		entities = new Array<Entity>();

		camera = new Camera();
		level = new Level(camera);
		player = new Player(input,this);
		
		entities.push(level);

		lastTime = Scheduler.time();

		kha.input.Mouse.get().hideSystemCursor();
		
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		player.update(delta);

		lastTime = Scheduler.time();
		
	}

	function render(framebuffer: Framebuffer): Void {
		frame++;


		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromBytes(84,36,55,255));
		g.imageScaleQuality = kha.graphics2.ImageScaleQuality.Low;
		
		camera.pos = new kha.math.Vector2(player.pos.x-kha.System.windowWidth()/2/camera.scale.x,player.pos.y-kha.System.windowHeight()/2/camera.scale.y);


		camera.transform(g);
		level.lights[0].pos = player.pos.div(8);
		level.draw(g);
		player.draw(g);
		
		

		var e = camera.screenToWorld(input.mousePos);
		g.color = kha.Color.Blue;
		//g.fillRect(e.x,e.y,1,1);
		g.color = kha.Color.White;



		camera.restore(g);
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/8 -4,input.mousePos.y/8 -4,2*8,0,8,8);

		

		g.end();
	}
}
