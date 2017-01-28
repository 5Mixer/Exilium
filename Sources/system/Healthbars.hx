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

			g.color = kha.Color.fromBytes(219,98,98);
			g.fillRect(transformation.pos.x,transformation.pos.y-4,8,1);
			g.color = kha.Color.fromBytes(219,219,98);
			g.fillRect(transformation.pos.x,transformation.pos.y-4,(Math.max(health.current/health.max,0))*8,1);
			
			
		}
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		for (entity in view.entities){
			var health:component.Health = entity.get(component.Health);
			if (health.current < 0){
				entity.destroy();
				trace("Destroy");
			}
		}
	}
}