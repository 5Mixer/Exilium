package entity;

class Bullet extends Entity{
	public var angle:Int;
	var speed = 3;
	var sprite:Sprite;
	var colliders:Array<Entity>;
	var onDeath:Bullet->Void;
	public var light:Level.Light;
	var parent:Entity;

	override public function new (parent:Entity,colliders,angle,onDeath,l){
		super();
		this.onDeath = onDeath;
		this.angle = angle;
		this.pos = new kha.math.Vector2(parent.pos.x,parent.pos.y);
		this.colliders = colliders;
		this.parent = parent;
		sprite = new Sprite(kha.Assets.images.Entities,1);
		sprite.angle = angle;
		light = l;
	}
	override public function draw (g){
		super.draw(g);
		
		sprite.draw(g,pos.x,pos.y);
	}
	override public function update (delta){
		
		pos.x += Math.cos(angle * (Math.PI / 180)) * speed;
		pos.y += Math.sin(angle * (Math.PI / 180)) * speed;

		for (entity in colliders){
			if (entity == parent) continue;
			if (entity.components.hasComponent("collider")){
				if (cast (entity.components.components.get("collider"),component.Collisions).doesShapeCollide(this)){
					entity.events.callEvent("shot",this);
					onDeath(this);
					break;
				}
			}
		}
		light.pos = pos.div(8);
	}
}