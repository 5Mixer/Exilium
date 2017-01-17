package system;

class TilemapRenderer extends System {
	var view:eskimo.views.View;
	
	var lights:eskimo.views.View;
	var camera:Camera;
	var tilesize = 16;
	public function new (camera:Camera,entities:eskimo.EntityManager){
		super();
		this.camera = camera;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Tilemap]),entities);
		lights = new eskimo.views.View(new eskimo.filters.Filter([component.Light,component.Transformation]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var map = entity.get(component.Tilemap);

			var camtiley:Int = cast Math.max(Math.floor((camera.pos.y)/tilesize),0);
			var camtilex:Int = cast Math.max(Math.floor((camera.pos.x)/tilesize),0);
			var windoww = Math.ceil(kha.System.windowWidth()/(16*4))+1;
			var windowh = Math.ceil(kha.System.windowHeight()/(16*4))+1;

			for (y in camtiley ... cast Math.min(camtiley+windowh,map.height)){
				for (x in camtilex ... cast Math.min(camtilex+windoww,map.width)){

					g.color = kha.Color.White;
					
					var tileData = map.tileInfo.get(map.tiles[(y*map.width)+x]);

					if (tileData.id == -1)
						continue;

					var spec = tileData.specularity==null ? 1.0 : tileData.specularity;
					
					//In the rendering loop of tilemaps, where x,y is tile location.
					var colours:Array<kha.Color> = []; //Stores all effecting colours from light sources.
					for (lit in lights.entities){
						var light = lit.get(component.Light);
						var lightTransform = lit.get(component.Transformation);
						
						//Can a path to the light be drawn from this tile without hitting an occluder?
						for (ox in -1...1){
							for (oy in -1...1){
								if (map.tileInfo.get(map.get(x,y)).collide || !map.raycast(g,Math.floor((lightTransform.pos.x)/tilesize +ox),Math.floor((lightTransform.pos.y)/tilesize +oy),x,y)){
									var lx = lightTransform.pos.x/tilesize;
									var ly = lightTransform.pos.y/tilesize;
									var l =	Math.sqrt(((x - lx) * (x - lx)) + ((y - ly) * (y - ly))); //Distance to light.
									l = Math.max(Math.min(light.strength/l,1),0)/4; //This is the lights effect, kept in range.

									colours.push(kha.Color.fromFloats(light.colour.R*l,light.colour.G*l,light.colour.B*l,1)); //Add to colours
								}
							}	
						}
						
					}
					//Now add these colours togethor and store in one variable.
					var c = {r: 0.2, g: 0.2, b:0.2, a: 1.0};
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
					//Now actually apply the tint, again, within a range.
					g.color = kha.Color.fromFloats(Math.min(c.r,1),Math.min(c.g,1),Math.min(c.b,1),1);
					
					var id = tileData.id;
					var sourcePos = { x: (id%Math.floor(kha.Assets.images.Dungeonsets.width/tilesize))*tilesize, y:Math.floor(id/Math.floor(kha.Assets.images.Dungeonsets.height/tilesize))*tilesize };
					
					g.drawScaledSubImage(kha.Assets.images.Dungeonsets,sourcePos.x,sourcePos.y,tilesize,tilesize,x*tilesize,y*tilesize,tilesize,tilesize);

				}
			}
			g.color = kha.Color.White;
		}
	
	}
}