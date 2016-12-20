package ;

//Perhaps this should be loaded from a file.
typedef Tile = {
	var name:String;
	var collide:Bool;
	@:optional var oncollide:Void -> Void;
	var id:Int;
}

class LevelCollisionShape {
	public var level:Level;
	public function new (level:Level){
		this.level = level;
	}
}

class Level extends Entity {
	var tileColours = [

	];
	public var tileInfo:Map<Int,Tile> = [
		0 => { name: "ground", collide: true, id: 0},
		1 => { name: "wall1", collide: false, id: 1},
		2 => { name: "wall2", collide: false, id: 2},
		3 => { name: "wall3", collide: false, id: 4},
		4 => { name: "wall4", collide: false, id: 5},
		5 => { name: "wall3", collide: true, id: 6}
	];
	var tiles = new Array<Int>();

	var width:Int;
	var height:Int;

	var camera:Camera;

	override public function new (camera:Camera) {
		super();
		this.camera = camera;

		//var levelData = haxe.Json.parse(kha.Assets.blobs.Level_json.toString());
		//tiles = levelData.tiles;

		var c = new component.Collisions(this);
		

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

				
				if (tileInfo.get(t).collide){
					c.registerCollisionRegion(new component.Collisions.RectangleCollisionShape(new kha.math.Vector2((i%width)*8,Math.floor(i/width)*8),new kha.math.Vector2(8,8)));
				}

				i++;
			}
			trace("Loaded data "+tiles);
		}

		if (tiles.length != width*height){
//			throw "Odd level data - More tiles than width*height";
		}

		this.components.set("collider",c);
	}


	override public function draw (g:kha.graphics2.Graphics){
		
		/*for (y in 0...height){
			for (x in 0...width){
				if (!camera.isWorldPointOnScreen(new kha.math.Vector2(x*8 - 4,y*8 - 4))) continue;

				var tileData = tileInfo.get(tiles[(y*width)+x]);
				var sourcePos = { x: (tileData.id%width)*8, y:Math.floor(tileData.id/height)*8 };
				var destPos = { x: x*8, y: y*8 };
				//trace(sourcePos + " " + destPos);
				
				g.drawScaledSubImage(kha.Assets.images.Tileset,sourcePos.x,sourcePos.y,8,8,destPos.x,destPos.y,8,8);
			}
		}*/


		var camtiley:Int = cast Math.max(Math.floor((camera.pos.y)/8),0);
		var camtilex:Int = cast Math.max(Math.floor((camera.pos.x)/8),0);
		var windoww = Math.ceil(((kha.System.windowWidth()+8*42)/8)/8);
		var windowh = Math.ceil(((kha.System.windowHeight()+8*42)/8)/8);
		for (y in camtiley ... cast Math.min(camtiley+windowh,height)){
			for (x in camtilex ... cast Math.min(camtilex+windoww,width)){
				//trace('rendering tile $x : $y');

				var tileData = tileInfo.get(tiles[(y*width)+x]);
				var sourcePos = { x: (tileData.id%width)*8, y:Math.floor(tileData.id/height)*8 };
				
				//trace(sourcePos + " " + destPos);
				
				g.drawScaledSubImage(kha.Assets.images.Tileset,sourcePos.x,sourcePos.y,8,8,x*8,y*8,8,8);

			}
		}

		/*g.color = kha.Color.fromFloats(.2,.3,.7,.9);
		g.drawRect(camtilex*8,camtiley*8,8,8);
		g.color = kha.Color.fromFloats(.2,.3,.7,.3);
		g.drawRect(camtilex*8,camtiley*8,windoww*8,windowh*8);*/
	}
}
