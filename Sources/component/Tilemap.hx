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
		0 => { name: "empty", collide: false, id: 0},
		1 => { name: "floor", collide: false, id: 4, specularity: 2},
		2 => { name: "dungeonwall", collide: true, id: 1, ambient: kha.Color.fromFloats(.1,.1,.1), specularity: 1.3},
		3 => { name: "dungeonwall.h", collide: true, id: 2, ambient: kha.Color.fromFloats(.1,.1,.1), specularity: 1.3},
		4 => { name: "dungeonwall.v", collide: true, id: 3, ambient: kha.Color.fromFloats(.1,.1,.1), specularity: 1.3},
		5 => { name: "gate", collide: false, id: 4}
	];
	public var width:Int;
	public var height:Int;
	public var treasure = new Array<{x:Int, y:Int}>();

	override public function new () {
		super();
	}
	inline public function get(x,y){
		return tiles[y*width+x];
	}
	inline public function set(x:Int,y:Int,i:Int){
		tiles[y*width+x] = i;
	}

	public function loadFromTiled (){
		var data = haxe.xml.Parser.parse(kha.Assets.blobs.level1_tmx.toString());
		var map = data.elementsNamed("map").next();
		width = Std.parseInt(map.get("width"));
		height = Std.parseInt(map.get("height"));

		for (layer in map.elementsNamed("layer")){
			tiles = [];
			var i = 0;
			var layerTiles = layer.elementsNamed("data").next().elements();
			for (tile in layerTiles){
				var t = Std.parseInt(tile.get("gid"))-1;
				tiles.push(t);

				i++;
			}
		}

		if (tiles.length != width*height){
			throw "Odd level data - More tiles than width*height";
		}

	}
	public function raycast (g:kha.graphics2.Graphics,x0:Int,y0:Int,x1:Int,y1:Int){
		g.color = kha.Color.Cyan;

		var swapXY = fastAbs( y1 - y0 ) > fastAbs( x1 - x0 );
		var tmp : Int;
		if ( swapXY ) {
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		
		if ( x0 > x1 ) {
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}
		
		var deltax = x1 - x0;
		var deltay = fastFloor( fastAbs( y1 - y0 ) );
		var error = fastFloor( deltax / 2 );
		var y = y0;
		var ystep = if ( y0 < y1 ) 1 else -1;
		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				var tInfo = tileInfo.get(get(y,x));
				if (tInfo != null && tInfo.collide) {
					//g.drawLine((x0+.5)*8,(y0+.5)*8,(x1+.5)*8,(y1+.5)*8,.5);
					//g.drawRect((x)*8+4,(y)*8+4,2,2);
					return true;
				}
				error -= deltay;
				if ( error < 0 ) {
					y = y + ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				var tInfo = tileInfo.get(get(x,y));
				if (tInfo != null && tInfo.collide) {
					
					//g.drawLine((x0+.5)*8,(y0+.5)*8,(x1+.5)*8,(y1+.5)*8,.5);
					//g.drawRect((x)*8+4,(y)*8+4,2,2);
					return true;
				}
				error -= deltay;
				if ( error < 0 ) {
					y = y + ystep;
					error = error + deltax;
				}
			}
		return false;
		//return pts;
	}
	static inline function fastAbs(v:Int) : Int {
		return (v ^ (v >> 31)) - (v >> 31);
	}
	
	static inline function fastFloor(v:Float) : Int {
		return Std.int(v);
	}

}