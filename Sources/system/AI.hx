package system;

class AI extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		//view = new eskimo.views.View(new eskimo.filters.Filter([component.AI,component.Physics,component.Transformation]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
	/*
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var AI = entity.get(component.AI);
			var physics = entity.get(component.Physics);
			
			if (AI.activeState == component.AI.AIMode.Idle){
				if (kha.System.time % 3000 == 0){
					entity.get(component.Physics).velocity = entity.get(component.Physics).velocity.add(new kha.math.Vector2(-5+Math.random()*10,-5+Math.random()*10));
				}
			}
		}*/
	}
}