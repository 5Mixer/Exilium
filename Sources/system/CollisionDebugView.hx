package system;

class CollisionDebugView extends System {
	var view:eskimo.views.View;
	var staticview:eskimo.views.View;
	var draw:util.KhaShapeDrawer;
	var grid:util.SpatialHash;
	public var showActiveEntities = true;
	public var showStaticEntities = true;
	public var visible = true;
	public function new (entities:eskimo.EntityManager,grid:util.SpatialHash,showStaticEntities = false){
		super();
		this.grid = grid;
		this.showStaticEntities = showStaticEntities;
		draw = new util.KhaShapeDrawer();
		staticview = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Collisions],[component.Physics]),entities);
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Physics,component.Transformation,component.Collisions]),entities);
		
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		if (!visible) return;

		draw.SetGraphics(g);
		
		if (showActiveEntities)
			for (entity in view.entities){
				var transform = entity.get(component.Transformation);
				var collisions = entity.get(component.Collisions);
				// for (region in collisions.collisionRegions){
					if (collisions.AABB.gridIndex == null) continue;
					/*for (cell in region.gridIndex){
						
						g.color = kha.Color.White;
						g.drawRect(Math.floor(cell%grid.w)*16,Math.floor(cell/grid.h)*16,16,16,.25);
						//g.color = kha.Color.fromFloats(.2,.2,.6,.1);
						//g.fillRect(Math.floor(cell%grid.w)*16,Math.floor(cell/grid.h)*16,16,16);
						
					}*/
					g.color = kha.Color.Cyan;
					g.drawRect(collisions.AABB.x+transform.pos.x,collisions.AABB.y+transform.pos.y,collisions.AABB.width,collisions.AABB.height,.5);
				// }
			}
		if (showStaticEntities)
			for (entity in staticview.entities){
				var transform = entity.get(component.Transformation);
				var collisions = entity.get(component.Collisions);
				// for (region in collisions.collisionRegions){
					if (collisions.AABB.gridIndex == null) continue;
					/*for (cell in region.gridIndex){
						
						g.color = kha.Color.White;
						g.drawRect(Math.floor(cell%grid.w)*16,Math.floor(cell/grid.h)*16,16,16,.25);
						//g.color = kha.Color.fromFloats(.2,.2,.6,.1);
						//g.fillRect(Math.floor(cell%grid.w)*16,Math.floor(cell/grid.h)*16,16,16);
						public 
					}*/
					g.color = kha.Color.Cyan;
					g.drawRect(collisions.AABB.x+transform.pos.x,collisions.AABB.y+transform.pos.y,collisions.AABB.width,collisions.AABB.height,.5);
				// }
			}

		g.color = kha.Color.White;
	}
}