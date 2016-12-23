package ;

import component.Collisions;
import kha.math.Vector2;

class Player extends Entity {
	var velocity:Vector2;
	var sprite:Sprite;
	var input:Input;
	var game:Project;

	var bullets = new Array<Bullet>();
	var particles = new Array<Particle>();
	
	public function new (input,game:Project) {
		super();

		pos = new Vector2(16,16);
		size = new Vector2(8,8);
		velocity = new Vector2(0,0);
		sprite = new Sprite(kha.Assets.images.Entities,0);
		this.input = input;
		
		var c = new Collisions(this);
		c.registerCollisionRegion(this);
		this.components.set("collider",c);

		this.game = game;
	}
	override public function draw (g){
		super.draw(g);
		
		trace('drawing ${bullets.length} bullet/s.');
		for (bullet in bullets) {
			bullet.draw(g);
		}

		for (particle in particles) particle.draw(g);
		
		sprite.draw(g,pos.x,pos.y);
		components.callEvent("draw",g);

		
		
	}
	var frame = 0;
	override public function update (delta:Float) {
		
		if (!input.mouseButtons.left){
			frame = -1;
		}else{
			frame++;
		}

		super.update(delta);
		for (bullet in bullets) bullet.update(delta);
		for (particle in particles) particle.update(delta);

		var speed = 1;
		var m = .8;
		if (input.left && velocity.x > -speed) velocity.x -= m;
		if (input.right && velocity.x < speed) velocity.x += m;
		if (input.up && velocity.y > -speed) velocity.y -= m;
		if (input.down && velocity.y < speed) velocity.y += m;

		

		if (frame%6 == 0 && input.mouseButtons.left){
			var dir = pos.sub(game.camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(32,32))));
			var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

			
			kha.audio1.Audio.play(kha.Assets.sounds.RapidFire);

			var l = { pos: new kha.math.Vector2(this.pos.x,this.pos.y), radius: .6, colour: kha.Color.Red};

			bullets.push(
				new Bullet(this,game.entities,a,
				function (entity:Bullet){
					game.level.lights.remove(entity.light);
					bullets.remove(entity);
					
					particles.push(
						new Particle(entity,6+Math.round(Math.random()*4),Math.floor(entity.angle+180),
									function (entity) { particles.remove(entity); }
						)
					);
				},l)
			);
			game.level.lights.push(l);

			particles.push(
				new Particle(this,10+Math.round(Math.random()*5),a,
							function (entity) { particles.remove(entity); }
				)
			);

			var camOffset = dir.mult(1);
			camOffset.normalize();
			camOffset = camOffset.mult(6);
			game.camera.offset.x += camOffset.x;
			game.camera.offset.y += camOffset.y;


			var knockback = .7+Math.random()/2;
			velocity.x -= Math.cos(a*(Math.PI/180))*knockback;
			velocity.y -= Math.sin(a*(Math.PI/180))*knockback;
		}

		
		var friction = .7;
		velocity.x *= friction;
		velocity.y *= friction;
		
		
		var newPos = new Vector2(pos.x,pos.y);

		//x collision wave
		var newCollider = new component.Collisions.RectangleCollisionShape(new Vector2(pos.x+velocity.x,pos.y), size);
		
		var collides = false;
		for (entity in game.entities){
			if (entity.components.hasComponent("collider")){
				 if (cast (entity.components.components.get("collider"),component.Collisions).doesShapeCollide(newCollider)){
					 collides = true;
					 //pos.x = Math.round(pos.x/8)*8;
					 break;
				 }
			}
		}
		
		
		if (!collides){
			pos.x += velocity.x;
		}



		newCollider = new component.Collisions.RectangleCollisionShape(new Vector2(pos.x,pos.y+velocity.y), size);
		
		collides = false;
		for (entity in game.entities){
			if (entity.components.hasComponent("collider")){
				 if (cast (entity.components.components.get("collider"),component.Collisions).doesShapeCollide(newCollider)){
					 collides = true;
					 //pos.y = Math.round(pos.y/8)*8;
					 break;
				 }
			}
		}
		if (!collides){
			pos.y += velocity.y;
		}
		

	}

}
