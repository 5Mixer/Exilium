package system;
using kha.graphics2.GraphicsExtension;

class CollisionDebugView extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Collisions]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		g.color = kha.Color.Red;

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var collisions = entity.get(component.Collisions);
			for (region in collisions.collisionRegions){
				if (Std.is(region,component.Collisions.RectangleCollisionShape)){
					var r = cast (region,component.Collisions.RectangleCollisionShape);
					g.drawRect(r.pos.x,r.pos.y,r.size.x,r.size.y);
				}	
			}
		}

		g.color = kha.Color.White;
	}
}