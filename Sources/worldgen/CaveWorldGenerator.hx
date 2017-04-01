package worldgen;

import worldgen.WorldGenerator.Room;
import worldgen.WorldGenerator.EntityType;
import worldgen.WorldGenerator.Side;
import worldgen.WorldGenerator.WorldGenerator;

import hxnoise.Perlin;

class CaveWorldGenerator extends WorldGenerator {
	override public function generate(){
		createMap();

		var perlin = new Perlin();
        var width = width;
        var height = height;

		spawnPoint = {x:0,y:0};
		exitPoint = {x:width-1,y:height-1};

        for(x in 0...width)
        {
            for(y in 0...height)
            {
                var c = perlin.OctavePerlin(x / 8, y / 8, 0.1, 5, 0.5, 0.25);
				set(x,y,c>.5?1:4);
            }
		}
	}
}