package system;

class CollisionDebugView extends System {
	var view:eskimo.views.View;
	var draw:util.KhaShapeDrawer;
	var grid:util.SpatialHash;
	public function new (entities:eskimo.EntityManager,grid:util.SpatialHash,showStaticEntities = false){
		super();
		this.grid = grid;
		draw = new util.KhaShapeDrawer();
		if (showStaticEntities){
			view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Collisions]),entities);
		}else{
			view = new eskimo.views.View(new eskimo.filters.Filter([component.Physics,component.Transformation,component.Collisions]),entities);
		}
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		draw.SetGraphics(g);
		

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var collisions = entity.get(component.Collisions);
			for (region in collisions.collisionRegions){
				if (region.gridIndex == null) continue;
				/*for (cell in region.gridIndex){
					
					g.color = kha.Color.White;
					g.drawRect(Math.floor(cell%grid.w)*16,Math.floor(cell/grid.h)*16,16,16,.25);
					//g.color = kha.Color.fromFloats(.2,.2,.6,.1);
					//g.fillRect(Math.floor(cell%grid.w)*16,Math.floor(cell/grid.h)*16,16,16);
					
				}*/
				g.color = kha.Color.Cyan;
				g.drawRect(region.x+transform.pos.x,region.y+transform.pos.y,region.width,region.height,.5);
			}
		}

		g.color = kha.Color.White;
	}
}