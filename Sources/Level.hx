package ;

//Perhaps this should be loaded from a file.
typedef Tile = {
	var name:String;
	var collide:Bool;
	@:optional var oncollide:Void -> Void;
	var id:Int;
}
typedef Light = {
	var colour:kha.Color;
	var radius:Float;
	var pos:kha.math.Vector2;
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
		3 => { name: "wall3", collide: false, id: 3},
		4 => { name: "wall4", collide: false, id: 4},
		5 => { name: "wall3", collide: true, id: 5}
	];
	var tiles = new Array<Int>();

	public var width:Int;
	public var height:Int;

	var camera:Camera;

	public var lights:Array<Light>;

	override public function new (camera:Camera) {
		super();
		this.camera = camera;

		//var levelData = haxe.Json.parse(kha.Assets.blobs.Level_json.toString());

		var c = new component.Collisions(this);

		lights = [
			{ pos: new kha.math.Vector2(10,10), radius: 1, colour: kha.Color.Green},
			{ pos: new kha.math.Vector2(10,5), radius: 1, colour: kha.Color.Red},
			{ pos: new kha.math.Vector2(5,7.5), radius: 1, colour: kha.Color.Blue},
		];
		

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
		}

		if (tiles.length != width*height){
			throw "Odd level data - More tiles than width*height";
		}

		this.components.set("collider",c);
	}

	inline public function getTile (x,y){
		return tiles[y*width+x];
	}

	override public function draw (g:kha.graphics2.Graphics){

		var camtiley:Int = cast Math.max(Math.floor((camera.pos.y)/8),0);
		var camtilex:Int = cast Math.max(Math.floor((camera.pos.x)/8),0);
		var windoww = Math.ceil(((kha.System.windowWidth()+8*4)/8)/8);
		var windowh = Math.ceil(((kha.System.windowHeight()+8*4)/8)/8);

		for (y in camtiley ... cast Math.min(camtiley+windowh,height)){
			for (x in camtilex ... cast Math.min(camtilex+windoww,width)){
				
				//In the rendering loop of tilemaps, where x,y is tile location.
				var colours:Array<kha.Color> = []; //Stores all effecting colours from light sources.
				for (light in lights){
					var lx = light.pos.x;
					var ly = light.pos.y;
					var l =	Math.sqrt(((x - lx) * (x - lx)) + ((y - ly) * (y - ly))); //Distance to light.
					l = Math.max(Math.min(light.radius/l,1),0); //This is the lights effect, kept in range.

					colours.push(kha.Color.fromFloats(light.colour.R*l,light.colour.G*l,light.colour.B*l,1)); //Add to colours
				}
				//Now add these colours togethor and store in one variable.
				var c = {r: 0.0, g: 0.0, b:0.0, a: 1.0};
				for (colour in colours){

					c.r += colour.R;
					c.g += colour.G;
					c.b += colour.B;
				}
				//Now actually apply the tint, again, within a range.
				g.color = kha.Color.fromFloats(Math.min(c.r,1),Math.min(c.g,1),Math.min(c.b,1),1);
				
				var tileData = tileInfo.get(tiles[(y*width)+x]);
				var sourcePos = { x: (tileData.id%width)*8, y:Math.floor(tileData.id/height)*8 };
				
				g.drawScaledSubImage(kha.Assets.images.Tileset,sourcePos.x,sourcePos.y,8,8,x*8,y*8,8,8);

			}
		}
		g.color = kha.Color.White;
	}
}
