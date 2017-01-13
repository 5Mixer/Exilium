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

		kha.SystemImpl.requestFullscreen();

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
		var dbsys = new system.CollisionDebugView(entities);
		renderSystems.push(dbsys);
		systems.add(dbsys);
		var renderer = new system.Renderer(entities);
		renderSystems.push(renderer);
		systems.add(renderer);
		var debug = new system.DebugView(entities);
		renderSystems.push(debug);
		systems.add(debug);
		haxe.Log.trace = debug.traceLog;

		systems.add(new system.KeyMovement(input,entities));
		systems.add(new system.Physics(entities));
		systems.add(new system.TimedLife(entities));
		systems.add(new system.Gun(input,camera,entities));
		
		var map = entities.create();
		map.set(new component.Transformation(new kha.math.Vector2()));
		map.set(new component.Tilemap());
		map.set(new component.Collisions());
		map.get(component.Collisions).lockShapesToEntityTransform = false;

		var generator = new util.DungeonWorldGenerator(180,180);
		map.get(component.Tilemap).tiles = generator.tiles;
		map.get(component.Tilemap).width = 180;
		map.get(component.Tilemap).height = 180;

		var t = 0;
		for (tile in generator.tiles){
			if (map.get(component.Tilemap).tileInfo.get(tile).collide){
				map.get(component.Collisions).registerCollisionRegion(differ.shapes.Polygon.rectangle(
					t%map.get(component.Tilemap).width*8,Math.floor(t/map.get(component.Tilemap).width)*8,
					8,8,false));
			}
			t++;
		}
		for (t in generator.treasure){
			var treasure = entities.create();
			treasure.set(new component.Transformation(new kha.math.Vector2(t.x*8,t.y*8)));
			//treasure.set(new component.Physics());
			treasure.set(new component.Sprite(4));
			treasure.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
			treasure.get(component.Collisions).registerCollisionRegion(differ.shapes.Polygon.rectangle(treasure.get(component.Transformation).pos.x,treasure.get(component.Transformation).pos.y,8,8,false));
			treasure.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Bullet]));
			
			//treasure.set(new component.Light());
			//treasure.get(component.Light).colour = kha.Color.fromBytes(0,0,140);//kha.Color.Green;
			//treasure.get(component.Light).strength = 1;
		}
		for (e in generator.enemies){
			//if (map.get(component.Tilemap).getTile(x,y) == 0) continue;
			var skelly = entities.create();
			skelly.set(new component.Transformation(new kha.math.Vector2(e.x*8,e.y*8)));
			skelly.set(new component.Sprite(3));
			skelly.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]));
			var b = differ.shapes.Polygon.rectangle(skelly.get(component.Transformation).pos.x,skelly.get(component.Transformation).pos.y,8,8,false);
			skelly.get(component.Collisions).registerCollisionRegion(b);
		}

		//player = new Player(input,this);

		p = entities.create();
		
		p.set(new component.Transformation(new kha.math.Vector2(31*8,31*8)));
		p.set(new component.Sprite(0));
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Collisions([component.Collisions.CollisionGroup.Friendly],[component.Collisions.CollisionGroup.Friendly]));
		p.get(component.Collisions).registerCollisionRegion(differ.shapes.Polygon.rectangle(p.get(component.Transformation).pos.x,p.get(component.Transformation).pos.y,8,8,false));
		p.set(new component.Light());
		
		p.get(component.Light).colour = kha.Color.fromBytes(130,240,140);//kha.Color.Green;
		p.get(component.Light).strength = 1.4;

		input.onRUp = function (){
			p.get(component.Transformation).pos = new kha.math.Vector2(31*8,31*8);
			
		}

		//entities.push(player);

		

		lastTime = Scheduler.time();

		kha.input.Mouse.get().hideSystemCursor();
		
	}

	function update() {
		var delta = Scheduler.time() - lastTime;
		
		systems.update(delta);

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
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/8 -4,input.mousePos.y/8 -4,2*8,0,8,8);

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
