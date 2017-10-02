package system;

class MummyAI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	public var map:world.Tilemap;
	var targets:eskimo.views.View;
	public function new (entities:eskimo.EntityManager,tilemap:world.Tilemap){
		this.entities = entities;
		map = tilemap;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.ai.MummyAI,component.Physics,component.Transformation]),entities);
		targets = new eskimo.views.View(new eskimo.filters.Filter([component.ai.AITarget]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame += 1;
	
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var physics = entity.get(component.Physics);
			var AI = entity.get(component.ai.MummyAI);
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
	

			if (distanceToTarget < 16){
				//Attack
				attackAnimation(entity);
				// if (entity.get(component.AnimatedSprite).frame == 2){
				if (frame % 20 == 0)
					closestTarget.get(component.Health).addToHealth(-8);
				// }
			}else if (distanceToTarget < AI.visionLength){
				//Chase
				var dir = closestTarget.get(component.Transformation).pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(entity.get(component.Transformation).pos);
				dir.normalize();
				entity.get(component.Physics).velocity = dir.mult(60);
				
				slitherAnimation(entity);
			}else{
				//Idle
				var angle = Math.atan2(entity.get(component.Physics).velocity.y,entity.get(component.Physics).velocity.x);

				if (AI.life % 20 == 0){
					angle += (-90+ Math.random()*180) * Math.PI/180;

				}
				
				entity.get(component.Physics).velocity.x = Math.cos(angle)*70;
				entity.get(component.Physics).velocity.y = Math.sin(angle)*70;

				slitherAnimation(entity);
				
			}
		}
	}

	public function slitherAnimation (entity:eskimo.Entity){
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
	public function attackAnimation (entity:eskimo.Entity){
		var angle = Math.atan2(entity.get(component.Physics).velocity.x,entity.get(component.Physics).velocity.y);
		var angleDeg = angle * (180/Math.PI);
		
		var normalVelocity = entity.get(component.Physics).velocity.mult(1);
		normalVelocity.normalize();
		
		var animation = "attack ";

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