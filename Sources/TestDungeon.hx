class TestDungeon {
    static function main() {
		trace("Building map.");
		var asciimap = [
			0 => ' ',
			1 => '_',
			2 => '#',
			3 => '|'
		];
        var generator = new util.DungeonWorldGenerator(100,100);
		for (y in 0...generator.width){
			for (x in 0...generator.height){
				print(asciimap.get(generator.tiles[y*generator.width+x]));
			}
			print('\n');
		}
    }
	static function print(text){
		#if js
			js.Browser.document.getElementById('map').innerText += text;
		#else
			Sys.print(text);
		#end
	}
}