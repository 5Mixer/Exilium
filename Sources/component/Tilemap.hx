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
		5 => { name: "wall3", collide: false, id: 5}
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
	inline public function get(x,y){
		return tiles[y*width+x];
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
				//pts.push({x:y, y:x});
				if (tileInfo.get(get(y,x)).collide) {
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
				//pts.push({x:x, y:y});
				if (tileInfo.get(get(x,y)).collide) {
					
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