package;

import kha.Framebuffer;
import kha.Scheduler;
import zui.Zui;
import zui.Id;
//import entity.Player;

class Project {
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
	
	var ui:Zui;

	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json');
		
		//kha.SystemImpl.requestFullscreen();

		ui = new Zui(kha.Assets.fonts.OpenSans, 17, 16, 0, 1.5);

		var components = new eskimo.ComponentManager();
		entities = new eskimo.EntityManager(components);
		systems = new eskimo.systems.SystemManager(entities);		

		input = new Input();

		camera = new Camera();

		var lrsys = new system.TilemapRenderer(camera,entities);
		renderSystems.push(lrsys);
		systems.add(lrsys);
		var prsys = new system.ParticleRenderer(entities);
		renderSystems.push(prsys);
		systems.add(prsys);
		
		var renderer = new system.Renderer(entities);
		renderSystems.push(renderer);
		systems.add(renderer);
		var debug = new system.DebugView(entities);
		renderSystems.push(debug);
		systems.add(debug);
		//haxe.Log.trace = debug.traceLog;

		var collisionSys = new system.Collisions(entities);

		var dbsys = new system.CollisionDebugView(entities,collisionSys.grid);
		renderSystems.push(dbsys);
		systems.add(dbsys);

		renderSystems.push(new system.Healthbars(entities));

		systems.add(new system.KeyMovement(input,entities));
		systems.add(collisionSys);
		systems.add(new system.Physics(entities,collisionSys.grid));
		systems.add(new system.TimedLife(entities));
		systems.add(new system.Gun(input,camera,entities));
		
		var map = entities.create();
		map.set(new component.Transformation(new kha.math.Vector2()));
		map.set(new component.Tilemap());
		map.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
		map.get(component.Collisions).lockShapesToEntityTransform = false;

		
		systems.add(new system.AI(entities,map.get(component.Tilemap)));

		var generator = new util.DungeonWorldGenerator(120,120);
		map.get(component.Tilemap).tiles = generator.tiles;
		map.get(component.Tilemap).width = 120;
		map.get(component.Tilemap).height = 120;

		var t = 0;
		for (tile in generator.tiles){
			if (map.get(component.Tilemap).tileInfo.get(tile).collide){
				map.get(component.Collisions).registerCollisionRegion({
					x:t%map.get(component.Tilemap).width*16,y:Math.floor(t/map.get(component.Tilemap).width)*16,
					width:16,height:16});
			}
			t++;
		}
		for (t in generator.treasure){
			var treasure = entities.create();
			treasure.set(new component.Transformation(new kha.math.Vector2(t.x*16,t.y*16)));
			treasure.set(new component.Sprite(4));
			treasure.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
			treasure.get(component.Collisions).registerCollisionRegion({x:treasure.get(component.Transformation).pos.x,y:treasure.get(component.Transformation).pos.y,width:16,height:16});
			treasure.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Bullet]));
			
			//treasure.set(new component.Light());
			//treasure.get(component.Light).colour = kha.Color.fromBytes(0,0,140);//kha.Color.Green;
			//treasure.get(component.Light).strength = 1;
		}
		for (e in generator.enemies){
			//if (map.get(component.Tilemap).getTile(x,y) == 0) continue;
			var slime = entities.create();
			slime.set(new component.Transformation(new kha.math.Vector2(e.x*16,e.y*16)));
			slime.set(new component.AnimatedSprite(spriteData.entity.slime.animations));
			slime.set(new component.Health(5));
			slime.get(component.AnimatedSprite).spriteMap = kha.Assets.images.Slime;
			slime.get(component.AnimatedSprite).tilesize = 8;
			slime.get(component.AnimatedSprite).speed = 4;
			slime.set(new component.Physics());
			slime.set(new component.AI());
			slime.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Bullet]));
			slime.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]));
			var b = {x:slime.get(component.Transformation).pos.x,y:slime.get(component.Transformation).pos.y,width:8,height:8};
			slime.get(component.Collisions).registerCollisionRegion(b);
		}

		p = entities.create();
		
		p.set(new component.Transformation(new kha.math.Vector2(31*16,31*16)));
		//p.set(new component.Sprite(0));
		p.set(new component.AnimatedSprite(spriteData.entity.ghost.animations));
		p.set(new component.AITarget());
		p.set(new component.Health(50));
		p.get(component.AnimatedSprite).spriteMap = kha.Assets.images.Ghost;
		p.get(component.AnimatedSprite).tilesize = 10;
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Collisions([component.Collisions.CollisionGroup.Friendly],[component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Bullet]));
		p.get(component.Collisions).registerCollisionRegion({x:p.get(component.Transformation).pos.x,y:p.get(component.Transformation).pos.y,width:10,height:10});
		p.set(new component.Light());
		
		p.get(component.Light).colour = kha.Color.fromBytes(255,200,200);//kha.Color.Green;
		p.get(component.Light).strength = .8;

		input.onRUp = function (){
			p.get(component.Transformation).pos = new kha.math.Vector2(31*16,31*16);
			
		}

		lastTime = Scheduler.time();

		kha.input.Mouse.get().hideSystemCursor();
		
	}

	function update() {
		//if (frame%30 == 0)
		//	trace(Math.random());
		
		var delta = Scheduler.time() - lastTime;
		
		systems.update(delta);
		cast(systems.get(system.Physics),system.Physics).grid = cast(systems.get(system.Collisions),system.Collisions).grid;

		camera.pos = new kha.math.Vector2(p.get(component.Transformation).pos.x-kha.System.windowWidth()/2/camera.scale.x,p.get(component.Transformation).pos.y-kha.System.windowHeight()/2/camera.scale.y);
		

		lastTime = Scheduler.time();
	}
	function render(framebuffer: Framebuffer): Void { 
		frame++;


		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;
		
		//camera.pos = new kha.math.Vector2(0,0);
		camera.transform(g);

		//level.draw(g);
		
		for (system in renderSystems)
			system.render(g);

	
		camera.restore(g);
		

		//Draw mouse cursor.
		g.color = kha.Color.White;
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/4 -4,input.mousePos.y/4 -4,2*16,0,16,16);

		g.end();

		//Clear any transformation for the UI.
		g.transformation = kha.math.FastMatrix3.identity();

		/*ui.begin(g);
        if (ui.window(Id.window(), 0, 0, 100, 100, Zui.LAYOUT_VERTICAL)) {
            if (ui.button("Hello")) {
                trace("World");
            }
        }
        ui.end();*/
	}
}
