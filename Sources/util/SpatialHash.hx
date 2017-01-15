package util;

import kha.math.Vector2;
import component.Collisions.Rect;

class SpatialHash {

	public var min(default, null):Vector2;
	public var max(default, null):Vector2;

	public var pos:Vector2;
		/* the square cell gridLength of the grid. Must be larger than the largest shape in the space. */
	public var cellSize(default, set):UInt;
		/* the world space width */
	public var w (default, null):Int;
		/* the world space height */
	public var h (default, null):Int;
		/* the number of buckets (i.e. cells) in the spatial grid */
	public var gridLength (default, null):Int;
		/* the array-list holding the spatial grid buckets */
	public var grid(default, null) : haxe.ds.Vector<Array<Rect>>;

	public var width(default, null):Float;
	public var height(default, null):Float;

	var powerOfTwo:UInt;

	// temp
	var _tmp_getGridIndexesArray:Array<Int>;

	public function new( _min:Vector2, _max:Vector2, _cs:UInt) {

		min = _min.mult(1);
		max = _max.mult(1);

		pos = new Vector2();

		width = max.x - min.x;
		height = max.y - min.y;

		cellSize = _cs;

		w = Math.ceil(width) >> powerOfTwo;
		h = Math.ceil(height) >> powerOfTwo;

		gridLength = Std.int(w * h);

		grid = new haxe.ds.Vector(gridLength);

		for (i in 0...gridLength) {
			grid[i] = new Array<Rect>();
		}

		// temp 
		_tmp_getGridIndexesArray = [];

	}


	public function addCollider(c:Rect){
		updateIndexes(c, aabbToGrid(new Vector2(c.x,c.y), new Vector2(c.x+c.width,c.y+c.height) ));
	}

	public function removeCollider(c:Rect):Void{
		removeIndexes(c);
	}

	public function updateCollider(c:Rect){
		updateIndexes(c, aabbToGrid(new Vector2(c.x,c.y), new Vector2(c.x+c.width,c.y+c.height) ));
		findContacts(c);
	}

	public function empty(){
		for (cell in grid) {
			if(cell.length > 0){
				for (c in cell) {
					c.gridIndex.splice(0, c.gridIndex.length);
				}
				cell.splice(0, cell.length);
			}
		}
	}

	public function destroy(){
		empty();
		min = null;
		max = null;
		pos = null;
		grid = null;
		_tmp_getGridIndexesArray = null;
	}

	inline public function findContacts(collider:Rect) {
		for (i in collider.gridIndex) {
			for (otherCollider in grid[i]) {
				if(collider == otherCollider) continue;
					// add contacts here
					// addContact(collider, otherCollider);
			}
		}

	}

	inline function aabbToGrid(_min:Vector2, _max:Vector2):Array<Int> {
		var ret:Array<Int> = _tmp_getGridIndexesArray;
		ret.splice(0, ret.length);

		if(!overlaps(_min, _max)) return ret;
		
		var aabbMinX:Int = clampi(getIndex_X(_min.x), 0, w-1);
		var aabbMinY:Int = clampi(getIndex_Y(_min.y), 0, h-1);
		var aabbMaxX:Int = clampi(getIndex_X(_max.x), 0, w-1);
		var aabbMaxY:Int = clampi(getIndex_Y(_max.y), 0, h-1);

		var aabbMin:Int = getIndex1d(aabbMinX, aabbMinY);
		var aabbMax:Int = getIndex1d(aabbMaxX, aabbMaxY);

		ret.push(aabbMin);
		if(aabbMin != aabbMax) {
			ret.push(aabbMax);

			var lenX:Int = aabbMaxX - aabbMinX + 1;
			var lenY:Int = aabbMaxY - aabbMinY + 1;
			for (x in 0...lenX) {
				for (y in 0...lenY) {
					if((x == 0 && y == 0) || (x == lenX-1 && y == lenY-1) ) continue;
					ret.push(getIndex1d(x, y) + aabbMin);
				}
			}
		}

		return ret;
	}

	function updateIndexes(c:Rect, _ar:Array<Int>) {
		for (i in c.gridIndex) {
			removeIndex(c, i);
		}

		c.gridIndex.splice(0, c.gridIndex.length);
		for (i in _ar) {
			addIndexes(c, i);
		}
	}

	function removeIndexes(c:Rect){
		for (i in c.gridIndex) {
			removeIndex(c, i);
		}
		c.gridIndex.splice(0, c.gridIndex.length);
	}

	inline function addIndexes(c:Rect, _cellPos:Int){
		grid[_cellPos].push(c);
		c.gridIndex.push(_cellPos);
	}

	inline function removeIndex(c:Rect, _pos:Int) {
		grid[_pos].remove(c);
	}

	inline function getIndex_X(_pos:Float):Int {
		return Std.int((_pos - (pos.x + min.x))) >> powerOfTwo;
	}

	inline function getIndex_Y(_pos:Float):Int {
		return Std.int((_pos - (pos.y + min.y))) >> powerOfTwo;
	}

	inline function getIndex1d(_x:Int, _y:Int):Int { // i = x + w * y;  x = i % w; y = i / w;
		return Std.int(_x + w * _y);
	}

	inline function overlaps(_min:Vector2, _max:Vector2):Bool {
		if ( _max.x < (pos.x + min.x) || _min.x > (pos.x + max.x) ) return false;
		if ( _max.y < (pos.y + min.y) || _min.y > (pos.y + max.y) ) return false;
		return true;
	}

	function set_cellSize(value:UInt):UInt {
		powerOfTwo = Math.round(Math.log(value)/Math.log(2));
		cellSize = 1 << powerOfTwo;
		return cellSize;
	}
	static inline public function clampi( value:Int, a:Int, b:Int ) : Int {
        return ( value < a ) ? a : ( ( value > b ) ? b : value );
	}
}