package ;

using util.ArrayExtender;
import component.Collisions.CollisionGroup;
import component.Inventory.ItemType;
import component.Inventory.Item;
import component.*;

class EntityFactory {
	public static var itemData:Map<Item,{name:String, stackable:Bool, type: ItemType, sprite: Dynamic}> = [
		component.Inventory.Item.Gold => { name: "gold", stackable: true, type: ItemType.Currency, sprite:states.Play.spriteData.entity.gold },
		component.Inventory.Item.HealthPotion => { name: "health potion", stackable: true, type: ItemType.Potion, sprite:states.Play.spriteData.entity.healthPotion },
		component.Inventory.Item.SlimeGun => { name: "slime gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.slimeGun },
		component.Inventory.Item.LaserGun => { name: "laser gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.laserGun },
		component.Inventory.Item.GrapplingHook => { name: "grappling gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.grapplingHook },
		component.Inventory.Item.CastSheild => { name: "cast shield", stackable: false, type: ItemType.Other, sprite:states.Play.spriteData.entity.cast_shield },
		component.Inventory.Item.Key => { name: "key", stackable: false, type: ItemType.Other, sprite:states.Play.spriteData.entity.key }
	];

	public function new () {};
	public static function createItem (entities:eskimo.EntityManager, item:Item, x:Float, y:Float){
		var droppedItem = entities.create();
		droppedItem.set(new Name("Dropped Item"));
		droppedItem.set(new Transformation(new kha.math.Vector2(x,y)));
		droppedItem.set(new Collisions([CollisionGroup.Item],[CollisionGroup.Item,CollisionGroup.Enemy,CollisionGroup.Chest],new component.Collisions.Rect(2,2,4,4),false));
		droppedItem.set(new Collectable([CollisionGroup.Friendly],[item]));
		droppedItem.set(new Magnet());
		droppedItem.set(new Physics());
	
		if (item == component.Inventory.Item.Gold){
			droppedItem.set(new AnimatedSprite(states.Play.spriteData.entity.gold).playAnimation("spin").setSpeed(3));
		}else{
			droppedItem.set(new Sprite(itemData.get(item).sprite));
		}
		return droppedItem;
	}
	public static function createPlayer(entities:eskimo.EntityManager,spawnPoint:{x:Int,y:Int}) {
		var p = entities.create();
		p.set(new Name("Ghost"));
		p.set(new Transformation(new kha.math.Vector2(spawnPoint.x*16,spawnPoint.y*16)));
		p.set(new Events());
		p.set(new AnimatedSprite(states.Play.spriteData.entity.ghost));
		p.set(new component.ai.AITarget());
		p.set(new Health(150));
		p.get(AnimatedSprite).spriteMap = kha.Assets.images.Ghost;
		p.get(AnimatedSprite).tilesize = 10;
		p.set(new KeyMovement());
		p.set(new component.PotionAffected());
		p.set(new Physics());
		p.get(Physics).pushStrength = .4;
		p.set(new Gun());
		p.set(new Inventory());
		p.set(new GrappleHook());
		p.set(new GhostModeCustomMultiplier(1/60));
		p.set(new Collisions([CollisionGroup.Friendly,CollisionGroup.Player],[CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Particle,CollisionGroup.Item],new component.Collisions.Rect(0,0,10,10)));
		p.set(new Light());
		p.set(new Zindex(5));
		p.set(new GhostMode());
		
		p.get(Light).colour = kha.Color.fromBytes(255,200,200);
		p.get(Light).strength = .7;

		// p.get(component.Inventory).putIntoInventory(component.Inventory.Item.CastSheild);
		p.get(Inventory).putIntoInventory(component.Inventory.Item.Blaster);
		p.get(Inventory).putIntoInventory(component.Inventory.Item.LaserGun);
		p.get(Inventory).putIntoInventory(component.Inventory.Item.Bow);
		// p.get(Inventory).putIntoInventory(component.Inventory.Item.CastSheild);
		// p.get(Inventory).putIntoInventory(component.Inventory.Item.GrapplingHook);
		p.get(Inventory).putIntoInventory(component.Inventory.Item.Key);
		p.get(Inventory).putIntoInventory(component.Inventory.Item.Bomb,25);
		p.get(Inventory).putIntoInventory(component.Inventory.Item.Gold,70);

		return p;
	}
	public static function createSlime(entities:eskimo.EntityManager,x:Int,y:Int){
		var slime = entities.create();
		slime.set(new Name("Slime"));
		slime.set(new Transformation(new kha.math.Vector2(x,y)));
		slime.set(new AnimatedSprite(states.Play.spriteData.entity.slime));
		slime.set(new Health(15));
		slime.set(new Light());
		slime.get(Light).colour = kha.Color.Green;
		slime.get(Light).strength = .2;

		slime.get(AnimatedSprite).speed = 4;
		slime.set(new Physics());
		slime.set(new component.ai.AI(component.ai.AI.AIMode.Slime));
		slime.set(new Collisions([CollisionGroup.Enemy,CollisionGroup.Chest],new Collisions.Rect(0,0,8,8)));

		
		slime.set(new ReleaseOnDeath([].pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*3)),[CollisionGroup.Friendly]));

		return slime;
	}
	public static function createMummy(entities:eskimo.EntityManager,x:Int,y:Int){
		var mummy = entities.create();
		mummy.set(new Name("Mummy"));
		mummy.set(new Transformation(new kha.math.Vector2(x,y)));
		mummy.set(new AnimatedSprite(states.Play.spriteData.entity.mummy));
		mummy.set(new Health(25));
		mummy.get(AnimatedSprite).speed = 5;
		mummy.set(new Physics());
		mummy.set(new ReleaseOnDeath([].pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*10)),[CollisionGroup.Friendly]));

		mummy.set(new component.ai.MummyAI());
		mummy.set(new Collisions([CollisionGroup.Enemy,CollisionGroup.Chest],[],new Collisions.Rect(0,0,8,8)));
		return mummy;
	}
	public static function createTreasure(entities:eskimo.EntityManager,x:Int,y:Int){
		var treasure = entities.create();
		treasure.set(new Name("Treasure"));
		treasure.set(new Transformation(new kha.math.Vector2(x,y)));
		treasure.set(new component.AnimatedSprite(cast states.Play.spriteData.entity.chest));
		treasure.get(AnimatedSprite).speed = 2;
		treasure.set(new Collisions([CollisionGroup.Chest],[],new component.Collisions.Rect(2,3,8,8)));
		
		var contents = [];
		contents.pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*40));
		contents.pushx(component.Inventory.Item.HealthPotion,Math.floor(Math.random()*2));
		contents.pushx(component.Inventory.Item.SpeedPotion,Math.floor(Math.random()*1));
		// if (Math.random() > .6) contents.push(component.Inventory.Item.LaserGun);
		// if (Math.random() > .75) contents.push(component.Inventory.Item.GrapplingHook);
		treasure.set(new ReleaseOnCollision(contents,[CollisionGroup.Friendly]));
		
		return treasure;
	}
	public static function createLava(entities:eskimo.EntityManager,x:Int,y:Int){
		var treasure = entities.create();
		treasure.set(new Name("Lava"));
		treasure.set(new Transformation(new kha.math.Vector2(x,y)));
		treasure.set(new AnimatedSprite(cast states.Play.spriteData.entity.lava));
		treasure.get(AnimatedSprite).speed = 4;
		treasure.get(AnimatedSprite).playAnimation("flow");
		treasure.set(new Collisions([],[CollisionGroup.Bullet,CollisionGroup.Item],new component.Collisions.Rect(0,0,16,16),false));
		treasure.set(new Damager(.3));
		treasure.get(Damager).causesBlood = false;
		// treasure.set(new component.Light());
		// treasure.get(component.Light).colour = kha.Color.Red;
		// treasure.get(component.Light).strength = .5;

		return treasure;
	}
	public static function createTorch(entities:eskimo.EntityManager,x:Int,y:Int){
		var torch = entities.create();
		torch.set(new Name("Torch"));
		torch.set(new Transformation(new kha.math.Vector2(x,y)));
		torch.set(new AnimatedSprite(cast states.Play.spriteData.entity.torch));
		torch.get(AnimatedSprite).playAnimation("flicker");
		torch.set(new Light());
		// torch.set(new ParticleTrail(1,component.VisualParticle.Effect.Smoke));
		torch.get(Light).colour = kha.Color.Red;
		torch.get(Light).strength = .4;

		return torch;
	}
	public static function createBlood(entities:eskimo.EntityManager,x:Float,y:Float){
		var particle = entities.create();
		particle.set(new component.VisualParticle(component.VisualParticle.Effect.Blood));
		particle.set(new component.Zindex(-1));
		particle.set(new component.ObeyLighting());
		particle.set(new component.Transformation(new kha.math.Vector2(x,y)));
		var phys = new component.Physics();
		var speed = Math.random()*6;
		phys.friction = 0.7;
		var particleAngle = Math.random()*360;
		phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
		particle.set(phys);
		particle.set(new component.TimedLife(5+Math.random()*5));
	}
	public static function createLockedDoor(entities:eskimo.EntityManager,x:Int,y:Int){
		var door = entities.create();
		door.set(new Name("Locked Door"));
		door.set(new Transformation(new kha.math.Vector2(x,y)));
		door.set(new Sprite(cast states.Play.spriteData.entity.door));
		door.set(new Collisions([CollisionGroup.Level],[],new Collisions.Rect(0,0,16,16)));
		door.set(new Message("Door","One must find a/ngolden key to pass here."));
		door.set(new CustomCollisionHandler(null,function (collider) {
			if (collider.has(Inventory)){
				if (collider.get(Inventory).getStack(component.Inventory.Item.Key) != null){
					collider.get(Inventory).takeFromInventory(component.Inventory.Item.Key);
					door.destroy();
				}
			}
		}));

		return door;
	}
	public static function createShooterTrap(entities:eskimo.EntityManager,x:Int,y:Int){
		var shooter = entities.create();
		shooter.set(new Name("Shooter"));
		
		shooter.set(new Transformation(new kha.math.Vector2(x,y)));
		var angle = Math.round(Math.random()*360/45)*45;
		shooter.get(Transformation).angle = angle;

		shooter.set(new Sprite(cast states.Play.spriteData.entity.shooter));
		shooter.set(new Collisions([CollisionGroup.ShooterTrap],[CollisionGroup.Level,CollisionGroup.Enemy],new component.Collisions.Rect(5,5,6,6)));

		shooter.set(new TimedShoot(.5+Math.random()));
		//shooter.set(new component.Spin(-2+(Math.random()*4)));
		
		return shooter;
	}
	public static function createGoblin (entities:eskimo.EntityManager,x:Int, y:Int){
		var goblin = entities.create();
		goblin.set(new Name("Goblin"));
		goblin.set(new Transformation(new kha.math.Vector2(x,y)));
		goblin.set(new AnimatedSprite(states.Play.spriteData.entity.goblin));
		goblin.set(new Health(30));
		goblin.set(new ReleaseOnDeath([].pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*6)),[CollisionGroup.Friendly]));
		goblin.get(AnimatedSprite).speed = 13;
		goblin.set(new Physics());
		goblin.set(new component.ai.GoblinAI());
		goblin.set(new Collisions([CollisionGroup.Enemy],[], new component.Collisions.Rect(2,1,6,9)));
		return goblin;
	}
	public static function createBat (entities:eskimo.EntityManager,x:Int, y:Int){
		//TODO: Make a 'flying' component.
		var bat = entities.create();
		bat.set(new Name("Bat"));
		bat.set(new Transformation(new kha.math.Vector2(x,y)));
		bat.set(new AnimatedSprite(states.Play.spriteData.entity.bat));
		bat.get(AnimatedSprite).playAnimation("fly");
		bat.set(new Health(15));
		bat.set(new ReleaseOnDeath([].pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*4)),[CollisionGroup.Friendly]));
		bat.get(AnimatedSprite).speed = 5;
		bat.set(new Physics());
		bat.set(new component.ai.BatAI());
		bat.set(new Collisions([CollisionGroup.Enemy],[],new Collisions.Rect(1,1,6,6),false));
		return bat;
	}
	public static function createCorruptSoul (entities:eskimo.EntityManager,x:Int, y:Int){
		var corruptSoul = entities.create();
		corruptSoul.set(new Name("Corrupt Soul"));
		corruptSoul.set(new Transformation(new kha.math.Vector2(x,y)));
		corruptSoul.set(new Physics());
		corruptSoul.set(new component.ai.CorruptSoulAI());
		corruptSoul.set(new ActiveBoss("Corrupt Soul"));
		corruptSoul.set(new Collisions([CollisionGroup.Chest],[CollisionGroup.Enemy,CollisionGroup.Bullet,CollisionGroup.Item],new component.Collisions.Rect(-3,-3,6,6),false));
		corruptSoul.set(new CorruptSoul());
		corruptSoul.set(new Events());
		for (i in 0...15){
			var size = 3+Math.random()*3;
			var corruptSoulChild = entities.create();
			corruptSoulChild.set(new Transformation(new kha.math.Vector2(x,y)));
			corruptSoulChild.set(new Health(10));
			corruptSoulChild.set(new Physics());
			corruptSoulChild.set(new CorruptSoulChild());
			corruptSoulChild.get(Physics).friction = .5;
			corruptSoulChild.set(new Collisions([CollisionGroup.Enemy],[CollisionGroup.Enemy], new component.Collisions.Rect(Math.ceil(-size/2),Math.ceil(-size/2),Math.ceil(size),Math.ceil(size)),false));

			corruptSoul.get(component.CorruptSoul).children.push(corruptSoulChild);
		}
		return corruptSoul;
	}
	public static function createCactusBoss(entities:eskimo.EntityManager,x:Float,y:Float,room:worldgen.DungeonWorldGenerator.Room){
		var cactusBoss = entities.create();
		cactusBoss.set(new Name("Cactus Boss"));
		cactusBoss.set(new Transformation(new kha.math.Vector2(x,y)));
		cactusBoss.set(new Health(300));
		cactusBoss.set(new Physics());
		cactusBoss.set(new CactusBoss(room));
		cactusBoss.set(new ActiveBoss("Cactus Boss"));
		cactusBoss.get(ActiveBoss).current = 300;
		cactusBoss.get(ActiveBoss).max = 300;
		cactusBoss.set(new Collisions([CollisionGroup.Enemy],[],new Collisions.Rect(0,0,16,16)));
		cactusBoss.set(new Damager(.35));
		cactusBoss.set(new Events());
		cactusBoss.get(Events).listenToEvent(component.Events.Event.Death,function(e){
			trace("You killed the cactus boss!");
		});
	}
	public static function createPotion(entities:eskimo.EntityManager,x:Float, y:Float){
		var potion = entities.create();
		potion.set(new Name("Dropped Item"));
		potion.set(new Transformation(new kha.math.Vector2(x,y)));
		potion.set(new TimedLife(5+Math.random()*3));
		potion.set(new Magnet());
		potion.set(new Collisions([CollisionGroup.Item],[CollisionGroup.Bullet,CollisionGroup.Enemy,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Particle,CollisionGroup.Item],new component.Collisions.Rect(2,2,4,4)));
		potion.set(new Sprite(states.Play.spriteData.entity.healthPotion));
		return potion;

	}
	public static function createLadder(entities:eskimo.EntityManager,x:Int,y:Int,onCollide:eskimo.Entity->Void){ 
		var ladder = entities.create(); 
		ladder.set(new Name("Ladder")); 
		ladder.set(new Transformation(new kha.math.Vector2(x,y))); 
		ladder.set(new Sprite(states.Play.spriteData.entity.ladder)); 
		ladder.set(new Collisions([CollisionGroup.Level],[],new Collisions.Rect(0,0,16,16)));
		ladder.set(new CustomCollisionHandler([CollisionGroup.Player],onCollide)); 
		return ladder; 
	}
	public static function createSign(entities:eskimo.EntityManager,x:Int,y:Int,message:String){ 
		var sign = entities.create(); 
		sign.set(new Name("Sign")); 
		sign.set(new Transformation(new kha.math.Vector2(x,y))); 
		sign.set(new Sprite(states.Play.spriteData.entity.sign));
		sign.set(new Message("sign",message));
		sign.set(new Collisions([],[],new Collisions.Rect(2,5,12,9),false));
		return sign;
	}
	public static function createSpike(entities:eskimo.EntityManager,x:Int,y:Int){ 
		var spikes = entities.create(); 
		spikes.set(new Name("Spike")); 
		spikes.set(new Transformation(new kha.math.Vector2(x,y)));
		spikes.set(new Damager(.4));
		spikes.set(new Spike());
		spikes.set(new Zindex(-1));
		spikes.set(new AnimatedSprite(states.Play.spriteData.entity.spikes));
		spikes.get(AnimatedSprite).playAnimation("raise","up").setSpeed(2);
		spikes.set(new Collisions([],[],new component.Collisions.Rect(0,0,16,16),false)); 
		return spikes; 
	} 
	public static function createBomb(entities:eskimo.EntityManager,x,y,vx,vy){
		var bomb = entities.create();
		bomb.set(new Name("Bomb"));
		bomb.set(new Transformation(new kha.math.Vector2(x,y)));
		bomb.set(new component.Physics());
		bomb.get(component.Physics).velocity = new kha.math.Vector2(vx,vy);
		bomb.set(new component.Sprite(states.Play.spriteData.entity.bomb));
		bomb.set(new component.Colour());
		bomb.set(new Collisions([CollisionGroup.Friendly],[CollisionGroup.Friendly],new component.Collisions.Rect(1,1,6,7),false)); 
		bomb.set(new component.TimedLife(1));
		bomb.set(new component.DieOnCollision([CollisionGroup.Enemy]));

		bomb.get(component.DieOnCollision).explode = true;
		bomb.get(component.TimedLife).explode = true;
		return bomb;
	}
	public static function createExplosion(entities:eskimo.EntityManager,pos:kha.math.Vector2){
		var explosion = entities.create();
		kha.audio1.Audio.play(kha.Assets.sounds.explosion);
		explosion.set(new Name("Explosion"));
		explosion.set(new Transformation(pos.sub(new kha.math.Vector2(16-5,30-4))));
		explosion.set(new AnimatedSprite(states.Play.spriteData.entity.explosion));
		explosion.get(AnimatedSprite).playAnimation("explode","").setSpeed(2);
		explosion.set(new component.TimedLife(.3));
		explosion.set(new component.Light());
		explosion.get(component.Light).strength = .3;
		explosion.get(component.Light).colour = kha.Color.White;
		return explosion;
	}
}