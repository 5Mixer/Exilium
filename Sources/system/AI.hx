package system;

class AI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	public var map:component.Tilemap;
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

			if (AI.mode == component.AI.AIMode.Slime)
				slimeAIMode(entity,transformation,physics,AI);

			if (AI.mode == component.AI.AIMode.Goblin)
				goblineAIMode(entity,transformation,physics,AI);
			
		}
	}
	public function goblineAIMode (entity:eskimo.Entity,transformation:component.Transformation,physics:component.Physics,AI:component.AI){
		var closestTarget = null;
		var distanceToTarget = Math.POSITIVE_INFINITY;
		for (target in targets.entities){
			if (target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length < distanceToTarget){
				distanceToTarget = target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length;
				closestTarget = target;
			}
		}		

		var angle = Math.atan2(entity.get(component.Physics).velocity.y,entity.get(component.Physics).velocity.x);
		angle += (-5+ Math.random()*10) * Math.PI/180;

		entity.get(component.Physics).velocity.x = Math.cos(angle);
		entity.get(component.Physics).velocity.y = Math.sin(angle);

		if (distanceToTarget < 60){
			var dir = closestTarget.get(component.Transformation).pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(entity.get(component.Transformation).pos);
			dir.normalize();
			entity.get(component.Physics).velocity = dir.mult(-1.7);
		}
		goblinWalkAnimation(entity);
	}
	function goblinWalkAnimation (entity:eskimo.Entity){
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

		entity.get(component.AnimatedSprite).playAnimation(animation);
	}


	public function slimeAIMode(entity:eskimo.Entity,transformation:component.Transformation,physics:component.Physics,AI:component.AI){
		var closestTarget = null;
		var distanceToTarget = Math.POSITIVE_INFINITY;
		for (target in targets.entities){
			if (target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length < distanceToTarget){
				distanceToTarget = target.get(component.Transformation).pos.sub(entity.get(component.Transformation).pos).length;
				closestTarget = target;
			}
		}

		if (distanceToTarget < 16){
			//Attack
			attackAnimation(entity);
			if (entity.get(component.AnimatedSprite).frame == 2){
				closestTarget.get(component.Health).current -= 1;
			}
		}else if (distanceToTarget < AI.visionLength){
			//Chase						
			var dir = closestTarget.get(component.Transformation).pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(entity.get(component.Transformation).pos);
			dir.normalize();
			entity.get(component.Physics).velocity = dir.mult(2);
			slitherAnimation(entity);
		}else{
			//Idle
			var angle = Math.atan2(entity.get(component.Physics).velocity.y,entity.get(component.Physics).velocity.x);
			angle += (-25+ Math.random()*50) * Math.PI/180;

			entity.get(component.Physics).velocity.x = Math.cos(angle)*1.4;
			entity.get(component.Physics).velocity.y = Math.sin(angle)*1.4;

			slitherAnimation(entity);
			
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