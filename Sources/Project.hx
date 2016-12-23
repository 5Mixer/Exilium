package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import entity.Player;

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
		entities.push(player);

		for (i in 0...150){
			var x = Math.floor(Math.random()*level.width);
			var y = Math.floor(Math.random()*level.height);
			if (level.getTile(x,y) == 0) continue;
			var skelly = new entity.Skeleton(this,new kha.math.Vector2(x*8,y*8),function (e){
				entities.remove(e);
			});
			entities.push(skelly);
		}

		lastTime = Scheduler.time();

		kha.input.Mouse.get().hideSystemCursor();
		
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		
		for (entity in entities)
			entity.update(delta);


		lastTime = Scheduler.time();
	}

	function render(framebuffer: Framebuffer): Void {
		frame++;

		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;
		
		camera.pos = new kha.math.Vector2(player.pos.x-kha.System.windowWidth()/2/camera.scale.x,player.pos.y-kha.System.windowHeight()/2/camera.scale.y);

		camera.transform(g);
		
		for (entity in entities)
			entity.draw(g);

		camera.restore(g);

		//Draw mouse cursor.
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/8 -4,input.mousePos.y/8 -4,2*8,0,8,8);

		g.end();
	}
}
