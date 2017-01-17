package system;

import kha.math.FastMatrix3;

class Healthbars extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Health,component.Transformation]), entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			
			var health:component.Health = entity.get(component.Health);
			var transformation:component.Transformation = entity.get(component.Transformation);

			g.color = kha.Color.Yellow;
			g.fillRect(transformation.pos.x,transformation.pos.y-5,10,2);
			g.color = kha.Color.Green;
			g.fillRect(transformation.pos.x+1,transformation.pos.y-4,(Math.max(health.current/health.max,0))*9,1);
			
			if (health.max - health.current < 0){
				entity.destroy();
			}
		}
	}
}