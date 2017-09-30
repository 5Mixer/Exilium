package system;

class BatAI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	var targets:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.ai.BatAI,component.Physics,component.Transformation]),entities);
		targets = new eskimo.views.View(new eskimo.filters.Filter([component.ai.AITarget]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame += 1;
	
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var physics = entity.get(component.Physics);
			var AI = entity.get(component.ai.BatAI);
			AI.life += 1;

			var closestTarget = null;
			var distanceToTarget = Math.POSITIVE_INFINITY;
			for (target in targets.entities){
				if (target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length < distanceToTarget){
					distanceToTarget = target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length;
					closestTarget = target;
				}
			}
			
			if (closestTarget == null)
				continue;
	
			var closestTransform = closestTarget.get(component.Transformation);

			entity.get(component.AnimatedSprite).playAnimation("fly");

			if (distanceToTarget < 16){
				//Attack
				closestTarget.get(component.Health).addToHealth(-1);
				
			}else if (distanceToTarget < 80){
				//Swoop						
				var dir = closestTransform.pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(transformation.pos);
				dir.normalize();
				physics.velocity = physics.velocity.add(dir.mult(20));
				
			}else{
				//Idle
				var angle = Math.atan2(physics.velocity.y,physics.velocity.x);

				if (AI.life % AI.moveRate == 0){
					angle += (-10+ Math.random()*20) * Math.PI/180;
				}
				
				physics.velocity.x = Math.cos(angle)*AI.speed;
				physics.velocity.y = Math.sin(angle)*AI.speed;				
			}
		}
	}
	
}