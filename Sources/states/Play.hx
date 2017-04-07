package states;

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


class Play extends states.State {
	var frame = 0;
	var input:Input;
	public var entities:eskimo.EntityManager;

	var lastRenderTime = 0.0;

	var systems:eskimo.systems.SystemManager;
	var renderSystems = new Array<System>();
	var renderview:eskimo.views.View;
	
	var p:eskimo.Entity;
	public var camera:Camera;

	var minimap:kha.Image;
	
	public static var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json');
	
	var dungeonLevel = 1;

	var lastSave:Save;
	var dungeons:Array<Dungeon> = [];
	
	var debugInterface:ui.DebugInterface;
	var mainMusicChannel:kha.audio1.AudioChannel;
	
	var tilemapRender:rendering.TilemapRenderer;
	var map:world.Tilemap;
	var mapShown = true;
	var mapCollisions:eskimo.Entity;
	var generator:worldgen.WorldGenerator;

	override public function new (){
		super();

		//mainMusicChannel = kha.audio1.Audio.play(kha.Assets.sounds.Synthwave_Beta_2,true);
		//mainMusicChannel.volume = .5;

		input = new Input();
		camera = new Camera();
		kha.input.Mouse.get().hideSystemCursor();

		var components = new eskimo.ComponentManager();
		entities = new eskimo.EntityManager(components);
		systems = new eskimo.systems.SystemManager(entities);

		var collisionSys = new system.Collisions(entities);
		tilemapRender = new rendering.TilemapRenderer(camera,entities);
		registerRenderSystem(new system.Renderer(entities));
		registerRenderSystem(new system.SpikeHandler(entities));
		registerRenderSystem(new system.ParticleRenderer(entities));
		registerRenderSystem(new system.GrappleHooker(input,camera,entities,collisionSys));
		registerRenderSystem(new system.DebugView(entities));
		registerRenderSystem(new system.Healthbars(entities));
		registerRenderSystem(new system.ActiveBoss(entities));
		registerRenderSystem(new system.CorruptSoulRenderer(entities));
		registerRenderSystem(new system.ShieldRenderer(input,camera,entities));
		
		registerRenderSystem(new system.CollisionDebugView(entities,collisionSys.grid,true));
		
		systems.add(collisionSys);
		systems.add(new system.KeyMovement(input,entities));
		systems.add(new system.Physics(entities,collisionSys.grid,collisionSys));
		systems.add(new system.Inventory(input,entities));
		systems.add(new system.TimedLife(entities));
		systems.add(new system.TimedLife(entities));
		systems.add(new system.Gun(input,camera,entities));
		systems.add(new system.AI(entities,null));
		systems.add(new system.CorruptSoulAI(entities,null));
		systems.add(new system.MummyAI(entities,null));
		systems.add(new system.Magnets(entities,p));
		systems.add(new system.TimedShoot(entities));
		
		map = createMap();

		debugInterface = new ui.DebugInterface(p);		
		//debugInterface.visible = false;
		
		input.listenToKeyRelease('r', descend);
		input.listenToKeyRelease('q',function (){
			debugInterface.visible = !debugInterface.visible;
		});
		input.listenToKeyRelease('m', function (){
			mapShown = !mapShown;
		});
		input.wheelListeners.push(function(dir){
			if (p.get(component.Inventory) == null) return;
			p.get(component.Inventory).activeIndex += dir;
			if (p.get(component.Inventory).activeIndex < 0) p.get(component.Inventory).activeIndex = p.get(component.Inventory).length-1;
			if (p.get(component.Inventory).activeIndex > p.get(component.Inventory).length-1) p.get(component.Inventory).activeIndex = 0;
			cast(systems.get(system.Inventory),system.Inventory).onChangeItem();
		});

		lastRenderTime = kha.Scheduler.time();
	}
	function registerRenderSystem(system:System){
		renderSystems.push(system);
		systems.add(system);
	}

	function createMap () {
		entities.clear();
		
		(cast systems.get(system.Collisions)).processFixedEntities = true;
		map = new world.Tilemap();
		mapCollisions = entities.create();
		mapCollisions.set(new component.Transformation(new kha.math.Vector2()));
		mapCollisions.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[]));
		mapCollisions.get(component.Collisions).fixed = true;
		(cast systems.get(system.AI)).map = map;

		var worldSize = 60;
		if (dungeonLevel == 1) {
			generator = new worldgen.TiledStructure(worldSize,worldSize);
		}else if (dungeonLevel > 1){
			generator = new worldgen.DungeonWorldGenerator(worldSize,worldSize);

		}
		map.tiles = generator.tiles;
		map.width = generator.width;
		map.height = generator.height;
		
		minimap = kha.Image.createRenderTarget(worldSize,worldSize);
		
		minimap.g2.begin();
		minimap.g2.clear(kha.Color.fromBytes(0,0,0,0));
		var t = 0;
		var collisionRects = [];
		while (t < generator.tiles.length-1){
			var tile = generator.tiles[t];

			if (map.tileInfo.get(tile.id).collide){
				var x = t%map.width;
				var y = Math.floor(t/map.width);
				var width = 1;
				var height = 1;
				/*while (map.get(component.Tilemap).tileInfo.get(generator.tiles[t+width]).collide && Math.floor((t+width)/map.get(component.Tilemap).width) == y){
					width += 1;
				}*/
				
				collisionRects.push({x:x,y:y,width:width,height:height,resolved:false,t:t});

				t += width;

				minimap.g2.color = map.tileInfo.get(tile.id).colour;
				minimap.g2.fillRect(t%map.width,Math.floor(t/map.width),1,1);
				
			}else{
				t+=1;
			}
		}
		for (rect in collisionRects){
			if (rect.resolved) continue;
			var width = 1;
			/*while (generator.tiles[rect.t+width] != null && map.get(component.Tilemap).tileInfo.get(generator.tiles[rect.t+width]).collide && Math.floor((rect.t+width)/map.get(component.Tilemap).width) == rect.y){
				width += 1;
				collisionRects[rect.t+width].resolved=true;
				rect.resolved = true;
			}*/
			mapCollisions.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(
					rect.x*16,rect.y*16,
					width*16,rect.height*16));
		}

		minimap.g2.color = kha.Color.Red;
		minimap.g2.fillRect(generator.spawnPoint.x,generator.spawnPoint.y,1,1);

		minimap.g2.color = kha.Color.Green;
		minimap.g2.fillRect(generator.exitPoint.x,generator.exitPoint.y,1,1);
		minimap.g2.end();
		
		for (e in generator.entities){
			switch e.type {
				case worldgen.WorldGenerator.EntityType.Treasure: EntityFactory.createTreasure(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Enemy: EntityFactory.createSlime(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Spike: EntityFactory.createSpike(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Shooter: EntityFactory.createShooterTrap(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Lava: EntityFactory.createLava(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.CorruptSoulBoss: EntityFactory.createCorruptSoul(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Item(item): EntityFactory.createItem(entities,item,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Door: EntityFactory.createLockedDoor(entities,e.x*16,e.y*16);
			}
		}

		EntityFactory.createLadder(entities,generator.exitPoint.x*16,generator.exitPoint.y*16,function (collider){
			descend();
		});
		//EntityFactory.createMummy(entities,generator.spawnPoint.x*16+10,generator.spawnPoint.y*16);

		p = EntityFactory.createPlayer(entities,{x:generator.spawnPoint.x, y:generator.spawnPoint.y});
		p.get(component.Inventory).putIntoInventory(component.Inventory.Item.SlimeGun);
		p.get(component.Events).listenToEvent(component.Events.Event.Death,function (args){
			Project.states.push(new states.Dead());
		});
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
	
	override public function render (framebuffer:kha.Framebuffer){
		var renderDelta = kha.Scheduler.time() - lastRenderTime;
		lastRenderTime = kha.Scheduler.time();



		minimap = kha.Image.createRenderTarget(60,60);
		
		minimap.g2.begin();
		minimap.g2.clear(kha.Color.fromBytes(0,0,0,0));
		var t = 0;
		while (t < map.tiles.length-1){
			var tile = map.tiles[t];
			if (map.tileInfo.get(tile.id).collide){
				var x = t%map.width;
				var y = Math.floor(t/map.width);
				t++;

				minimap.g2.color = map.tileInfo.get(tile.id).colour;
				minimap.g2.fillRect(t%map.width,Math.floor(t/map.width),1,1);
				
			}else{
				t+=1;
			}
		}
		minimap.g2.color = kha.Color.Red;
		minimap.g2.fillRect(generator.spawnPoint.x,generator.spawnPoint.y,1,1);

		minimap.g2.color = kha.Color.Green;
		minimap.g2.fillRect(generator.exitPoint.x,generator.exitPoint.y,1,1);

		var ppos = p.get(component.Transformation).pos;
		minimap.g2.color = kha.Color.White;
		minimap.g2.fillRect(Math.floor((ppos.x+16)/16),Math.floor((ppos.y+5)/16),1,1);
		minimap.g2.end();



		cast(systems.get(system.ShieldRenderer),system.ShieldRenderer).prepass();

		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;
		
		//Let individual systems render.
		camera.transform(g);
		tilemapRender.render(g,map);
		for (system in renderSystems)
			system.render(g);
		camera.restore(g);
		
		//Draw mouse cursor.
		if (debugInterface.visible){
			kha.input.Mouse.get().showSystemCursor();
			input.mouseEvents = false;
		}else{
			input.mouseEvents = true;
			kha.input.Mouse.get().hideSystemCursor();
			g.color = kha.Color.White;
			g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/4 -8,input.mousePos.y/4 -8,2*16,0,16,16);
		}

		//Clear any transformation for the UI.
		if (mapShown){
			g.pushTransformation(kha.math.FastMatrix3.identity());
			g.transformation._00 = 4;
			g.transformation._11 = 4;
			g.drawImage(minimap,kha.System.windowWidth()/4 - map.width,0);

		}
		g.transformation = kha.math.FastMatrix3.identity();

		var x = 0;
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38;

		var pinv = p.get(component.Inventory);
		g.color = kha.Color.fromBytes(234,211,220);

		if (p.has(component.Inventory)){
			g.drawString(pinv.itemData.get(pinv.getByIndex(pinv.activeIndex).item).name,(3*4), -1*4);
			
			g.translate(0,8*4);
			for (stack in p.get(component.Inventory).stacks){
				g.transformation._00 = camera.scale.x;
				g.transformation._11 = camera.scale.y;
				system.Renderer.renderSpriteData(g,p.get(component.Inventory).itemData.get(stack.item).sprite,6,x*10);
				
				g.color = kha.Color.fromBytes(112,107,137);
				if (x == pinv.activeIndex)
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

		g.popTransformation();
		
		g.end();

		g.color = kha.Color.White;
		debugInterface.render(g);
		debugInterface.updateGraph.pushValue(1/renderDelta/debugInterface.updateGraph.size.y);
		
	}
	override public function update(delta:Float){
		input.startUpdate();
				
		systems.update(delta);
		cast(systems.get(system.Physics),system.Physics).grid = cast(systems.get(system.Collisions),system.Collisions).grid;
		cast(systems.get(system.Magnets),system.Magnets).p = p;

		if (p != null && p.has(component.Transformation))
			camera.pos = new kha.math.Vector2(p.get(component.Transformation).pos.x-kha.System.windowWidth()/2/camera.scale.x,p.get(component.Transformation).pos.y-kha.System.windowHeight()/2/camera.scale.y);
		
		debugInterface.fpsGraph.pushValue(1/delta/debugInterface.fpsGraph.size.y);
		
		// if (p.has(component.Transformation)){
		// 	var playerPosition = p.get(component.Transformation).pos;
		// 	var playerZone = map.get(Math.round(playerPosition.x/16),Math.round(playerPosition.y/16)).zone;
		// 	debugInterface.windows = [{
		// 		title:"world",
		// 		contents: [
		// 			ui.DebugInterface.Module.Label("Zone: "+playerZone)
		// 		]
		// 	}];
		// }

		cast(systems.get(system.CollisionDebugView),system.CollisionDebugView).showActiveEntities = (debugInterface.activeCollisionRegionsShown);
		cast(systems.get(system.CollisionDebugView),system.CollisionDebugView).showStaticEntities = (debugInterface.staticCollisionRegionsShown);
		
		input.endUpdate();
	}
}