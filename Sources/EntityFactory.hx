package ;

using util.ArrayExtender;

class EntityFactory {
	public function new () {};
	public static function makeItem (entities:eskimo.EntityManager, item:component.Inventory.Item, options:{pos:{x:Float,y:Float}}){
		var droppedItem = entities.create();
		droppedItem.set(new component.Name("Dropped Item"));
		droppedItem.set(new component.Transformation(new kha.math.Vector2(options.pos.x,options.pos.y)));
		droppedItem.set(new component.TimedLife(5+Math.random()*3));
		droppedItem.set(new component.Collisions([component.Collisions.CollisionGroup.Item],[component.Collisions.CollisionGroup.Item,component.Collisions.CollisionGroup.Enemy],false).registerCollisionRegion(new component.Collisions.Rect(2,2,4,4)));
		droppedItem.set(new component.Collectable([component.Collisions.CollisionGroup.Friendly],[item]));
		droppedItem.set(new component.Magnet());
		droppedItem.set(new component.Physics());

		if (item == component.Inventory.Item.Gold){
			droppedItem.set(new component.AnimatedSprite(states.Play.spriteData.entity.gold).playAnimation("spin").setSpeed(3));
		}
		if (item == component.Inventory.Item.HealthPotion){
			droppedItem.set(new component.Sprite(states.Play.spriteData.entity.healthPotion));
		}
		return droppedItem;
	}
	public static function createPlayer(entities:eskimo.EntityManager,spawnPoint:{x:Int,y:Int}) {
		var p = entities.create();
		p.set(new component.Name("Ghost"));
		p.set(new component.Transformation(new kha.math.Vector2(spawnPoint.x*16,spawnPoint.y*16)));
		p.set(new component.Events());
		p.set(new component.AnimatedSprite(states.Play.spriteData.entity.ghost));
		p.set(new component.AITarget());
		p.set(new component.Health(150));
		p.get(component.AnimatedSprite).spriteMap = kha.Assets.images.Ghost;
		p.get(component.AnimatedSprite).tilesize = 10;
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Inventory());
		p.set(new component.Collisions([component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Player],[component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Player,component.Collisions.CollisionGroup.Particle,component.Collisions.CollisionGroup.Item]));
		p.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(0,0,10,10));
		p.set(new component.Light());
		
		p.get(component.Light).colour = kha.Color.fromBytes(255,200,200);
		p.get(component.Light).strength = .8;

		// if (lastSave != null && lastSave.player != null){
		// 	p.get(component.Health).current = lastSave.player.health;
		// }
		return p;
	}
	public static function createSlime(entities:eskimo.EntityManager,x:Int,y:Int){
		var slime = entities.create();
		slime.set(new component.Name("Slime"));
		slime.set(new component.Transformation(new kha.math.Vector2(x,y)));
		slime.set(new component.AnimatedSprite(states.Play.spriteData.entity.slime));
		slime.set(new component.Health(5));
		slime.get(component.AnimatedSprite).speed = 4;
		slime.set(new component.Physics());
		slime.set(new component.AI(component.AI.AIMode.Slime));
		slime.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]));
		var b:component.Collisions.Rect = new component.Collisions.Rect(0,0,8,8);
		slime.get(component.Collisions).registerCollisionRegion(b);
		return slime;
	}
	public static function createTreasure(entities:eskimo.EntityManager,x:Int,y:Int){
		var treasure = entities.create();
		treasure.set(new component.Name("Treasure"));
		treasure.set(new component.Transformation(new kha.math.Vector2(x,y)));
		treasure.set(new component.AnimatedSprite(cast states.Play.spriteData.entity.chest));
		treasure.get(component.AnimatedSprite).speed = 2;
		treasure.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
		treasure.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(2,3,8,8));
		
		var contents = [];
		contents.pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*15));
		contents.pushx(component.Inventory.Item.HealthPotion,Math.floor(Math.random()*2));
		if (Math.random() > .5) contents.push(component.Inventory.Item.LaserGun);
		if (Math.random() > .75) contents.push(component.Inventory.Item.GrapplingHook);
		treasure.set(new component.ReleaseOnCollision(contents,[component.Collisions.CollisionGroup.Friendly]));
		
		return treasure;
	}
	public static function createShooterTrap(entities:eskimo.EntityManager,x:Int,y:Int){
		var shooter = entities.create();
		shooter.set(new component.Name("Shooter"));
		
		shooter.set(new component.Transformation(new kha.math.Vector2(x,y)));
		var angle = Math.round(Math.random()*360/45)*45;
		shooter.get(component.Transformation).angle = angle;

		shooter.set(new component.Sprite(cast states.Play.spriteData.entity.shooter));
		shooter.set(new component.Collisions([],[component.Collisions.CollisionGroup.Level,component.Collisions.CollisionGroup.Enemy]));
		shooter.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(5,5,6,6));

		shooter.set(new component.TimedShoot(10));
		
		return shooter;
	}
	public static function createGoblin (entities:eskimo.EntityManager,x:Int, y:Int){
		var goblin = entities.create();
		goblin.set(new component.Name("Goblin"));
		goblin.set(new component.Transformation(new kha.math.Vector2(x,y)));
		goblin.set(new component.AnimatedSprite(states.Play.spriteData.entity.goblin));
		goblin.set(new component.Health(15));
		goblin.get(component.AnimatedSprite).speed = 13;
		goblin.set(new component.Physics());
		goblin.set(new component.AI(component.AI.AIMode.Goblin));
		goblin.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]));
		var b:component.Collisions.Rect = new component.Collisions.Rect(2,1,6,9);
		goblin.get(component.Collisions).registerCollisionRegion(b);
		return goblin;
	}
	public static function createCorruptSoul (entities:eskimo.EntityManager,x:Int, y:Int){
		var corruptSoul = entities.create();
		corruptSoul.set(new component.Name("Corrupt Soul"));
		corruptSoul.set(new component.Transformation(new kha.math.Vector2(x,y)));
		//corruptSoul.set(new component.Health(75));
		corruptSoul.set(new component.Physics());
		corruptSoul.set(new component.CorruptSoulAI());
		corruptSoul.set(new component.ActiveBoss("Corrupt Soul"));
		corruptSoul.set(new component.Collisions([],[component.Collisions.CollisionGroup.Enemy,component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Item],false));
		var b:component.Collisions.Rect = new component.Collisions.Rect(-3,-3,6,6);
		corruptSoul.get(component.Collisions).registerCollisionRegion(b);
		corruptSoul.set(new component.CorruptSoul());
		for (i in 0...25){
			var size = 4+Math.random()*5;
			var corruptSoulChild = entities.create();
			corruptSoulChild.set(new component.Transformation(new kha.math.Vector2(x,y)));
			corruptSoulChild.set(new component.Health(10));
			corruptSoulChild.set(new component.Physics());
			corruptSoulChild.set(new component.CorruptSoulChild());
			corruptSoulChild.get(component.Physics).friction = .5;
			corruptSoulChild.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy],[component.Collisions.CollisionGroup.Enemy],false));
			var b:component.Collisions.Rect = new component.Collisions.Rect(Math.ceil(-size/2),Math.ceil(-size/2),Math.ceil(size),Math.ceil(size));
			corruptSoulChild.get(component.Collisions).registerCollisionRegion(b);
			
			corruptSoul.get(component.CorruptSoul).children.push(corruptSoulChild);
		}
		return corruptSoul;
	}
	public static function createPotion(entities:eskimo.EntityManager,x:Float, y:Float){
		var potion = entities.create();
		potion.set(new component.Name("Dropped Item"));
		potion.set(new component.Transformation(new kha.math.Vector2(x,y)));
		potion.set(new component.TimedLife(5+Math.random()*3));
		potion.set(new component.Magnet());
		potion.set(new component.Collisions([component.Collisions.CollisionGroup.Item],[component.Collisions.CollisionGroup.Bullet,component.Collisions.CollisionGroup.Enemy,component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Player,component.Collisions.CollisionGroup.Particle,component.Collisions.CollisionGroup.Item]).registerCollisionRegion(new component.Collisions.Rect(2,2,4,4)));
		potion.set(new component.Sprite(states.Play.spriteData.entity.healthPotion));
		return potion;

	}
	public static function createLadder(entities:eskimo.EntityManager,x:Int,y:Int,onCollide:Void->Void){ 
		var ladder = entities.create(); 
		ladder.set(new component.Name("Ladder")); 
		ladder.set(new component.Transformation(new kha.math.Vector2(x,y))); 
		ladder.set(new component.Sprite(states.Play.spriteData.entity.ladder)); 
		ladder.set(new component.Collisions([component.Collisions.CollisionGroup.Level])); 
		ladder.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(0,0,8,8)); 
		ladder.set(new component.CustomCollisionHandler([component.Collisions.CollisionGroup.Player],onCollide)); 
		return ladder; 
	}
	public static function createSpike(entities:eskimo.EntityManager,x:Int,y:Int){ 
		var spikes = entities.create(); 
		spikes.set(new component.Name("Spike")); 
		spikes.set(new component.Transformation(new kha.math.Vector2(x,y)));
		spikes.set(new component.Damager(1));
		spikes.set(new component.Spike());
		spikes.set(new component.AnimatedSprite(states.Play.spriteData.entity.spikes));
		spikes.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy],component.Collisions.CollisionGroup.createAll(),false)); 
		spikes.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(0,0,16,16));
		return spikes; 
	} 
}