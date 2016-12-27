package;

import kha.Framebuffer;
import kha.Scheduler;

import entity.Player;

class Project {
	public var level:Level;
	public var camera:Camera;
	var frame = 0;
	var player:Player;
	var input:Input;

	var lastTime:Float;
	public var entities:eskimo.EntityManager;

	var systems:eskimo.systems.SystemManager;
	
	var p:eskimo.Entity;

	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		var components = new eskimo.ComponentManager();
		entities = new eskimo.EntityManager(components);
		systems = new eskimo.systems.SystemManager(entities);
		

		input = new Input();

		camera = new Camera();
		level = new Level(camera);

		systems.add(new system.Renderer());
		systems.add(new system.KeyMovement(input));
		systems.add(new system.Physics(entities));
		systems.add(new system.Gun(input,camera,level.lights));

		player = new Player(input,this);

		p = entities.create();
		
		p.set(new component.Transformation(new kha.math.Vector2(20,20)));
		p.set(new component.Sprite(0));
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Collisions().registerCollisionRegion(new component.Collisions.RectangleCollisionShape(new kha.math.Vector2(),new kha.math.Vector2(8,8))));
		
		
		//entities.push(level);
		//entities.push(player);

		for (i in 0...150){
			var x = Math.floor(Math.random()*level.width);
			var y = Math.floor(Math.random()*level.height);
			if (level.getTile(x,y) == 0) continue;
			var skelly = new entity.Skeleton(this,new kha.math.Vector2(x*8,y*8),function (e){
				//entities.remove(e);
			});
			//entities.push(skelly);
		}

		lastTime = Scheduler.time();

		kha.input.Mouse.get().hideSystemCursor();
		
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		
		//for (entity in entities)
		//	entity.update(delta);

		for (system in systems.)
		system.update(delta);


		lastTime = Scheduler.time();
	}

	function render(framebuffer: Framebuffer): Void {
		frame++;

		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;
		
		//camera.pos = new kha.math.Vector2(player.pos.x-kha.System.windowWidth()/2/camera.scale.x,player.pos.y-kha.System.windowHeight()/2/camera.scale.y);
		camera.pos = new kha.math.Vector2(p.get(component.Transformation).pos.x-kha.System.windowWidth()/2/camera.scale.x,p.get(component.Transformation).pos.y-kha.System.windowHeight()/2/camera.scale.y);
		//camera.pos = new kha.math.Vector2(60,60);
		camera.transform(g);
		
		//for (entity in entities)
		//	entity.draw(g);
		
		for (system in systems)
			system.render(g,entities);

		camera.restore(g);

		//Draw mouse cursor.
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/8 -4,input.mousePos.y/8 -4,2*8,0,8,8);

		g.end();
	}
}
