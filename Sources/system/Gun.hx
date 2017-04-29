package system;

import component.Collisions.CollisionGroup;

class Gun extends System {
	var frame = 0;
	var input:Input;
	var camera:Camera;
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json').entity.bullet_basic;

	override public function new (input:Input,camera:Camera,entities:eskimo.EntityManager){
		this.input = input;
		this.camera = camera;
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Inventory,component.Gun,component.Transformation]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame++;

		
		
		if (input.mouseButtons.left){
			for (entity in view.entities){
				if (entity.get(component.Inventory) != null){
					var pinv = entity.get(component.Inventory);
					var selectedItem = pinv.getByIndex(pinv.activeIndex).item;
					var itemData = pinv.itemData.get(selectedItem);
					if (selectedItem == component.Inventory.Item.SlimeGun){
						entity.get(component.Gun).gun = component.Gun.GunType.SlimeGun;
						entity.get(component.Gun).fireRate = 7;
					}else if (selectedItem == component.Inventory.Item.LaserGun) {
						entity.get(component.Gun).gun = component.Gun.GunType.LaserGun;
						entity.get(component.Gun).fireRate = 6;
					}else if (selectedItem == component.Inventory.Item.Blaster) {
						entity.get(component.Gun).gun = component.Gun.GunType.BlasterGun;
						entity.get(component.Gun).fireRate = 10;
					}else{
						entity.get(component.Gun).gun = null;

					}
				}
				
				var transformation:component.Transformation = entity.get(component.Transformation);
				var gun:component.Gun = entity.get(component.Gun);

				if (frame%gun.fireRate == 0){
					var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(24,24))));
					var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

					if (gun.gun != null){
						var camOffset = dir.mult(1);
						camOffset.normalize();
						camOffset = camOffset.mult(6+Math.random()*2);
						camera.offset.x += camOffset.x;
						camera.offset.y += camOffset.y;
					}

					if (entity.has(component.Physics) && gun.gun != null){
						var physics:component.Physics = entity.get(component.Physics);
						
						var knockback = .5+(Math.random()*.3);
						physics.velocity.x -= Math.cos(a*(Math.PI/180))*knockback;
						physics.velocity.y -= Math.sin(a*(Math.PI/180))*knockback;
					}

					if (gun.gun == component.Gun.GunType.SlimeGun)
						shootSlimeGun(entity,a);
					if (gun.gun == component.Gun.GunType.LaserGun)
						shootLaserGun(entity,a);
					if (gun.gun == component.Gun.GunType.BlasterGun)
						shootBlaster(entity,a);
				}
			}
		}else{
			frame = -1;
		}
	}
	public function shootSlimeGun (parent:eskimo.Entity,angle){

		
		kha.audio1.Audio.play(kha.Assets.sounds.shoot2);
		
		var bullet = entities.create();

		var t = new component.Transformation(parent.get(component.Transformation).pos.sub(new kha.math.Vector2(3,3)));
		t.angle = angle;
		bullet.set(t);
		
		var p = new component.Physics();
		var speed = 4;
		p.friction = 0.999;
		p.velocity = new kha.math.Vector2(Math.cos(angle * (Math.PI / 180)) * speed,Math.sin(angle * (Math.PI / 180)) * speed);
		bullet.set(p);
		bullet.set(new component.Sprite(cast spriteData));

		bullet.set(new component.TimedLife(3));
		bullet.set(new component.Damager(4));
		bullet.set(new component.DieOnCollision([CollisionGroup.Level,CollisionGroup.ShooterTrap]));		
		
		bullet.set(new component.Collisions([CollisionGroup.Bullet,CollisionGroup.Friendly],[CollisionGroup.Bullet,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Item,CollisionGroup.Particle]));
		bullet.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(4,4,8,8));

		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
		
		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(5,5)));
		t.angle = angle;
		particle.set(t);
		var phys = new component.Physics();
		var speed = 3;
		phys.friction = 0.6;
		var particleAngle = angle - 6 + Math.random()*12;
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
		particle.set(phys);
		particle.set(new component.TimedLife(.15));
		
	}
	public function shootLaserGun (parent:eskimo.Entity,angle){

		
		kha.audio1.Audio.play(kha.Assets.sounds.shoot1);
		
		var bullet = entities.create();

		var t = new component.Transformation(parent.get(component.Transformation).pos.sub(new kha.math.Vector2(3,3)));
		t.angle = angle;
		bullet.set(t);
		
		var p = new component.Physics(false);
		var speed = 4;
		p.friction = 0.999;
		p.velocity = new kha.math.Vector2(Math.cos(angle * (Math.PI / 180)) * speed,Math.sin(angle * (Math.PI / 180)) * speed);
		bullet.set(p);
		var s = null;
		if (Math.random()>.5){
			s = states.Play.spriteData.entity.summoned_missile;
		}else{
			s = states.Play.spriteData.entity.summoned_missile_2;
		}
		bullet.set(new component.Sprite(s));
		bullet.set(new component.Damager(.6));

		bullet.set(new component.TimedLife(3));
		bullet.set(new component.DieOnCollision([CollisionGroup.Level,CollisionGroup.ShooterTrap]));
		bullet.set(new component.ParticleTrail(.3,component.VisualParticle.Effect.Spark));

		bullet.set(new component.Collisions([CollisionGroup.Bullet,CollisionGroup.Friendly],[CollisionGroup.Bullet,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Item,CollisionGroup.Particle],false));
		bullet.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(6,6,4,4));

		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
		

		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(5,5)));
		t.angle = angle;
		particle.set(t);
		var phys = new component.Physics();
		var speed = 3;
		phys.friction = 0.6;
		var particleAngle = angle - 6 + Math.random()*12;
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
		particle.set(phys);
		particle.set(new component.TimedLife(.15));
		
	}
	public function shootBlaster (parent:eskimo.Entity,a){

		kha.audio1.Audio.play(kha.Assets.sounds.shoot3);
		
		var spread = 7;
		var density = .1;
		for (offseta in 0...spread){
			var bullet = entities.create();
			var angle = a+((offseta-(spread/2))/density);
			var t = new component.Transformation(parent.get(component.Transformation).pos.sub(new kha.math.Vector2(3,3)));
			t.angle = angle;
			bullet.set(t);
			
			var p = new component.Physics();
			var speed = 3;
			p.friction = 0.98;
			p.velocity = new kha.math.Vector2(Math.cos(angle * (Math.PI / 180)) * speed,Math.sin(angle * (Math.PI / 180)) * speed);
			bullet.set(p);
			bullet.set(new component.Sprite(states.Play.spriteData.entity.bullet_small));

			bullet.set(new component.TimedLife(.15+(.05*Math.random())));
			bullet.set(new component.Damager(1));
			bullet.set(new component.DieOnCollision([CollisionGroup.Enemy,CollisionGroup.Level,CollisionGroup.ShooterTrap]));
			
			bullet.set(new component.Collisions([CollisionGroup.Bullet,CollisionGroup.Friendly],[CollisionGroup.Bullet,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Item,CollisionGroup.Particle]));
			bullet.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(4,4,8,8));

			var particle = entities.create();
			particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
			

			var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(5,5)));
			t.angle = angle;
			particle.set(t);
			var phys = new component.Physics();
			var speed = 3;
			phys.friction = 0.6;
			var particleAngle = angle - 6 + Math.random()*12;
			phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
			particle.set(phys);
			particle.set(new component.TimedLife(.15));
		}
		
		
	}
}