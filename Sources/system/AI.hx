package system;

class AI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	public function new (entities:eskimo.EntityManager){
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.AI,component.Physics,component.Transformation]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame += 1;
	
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var AI = entity.get(component.AI);
			var physics = entity.get(component.Physics);
			
			if (AI.activeState == component.AI.AIMode.Idle){
				if (Math.floor(frame%3) == 0 ){
					var angle = Math.atan2(entity.get(component.Physics).velocity.y,entity.get(component.Physics).velocity.x);
					angle += (-25+ Math.random()*50) * Math.PI/180;

					entity.get(component.Physics).velocity.x = Math.cos(angle)*2;
					entity.get(component.Physics).velocity.y = Math.sin(angle)*2;

				}
			}
		}
	}
}