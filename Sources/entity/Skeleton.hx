package entity;

import component.Collisions;
import kha.math.Vector2;

class Skeleton extends SubEntity {
	var velocity:Vector2;
	var sprite:Sprite;
	var input:Input;
	var game:Project;

	public function new (game:Project,pos:Vector2,onDeath) {
		super(onDeath);

		this.pos = pos;
		size = new Vector2(16,16);
		velocity = new Vector2(0,0);
		sprite = new Sprite(kha.Assets.images.Entities,3);
		
		var c = new Collisions();
		c.registerCollisionRegion(this);
		this.components.set("collider",c);

		this.events.listenToEvent("shot",function(shooter){
			onDeath(this);
		});

		this.game = game;

	}
	override public function draw (g){
		super.draw(g);
		
		sprite.draw(g,pos.x,pos.y);
	}
	override public function update (delta:Float){
		super.update(delta);

		for (entity in game.entities.entities){
			if (entity == this) continue;
			
			if (entity.components.has("collider")){
				if (cast (entity.components.components.get("collider"),component.Collisions).doesShapeCollide(this)){
					 if (Std.is(entity,Bullet)){
						 this.onDeath(this);
					 }
				}
			}
		}
	}
		
}