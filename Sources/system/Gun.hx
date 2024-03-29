package system;

import component.Collisions.CollisionGroup;

class Gun extends System {
	var frame = 0.;
	var input:Input;
	var camera:Camera;
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json').entity.bullet_basic;
	var n =0; //Frame but not based on delta, goofed a little.

	override public function new (input:Input,camera:Camera,entities:eskimo.EntityManager){
		this.input = input;
		this.camera = camera;
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Inventory,component.Gun,component.Transformation]),entities);
		super();
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame+=delta;
		n++;
		if (input.mouseButtons.left && input.mouseEvents){
			for (entity in view.entities){
				if (entity.get(component.Inventory) != null){
					var pinv = entity.get(component.Inventory);
					var selectedItem = pinv.getByIndex(pinv.activeIndex).item;
					var transformation:component.Transformation = entity.get(component.Transformation);
					var gun:component.Gun = entity.get(component.Gun);

					gun.cooldown -= delta;

					if (selectedItem == component.Inventory.Item.SlimeGun){
						gun.gun = component.Gun.GunType.SlimeGun;
						gun.fireRate = .12;
					}else if (selectedItem == component.Inventory.Item.LaserGun) {
						gun.gun = component.Gun.GunType.LaserGun;
						gun.fireRate = .2;
					}else if (selectedItem == component.Inventory.Item.Blaster) {
						gun.gun = component.Gun.GunType.BlasterGun;
						gun.fireRate = .15;
					}else if (selectedItem == component.Inventory.Item.Bow) {
						gun.gun = component.Gun.GunType.Bow;
						if (gun.charge < 3)
							gun.charge += delta;
					}else{
						gun.gun = null;

					}

					if (selectedItem == component.Inventory.Item.Bomb && n % 10 == 0){
						var transform = entity.get(component.Transformation);
						var throwSound = kha.audio1.Audio.play(kha.Assets.sounds.throwItem);
						throwSound.volume = .4 + Math.random()*.3;
						if (transform != null){
							var dir = transform.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(24,24))));
							var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));
							var speed = 100;
							var bomb = EntityFactory.createBomb(entities,transform.pos.x,transform.pos.y,Math.cos(a * (Math.PI / 180)) * speed,Math.sin(a * (Math.PI / 180)) * speed);
							bomb.get(component.Physics).velocityz = 1.5;
							bomb.get(component.Physics).friction = .95;
							var c = new hxColorToolkit.spaces.HSB(n%256,50,50).toRGB();
							var kc = kha.Color.fromBytes(Math.floor(c.red),Math.floor(c.blue),Math.floor(c.green));
							bomb.get(component.Colour).colour = kc;
							bomb.get(component.Physics).zgraivity = true;
							// bomb.set(new component.Light());
							// bomb.get(component.Light).colour = kc;
							// bomb.get(component.Light).strength = .1;
							
							pinv.takeFromInventory(component.Inventory.Item.Bomb);
						}
					}
				

					if (gun.cooldown <= 0){
						gun.cooldown = gun.fireRate;
						var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(24,24))));
						var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

						if (gun.gun != null && gun.gun != component.Gun.GunType.Bow && gun.gun != component.Gun.GunType.LaserGun){
							var camOffset = dir.mult(1);
							camOffset.normalize();
							camOffset = camOffset.mult(6+Math.random()*2);
							camera.offset.x += camOffset.x;
							camera.offset.y += camOffset.y;
						}

						if (entity.has(component.Physics) && gun.gun != null && gun.gun != component.Gun.GunType.Bow){
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
			}
		}else{


			for (entity in view.entities){
				
				var gun:component.Gun = entity.get(component.Gun);
				gun.cooldown -= delta;
				if (entity.get(component.Inventory) != null){
					var pinv = entity.get(component.Inventory);
					var selectedItem = pinv.getByIndex(pinv.activeIndex).item;
					var itemData = pinv.itemData.get(selectedItem);
					var transformation:component.Transformation = entity.get(component.Transformation);
					var gun:component.Gun = entity.get(component.Gun);
					frame = -1;
					var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(24,24))));
					
					var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

					if (gun.gun == component.Gun.GunType.Bow){
						if (gun.charge > .1){
							fireArrow(entity,a,1+gun.charge*3);
							gun.charge = 0;
						}
					}
				}
			}
		}
	}
	override public function render(g:kha.graphics2.Graphics) {
		if (input.mouseButtons.left && input.mouseEvents){
			for (entity in view.entities){
				if (entity.get(component.Inventory) != null){
					var pinv = entity.get(component.Inventory);
					var selectedItem = pinv.getByIndex(pinv.activeIndex).item;
					var itemData = pinv.itemData.get(selectedItem);
					var transformation:component.Transformation = entity.get(component.Transformation);
					var gun:component.Gun = entity.get(component.Gun);
					var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(24,24))));
					var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

					if (gun.gun == component.Gun.GunType.Bow){
						var offx = transformation.pos.x+6;
						var offy = transformation.pos.y+6;

						var max = 200;
						var dist = 1;//max-(Math.pow(.99,gun.charge)*max);//-Math.log(gun.charge)/Math.log(.9);
						var a = dir.mult(1);
						a.normalize();
						g.color = kha.Color.fromBytes(140,140,240,70);
						
						var seperation = 4; //* (3/Math.ceil(gun.charge));
						var dots = Math.floor(dir.length/seperation);
						var multiplier = dir.length/seperation;
						for (i in 0...dots){
							g.color = kha.Color.White;
							g.fillRect(offx-(a.x*seperation*i),offy-(a.y*seperation*i),1,1);
						}

						// g.drawLine(offx,offy,offx-(a.x * dist),offy-(a.y * dist),1);
					}
					
				}
			}
		}
	}
	public function shootSlimeGun (parent:eskimo.Entity,angle){

		AudioManager.play("LASER_SHOOT");
		// kha.audio1.Audio.play(kha.Assets.sounds.shoot2);
		
		var bullet = entities.create();

		var t = new component.Transformation(parent.get(component.Transformation).pos.sub(new kha.math.Vector2(3,3)));
		t.angle = angle;
		bullet.set(t);
		
		var p = new component.Physics();
		var speed = 150;
		p.friction = 0.999;
		p.velocity = new kha.math.Vector2(Math.cos(angle * (Math.PI / 180)) * speed,Math.sin(angle * (Math.PI / 180)) * speed);
		bullet.set(p);
		bullet.set(new component.Sprite(cast spriteData));

		bullet.set(new component.TimedLife(3));
		bullet.set(new component.Damager(4));
		bullet.set(new component.DieOnCollision([CollisionGroup.Level,CollisionGroup.ShooterTrap,CollisionGroup.Chest]));		
		
		bullet.set(new component.Light());
		bullet.get(component.Light).colour = kha.Color.Green;
		bullet.get(component.Light).strength = .1;

		bullet.set(new component.Collisions([CollisionGroup.Bullet,CollisionGroup.Friendly],[CollisionGroup.Bullet,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Item,CollisionGroup.Particle],new component.Collisions.Rect(4,4,8,8)));

		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
		
		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(5,5)));
		t.angle = angle;
		particle.set(t);
		var phys = new component.Physics();
		var speed = 80;
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
		var speed = 170;
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
		bullet.set(new component.Damager(5));

		
		bullet.set(new component.Light());
		bullet.get(component.Light).colour = kha.Color.Red;
		bullet.get(component.Light).strength = .4;

		bullet.set(new component.TimedLife(3));
		bullet.set(new component.DieOnCollision([CollisionGroup.Level,CollisionGroup.ShooterTrap,CollisionGroup.Chest]));
		bullet.set(new component.ParticleTrail(.2,component.VisualParticle.Effect.Spark));

		bullet.set(new component.Collisions([CollisionGroup.Bullet,CollisionGroup.Friendly],[CollisionGroup.Bullet,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Item,CollisionGroup.Particle],new component.Collisions.Rect(6,6,4,4),false));

		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Spark));
		

		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(5,5)));
		t.angle = angle;
		particle.set(t);
		var phys = new component.Physics();
		var speed = 130;
		phys.friction = 0.6;
		var particleAngle = angle - 6 + Math.random()*12;
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
		particle.set(phys);
		particle.set(new component.TimedLife(.15));
		
	}
	public function shootBlaster (parent:eskimo.Entity,a){

		kha.audio1.Audio.play(kha.Assets.sounds.shoot3);
		
		var spread = 5;
		var density = .1;
		for (offseta in 0...spread){
			var bullet = entities.create();
			var angle = a+((offseta-(spread/2))/density);
			var t = new component.Transformation(parent.get(component.Transformation).pos.sub(new kha.math.Vector2(3,3)));
			t.angle = angle;
			bullet.set(t);
			
			var p = new component.Physics();
			var speed = 190;
			p.friction = 0.98;
			p.velocity = new kha.math.Vector2(Math.cos(angle * (Math.PI / 180)) * speed,Math.sin(angle * (Math.PI / 180)) * speed);
			var shooterPhys = parent.get(component.Physics);
			var knockback = p.velocity.mult(1);
			knockback.normalize();
			shooterPhys.velocity = shooterPhys.velocity.sub(knockback.mult(8  ));
			bullet.set(p);
			bullet.set(new component.Sprite(states.Play.spriteData.entity.bullet_small));

			bullet.set(new component.TimedLife(.3));
			bullet.set(new component.Damager(2));
			bullet.set(new component.DieOnCollision([CollisionGroup.Enemy,CollisionGroup.Level,CollisionGroup.ShooterTrap,CollisionGroup.Chest]));
			
			bullet.set(new component.Collisions([CollisionGroup.Bullet,CollisionGroup.Friendly],[CollisionGroup.Bullet,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Item,CollisionGroup.Particle],new component.Collisions.Rect(4,4,8,8)));

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
	public function fireArrow (parent:eskimo.Entity,angle:Float,strength:Float){
		
		var shoot = kha.audio1.Audio.play(kha.Assets.sounds.shoot3);
		shoot.volume = .1+(strength/17);

		var angleDegrees = angle;
		var angleRadians = angle * (Math.PI / 180);
		//kha.audio1.Audio.play(kha.Assets.sounds.RapidFire);
		
		var bullet = entities.create();

		//var position = new kha.math.Vector2(arrowWidth/2,arrowHeight/2); //Centre arrow on world origin point.
		
		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(-3,-3)));
		t.angle = angle;
		bullet.set(t);
		
		//Arrow
		//Physics
		var physics = new component.Physics();
		physics.friction = 0.9;
		var speed = strength * 200; //1 strength = 1 second pull pack.
		physics.velocity = new kha.math.Vector2(Math.cos(angleRadians) * speed, Math.sin(angleRadians) * speed);
		bullet.set(physics);

		//Sprite
		bullet.set(new component.Sprite(states.Play.spriteData.entity.arrow_blue));
		
		//Death
		bullet.set(new component.TimedLife(1));
		bullet.get(component.TimedLife).explode = true;
		bullet.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Enemy,component.Collisions.CollisionGroup.Level]));
		bullet.get(component.DieOnCollision).explode = true;
		
		//Damage and collisions
		bullet.set(new component.Damager(30));
		bullet.set(new component.Collisions([component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Friendly],[component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Player],new component.Collisions.Rect(4,4,8,8),false));

		//////bullet.set(new component.ParticleTrail((17-strength*1.4),component.VisualParticle.Effect.Spark));
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
		
		var speed = 130;
		var particleAngle = angle - 6 + Math.random()*12;
		var particleAngleRadians = particleAngle * (Math.PI / 180);
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngleRadians) * speed,Math.sin(particleAngleRadians) * speed);
		particle.set(phys);
		
		
	}
}