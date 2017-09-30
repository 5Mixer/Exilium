package system;

class GoblinAI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	public var map:world.Tilemap;
	var targets:eskimo.views.View;
	public function new (entities:eskimo.EntityManager,tilemap:world.Tilemap){
		this.entities = entities;
		map = tilemap;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.ai.GoblinAI,component.Physics,component.Transformation]),entities);
		targets = new eskimo.views.View(new eskimo.filters.Filter([component.ai.AITarget]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame += 1;
	
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var physics = entity.get(component.Physics);
			var AI = entity.get(component.ai.GoblinAI);
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
	
			walkAnimation(entity);
			if (distanceToTarget < 16){
				//Attack
				// if (entity.get(component.AnimatedSprite).frame == 2){
				if (frame % 4 == 0)
					closestTarget.get(component.Health).addToHealth(-2);
				// }
			}else if (distanceToTarget < AI.visionLength){
				//Chase						
				var dir = closestTarget.get(component.Transformation).pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(entity.get(component.Transformation).pos);
				dir.normalize();
				entity.get(component.Physics).velocity = dir.mult(80);
				
			}else{
				//Idle
				var angle = Math.atan2(entity.get(component.Physics).velocity.y,entity.get(component.Physics).velocity.x);

				if (AI.life % 20 == 0){
					angle += (-90+ Math.random()*180) * Math.PI/180;

				}
				
				entity.get(component.Physics).velocity.x = Math.cos(angle)*50;
				entity.get(component.Physics).velocity.y = Math.sin(angle)*50;

				
			}
		}
	}

	function walkAnimation (entity:eskimo.Entity){
		var angle = Math.atan2(entity.get(component.Physics).velocity.x,entity.get(component.Physics).velocity.y);
		var angleDeg = angle * (180/Math.PI);
		
		var normalVelocity = entity.get(component.Physics).velocity.mult(1);
		normalVelocity.normalize();
		
		var animation = "walk";

		if (normalVelocity.y < -.4)
			animation += "_up";
		if (normalVelocity.y > .4)
			animation += "_down";
			
		if (normalVelocity.x < -.4)
			animation += "_left";
		if (normalVelocity.x > .4)
			animation += "_right";

		if (entity.has(component.AnimatedSprite))
			entity.get(component.AnimatedSprite).playAnimation(animation);
	}
	
}

