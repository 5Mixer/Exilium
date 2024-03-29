package states;

import zui.Zui;

typedef Dungeon = {
	var seed:Int;
}
typedef PlayerSave = {
	var pos : {x: Int, y:Int};
	var health: Int;
	var inventory: Array<component.Inventory.Stack>;
	var inventoryIndex:Int;
}
typedef Save  = {
	var player : PlayerSave;
	var dungeonLevel: Int;
	var dungeons:Array<Dungeon>;
}

class Play extends states.State {
	var frame = 0;
	var input:Input;
	var lastRenderTime = 0.0;
	public var entities:eskimo.EntityManager;
	var p:eskimo.Entity;
	public var camera:Camera;
	public var track:kha.audio1.AudioChannel;

	var systems:eskimo.systems.SystemManager;
	var renderSystems = new Array<System>();
	var renderview:eskimo.views.View;
	
	public static var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json');
	
	var dungeonLevel = 1;

	var lastSave:Save;
	var dungeons:Array<Dungeon> = [];
	
	var debugInterface:ui.DebugInterface;
	var audioInterface:ui.AudioInterface;
	var mainMusicChannel:kha.audio1.AudioChannel;
	var zuiInstance:Zui;
	
	var tilemapRender:rendering.TilemapRenderer;
	var map:world.Tilemap;
	var mapCollisions:eskimo.Entity;
	var generator:worldgen.WorldGenerator;

	var minimap:kha.Image;
	var mapShown = true;
	var paused = false;

	public var openShop:ui.Shop ;

	var overlayShade = 0.;

	var playlist = [2,3,4,5];
	var soundFiles:Array<kha.Sound> = [];

	override public function new (){
		super();


		input = new Input();
		camera = new Camera();
		kha.input.Mouse.get().hideSystemCursor();
		
		minimap = kha.Image.createRenderTarget(60,60);

		var components = new eskimo.ComponentManager();
		entities = new eskimo.EntityManager(components);
		systems = new eskimo.systems.SystemManager(entities);

		var collisionSys = new system.Collisions(entities,this);
		tilemapRender = new rendering.TilemapRenderer(camera,entities);
		registerRenderSystem(new system.Renderer(entities));
		registerRenderSystem(new system.CactusBoss(entities));
		registerRenderSystem(new system.SpikeHandler(entities));
		registerRenderSystem(new system.PotionEffects(entities));
		registerRenderSystem(new system.ParticleRenderer(entities));
		registerRenderSystem(new system.GrappleHooker(input,camera,entities,collisionSys));
		registerRenderSystem(new system.Gun(input,camera,entities));
		registerRenderSystem(new system.DebugView(entities));
		registerRenderSystem(new system.Healthbars(entities));
		registerRenderSystem(new system.ActiveBoss(entities));
		registerRenderSystem(new system.ShieldRenderer(input,camera,entities));
		registerRenderSystem(new system.CorruptSoulRenderer(entities));
		registerRenderSystem(new system.MessageRenderer(entities));
		registerRenderSystem(new system.CollisionDebugView(entities,collisionSys.grid,true));
		
		systems.add(collisionSys);
		systems.add(new system.KeyMovement(input,entities));
		systems.add(new system.Physics(entities,collisionSys.grid,collisionSys));
		systems.add(new system.Inventory(input,entities));
		systems.add(new system.TimedLife(entities,camera));
		systems.add(new system.ParticleTrails(entities));
		systems.add(new system.AI(entities,null));
		systems.add(new system.CorruptSoulAI(entities,null));
		systems.add(new system.MummyAI(entities,null));
		systems.add(new system.GoblinAI(entities,null));
		systems.add(new system.BatAI(entities));
		systems.add(new system.Magnets(entities,p));
		systems.add(new system.TimedShoot(entities));
		systems.add(new system.TimedCalls(entities));
		systems.add(new system.Spinner(entities));
		
		map = createMap();

		zuiInstance = new Zui({font: kha.Assets.fonts.OpenSans});
		debugInterface = new ui.DebugInterface(zuiInstance,p);
		audioInterface = new ui.AudioInterface(zuiInstance);		
		debugInterface.visible = false;
		
		input.listenToKeyRelease(kha.input.KeyCode.R, descend);
		input.listenToKeyRelease(kha.input.KeyCode.T,function (){
			debugInterface.visible = !debugInterface.visible;
			audioInterface.visible = debugInterface.visible;
		});
		input.listenToKeyRelease(kha.input.KeyCode.M, function (){
			mapShown = !mapShown;
		});
		input.listenToKeyRelease(kha.input.KeyCode.Escape, function (){
			if (openShop != null){
				kha.audio1.Audio.play(kha.Assets.sounds.close_shop);
				openShop.close();
				openShop = null;
				return;
			}
			kha.audio1.Audio.play(kha.Assets.sounds.button_click);
			paused = !paused;
		});
		input.wheelListeners.push(offsetInventorySelection);

		lastRenderTime = kha.Scheduler.time();

		track = kha.audio1.Audio.play(kha.Assets.sounds.track_3);
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
		// mapCollisions.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[]));
		// mapCollisions.get(component.Collisions).fixed = true;
		(cast systems.get(system.AI)).map = map;

		var difficulty = (dungeonLevel + 1)*2;
		var worldSize = Math.floor(Math.min(70,40+difficulty*3));
		generator = dungeonLevel == 1 ? new worldgen.TiledStructure(worldSize,worldSize) : new worldgen.DungeonWorldGenerator(worldSize,worldSize);
		
		if (dungeonLevel != 1){
			(cast generator).difficulty = difficulty;
		}

		map.tiles = generator.tiles;
		map.width = generator.width;
		map.height = generator.height;
		
		minimap = kha.Image.createRenderTarget(worldSize,worldSize);
		
		var i = 0;
		for (tile in generator.tiles){
			if (map.tileInfo.get(tile.id).collide){
				var x = i%map.width;
				var y = Math.floor(i/map.width);

				var mapCollisions = entities.create();
				mapCollisions.set(new component.Transformation(new kha.math.Vector2(x*16,y*16)));
				mapCollisions.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[],new component.Collisions.Rect(0,0,16,16)));
				
				// mapCollisions.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(
				// 		x*16,y*16,
				// 		16,16));
			}
			i++;
		}

		cast (systems.get(system.Renderer),system.Renderer).tilemap = map;
		cast (systems.get(system.ParticleRenderer),system.ParticleRenderer).tilemap = map;

		if (dungeonLevel == 4){
			EntityFactory.createSign(entities,(generator.spawnPoint.x+1)*16,generator.spawnPoint.y*16,"Beware, a corrupt evil/nlives in this realm.");
			EntityFactory.createCorruptSoul(entities,(generator.exitPoint.x+1)*16,generator.exitPoint.y*16);
		}
		
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
				case worldgen.WorldGenerator.EntityType.RoomDoor(room): EntityFactory.createRoomDoor(entities,map,room,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Torch: EntityFactory.createTorch(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Sign(message): EntityFactory.createSign(entities,e.x*16,e.y*16,message);
				case worldgen.WorldGenerator.EntityType.Bat: EntityFactory.createBat(entities,e.x*16,e.y*16);
				case worldgen.WorldGenerator.EntityType.Mummy: EntityFactory.createMummy(entities,e.x*16+10,e.y*16);
				case worldgen.WorldGenerator.EntityType.Goblin: EntityFactory.createGoblin(entities,e.x*16+10,e.y*16);
				case worldgen.WorldGenerator.EntityType.PotionSeller: EntityFactory.createShop(entities,input,p.get(component.Inventory),e.x*16,e.y*16);
			}
		}

		//Place ladder
		EntityFactory.createLadder(entities,generator.exitPoint.x*16,generator.exitPoint.y*16,function (collider){
			if (openShop == null)
				descend();
		});

		//Place cactus boss
		if (Std.is(generator,worldgen.DungeonWorldGenerator)){
			var dungeon:worldgen.DungeonWorldGenerator = cast generator;
			var room = dungeon.rooms[2];
			var pos = dungeon.middleOfRoom(room);
			//EntityFactory.createCactusBoss(entities,pos.x*16,pos.y*16,room);
		}

		//Creator the player.
		p = EntityFactory.createPlayer(entities,{x:generator.spawnPoint.x, y:generator.spawnPoint.y});
		p.get(component.Inventory).putIntoInventory(component.Inventory.Item.SlimeGun);
		p.get(component.Events).listenToEvent(component.Events.Event.Death,function (args){
			track.stop();
			Project.states = [new states.Dead()];
		});

		//Load the player
		if (lastSave != null && lastSave.player != null){
			p.get(component.Health).current = lastSave.player.health;
			p.get(component.Inventory).stacks = lastSave.player.inventory;
			p.get(component.Inventory).activeIndex = lastSave.player.inventoryIndex;
		}

		dungeons.push ({
			seed: generator.seed
		});

		return map;
	}

	var descending = false;
	function descend (){
		if (descending) return;
		descending = true;
		dungeonLevel++;
		// if (dungeonLevel == 5)
		// 	Project.states = [new End()];
		save();

		kha.audio1.Audio.play(kha.Assets.sounds.new_level_descend);
		
		motion.Actuate.tween (track, 1, { volume: 0 }, true).ease (motion.easing.Quad.easeInOut).reflect(true).repeat(1);
		motion.Actuate.tween (this, 1, {overlayShade: 1}, true).ease (motion.easing.Quad.easeInOut).reflect(true).repeat(1);
		motion.Actuate.timer(1).onComplete(actuallyDescend);
			
	}
	function actuallyDescend(){
		track.stop();
		if (Math.random() > .5){
			track = kha.audio1.Audio.play(kha.Assets.sounds.track_5,true);
		}else{
			track = kha.audio1.Audio.play(kha.Assets.sounds.track_2,true);
		}
		createMap();
		p.get(component.Inventory).putIntoInventory(component.Inventory.Item.Key);
		descending = false;
		save();
	}
	
	function save (){
		lastSave = {
			dungeonLevel: dungeonLevel,
			dungeons: dungeons,
			player: null
		};
		if (p.has(component.Transformation))
			lastSave.player = {
				pos: {
					x: Math.round(p.get(component.Transformation).pos.x),
					y: Math.round(p.get(component.Transformation).pos.y)
				},
				health: Math.round(p.get(component.Health).current),
				inventory: p.get(component.Inventory).stacks,
				inventoryIndex: p.get(component.Inventory).activeIndex
			}
		
	}
	
	override public function render (framebuffer:kha.Framebuffer){
		var renderDelta = kha.Scheduler.realTime() - lastRenderTime;
		lastRenderTime = kha.Scheduler.realTime();

		minimap.g2.begin(false);
		minimap.g2.clear(kha.Color.fromFloats(0,0,0,0));
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

		// var shieldSys:system.ShieldRenderer = systems.get(system.ShieldRenderer);
		// shieldSys.prepass();

		var g = framebuffer.g2;
		g.begin();
		g.color = kha.Color.White;

		camera.transform(g);
		tilemapRender.render(g,map);
		for (system in renderSystems)
			system.render(g);
		tilemapRender.renderHidden(g,map);
		camera.restore(g);
		
		if (openShop != null)
			openShop.render(g);

		drawCursor(g);
		drawMap(g);
		inventory(g);
		watermark(g);

		if (p.get(component.GhostMode).enabled){
			g.color = kha.Color.fromFloats(.1,.2,.2,.6);
			g.fillRect(0,0,framebuffer.width,framebuffer.height);
			p.get(component.KeyMovement).speed = 140;
		}else{
			p.get(component.KeyMovement).speed = 110;
		}

		pauseOverlay(g);

		g.color = kha.Color.fromFloats(0,0,0,overlayShade);
		g.fillRect(0,0,kha.System.windowWidth(),kha.System.windowHeight());
		
		g.color = kha.Color.White;
		g.end();
		
		zuiInstance.begin(g);
		debugInterface.render(g);
		debugInterface.updateGraph.pushValue(1/renderDelta/debugInterface.updateGraph.size.y);
		audioInterface.render(g);
		zuiInstance.end();
		
	}
	public function offsetInventorySelection(offset:Int){
		kha.audio1.Audio.play(kha.Assets.sounds.ui_blip);
		if (p.get(component.Inventory) == null) return;
		p.get(component.Inventory).activeIndex += offset;
		if (p.get(component.Inventory).activeIndex < 0) p.get(component.Inventory).activeIndex = p.get(component.Inventory).length-1;
		if (p.get(component.Inventory).activeIndex > p.get(component.Inventory).length-1) p.get(component.Inventory).activeIndex = 0;
		cast(systems.get(system.Inventory),system.Inventory).onChangeItem();
	}

	function drawCursor (g:kha.graphics2.Graphics){
		if (debugInterface.visible || openShop != null){
			// kha.input.Mouse.get().showSystemCursor();
			g.transformation = kha.math.FastMatrix3.scale(4,4);
			g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/4,input.mousePos.y/4,2*16,16,16,16);

			input.mouseEvents = false;
		}else{
			input.mouseEvents = true;
			kha.input.Mouse.get().hideSystemCursor();
			g.transformation = kha.math.FastMatrix3.scale(4,4);
			g.drawSubImage(kha.Assets.images.Entities,input.mousePos.x/4 -8,input.mousePos.y/4 -8,2*16,0,16,16);
		}
	}
	function watermark (g:kha.graphics2.Graphics){
		g.transformation = kha.math.FastMatrix3.identity();
		g.font = kha.Assets.fonts.OpenSans;
		g.color = kha.Color.fromFloats(1,1,1,.3);
		g.fontSize = 20;
		g.drawString("Exilium 0.2.0. @5mixer, @BU773RH4ND5, @gas1312_AGD",10,kha.System.windowHeight()-30);
	}

	function pauseOverlay (g:kha.graphics2.Graphics){
		if (paused){
			//Pause overlay.
			g.color = kha.Color.fromFloats(.1,.2,.2,.6);
			g.fillRect(0,0,kha.System.windowWidth(),kha.System.windowHeight());

			g.color = kha.Color.fromBytes(30,30,30);
			g.fillRect(0,0,400,kha.System.windowHeight());
			
			g.color = kha.Color.White;
			g.font = kha.Assets.fonts.trenco;
			g.fontSize = 38*4;
			g.drawString("Paused [esc]",20,20);

		}
	}

	function drawMap (g:kha.graphics2.Graphics) {
		if (mapShown){
			//Draw minimap at the top right of the screen.
			g.transformation = kha.math.FastMatrix3.scale(4,4);
			g.drawImage(minimap,kha.System.windowWidth()/4 - map.width,0);
			g.transformation = kha.math.FastMatrix3.identity();
		}
	}

	function inventory (g:kha.graphics2.Graphics) {
		var pinv = p.get(component.Inventory);

		if (pinv != null){	
			g.font = kha.Assets.fonts.trenco;
			g.color = kha.Color.fromBytes(234,211,220);
			g.fontSize = 38;
			g.drawString(pinv.itemData.get(pinv.getByIndex(pinv.activeIndex).item).name,(3*4), -1*4);
			
			g.translate(0,8*4);
			var n = 0;
			for (stack in p.get(component.Inventory).stacks){
				g.transformation._00 = camera.scale.x;
				g.transformation._11 = camera.scale.y;
				var off = n == pinv.activeIndex ? 1 : 0;
				system.Renderer.renderSpriteData(g,p.get(component.Inventory).itemData.get(stack.item).sprite,2+off,n*10);
				
				g.color = kha.Color.fromBytes(112,107,137);
				if (n == pinv.activeIndex)
					g.fillRect(1,n*10+1,1,6);

				g.transformation._00 = 1;
				g.transformation._11 = 1;
				g.color = kha.Color.fromBytes(234,211,220);
				g.drawString(stack.quantity+"",(12*4)+off, (n*10*4)-8);
				
				n++;
			}
		}
	}

	override public function update(delta:Float){
		debugInterface.fpsGraph.pushValue(1/delta/debugInterface.fpsGraph.size.y);
		input.startUpdate();
		camera.update(delta);
		// if (input.keysReleased.get(kha.input.KeyCode.V)){
		// 	if (openShop == null){ openShop = new ui.PotionShop(input,p.get(component.Inventory)); }
		// 	else { openShop = null; }
		// }
		if (openShop != null)
			openShop.update();
			
		p.get(component.GhostMode).enabled = input.keys.get(kha.input.KeyCode.Shift);
		frame++;
		var globalMultiplier = input.keys.get(kha.input.KeyCode.F) ? 1/100 : 1/60;
		if (openShop != null) globalMultiplier = 0;
		if (!paused && openShop == null)
			systems.update(globalMultiplier);

		//Q/E Inventory slide.
		if (input.keys.get(kha.input.KeyCode.Q) && frame%7==0)
			offsetInventorySelection(-1);
		if (input.keys.get(kha.input.KeyCode.E) && frame%7==0)
			offsetInventorySelection(1);
			
		(cast systems.get(system.Physics)).grid = (cast systems.get(system.Collisions)).grid;

		cast (systems.get(system.Magnets),system.Magnets).p = p; 


		// (input.mousePos.x - kha.System.windowWidth() / 2)
		//(input.mousePos.y - kha.System.windowHeight() / 2)

		var mouseCamMovement = .03;

		if (p != null && p.has(component.Transformation)){
			camera.pos = new kha.math.Vector2(
				(p.get(component.Transformation).pos.x - (kha.System.windowWidth()/2) /camera.scale.x) + (input.mousePos.x - kha.System.windowWidth()/2)*mouseCamMovement,
				(p.get(component.Transformation).pos.y - (kha.System.windowHeight()/2) /camera.scale.y) + (input.mousePos.y - kha.System.windowHeight()/2)*mouseCamMovement
			);
		}

		var collisionDebugViewSys:system.CollisionDebugView = systems.get(system.CollisionDebugView);
		collisionDebugViewSys.showActiveEntities = debugInterface.activeCollisionRegionsShown;
		collisionDebugViewSys.showStaticEntities = debugInterface.staticCollisionRegionsShown;
		
		input.endUpdate();
	}
}