package system;
using kha.graphics2.GraphicsExtension;

class ParticleRenderer extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.VisualParticle]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var particle = entity.get(component.VisualParticle);
			if (entity.has(component.TimedLife)){
				var life = entity.get(component.TimedLife);

				g.fillCircle(transform.pos.x,transform.pos.y,((life.length-life.fuse)/life.length)*2,4);
			}else{
				g.fillCircle(transform.pos.x,transform.pos.y,3,4);
			}
		}
	}
}