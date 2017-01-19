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
	var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json');

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
		input.onRUp = function (){
			resetWorld();
		}

		lastTime = Scheduler.time();
		
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
			treasure.set(new component.Sprite(cast spriteData.entity.chest));
			treasure.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
			treasure.get(component.Collisions).registerCollisionRegion({x:0,y:0,width:8,height:8});
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
			var b:component.Collisions.Rect = {x:0,y:0,width:8,height:8};
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
		p.get(component.Collisions).registerCollisionRegion({x:0,y:0,width:10,height:10});
		p.set(new component.Light());
		
		p.get(component.Light).colour = kha.Color.fromBytes(255,200,200);//kha.Color.Green;
		p.get(component.Light).strength = .8;
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		
		systems.update(delta);
		cast(systems.get(system.Physics),system.Physics).grid = cast(systems.get(system.Collisions),system.Collisions).grid;

		if (p != null && p.has(component.Transformation))
			camera.pos = new kha.math.Vector2(p.get(component.Transformation).pos.x-kha.System.windowWidth()/2/camera.scale.x,p.get(component.Transformation).pos.y-kha.System.windowHeight()/2/camera.scale.y);
		

		lastTime = Scheduler.time();
	}
	function render(framebuffer: Framebuffer): Void { 
		frame++;


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
