package ;

import component.Collisions;
import kha.math.Vector2;

class Player extends Entity {
	var velocity:Vector2;
	var sprite:Sprite;
	var input:Input;
	var game:Project;

	var bullets = new Array<Bullet>();
	
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
	
		
		for (bullet in bullets) bullet.draw(g);
		
		sprite.draw(g,pos.x,pos.y);
		components.callEvent("draw",g);

		
		
	}
	var frame = 0;
	override public function update (delta:Float) {
		frame++;
		super.update(delta);
		for (bullet in bullets) bullet.update(delta);

		var speed = 1;
		if (input.left) velocity.x = -speed;
		if (input.right) velocity.x = speed;
		if (input.up) velocity.y = -speed;
		if (input.down) velocity.y = speed;

		if (frame%10 == 0){
			var dir = pos.sub(game.camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(32,32))));
			var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));

			bullets.push(
				new Bullet(this,game.entities,a,
				function (entity){
					bullets.remove(entity);
				})
			);
		}
		


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
		
		var friction = .7;
		
		if (!collides){
			pos.x += velocity.x;
			velocity.x *= friction;
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
			velocity.y *= friction;
		}
		

	}

}
