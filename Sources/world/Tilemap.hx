package world;

import kha.Color;
import worldgen.Tile;

typedef TileType = {
	var name:String;
	var collide:Bool;
	@:optional var oncollide:Void -> Void;
	@:optional var specularity:Float;
	@:optional var ambient:kha.Color;
	var id:Int;
	var colour:kha.Color;
}

class Tilemap {
	public var tiles = new Array<Tile>();
	public var tileInfo:Map<Int,TileType> = [
		0 => { name: "empty", collide: false, id: -1, colour: Color.fromFloats(0,0,0,0) },
		1 => { name: "floor", collide: false, id: 0, specularity: 2, colour:Color.fromBytes(158,93,94)},
		2 => { name: "dungeonwall", collide: true, id: 1, ambient: Color.fromFloats(.1,.1,.1), specularity: 1.3, colour:Color.fromBytes(214,166,122)},
		3 => { name: "dungeonwall.side", collide: true, id: 2, ambient: Color.fromFloats(.1,.1,.1), specularity: 1.3, colour:Color.fromBytes(186,143,104)},
		4 => { name: "dungeonwall.h", collide: true, id: 3, ambient: Color.fromFloats(.1,.1,.1), specularity: 1.3, colour:Color.fromBytes(214,166,122)},
		5 => { name: "dungeonwall.v", collide: true, id: 4, ambient: Color.fromFloats(.1,.1,.1), specularity: 1.3, colour:Color.fromBytes(214,166,122)},
		6 => { name: "gate", collide: false, id: 0, colour:Color.fromBytes(104,111,186)}
	];
	public var width:Int;
	public var height:Int;
	public var treasure = new Array<{x:Int, y:Int}>();

	public function new () {

	}

	inline public function get(x,y){
		return tiles[y*width+x];
	}
	inline public function set(x:Int,y:Int,i:Tile){
		tiles[y*width+x] = i;
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
				var tInfo = tileInfo.get(get(y,x).id);
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
				var tInfo = tileInfo.get(get(x,y).id);
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