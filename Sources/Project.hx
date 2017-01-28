package;

import kha.Framebuffer;
import kha.Scheduler;
//import entity.Player;

typedef Dungeon = {
	var seed:Int;
}
typedef PlayerSave = {
	var pos : {x: Int, y:Int};
	var health: Int;
	var inventory: Array<component.Inventory.Stack>;
}
typedef Save  = {
	var player : PlayerSave;
	var dungeonLevel: Int;
	var dungeons:Array<Dungeon>;
}

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
	
	//var ui:Zui;
	public static var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json');
	var fpsGraph:ui.Graph;
	var updateGraph:ui.Graph;
	var dungeonLevel = 1;

	var overlay:Float = 0.0;

	//var dungeonLevels = Array<DungeonLevel>;
	var lastSave:Save;
	var dungeons:Array<Dungeon> = [];
	var inventorySelectIndex = 0;

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
		systems.add(new system.AI(entities,null));
		
		createMap();

		lastTime = Scheduler.time();
		realLastTime = Scheduler.realTime();
		lastRenderTime = Scheduler.time();

		fpsGraph = new ui.Graph(new kha.math.Vector2(5,30),new kha.math.Vector2(200,60));
		updateGraph = new ui.Graph(new kha.math.Vector2(5,100),new kha.math.Vector2(200,60));
		
		input.listenToKeyRelease('r', descend);
		input.listenToKeyRelease('q',function (){
			fpsGraph.visible = !fpsGraph.visible;
			updateGraph.visible = ! updateGraph.visible;
		});
		input.listenToKeyRelease('m', function (){
			minimapOpacity = 1.0;
		});
		input.wheelListeners.push(function(dir){
			inventorySelectIndex += dir;
			if (inventorySelectIndex < 0) inventorySelectIndex = p.get(component.Inventory).length-1;
			if (inventorySelectIndex > p.get(component.Inventory).length-1) inventorySelectIndex = 0;
		});
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
		(cast systems.get(system.AI)).map = map.get(component.Tilemap);


		var generator = new util.DungeonWorldGenerator(60,60);
		map.get(component.Tilemap).tiles = generator.tiles;
		map.get(component.Tilemap).width = 60;
		map.get(component.Tilemap).height = 60;
		
		minimap = kha.Image.createRenderTarget(60,60);
		
		minimapOpacity = 1.0;
		minimap.g2.begin();
		minimap.g2.clear(kha.Color.fromBytes(0,0,0,200));
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
		minimap.g2.color = kha.Color.Red;
		minimap.g2.fillRect(generator.spawnPoint.x,generator.spawnPoint.y,1,1);

		minimap.g2.color = kha.Color.Green;
		minimap.g2.fillRect(generator.exitPoint.x,generator.exitPoint.y,1,1);
		minimap.g2.end();
		
		for (t in generator.treasure){
			EntityFactory.createTreasure(entities,t.x*16,t.y*16);
		}
		for (e in generator.enemies){
			EntityFactory.createSlime(entities,e.x*16,e.y*16);
			EntityFactory.createGoblin(entities,e.x*16,e.y*16);
		}

		EntityFactory.createLadder(entities,generator.exitPoint.x*16,generator.exitPoint.y*16,descend);

		p = EntityFactory.createPlayer(entities,{x:generator.spawnPoint.x, y:generator.spawnPoint.y});
		p.get(component.Inventory).putIntoInventory(component.Inventory.Item.SlimeGun);
		if (lastSave != null && lastSave.player != null){
			p.get(component.Health).current = lastSave.player.health;
			p.get(component.Inventory).stacks = lastSave.player.inventory;
		}

		dungeons.push ({
			seed: generator.seed
		});

		return map;
	}
	function descend (){
		trace("You enter deeper into the dungeon...");
		overlay = .7;
		dungeonLevel++;
		save();
		createMap();
		save();
	}
	
	function save (){
		lastSave = {
			dungeonLevel: dungeonLevel,
			dungeons: dungeons,
			player: null
		};
		if (p.get(component.Transformation) != null)
			lastSave.player = {
				pos: {
					x: Math.round(p.get(component.Transformation).pos.x),
					y: Math.round(p.get(component.Transformation).pos.y)
				},
				health: Math.round(p.get(component.Health).current),
				inventory: p.get(component.Inventory).stacks
			}
		
	}

	function update() {
		
		var delta = Scheduler.time() - lastTime;
		var realDelta = Scheduler.realTime() - realLastTime;

		if (p.get(component.Inventory) != null){
			var pinv = p.get(component.Inventory);
			var itemData = pinv.itemData.get(pinv.getByIndex(inventorySelectIndex).item);
			if (itemData.type == component.Inventory.ItemType.Gun){
				p.get(component.Gun).gun = component.Gun.GunType.SlimeGun;
			}else{
				p.get(component.Gun).gun = null;

			}
		}
		
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
		
		if (overlay > 0.0) overlay -= delta;
		if (overlay < 0.0) overlay = 0.0;

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

		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		
		var x = 0;
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38;//Math.floor(frame/30);
		if (p.has(component.Inventory)){
			for (stack in p.get(component.Inventory).stacks){
				g.transformation._00 = camera.scale.x;
				g.transformation._11 = camera.scale.y;
				system.Renderer.renderSpriteData(g,p.get(component.Inventory).itemData.get(stack.item).sprite,6,x*10);
				
				g.color = kha.Color.fromBytes(112,107,137);
				if (x == inventorySelectIndex)
					g.fillRect(1,x*10+1,1,6);

				g.transformation._00 = 1;
				g.transformation._11 = 1;
				g.color = kha.Color.fromBytes(234,211,220);
				g.drawString(stack.quantity+"",(3*4), (x*10*4)-8);
				
				x++;
				
			}
		}

		g.transformation = kha.math.FastMatrix3.identity();
		g.font = kha.Assets.fonts.OpenSans;
		g.color = kha.Color.White;
		g.fontSize = 20;
		g.drawString("Floor "+dungeonLevel,10,kha.System.windowHeight()-30);

		g.transformation = kha.math.FastMatrix3.identity();

		g.color = kha.Color.fromFloats(0,0,0,overlay);
		g.fillRect(0,0,kha.System.windowWidth(),kha.System.windowHeight());

		g.color = kha.Color.White;
		fpsGraph.render(g);
		updateGraph.render(g);

		g.popTransformation();
		
		g.end();

		updateGraph.pushValue(1/renderDelta/updateGraph.size.y);
		

		lastRenderTime = Scheduler.time();
	}
}
