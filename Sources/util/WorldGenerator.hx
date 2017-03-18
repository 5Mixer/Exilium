package util;

enum EntityType {
	Treasure;
	Enemy;
	Spike;
	Shooter;
}
typedef Room = {
	var id:Int;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var attachedFromSide:Side;
	var doorways:Array<{x:Int, y:Int}>;
	@:optional var distanceToEntrance:Int;
}

enum Side {
	Left;
	Right;
	Top;
	Bottom;
}
class WorldGenerator {
	public var width:Int;
	public var height:Int;
	public var tiles = new Array<Int>();
	public var entities:Array<{type:EntityType,x:Int, y:Int}> = [];
	public var exitPoint:{x:Int, y:Int};
	var random:util.Random;
	public var spawnPoint:{x:Int, y:Int};
	public var seed:Int;

	public function new (width,height){
		this.width = width;
		this.height = height;
		seed = Math.floor(Math.random()*999999);
		random = new util.Random(seed);
		generate();
	}
	inline public function set(x:Int,y:Int,i:Int){
		tiles[y*width+x] = i;
	}
	inline public function get(x,y){
		return tiles[y*width+x];
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
	public function generate(){}
}