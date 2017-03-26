package system;

class TimedShoot extends System {
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	public function new (entities:eskimo.EntityManager){
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.TimedShoot,component.Transformation]), entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var timedShoot:component.TimedShoot = entity.get(component.TimedShoot);
			if (entity.has(component.Sprite)){
				//var sprite = entity.get(component.Sprite);
				//sprite.textureId = spike.isUp ? 6 : 7;
			}
			
		}
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		for (entity in view.entities){
			entity.get(component.Transformation).angle += 2;
			
			var timedShoot:component.TimedShoot = entity.get(component.TimedShoot);
			timedShoot.timeLeft += 1;
			
			if (timedShoot.timeLeft > timedShoot.fireRate){
				//var gun = entity.get(component.Gun);
				//gun.gun =
				//gun.fire()???
				timedShoot.timeLeft = 0;
				fireArrow(entity,entity.get(component.Transformation).angle+Math.random()*6 -3);

				var animation = entity.get(component.AnimatedSprite);
				if (animation != null){
					animation.playAnimation("shoot","rest");
				}
			
			}
			
		}
	}
	public function fireArrow (parent:eskimo.Entity,angle:Float){

		var angleDegrees = angle;
		var angleRadians = angle * (Math.PI / 180);
		//kha.audio1.Audio.play(kha.Assets.sounds.RapidFire);
		
		var bullet = entities.create();

		var arrowWidth = 11;
		var arrowHeight = 5;
		//var position = new kha.math.Vector2(arrowWidth/2,arrowHeight/2); //Centre arrow on world origin point.
		
		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2((0*Math.cos(angleRadians)),1)));
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
		bullet.set(new component.Sprite(states.Play.spriteData.entity.arrow_blue));
		
		//Death
		bullet.set(new component.TimedLife(3));
		bullet.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Level]));
		
		//Damage and collisions
		bullet.set(new component.Damager(10));
		bullet.set(new component.Collisions([component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Enemy],[component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Enemy],true));
		bullet.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(3,6,10,10));

		//Little particle
		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
		particle.set(new component.TimedLife(.15));
		
		var aabb = parent.get(component.Collisions).AABB;
		var transform = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(0*Math.cos(angleRadians)+8,3*Math.sin(angleRadians)+8)));
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