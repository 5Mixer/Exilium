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
	var realLastTime:Float;
	var lastRenderTime:Float;
	public var entities:eskimo.EntityManager;

	var systems:eskimo.systems.SystemManager;

	var renderSystems = new Array<System>();
	
	var p:eskimo.Entity;

	var renderview:eskimo.views.View;

	var minimap:kha.Image;
	var minimapOpacity = 1.0;
	
	var ui:Zui;
	var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json');
	var fpsGraph:ui.Graph;
	var updateGraph:ui.Graph;

	public function new() {
		kha.System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		
		input = new Input();
		camera = new Camera();
		kha.input.Mouse.get().hideSystemCursor();

		var components = new eskimo.ComponentManager();
		entities = new eskimo.EntityManager(components);
		systems = new eskimo.systems.SystemManager(entities);		


		registerRenderSystem(new system.TilemapRenderer(camera,entities));
		registerRenderSystem(new system.ParticleRenderer(entities));
		registerRenderSystem(new system.Renderer(entities));
		registerRenderSystem(new system.DebugView(entities));
		registerRenderSystem(new system.Healthbars(entities));
		
		var collisionSys = new system.Collisions(entities);
		//registerRenderSystem(new system.CollisionDebugView(entities,collisionSys.grid));
		
		systems.add(collisionSys);
		systems.add(new system.KeyMovement(input,entities));
		systems.add(new system.Physics(entities,collisionSys.grid));
		systems.add(new system.TimedLife(entities));
		systems.add(new system.Gun(input,camera,entities));
		
		resetWorld();

		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
		lastRenderTime = Scheduler.time();

		fpsGraph = new ui.Graph(new kha.math.Vector2(5,30),new kha.math.Vector2(200,60));
		updateGraph = new ui.Graph(new kha.math.Vector2(5,100),new kha.math.Vector2(200,60));
		
		input.listenToKeyRelease('r', resetWorld);
		input.listenToKeyRelease('q',function (){
			fpsGraph.visible = !fpsGraph.visible;
			updateGraph.visible = ! updateGraph.visible;
		});
	}
	function resetWorld(){
		createMap();
		createPlayer();
	}
	function registerRenderSystem(system:System){
		renderSystems.push(system);
		systems.add(system);
	}
	function createMap () {
		entities.clear();
		
		(cast systems.get(system.Collisions)).processFixedEntities = true;
		var map = entities.create();
		map.set(new component.Transformation(new kha.math.Vector2())); 
		map.set(new component.Tilemap());
		map.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
		map.get(component.Collisions).fixed = true;
		systems.add(new system.AI(entities,map.get(component.Tilemap)));


		var generator = new util.DungeonWorldGenerator(60,60);
		map.get(component.Tilemap).tiles = generator.tiles;
		map.get(component.Tilemap).width = 60;
		map.get(component.Tilemap).height = 60;
		
		minimap = kha.Image.createRenderTarget(60,60);
		
		minimapOpacity = 1.0;
		minimap.g2.begin();
		minimap.g2.clear(kha.Color.fromBytes(0,0,0,128));
		var t = 0;
		for (tile in generator.tiles){
			if (map.get(component.Tilemap).tileInfo.get(tile).collide){
				map.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(
					t%map.get(component.Tilemap).width*16,Math.floor(t/map.get(component.Tilemap).width)*16,
					16,16));

				minimap.g2.color = map.get(component.Tilemap).tileInfo.get(tile).colour;
				minimap.g2.fillRect(t%map.get(component.Tilemap).width,Math.floor(t/map.get(component.Tilemap).width),1,1);
				
			}
			t++;
		}
		minimap.g2.end();

		for (t in generator.treasure){
			var treasure = entities.create();
			treasure.set(new component.Transformation(new kha.math.Vector2(t.x*16,t.y*16)));
			treasure.set(new component.Sprite(cast spriteData.entity.chest));
			treasure.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
			treasure.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(0,0,8,8));
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
			var b:component.Collisions.Rect = new component.Collisions.Rect(0,0,8,8);
			slime.get(component.Collisions).registerCollisionRegion(b);
		}
	}
	function createPlayer() {
		if (p != null && p.get(component.Transformation) != null)
			p.destroy();

		p = entities.create();
		p.set(new component.Transformation(new kha.math.Vector2(31*16,32*16)));
		p.set(new component.AnimatedSprite(spriteData.entity.ghost.animations));
		p.set(new component.AITarget());
		p.set(new component.Health(50));
		p.get(component.AnimatedSprite).spriteMap = kha.Assets.images.Ghost;
		p.get(component.AnimatedSprite).tilesize = 10;
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Collisions([component.Collisions.CollisionGroup.Friendly],[component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Bullet]));
		p.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(0,0,10,10));
		p.set(new component.Light());
		
		p.get(component.Light).colour = kha.Color.fromBytes(255,200,200);//kha.Color.Green;
		p.get(component.Light).strength = .8;
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		var realDelta = Scheduler.realTime() - realLastTime;
		
		if (minimapOpacity > 0)
			if (minimapOpacity - delta < 0)
				minimapOpacity = 0;
			else
				minimapOpacity -= delta;

		systems.update(delta);
		cast(systems.get(system.Physics),system.Physics).grid = cast(systems.get(system.Collisions),system.Collisions).grid;

		if (p != null && p.has(component.Transformation))
			camera.pos = new kha.math.Vector2(p.get(component.Transformation).pos.x-kha.System.windowWidth()/2/camera.scale.x,p.get(component.Transformation).pos.y-kha.System.windowHeight()/2/camera.scale.y);
		
		fpsGraph.pushValue(1/delta/fpsGraph.size.y);
		

		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
	}
	function render(framebuffer: Framebuffer): Void {
		frame++;

		var renderDelta = Scheduler.time() - lastRenderTime;

		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;
		
		camera.transform(g);

		for (system in renderSystems)
			system.render(g);

		camera.restore(g);
		
		//Draw mouse cursor.
		g.color = kha.Color.White;
		g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/4 -8,input.mousePos.y/4 -8,2*16,0,16,16);


		//Clear any transformation for the UI.
		g.pushTransformation(kha.math.FastMatrix3.identity());
		g.transformation._00 = 5;
		g.transformation._11 = 5;
		g.transformation._20 = kha.System.windowWidth()/2 - minimap.width*5/2;
		g.transformation._21 = kha.System.windowHeight()/2 - minimap.height*5/2;
		g.color = kha.Color.fromFloats(1,1,1,minimapOpacity);
		g.drawImage(minimap,0,0);

		g.transformation = kha.math.FastMatrix3.identity();
		fpsGraph.render(g);
		updateGraph.render(g);

		g.popTransformation();
		
		g.end();

		updateGraph.pushValue(1/renderDelta/updateGraph.size.y);
		

		lastRenderTime = Scheduler.time();

		/*ui.begin(g);
        if (ui.window(Id.window(), 0, 0, 100, 100, Zui.LAYOUT_VERTICAL)) {
            if (ui.button("Hello")) {
                trace("World");
            }
        }
        ui.end();*/
	}
}
