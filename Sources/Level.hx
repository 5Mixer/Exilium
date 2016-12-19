package ;

//Perhaps this should be loaded from a file.
typedef Tile = {
	var name:String;
	var collide:Bool;
	@:optional var oncollide:Void -> Void;
	var id:Int;
}

class Level {
	var tileColours = [

	];
	public var tileInfo:Map<Int,Tile> = [
		0 => { name: "ground", collide: false, id: 0},
		1 => { name: "wall1", collide: true, id: 1},
		2 => { name: "wall2", collide: true, id: 2},
		3 => { name: "wall3", collide: true, id: 3},
		4 => { name: "wall4", collide: true, id: 4},
		5 => { name: "wall3", collide: true, id: 5}
	];
	var tiles = new Array<Int>();

	var width:Int;
	var height:Int;

	public function new () {
		var levelData = haxe.Json.parse(kha.Assets.blobs.Level_json.toString());
		//tiles = levelData.tiles;
		//width = levelData.width;
		//height = levelData.height;

		var data = haxe.xml.Parser.parse(kha.Assets.blobs.level1_tmx.toString());
		var map = data.elementsNamed("map").next();
		width = Std.parseInt(map.get("width"));
		height = Std.parseInt(map.get("height"));
		var layers = map.elementsNamed("layer");
		for (layer in layers){
			tiles = [];
			var layerTiles = layer.elementsNamed("data").next().elements();
			for (tile in layerTiles){
				tiles.push(Std.parseInt(tile.get("gid")) +1);
			}
			trace("Loaded data "+tiles);
		}

		if (tiles.length != width*height){
//			throw "Odd level data - More tiles than width*height";
		}
	}
	public function draw (g:kha.graphics2.Graphics){
		for (y in 0...height){
			for (x in 0...width){
				var tileData = tileInfo.get(tiles[(y*width)+x]);
				var sourcePos = { x: (width%tileData.id)*8, y:Math.floor(tileData.id/height)*8 };
				var destPos = { x: x*8, y: y*8 };
				//trace(sourcePos + " " + destPos);

				g.drawScaledSubImage(kha.Assets.images.Tileset,sourcePos.x,sourcePos.y,8,8,destPos.x,destPos.y,8,8);
			}
		}
	}
}
