package rendering;

class TilemapRenderer  {
	
	var lights:eskimo.views.View;
	var camera:Camera;
	var tilesize = 16;
	public function new (camera:Camera,entities:eskimo.EntityManager){
		this.camera = camera;
		lights = new eskimo.views.View(new eskimo.filters.Filter([component.Light,component.Transformation]),entities);
	}

	public function render (g:kha.graphics2.Graphics,map:world.Tilemap){


		var camtiley:Int = cast Math.max(Math.floor((camera.pos.y)/tilesize),0);
		var camtilex:Int = cast Math.max(Math.floor((camera.pos.x)/tilesize),0);
		var windoww = Math.ceil(kha.System.windowWidth()/(16*4))+1;
		var windowh = Math.ceil(kha.System.windowHeight()/(16*4))+1;

		//Loop through every visible tile.
		for (y in camtiley ... cast Math.min(camtiley+windowh,map.height)){
			for (x in camtilex ... cast Math.min(camtilex+windoww,map.width)){

				g.color = kha.Color.White;
				var tile = map.tiles[Math.floor(y*map.width)+x];
				var tileData = map.tileInfo.get(tile.id);

				if (tileData.id == -1)
					continue;

				var spec = tileData.specularity==null ? 1.0 : tileData.specularity;
				
				//In the rendering loop of tilemaps, where x,y is tile location.
				var colours:Array<kha.Color> = []; //Stores all effecting colours from light sources.
				for (lit in lights.entities){
					var light = lit.get(component.Light);
					var lightTransform = lit.get(component.Transformation);
					
					var lightPositionx:Int = Math.floor(lightTransform.pos.x/tilesize);
					var lightPositiony:Int = Math.floor(lightTransform.pos.y/tilesize);
					
					var smootherLights = [];
					for (sx in -1...2){
						for (sy in -1...2){
							if (map.get(lightPositionx+sx,lightPositiony+sy) == null) continue;
							if (map.tileInfo.get(map.get(lightPositionx+sx,lightPositiony+sy).id) == null) continue;
							if (map.tileInfo.get(map.get(lightPositionx+sx,lightPositiony+sy).id).collide) continue;
							smootherLights.push({x:sx,y:sy});
						}
					}
					//Can a path to the light be drawn from this tile without hitting an occluder?
					for (smootherLight in smootherLights){
						
						if (map.tileInfo.get(map.get(x,y).id).collide || !map.raycast(g,lightPositionx+smootherLight.x,lightPositiony +smootherLight.y,x,y)){
							var lx = (lightTransform.pos.x-4)/tilesize;
							var ly = (lightTransform.pos.y-4)/tilesize;
							var l =	Math.sqrt(((x - lx + smootherLight.x) * (x - lx + smootherLight.x)) + ((y - ly + smootherLight.y) * (y - ly + smootherLight.y))); //Distance to light.
							l = Math.max(Math.min(light.strength/l,1),0)/smootherLights.length; //This is the lights effect, kept in range.

							colours.push(kha.Color.fromFloats(light.colour.R*l,light.colour.G*l,light.colour.B*l,1)); //Add to colours
						}
					}
					
				}
				//Now add these colours togethor and store in one variable.
				var c = {r: 0.1, g: 0.1, b:0.1, a: 1.0};
				if (tileData.ambient != null){
					c.r = tileData.ambient.R;
					c.g = tileData.ambient.G;
					c.b = tileData.ambient.B;
				}
				for (colour in colours){

					c.r += colour.R * spec;
					c.g += colour.G * spec;
					c.b += colour.B * spec;
				}
				//Scale everything to a maximum of 1
				var max = Math.max(Math.max(c.r,1),Math.max(c.g,c.b));
				//Now actually apply the tint, again, within a range.
				g.color = kha.Color.fromFloats(c.r/max,c.g/max,c.b/max,1);
								
				var id = tileData.id + tile.zone.getIndex() * 5;
				var sourcePos = { x: (id%Math.floor(kha.Assets.images.Dungeonsets.width/tilesize))*tilesize, y:Math.floor(id/Math.floor(kha.Assets.images.Dungeonsets.width/tilesize))*tilesize };
				
				g.drawScaledSubImage(kha.Assets.images.Dungeonsets,sourcePos.x,sourcePos.y,tilesize,tilesize,x*tilesize,y*tilesize,tilesize,tilesize);

			}
		}
		g.color = kha.Color.White;
	}
	
}