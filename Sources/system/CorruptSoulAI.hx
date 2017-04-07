package system;

class CorruptSoulAI extends System {
	var view:eskimo.views.View;
	var frame = 0.0;
	var entities:eskimo.EntityManager;
	public var map:world.Tilemap;
	var targets:eskimo.views.View;
	public function new (entities:eskimo.EntityManager,tilemap:world.Tilemap){
		this.entities = entities;
		map = tilemap;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.ai.CorruptSoulAI,component.Physics,component.Transformation]),entities);
		targets = new eskimo.views.View(new eskimo.filters.Filter([component.ai.AITarget]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame += 1;
	
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var AI = entity.get(component.ai.CorruptSoulAI);
			var physics = entity.get(component.Physics);
			var soul = entity.get(component.CorruptSoul);
			var boss = entity.get(component.ActiveBoss);
			
			AI.life += 1;
			var totalMaxHealth:Float = 0;
			var totalCurrentHealth:Float = 0;
			for (c in soul.children){
				var health = c.get(component.Health);
				if (health != null){
					totalCurrentHealth += health.current;
				}
				totalMaxHealth += 10; //Ensure this is the same value as a childs max health;
			}

			if (boss != null){
				boss.current = Math.floor(totalCurrentHealth);
				boss.max = Math.floor(totalMaxHealth);
			}

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

			boss.active = (distanceToTarget < 200);
			
	
			if (AI.rage == false){
				if (totalCurrentHealth/totalMaxHealth < .25){
					//At 10 percent health enter RAGE mode.
					AI.rage = true;
					boss.rage = true;
				}
				if (Math.floor(AI.life/100)%2==0){
					boss.mode = "chasing!";
					var dir = closestTarget.get(component.Transformation).pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(entity.get(component.Transformation).pos);
					dir.normalize();
					entity.get(component.Physics).velocity = dir.mult(2);
				}else{
					boss.mode = "firing!";
					var angle = Math.atan2(entity.get(component.Physics).velocity.y,entity.get(component.Physics).velocity.x);
					angle += (-25+ Math.random()*50) * Math.PI/180;

					entity.get(component.Physics).velocity = entity.get(component.Physics).velocity.mult(.5);

					if ((AI.life%15)==0){
						var shots = 0;
						var max = 3;
						for (child in soul.children){
							if (Math.random()>.99 || shots++ > max) continue;
							remotelyAttack(child,closestTarget);
						}

					}
					//entity.get(component.Physics).velocity.x = Math.cos(angle)*1.4;
					//entity.get(component.Physics).velocity.y = Math.sin(angle)*1.4;
				}
			}else{
				boss.mode = "raging!";
				//CHASE.
				if ((AI.life%20)==0){
					for (child in soul.children){
						if (Math.random()<.3) continue;
						remotelyAttack(child,closestTarget);
					}

				}
				var dir = closestTarget.get(component.Transformation).pos.add(new kha.math.Vector2(-10+Math.random()*20,-10+Math.random()*20)).sub(entity.get(component.Transformation).pos);
				dir.normalize();
				entity.get(component.Physics).velocity = dir.mult(4+Math.random()*2);
			}

		}
	}
	public function remotelyAttack(from:eskimo.Entity,to:eskimo.Entity){
		var bullet = entities.create();

		if (!from.has(component.Transformation)|| !to.has(component.Transformation))
			return;

		var diff = to.get(component.Transformation).pos.sub(from.get(component.Transformation).pos);
		var angleRadians = Math.atan2(diff.y,diff.x);
		var angle = angleRadians * (180/Math.PI);

		//var position = new kha.math.Vector2(arrowWidth/2,arrowHeight/2); //Centre arrow on world origin point.
		
		var t = new component.Transformation(from.get(component.Transformation).pos.add(new kha.math.Vector2((0*Math.cos(angleRadians)),1)));
		t.angle = angle;
		bullet.set(t);
		
		//Arrow
		//Physics
		var physics = new component.Physics();
		physics.friction = 0.999;
		var speed = 4;
		physics.velocity = new kha.math.Vector2(Math.cos(angleRadians) * speed, Math.sin(angleRadians) * speed);
		bullet.set(physics);

		//Sprite
		bullet.set(new component.Sprite(states.Play.spriteData.entity.corrupt_projectile));
		
		//Death
		bullet.set(new component.TimedLife(3));
		bullet.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Level]));
		
		//Damage and collisions
		bullet.set(new component.Damager(10));
		bullet.set(new component.Collisions([component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Enemy],[component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Enemy,component.Collisions.CollisionGroup.Item,component.Collisions.CollisionGroup.Particle],true));
		bullet.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(3,6,10,10));

		//Little particle
		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
		particle.set(new component.TimedLife(.15));
		
		var aabb = from.get(component.Collisions).AABB;
		var transform = new component.Transformation(from.get(component.Transformation).pos.add(new kha.math.Vector2(0*Math.cos(angleRadians)+8,3*Math.sin(angleRadians)+8)));
		transform.angle = angle;
		particle.set(transform);
		
		var phys = new component.Physics();
		phys.friction = 0.6;
		
		var speed = 3;
		var particleAngle = angle - 6 + Math.random()*12;
		var particleAngleRadians = particleAngle * (Math.PI / 180);
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngleRadians) * speed,Math.sin(particleAngleRadians) * speed);
		particle.set(phys);
	}
}