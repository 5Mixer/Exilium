package component;

typedef Tile = {
	var name:String;
	var collide:Bool;
	@:optional var oncollide:Void -> Void;
	@:optional var specularity:Float;
	@:optional var ambient:kha.Color;
	var id:Int;
}

class Tilemap extends Component{
	public var tiles = new Array<Int>();
	public var tileInfo:Map<Int,Tile> = [
		0 => { name: "ground", collide: true, id: 0, ambient: kha.Color.fromFloats(.1,.1,.1), specularity: 1.3},
		1 => { name: "wall1", collide: false, id: 1},
		2 => { name: "wall2", collide: false, id: 2},
		3 => { name: "wall3", collide: false, id: 3},
		4 => { name: "wall4", collide: false, id: 4},
		5 => { name: "wall3", collide: true, id: 5}
	];
	public var width:Int;
	public var height:Int;

	override public function new () {
		var data = haxe.xml.Parser.parse(kha.Assets.blobs.level1_tmx.toString());
		var map = data.elementsNamed("map").next();
		width = Std.parseInt(map.get("width"));
		height = Std.parseInt(map.get("height"));
		var layers = map.elementsNamed("layer");

		for (layer in layers){
			tiles = [];
			var i = 0;
			var layerTiles = layer.elementsNamed("data").next().elements();
			for (tile in layerTiles){
				var t = Std.parseInt(tile.get("gid"))-1;
				tiles.push(t);
				
				//if (tileInfo.get(t).collide){
				//	c.registerCollisionRegion(new component.Collisions.RectangleCollisionShape(new kha.math.Vector2((i%width)*8,Math.floor(i/width)*8),new kha.math.Vector2(8,8)));
				//}

				i++;
			}
		}

		if (tiles.length != width*height){
			throw "Odd level data - More tiles than width*height";
		}

		super();
	}

}