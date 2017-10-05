package worldgen;
typedef Tile = {
	var id:Int;
	var zone:Zone;
	@:optional var visible:Bool;
	@:optional var colour:kha.Color;
}