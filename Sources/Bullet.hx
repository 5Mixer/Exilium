package ;

class Bullet extends Entity{
	var angle:Int;
	var speed = 2;
	var sprite:Sprite;
	var colliders:Array<Entity>;
	var onDeath:Bullet->Void;
	override public function new (parent:Entity,colliders,angle,onDeath){
		super();
		this.angle = angle;
		this.pos = new kha.math.Vector2(parent.pos.x,parent.pos.y);
		this.colliders = colliders;
		sprite = new Sprite(kha.Assets.images.Entities,1);
		sprite.angle = angle;
		this.onDeath = onDeath;
	}
	override public function draw (g){
		super.draw(g);
		
		sprite.draw(g,pos.x,pos.y);
	}
	override public function update (delta){
		
		pos.x += Math.cos(angle * (Math.PI / 180)) * speed;
		pos.y += Math.sin(angle * (Math.PI / 180)) * speed;

		for (entity in colliders){
			if (entity.components.hasComponent("collider")){
				if (cast (entity.components.components.get("collider"),component.Collisions).doesShapeCollide(this)){
					onDeath(this);
					break;
				}
			}
		}
	}
}