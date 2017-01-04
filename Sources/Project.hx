package;

import kha.Framebuffer;
import kha.Scheduler;

//import entity.Player;

class Project {
	public var level:Level;
	public var camera:Camera;
	var frame = 0;
	//var player:Player;
	var input:Input;

	var lastTime:Float;
	public var entities:eskimo.EntityManager;

	var systems:eskimo.systems.SystemManager;

	var renderSystems = new Array<System>();
	
	var p:eskimo.Entity;

	var renderview:eskimo.views.View;

	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		var components = new eskimo.ComponentManager();
		entities = new eskimo.EntityManager(components);
		systems = new eskimo.systems.SystemManager(entities);
		

		input = new Input();

		camera = new Camera();
		level = new Level(camera);

		var lrsys = new system.TilemapRenderer(camera,entities);
		renderSystems.push(lrsys);
		systems.add(lrsys);
		var prsys = new system.ParticleRenderer(entities);
		renderSystems.push(prsys);
		systems.add(prsys);
		var dbsys = new system.CollisionDebugView(entities);
		renderSystems.push(dbsys);
		systems.add(dbsys);

		systems.add(new system.Renderer());
		systems.add(new system.KeyMovement(input,entities));
		systems.add(new system.Physics(entities));
		systems.add(new system.TimedLife(entities));
		systems.add(new system.Gun(input,camera,level.lights,entities));
		
		renderview = new eskimo.views.View(new eskimo.filters.Filter([component.Sprite,component.Transformation]), entities);

		var map = entities.create();
		map.set(new component.Transformation(new kha.math.Vector2()));
		map.set(new component.Tilemap());
		map.set(new component.Collisions([component.Collisions.CollisionGroup.Level]));

		var t = 0;
		for (tile in map.get(component.Tilemap).tiles){
			if (map.get(component.Tilemap).tileInfo.get(tile).collide){
				map.get(component.Collisions).registerCollisionRegion(new component.Collisions.RectangleCollisionShape(
					new kha.math.Vector2(t%map.get(component.Tilemap).width*8,Math.floor(t/map.get(component.Tilemap).width)*8),
					new kha.math.Vector2(8,8)));
			}
			t++;
		}
		

		//player = new Player(input,this);

		p = entities.create();
		
		p.set(new component.Transformation(new kha.math.Vector2(20,20)));
		p.set(new component.Sprite(0));
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Collisions([component.Collisions.CollisionGroup.Friendly],[component.Collisions.CollisionGroup.Friendly]).registerCollisionRegion(new component.Collisions.RectangleCollisionShape(new kha.math.Vector2(),new kha.math.Vector2(8,8))));
		p.set(new component.Light());
		
		p.get(component.Light).colour = kha.Color.Green;
		p.get(component.Light).strength = 2;

		//entities.push(level);
		//entities.push(player);

		for (i in 0...150){
			var x = Math.floor(Math.random()*level.width);
			var y = Math.floor(Math.random()*level.height);
			if (level.getTile(x,y) == 0) continue;
			var skelly = entities.create();
			skelly.set(new component.Transformation(new kha.math.Vector2(x*8,y*8)));
			skelly.set(new component.Sprite(3));
			skelly.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]).registerCollisionRegion(new component.Collisions.RectangleCollisionShape(skelly.get(component.Transformation).pos,new kha.math.Vector2(8,8))));
			//entities.push(skelly);
		}
		

		lastTime = Scheduler.time();

		kha.input.Mouse.get().hideSystemCursor();
		
	}

	function update() {
		var delta = Scheduler.time() - lastTime;
		
		systems.update(delta);

		lastTime = Scheduler.time();
	}
	function render(framebuffer: Framebuffer): Void { 
		frame++;


		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;
		
		camera.pos = new kha.math.Vector2(p.get(component.Transformation).pos.x-kha.System.windowWidth()/2/camera.scale.x,p.get(component.Transformation).pos.y-kha.System.windowHeight()/2/camera.scale.y);
		//camera.pos = new kha.math.Vector2(0,0);
		camera.transform(g);

		//level.draw(g);
		
		for (system in renderSystems)
			system.render(g);

		for (entity in renderview.entities){
			

			var sprite:component.Sprite = entity.get(component.Sprite);
			var transformation:component.Transformation = entity.get(component.Transformation);

			var originX = 4;
			var originY = 4;
			var x = transformation.pos.x;
			var y = transformation.pos.y;
			var angle = transformation.angle;

			g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(x + originX, y + originY)).multmat(kha.math.FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(kha.math.FastMatrix3.translation(-x - originX, -y - originY)));
					
			g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%8)*8),Math.floor(Math.floor(sprite.textureId/8)*8),8,8,x,y,8,8);
			
			g.popTransformation();
		}

		camera.restore(g);

		//Draw mouse cursor.
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/8 -4,input.mousePos.y/8 -4,2*8,0,8,8);

		g.end();
	}
}
