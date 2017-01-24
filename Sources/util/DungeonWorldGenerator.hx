package util;

typedef Room = {
	var id:Int;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var attachedFromSide:Side;
	var doorways:Array<{x:Int, y:Int}>;
}

enum Side {
	Left;
	Right;
	Top;
	Bottom;
}

class DungeonWorldGenerator {
	public var width:Int;
	public var height:Int;
	public var tiles = new Array<Int>();
	var rooms = new Array<Room>();
	public var treasure = new Array<{x:Int, y:Int}>();
	public var enemies = new Array<{x:Int, y:Int}>();
	var random:util.Random;

	public function new (width,height){
		this.width = width;
		this.height = height;
		random = new util.Random(11);
		generate();
	}
	function roomPlacementValid (room:Room){
		for (r in rooms){
			if (roomsTouch(r,room))
				return false;
		}
		return (room.x >= 0 && room.y >=0 && room.x+room.width < width && room.y+room.height < height);
	}
	public function generate () {
		createMap();

		//Place root rooms
		rooms.push({id:rooms.length, x:Std.int(width/2), y: Std.int(height/2), width: 5, height: 5, attachedFromSide: null, doorways: []});
		growFromRoom(rooms[0]);
		fillRooms();
		bakerooms();
		createWallDepth();
	}
	var fails = 0;
	function fail(){
		fails++;
		return fails < 20;
	}
	function placeThingInRoom (room:Room){
		if (room.id < 2) return; //Don't place in start room
		var thing = {x:room.x+Math.floor(room.width/2),y:room.y+Math.floor(room.height/2)};
		treasure.push(thing);

		var enemy = {x: room.x+2+Math.floor(random.generate()*(room.width-4)),y: room.y+2+Math.floor(random.generate()*(room.height-4))};
		if (thing.x != enemy.x && thing.y != enemy.y)
				enemies.push(enemy);
		
	}
	var roomCount = 0;
	function growFromRoom (room:Room){
		if (roomCount++ > 100) return;
		var side = Side.createByIndex(Math.floor(random.generate()*4));
		while (side == room.attachedFromSide){
			side = Side.createByIndex(Math.floor(random.generate()*4));
		}
		
		var width = 9+Math.floor(random.generate()*6);
		var height = 9+Math.floor(random.generate()*6);
		
		var doorx = room.x+Math.floor(Math.min(room.width/2,width/2)) ;
		var doory = room.y+Math.floor(Math.min(room.height/2,height/2)) ;

		if (random.generate() > .25) {
			var newRoom = {id:rooms.length, attachedFromSide: Side.Left, doorways:[{x:room.x+room.width-1,y:doory}], x: room.x+room.width-1, y: room.y, width:width, height:height};
			if (roomPlacementValid(newRoom)){
				rooms.push(newRoom);
				growFromRoom(newRoom);
			}else if (fail()){
				growFromRoom(room);
			}
		}
		if (random.generate() > .25) {
			var newRoom = {id:rooms.length, attachedFromSide: Side.Top, doorways:[{x:doorx,y:room.y+room.height-1}], x: room.x, y: room.y+room.height-1, width:width, height:height};
			if (roomPlacementValid(newRoom)){
				rooms.push(newRoom);
				growFromRoom(newRoom);
			}else if (fail()){
				growFromRoom(room);
			}
		}
		if (random.generate() > .25) {
			var newRoom = {id:rooms.length, attachedFromSide: Side.Right, doorways:[{x:room.x,y:doory}], x: room.x-width+1, y: room.y, width:width, height:height};
			if (roomPlacementValid(newRoom)){
				rooms.push(newRoom);
				growFromRoom(newRoom);
			}else if (fail()){
				growFromRoom(room);
			}
		}
		if (random.generate() > .25) {
			var newRoom = {id:rooms.length, attachedFromSide: Side.Bottom, doorways:[{x:doorx,y:room.y}], x: room.x, y: room.y-height+1, width:width, height:height};
			if (roomPlacementValid(newRoom)){
				rooms.push(newRoom);
				growFromRoom(newRoom);
			}else if (fail()){
				growFromRoom(room);
			}
			

		}
	}
	function fillRooms (){
		for (room in rooms){
			placeThingInRoom(room);
		}
	}
	function createWallDepth (){
		for (x in 0...width){
			for (y in 0...height){
				if ((get(x,y-1) == 3 || get(x,y-1) == 2) && get(x,y) != 4)
					set(x,y,5);
			}
		}
	}
	function createMap () {
		var i = 0;
		for (y in 0...height){
			for (x in 0...width){
				tiles.push(0);
				i++;
			}
		}
	}
	inline function bakerooms () {
		for (room in rooms){
			for (x in 0...room.width){
				for (y in 0...room.height){
					if (get (room.x+x,room.y+y) != 0) continue;
					set(room.x+x,room.y+y,1);

					if ((x==0 || x==room.width-1))
						set(room.x+x,room.y+y,4);

					if ((y==0  || y==room.height-1))
						set(room.x+x,room.y+y,3);

					//Corner tiles.
					if ((x==0 || x==room.width-1) && (y==0  || y==room.height-1))
						set(room.x+x,room.y+y,2);
				}
			}
		}
		for (room in rooms){
			for (door in room.doorways){
				set(door.x,door.y,6);
			}
		}
	}
	inline public function set(x:Int,y:Int,i:Int){
		tiles[y*width+x] = i;
	}
	inline public function get(x,y){
		return tiles[y*width+x];
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