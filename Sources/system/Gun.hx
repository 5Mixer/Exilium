package system;

import entity.Bullet;
import entity.Particle;

class Gun extends System {
	var bullets = new Array<Bullet>();
	var particles = new Array<Particle>();
	var frame = 0;
	var input:Input;
	var camera:Camera;
	var lights:Array<Level.Light>;

	override public function new (input:Input,camera:Camera,lights:Array<Level.Light>){
		this.input = input;
		this.camera = camera;
		this.lights = lights;
		super();
	}

	override public function render (g:kha.graphics2.Graphics,entities:Array<Entity>){
		super.render(g,entities);

		for (bullet in bullets) bullet.draw(g);
		for (particle in particles) particle.draw(g);
	}

	override public function update (delta:Float,entities:Array<Entity>){
		super.update(delta,entities);
		frame++;

		for (bullet in bullets) bullet.update(delta);
		for (particle in particles) particle.update(delta);

		
		if (frame%6 == 0 && input.mouseButtons.left){
			for (entity in entities){
				if (entity.components.has("gun") && entity.components.has("transformation")){
					var transformation:component.Transformation = cast entity.components.get("transformation");
					var gun:component.Gun = cast entity.components.get("gun");

					var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(32,32))));
					var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

					
					var camOffset = dir.mult(1);
					camOffset.normalize();
					camOffset = camOffset.mult(6);
					camera.offset.x += camOffset.x;
					camera.offset.y += camOffset.y;

					if (entity.components.has("physics")){
						var physics:component.Physics = cast entity.components.get("physics");
						
						var knockback = .7+Math.random()/2;
						physics.velocity.x -= Math.cos(a*(Math.PI/180))*knockback;
						physics.velocity.y -= Math.sin(a*(Math.PI/180))*knockback;
					}

					shoot(entity,entities,a);
				}
			}
		}
	}
	public function shoot (parent:Entity,entities,angle){

		
		kha.audio1.Audio.play(kha.Assets.sounds.RapidFire);
		
		var l = { pos: parent.pos, radius: .6, colour: kha.Color.Red};
	
		bullets.push(
			new Bullet(parent,cast(parent.components.get("transformation"),component.Transformation).pos.mult(1),entities,angle,
			function (entity:Bullet){
				lights.remove(entity.light);
				bullets.remove(entity);
				
				particles.push(
					new Particle(entity,entity.pos,6+Math.round(Math.random()*4),Math.floor(entity.angle+180),
								function (entity) { particles.remove(entity); }
					)
				);
			},l)
		);

		particles.push(
			new Particle(parent,(cast parent.components.get("transformation")).pos, 10+Math.round(Math.random()*5),angle,
						function (entity) { particles.remove(entity); }
			)
		);

		

		lights.push(l);
	
	}
}