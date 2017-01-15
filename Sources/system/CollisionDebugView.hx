package system;
using kha.graphics2.GraphicsExtension;

class CollisionDebugView extends System {
	var view:eskimo.views.View;
	var draw:util.KhaShapeDrawer;
	public function new (entities:eskimo.EntityManager){
		super();
		draw = new util.KhaShapeDrawer();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Collisions]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		g.color = kha.Color.Red;
		draw.SetGraphics(g);
		

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var collisions = entity.get(component.Collisions);
			for (region in collisions.collisionRegions){
				draw.drawShape(region);
			}
		}

		g.color = kha.Color.White;
	}
}