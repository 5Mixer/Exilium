package ;

using kha.graphics2.GraphicsExtension;

class Particle extends Entity{
	var angle:Int;
	var speed = .5;
	var sprite:Sprite;
	var life:Int = 0;
	var maxLife:Int;
	var onDeath:Particle->Void;

	override public function new (parent:Entity,life:Int,angle,onDeath){
		super();
		this.onDeath = onDeath;
		this.angle = angle;
		this.pos = new kha.math.Vector2(parent.pos.x+4+Math.cos(angle* (Math.PI / 180))*4,parent.pos.y+4+Math.sin(angle* (Math.PI / 180))*4);
		this.maxLife = life;
		sprite = new Sprite(kha.Assets.images.Entities,1);
		sprite.angle = angle;
	}
	override public function draw (g:kha.graphics2.Graphics){
		super.draw(g);
		
		var color = life/maxLife < .5 ? kha.Color.White : kha.Color.Black;
		var size = 1 + (maxLife/life * .25); //Collectively, a max of size 2 = 4 pixels, = 8 (this is radius)
		g.color = color;
		g.fillCircle(this.pos.x,this.pos.y,size,4);
		g.color = kha.Color.White;

	}
	override public function update (delta){
		
		pos.x += Math.cos(angle * (Math.PI / 180)) * speed;
		pos.y += Math.sin(angle * (Math.PI / 180)) * speed;

		life++;

		if (life > maxLife)
			onDeath(this);
	}
}