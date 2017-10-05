package worldgen;

import worldgen.WorldGenerator.EntityType;
import worldgen.WorldGenerator.Side;
import worldgen.WorldGenerator.WorldGenerator;
import worldgen.Tile;
import worldgen.Zone;

typedef Room = {
	var id:Int;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var attachedFromSide:Side;
	var doorways:Array<{x:Int, y:Int}>;
	@:optional var distanceToEntrance:Int;
	var zone:Zone;
	var visible:Bool;
	var childRooms:Int;
	@:optional var exitRoom:Bool;
	@:optional var structure:Array<Tile>;
}

typedef Region = {
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
}

class DungeonWorldGenerator extends WorldGenerator {
	public var rooms = new Array<Room>();
	var probabilityForTreasureInRoom = .3;
	public var difficulty = 5;
	
	var tileInfo = {
		"empty":0,
		"floor":1,
		"dungeonwall":2,
		"dungeonwallside":3,
		"dungeonwallh":4,
		"dungeonwallv":5,
		"gate":6
	};

	function roomPlacementValid (room:Room){
		for (r in rooms){
			if (roomsTouch(r,room))
				return false;
		}
		return (room.x >= 0 && room.y >=0 && room.x+room.width < width && room.y+room.height < height);
	}
	override public function generate () {
		createMap();
		rooms = [];
		roomCount = 0;

		//Place root rooms
		rooms.push({id:rooms.length, visible:true, x:Std.int(width/2), y: Std.int(height/2), width: 9, height: 7, childRooms:0, attachedFromSide: null, doorways: [], distanceToEntrance:0, zone: Zone.Friendly});
		spawnPoint = {x:Std.int(width/2)+4, y: Std.int(height/2)+3};
		growFromRoom(rooms[0]);
		placeExit();
		designateSpecialRoom();
		fillRooms();
		bakerooms();
		createWallDepth();

	}
	function placeExit(){
		//Sort rooms so furtherest rooms are at end of Array
		rooms.sort(function(a,b){
			if (a.distanceToEntrance > b.distanceToEntrance) return 1;
			if (a.distanceToEntrance < b.distanceToEntrance) return -1;
			return 0;
		});
		var farRoom = rooms[rooms.length-1];
		exitPoint = {x:farRoom.x+Math.floor(farRoom.width/2)+1,y:farRoom.y+Math.floor(farRoom.height/2)};
		farRoom.exitRoom = true;
	
		for (door in farRoom.doorways) {
			entities.push({type:worldgen.WorldGenerator.EntityType.Door,x:door.x,y:door.y});
		}
	}
	function designateSpecialRoom (){
		var validRooms:Array<Room> = [];
		for (room in rooms){
			if (room.id == 0) continue; //Never first room.
			if (room.childRooms == 0) //No exits
				if (room.exitRoom == null || room.exitRoom == false)
					validRooms.push(room); //No exits.
		}
		var specialRoom = validRooms[Math.floor(Math.random()*validRooms.length)];
		if (specialRoom != null){
			specialRoom.visible = false;
		}
	}
	function placeThingInRoom (room:Room){
		var centre = {x:room.x+Math.floor(room.width/2),y:room.y+Math.floor(room.height/2)};
		if (room.id < 1){
			// entities.push({type: worldgen.WorldGenerator.EntityType.PotionSeller,x:centre.x-2,y:centre.y+1});
			entities.push({type: worldgen.WorldGenerator.EntityType.PotionSeller,x:centre.x,y:centre.y+1});
			// entities.push({type: worldgen.WorldGenerator.EntityType.PotionSeller,x:centre.x+2,y:centre.y+1});
			entities.push({type:worldgen.WorldGenerator.EntityType.Door,x:rooms[1].doorways[0].x, y:rooms[1].doorways[0].y});
		}

		//For mystery rooms
		if (!room.visible){
			//offset so the sign appears in front of the room.
			var offx = 0;
			var offy = 0;

			switch (room.attachedFromSide){
				case Side.Top: offy--;
				case Side.Bottom: offy++;
				case Side.Left: offx--;
				case Side.Right: offx++;
			}

			entities.push({type:worldgen.WorldGenerator.EntityType.Sign("Mystery Room"),x:room.doorways[0].x+offx,y:room.doorways[0].y+offy});
			entities.push({type: worldgen.WorldGenerator.EntityType.RoomDoor(room),x:room.doorways[0].x,y:room.doorways[0].y});
		}

		if (room.id < 1) return; //Don't place enemies, treasure etc. in start room

		var possibleLocations:Region = {x: room.x + 2, y: room.y + 2, width: room.width - 4, height: room.height - 4};
		var chestLocation = {x: centre.x-1+Math.round(Math.random()*2), y: centre.y-1+Math.round(Math.random()*2)};


		var enemyCount = Math.floor(Math.max(0,difficulty - 3)) + Math.floor(Math.random()*difficulty);
		for (i in 0...enemyCount){
			var x = Math.floor(Math.random()*possibleLocations.width) + possibleLocations.x;
			var y = Math.floor(Math.random()*possibleLocations.height) + possibleLocations.y;
			if (Math.random() < .6){
				entities.push({type: worldgen.WorldGenerator.EntityType.Bat,x:x,y:y});
			}else if (Math.random() < .5){
				entities.push({type: worldgen.WorldGenerator.EntityType.Mummy,x:x,y:y});
			}else{
				entities.push({type: worldgen.WorldGenerator.EntityType.Goblin,x:x,y:y});

			}
		}

		//entities.push({type:EntityType.Lava, x: thing.x+3,y:thing.y});
		
		if (random.generate() > probabilityForTreasureInRoom)
			entities.push({type:EntityType.Treasure,x:chestLocation.x,y:chestLocation.y});

		var enemy = {x: room.x+2+Math.floor(random.generate()*(room.width-4)),y: room.y+2+Math.floor(random.generate()*(room.height-4))};
		if (centre.x != enemy.x && centre.y != enemy.y)
			// if (Math.random()>.5){
				entities.push({type:EntityType.Enemy,x:enemy.x,y:enemy.y});
			// }else{
			// 	entities.push({type:Math.random()>.8?EntityType.Spike:EntityType.Shooter,x:enemy.x,y:enemy.y});
			// }
		
	}
	public function middleOfRoom(room:Room){
		return {x:room.x+Std.int(room.width/2), y: room.y+Std.int(room.height/2)}
	}
	var roomCount = 0;
	function growFromRoom (room:Room){
		var thisZone = Math.random() > .6 ? room.zone : Zone.createByIndex(Math.floor(Math.random()*4)+1);
		
		if (roomCount++ > 100) return;
		var side = Side.createByIndex(Math.floor(random.generate()*4));
		while (side == room.attachedFromSide){
			side = Side.createByIndex(Math.floor(random.generate()*4));
		}

		
		var width = 8+Math.floor(random.generate()*5);
		var height = 8+Math.floor(random.generate()*5);
		
		var doorx = room.x+Math.floor(Math.min(room.width/2,width/2));
		var doory = room.y+Math.floor(Math.min(room.height/2,height/2));
		
		var dte = room.distanceToEntrance+1;

		var singleSide = -1;
		if (roomCount == 1){
			//The first room can have only one exit.
			singleSide = [0,2,3][ Math.floor(Math.random()*3)]; // The second room will extend from the left, right of top of the first.
		}
		if (false){
			//place room by structure
			/*var data = haxe.xml.Parser.parse(kha.Assets.blobs.passageway_tmx.toString());
			var structure = data.elementsNamed("map").next();
			var swidth = Std.parseInt(structure.get("width"));
			var sheight = Std.parseInt(structure.get("height"));
			var tiles:Array<Tile> = [];

			for (layer in structure.elementsNamed("layer")){
				var layerTiles = layer.elementsNamed("data").next().elements();
				for (tile in layerTiles){
					var t = Std.parseInt(tile.get("gid"));
					tiles.push({id:t,zone:null});
					
				}
			}
			var newRoom = {id:rooms.length, attachedFromSide: Side.Top, distanceToEntrance:dte, doorways:[{x:doorx,y:room.y+room.height-1}], x: room.x, y: room.y+room.height-1, width:swidth, height:sheight,zone:thisZone,structure:tiles};
			if (roomPlacementValid(newRoom)){
				rooms.push(newRoom);
				growFromRoom(newRoom);
			}else{
				growFromRoom(room);
			}
			*/
		}else{
			if ((random.generate() > .25 && singleSide == -1) || singleSide == 0) {
				var newRoom = {id:rooms.length, attachedFromSide: Side.Left, distanceToEntrance:dte, childRooms: 0, visible:true, doorways:[{x:room.x+room.width-1,y:doory}], x: room.x+room.width-1, y: room.y, width:width, height:height,zone:thisZone};
				if (roomPlacementValid(newRoom)){
					room.childRooms++;
					rooms.push(newRoom);
					growFromRoom(newRoom);
				}else{
					growFromRoom(room);
				}
			}
			if ((random.generate() > .25 && singleSide == -1) || singleSide == 1) {
				var newRoom = {id:rooms.length, attachedFromSide: Side.Top, distanceToEntrance:dte, childRooms: 0, visible:true, doorways:[{x:doorx,y:room.y+room.height-1}], x: room.x, y: room.y+room.height-1, width:width, height:height,zone:thisZone};
				if (roomPlacementValid(newRoom)){
					room.childRooms++;
					rooms.push(newRoom);
					growFromRoom(newRoom);
				}else{
					growFromRoom(room);
				}
			}
			if ((random.generate() > .25 && singleSide == -1) || singleSide == 2) {
				var newRoom = {id:rooms.length, attachedFromSide: Side.Right, distanceToEntrance:dte, childRooms: 0, visible:true, doorways:[{x:room.x,y:doory}], x: room.x-width+1, y: room.y, width:width, height:height,zone:thisZone};
				if (roomPlacementValid(newRoom)){
					room.childRooms++;
					rooms.push(newRoom);
					growFromRoom(newRoom);
				}else{
					growFromRoom(room);
				}
			}
			if ((random.generate() > .25 && singleSide == -1) || singleSide == 3) {
				var newRoom = {id:rooms.length, attachedFromSide: Side.Bottom, distanceToEntrance:dte, childRooms: 0, visible:true, doorways:[{x:doorx,y:room.y}], x: room.x, y: room.y-height+1, width:width, height:height,zone:thisZone};
				if (roomPlacementValid(newRoom)){
					room.childRooms++;
					rooms.push(newRoom);
					growFromRoom(newRoom);
				}else{
					growFromRoom(room);
				}
			}
		}
	}
	function fillRooms (){
		for (room in rooms){
			placeThingInRoom(room);
		}
		//Place key in random room.
		var room = Math.floor(Math.random()*(rooms.length-1));
		var pos = middleOfRoom(rooms[room]);
		entities.push({type:worldgen.WorldGenerator.EntityType.Item(component.Inventory.Item.Key),x:pos.x+1,y:pos.y});
		
	}
	function createWallDepth (){
		for (x in 0...width){
			for (y in 0...height){
				if (get(x,y-1) == null)
					continue;
				
				if ((get(x,y-1).id == tileInfo.dungeonwall || get(x,y-1).id == tileInfo.dungeonwallh || get(x,y-1).id == tileInfo.dungeonwallv) && get(x,y).id != tileInfo.gate && (get(x,y).id == tileInfo.empty || get(x,y).id == tileInfo.floor))
					set(x,y,{id:tileInfo.dungeonwallside,zone:get(x,y-1).zone, visible: get(x,y-1).visible  });
			}
		}
	}
	
	function bakerooms () {
		for (room in rooms){
			if (room.structure == null){
				for (x in 0...room.width){
					for (y in 0...room.height){
						
						if (get (room.x+x,room.y+y).id != tileInfo.empty) continue; //If there is already a tile somewhere don't override
						
						set(room.x+x,room.y+y,{id: tileInfo.floor, zone:room.zone, visible:room.visible}); //By default set to zone tile.	

						//Fill in walls with appropriate tiles.
						if (x == 0)
							set(room.x+x,room.y+y,{id: tileInfo.dungeonwallv, zone:room.zone, visible:true});

						if (x == room.width-1)
							set(room.x+x,room.y+y,{id: tileInfo.dungeonwallv, zone:room.zone, visible:true});

						if (y == 0)
							set(room.x+x,room.y+y,{id: tileInfo.dungeonwallh, zone:room.zone, visible:true});

						if (y == room.height-1)
							set(room.x+x,room.y+y,{id:tileInfo.dungeonwallh,zone:room.zone, visible:true});

						//Corner tiles.
						if ((x==0 || x==room.width-1) && (y==0  || y==room.height-1))
							set(room.x+x,room.y+y,{id:tileInfo.dungeonwall,zone:room.zone, visible:true});
					}
				}
			}else{
				var i = 0;
				var structure = room.structure;

				for (tile in structure){
					var x = room.x+(i%room.width);
					var y = room.y+Math.floor(i/room.width);
					
					if (tile != null)
						set(x,y,tile);
					
					i++;
				}	
			}
		}
		for (room in rooms){
			for (door in room.doorways){
				set(door.x,door.y,{id:tileInfo.gate,zone:room.zone, visible: true});
			}
		}

		if (tiles.length != width*height)
			throw "Odd level data - Different number of tiles than width*height";
		
	}
	
	inline function roomsTouch (room1,room2){
		return (room1.x < room2.x + room2.width-1 &&
			room1.x + room1.width-1 > room2.x &&
			room1.y < room2.y + room2.height-1 &&
			room1.height-1 + room1.y > room2.y);
	}
	inline function pointInRoom(room:Room,pointx:Int,pointy:Int){
		return (pointx > room.x && pointx < room.x + room.width &&
				pointy > room.y && pointy < room.y + room.height);
	}

}