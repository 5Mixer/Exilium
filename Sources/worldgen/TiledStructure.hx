package worldgen;

import worldgen.WorldGenerator.WorldGenerator;

class TiledStructure extends WorldGenerator {
	
	override public function generate () {
		var data = haxe.xml.Parser.parse(kha.Assets.blobs.intro_tmx.toString());
		//trace(kha.Assets.blobs.test_tmx.toString());
		var structure = data.elementsNamed("map").next();
		width = Std.parseInt(structure.get("width"));
		height = Std.parseInt(structure.get("height"));
		createMap();

		//for (i in 0...25)
		//	tiles.push({id:1,zone:worldgen.Zone.Slime});

		for (layer in structure.elementsNamed("layer")){
			var n = 0;
			var layerTiles = layer.elementsNamed("data").next().elements();
			
			for (tile in layerTiles){
				var t = Std.parseInt(tile.get("gid"));
				var x = n%width;
				var y = Math.floor(n/width);
				if (t == 0){
					//set(x,y,{id:1,zone:Zone.Castle});
					n++;
					continue;
				}

				var dezonedId = ((t-1)%5)+1;
				if (dezonedId > 6)
					throw "wat.";
				var zone = worldgen.Zone.createByIndex(Math.floor((t-1)/5));
				set(x,y,{id:dezonedId,zone:zone});
				n++;
			}
		}
		
		var log = "\n";
		for (y in 0...height){
			for (x in 0...width){
				log += (tiles[(y*width)+x].id+",");
			}
			log += ("\n");
		}
		//trace(log);

		if (tiles.length != width*height)
			trace("Expected "+(width*height)+" tiles but got "+tiles.length);

		
		for (objectlayer in structure.elementsNamed("objectgroup")){
			//var layerTiles = objectlayer.elementsNamed("data").next().elements();
			for (object in objectlayer.elements()){
				var name = object.get("name");
				var properties = new Map<String,String>();
				for (element in object.elements()){
					if (element.nodeName == "properties"){
						for (property in element.elements()){
							properties.set(property.get("name"),property.get("value"));
						}
					}
				}
				switch (name){
					case "spawn": spawnPoint = {x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16) };
					case "exit" : exitPoint = {x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16) };
					case "spike" : entities.push({type: worldgen.WorldGenerator.EntityType.Spike, x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "slime" : entities.push({type: worldgen.WorldGenerator.EntityType.Enemy, x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "lava" : entities.push({type: worldgen.WorldGenerator.EntityType.Lava, x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "item" : entities.push({type: worldgen.WorldGenerator.EntityType.Item(component.Inventory.Item.createByName(properties.get("item").toString())), x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "door" : entities.push({type: worldgen.WorldGenerator.EntityType.Door, x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "shooter" : entities.push({type: worldgen.WorldGenerator.EntityType.Shooter, x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "torch" : entities.push({type: worldgen.WorldGenerator.EntityType.Torch, x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
					case "sign" : entities.push({type: worldgen.WorldGenerator.EntityType.Sign(properties.get("message").toString()), x: Math.floor(Std.parseInt(object.get("x"))/16), y: Math.floor(Std.parseInt(object.get("y"))/16)});
				}
			}
		}

		
	}	
}