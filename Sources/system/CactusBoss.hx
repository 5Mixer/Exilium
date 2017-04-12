package system;

class CactusBoss extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.CactusBoss]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var cactus = entity.get(component.CactusBoss);
			var image = kha.Assets.images.Cactus;
			var collisions = entity.get(component.Collisions);
			cactus.tick++;

			var size = cactus.size;
			collisions.collisionRegions[0].width = 16*size.width;
			collisions.collisionRegions[0].height = 16*size.height;
			collisions.recalculateAABB();
			if (size.width == 1 && size.height == 1){
				g.drawSubImage(image,transform.pos.x,transform.pos.y,0,0,16,16);
			}
			if (size.width == 1 && size.height != 1){
				g.drawSubImage(image,transform.pos.x,transform.pos.y,16,0,16,16);
				for (intermediary in 1...size.height){
					g.drawSubImage(image,transform.pos.x,transform.pos.y+(16*intermediary),16,16,16,16);
				}
				g.drawSubImage(image,transform.pos.x,transform.pos.y+(16*(size.height)),16,32,16,16);
			}
			if (size.width != 1 && size.height == 1){
				g.drawSubImage(image,transform.pos.x,transform.pos.y,32,0,16,16);
				for (intermediary in 1...size.width){
					g.drawSubImage(image,transform.pos.x+(16*intermediary),transform.pos.y,48,0,16,16);
				}
				g.drawSubImage(image,transform.pos.x+(16*(size.width)),transform.pos.y,64,0,16,16);
			}
			if (size.width != 1 && size.height != 1){
				//Top left.
				g.drawSubImage(image,transform.pos.x,transform.pos.y,80,0,16,16);
				//Top middle
				for (intermediary in 1...size.width){
					g.drawSubImage(image,transform.pos.x+(16*intermediary),transform.pos.y,96,0,16,16);
				}
				//Top right
				g.drawSubImage(image,transform.pos.x+(16*(size.width)),transform.pos.y,112,0,16,16);

				//Left middle.
				for (intermediary in 1...size.height){
					g.drawSubImage(image,transform.pos.x,transform.pos.y+(16*intermediary),80,16,16,16);
				}
				//Middle middle
				for (intermediaryx in 1...size.width){
					for (intermediaryy in 1...size.height){
						g.drawSubImage(image,transform.pos.x+(16*intermediaryx),transform.pos.y+(16*intermediaryy),96,16,16,16);
					}
				}
				//Right middle.
				for (intermediary in 1...size.height){
					g.drawSubImage(image,transform.pos.x+(16*(size.width)),transform.pos.y+(16*intermediary),112,16,16,16);
				}
				//Bottom left
				g.drawSubImage(image,transform.pos.x,transform.pos.y+(16*(size.height)),80,32,16,16);
				//Bottom middle
				for (intermediary in 1...size.width){
					g.drawSubImage(image,transform.pos.x+(16*intermediary),transform.pos.y+(16*(size.height)),96,32,16,16);
				}
				//Bottom right
				g.drawSubImage(image,transform.pos.x+(16*(size.width)),transform.pos.y+(16*(size.height)),112,32,16,16);
				
			}
		}
	}
}