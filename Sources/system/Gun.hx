package system;

class Gun extends System {
	var frame = 0;
	var input:Input;
	var camera:Camera;
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;

	override public function new (input:Input,camera:Camera,entities:eskimo.EntityManager){
		this.input = input;
		this.camera = camera;
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Gun,component.Transformation]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame++;
		
		if (frame%2 == 0 && input.mouseButtons.left){
			for (entity in view.entities){
				
				var transformation:component.Transformation = entity.get(component.Transformation);
				var gun:component.Gun = entity.get(component.Gun);

				var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(32,32))));
				var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

				var camOffset = dir.mult(1);
				camOffset.normalize();
				camOffset = camOffset.mult(6);
				camera.offset.x += camOffset.x;
				camera.offset.y += camOffset.y;

				if (entity.has(component.Physics)){
					var physics:component.Physics = entity.get(component.Physics);
					
					var knockback = .7+Math.random()/2;
					physics.velocity.x -= Math.cos(a*(Math.PI/180))*knockback;
					physics.velocity.y -= Math.sin(a*(Math.PI/180))*knockback;
				}

				shoot(entity,a);
				
			}
		}
	}
	public function shoot (parent:eskimo.Entity,angle){

		
		//kha.audio1.Audio.play(kha.Assets.sounds.RapidFire);
		
		var l = { pos: parent.get(component.Transformation).pos.mult(1), radius: .6, colour: kha.Color.Red};
	
		var bullet = entities.create();

		var t = new component.Transformation(parent.get(component.Transformation).pos.mult(1));
		t.angle = angle;
		bullet.set(t);
		
		var p = new component.Physics();
		var speed = 3;
		p.friction = 0.999;
		p.velocity = new kha.math.Vector2(Math.cos(angle * (Math.PI / 180)) * speed,Math.sin(angle * (Math.PI / 180)) * speed);
		bullet.set(p);
		bullet.set(new component.Sprite(1));

		bullet.set(new component.TimedLife(3));
		bullet.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Enemy,component.Collisions.CollisionGroup.Level]));
		
		bullet.set(new component.Light());
		bullet.get(component.Light).colour = kha.Color.Red;
		bullet.get(component.Light).strength = .9;
		bullet.set(new component.Collisions([component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Friendly],[component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Friendly]));
		bullet.get(component.Collisions).registerCollisionRegion({x:bullet.get(component.Transformation).pos.x,y:bullet.get(component.Transformation).pos.y,width:16,height:16});

		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Smoke));
		

		var t = new component.Transformation(parent.get(component.Transformation).pos.add(new kha.math.Vector2(8,8)));
		t.angle = angle;
		particle.set(t);
		var phys = new component.Physics();
		var speed = 8;
		phys.friction = 0.8;
		var particleAngle = angle - 6 + Math.random()*12;
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
		particle.set(phys);
		particle.set(new component.TimedLife(.2));	
	}
}