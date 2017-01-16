package system;

class AI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	var map:component.Tilemap;
	var targets:eskimo.views.View;
	public function new (entities:eskimo.EntityManager,tilemap:component.Tilemap){
		this.entities = entities;
		map = tilemap;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.AI,component.Physics,component.Transformation]),entities);
		targets = new eskimo.views.View(new eskimo.filters.Filter([component.AITarget]),entities);
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
				for (target in targets.entities){
					if (target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length < AI.visionLength){
						AI.activeState = component.AI.AIMode.Chase;
					}
				}
			}else if (AI.activeState == component.AI.AIMode.Chase){
				var thingSighted = null;
				for (target in targets.entities){
					if (target.get(component.Transformation).pos.add(new kha.math.Vector2(-40+Math.random()*80,-40+Math.random()*80)).sub(entity.get(component.Transformation).pos).length < AI.visionLength){
						thingSighted = target;
					}
				}
				if (thingSighted != null){
					var dir = thingSighted.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos);
					dir.normalize();
					entity.get(component.Physics).velocity = dir.mult(2);
					
				}else{
					AI.activeState = component.AI.AIMode.Idle;
				}
			}

			var angle = Math.atan2(entity.get(component.Physics).velocity.x,entity.get(component.Physics).velocity.y);
			var angleDeg = angle * (180/Math.PI);
			
			var normalVelocity = entity.get(component.Physics).velocity.mult(1);
			normalVelocity.normalize();
			
			var animation = "";

			if (normalVelocity.y < -.4)
				animation += "u";
			if (normalVelocity.y > .4)
				animation += "d";
				
			if (normalVelocity.x < -.4)
				animation += "l";
			if (normalVelocity.x > .4)
				animation += "r";
				

			entity.get(component.AnimatedSprite).playAnimation(animation);
		}
	}
}