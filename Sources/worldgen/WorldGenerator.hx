package worldgen;

enum EntityType {
	Treasure;
	Enemy;
	Spike;
	Shooter;
	Lava;
	CorruptSoulBoss;
	Item(type:component.Inventory.Item);
	Door;
	Torch;
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
	public var tiles = new Array<Tile>();
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
	inline public function set(x:Int,y:Int,i:Tile){
		tiles[y*width+x] = i;
	}
	inline public function get(x,y){
		return tiles[y*width+x];
	}
	function createMap () {
		var i = 0;
		for (y in 0...height){
			for (x in 0...width){
				tiles.push({id:0,zone:null});
				i++;
			}
		}
	}
	public function generate(){}
}