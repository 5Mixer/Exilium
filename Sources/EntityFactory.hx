package ;

using util.ArrayExtender;
import component.Collisions.CollisionGroup;
import component.Inventory.ItemType;
import component.Inventory.Item;

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
		droppedItem.set(new component.Name("Dropped Item"));
		droppedItem.set(new component.Transformation(new kha.math.Vector2(x,y)));
		droppedItem.set(new component.Collisions([CollisionGroup.Item],[CollisionGroup.Item,CollisionGroup.Enemy,CollisionGroup.Chest],new component.Collisions.Rect(2,2,4,4),false));
		droppedItem.set(new component.Collectable([CollisionGroup.Friendly],[item]));
		droppedItem.set(new component.Magnet());
		droppedItem.set(new component.Physics());
	
		if (item == component.Inventory.Item.Gold){
			droppedItem.set(new component.AnimatedSprite(states.Play.spriteData.entity.gold).playAnimation("spin").setSpeed(3));
		}else{
			droppedItem.set(new component.Sprite(itemData.get(item).sprite));
		}
		return droppedItem;
	}
	public static function createPlayer(entities:eskimo.EntityManager,spawnPoint:{x:Int,y:Int}) {
		var p = entities.create();
		p.set(new component.Name("Ghost"));
		p.set(new component.Transformation(new kha.math.Vector2(spawnPoint.x*16,spawnPoint.y*16)));
		p.set(new component.Events());
		p.set(new component.AnimatedSprite(states.Play.spriteData.entity.ghost));
		p.set(new component.ai.AITarget());
		p.set(new component.Health(150));
		p.get(component.AnimatedSprite).spriteMap = kha.Assets.images.Ghost;
		p.get(component.AnimatedSprite).tilesize = 10;
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.get(component.Physics).pushStrength = .4;
		p.set(new component.Gun());
		p.set(new component.Inventory());
		p.set(new component.GrappleHook());
		p.set(new component.GhostModeCustomMultiplier(1/60));
		p.set(new component.Collisions([CollisionGroup.Friendly,CollisionGroup.Player],[CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Particle,CollisionGroup.Item],new component.Collisions.Rect(0,0,10,10)));
		p.set(new component.Light());
		p.set(new component.Zindex(5));
		p.set(new component.GhostMode());
		
		p.get(component.Light).colour = kha.Color.fromBytes(255,200,200);
		p.get(component.Light).strength = .7;

		// p.get(component.Inventory).putIntoInventory(component.Inventory.Item.CastSheild);
		p.get(component.Inventory).putIntoInventory(component.Inventory.Item.Blaster);
		// p.get(component.Inventory).putIntoInventory(component.Inventory.Item.Bow);

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
		slime.set(new component.ai.AI(component.ai.AI.AIMode.Slime));
		slime.set(new component.Collisions([CollisionGroup.Enemy,CollisionGroup.Chest],new component.Collisions.Rect(0,0,8,8)));
		return slime;
	}
	public static function createMummy(entities:eskimo.EntityManager,x:Int,y:Int){
		var mummy = entities.create();
		mummy.set(new component.Name("Mummy"));
		mummy.set(new component.Transformation(new kha.math.Vector2(x,y)));
		mummy.set(new component.AnimatedSprite(states.Play.spriteData.entity.mummy));
		mummy.set(new component.Health(20));
		mummy.get(component.AnimatedSprite).speed = 5;
		mummy.set(new component.Physics());
		mummy.set(new component.ai.MummyAI());
		mummy.set(new component.Collisions([CollisionGroup.Enemy,CollisionGroup.Chest],[],new component.Collisions.Rect(0,0,8,8)));
		return mummy;
	}
	public static function createTreasure(entities:eskimo.EntityManager,x:Int,y:Int){
		var treasure = entities.create();
		treasure.set(new component.Name("Treasure"));
		treasure.set(new component.Transformation(new kha.math.Vector2(x,y)));
		treasure.set(new component.AnimatedSprite(cast states.Play.spriteData.entity.chest));
		treasure.get(component.AnimatedSprite).speed = 2;
		treasure.set(new component.Collisions([CollisionGroup.Chest],[],new component.Collisions.Rect(2,3,8,8)));
		
		var contents = [];
		contents.pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*15));
		contents.pushx(component.Inventory.Item.HealthPotion,Math.floor(Math.random()*2));
		if (Math.random() > .6) contents.push(component.Inventory.Item.LaserGun);
		if (Math.random() > .75) contents.push(component.Inventory.Item.GrapplingHook);
		treasure.set(new component.ReleaseOnCollision(contents,[CollisionGroup.Friendly]));
		
		return treasure;
	}
	public static function createLava(entities:eskimo.EntityManager,x:Int,y:Int){
		var treasure = entities.create();
		treasure.set(new component.Name("Lava"));
		treasure.set(new component.Transformation(new kha.math.Vector2(x,y)));
		treasure.set(new component.AnimatedSprite(cast states.Play.spriteData.entity.lava));
		treasure.get(component.AnimatedSprite).speed = 4;
		treasure.get(component.AnimatedSprite).playAnimation("flow");
		treasure.set(new component.Collisions([],[CollisionGroup.Bullet,CollisionGroup.Item],new component.Collisions.Rect(0,0,16,16),false));
		treasure.set(new component.Damager(.3));
		treasure.get(component.Damager).causesBlood = false;
		// treasure.set(new component.Light());
		// treasure.get(component.Light).colour = kha.Color.Red;
		// treasure.get(component.Light).strength = .5;

		return treasure;
	}
	public static function createTorch(entities:eskimo.EntityManager,x:Int,y:Int){
		var torch = entities.create();
		torch.set(new component.Name("Torch"));
		torch.set(new component.Transformation(new kha.math.Vector2(x,y)));
		torch.set(new component.AnimatedSprite(cast states.Play.spriteData.entity.torch));
		torch.get(component.AnimatedSprite).playAnimation("flicker");
		torch.set(new component.Light());
		torch.set(new component.ParticleTrail(1,component.VisualParticle.Effect.Smoke));
		torch.get(component.Light).colour = kha.Color.Red;
		torch.get(component.Light).strength = .4;

		return torch;
	}
	public static function createLockedDoor(entities:eskimo.EntityManager,x:Int,y:Int){
		var door = entities.create();
		door.set(new component.Name("Locked Door"));
		door.set(new component.Transformation(new kha.math.Vector2(x,y)));
		door.set(new component.Sprite(cast states.Play.spriteData.entity.door));
		door.set(new component.Collisions([CollisionGroup.Level],[],new component.Collisions.Rect(0,0,16,16)));
		door.set(new component.Message("Door","One must find a/ngolden key to pass here."));
		door.set(new component.CustomCollisionHandler(null,function (collider) {
			if (collider.has(component.Inventory)){
				if (collider.get(component.Inventory).getStack(component.Inventory.Item.Key) != null){
					collider.get(component.Inventory).takeFromInventory(component.Inventory.Item.Key);
					door.destroy();
				}
			}
		}));

		return door;
	}
	public static function createShooterTrap(entities:eskimo.EntityManager,x:Int,y:Int){
		var shooter = entities.create();
		shooter.set(new component.Name("Shooter"));
		
		shooter.set(new component.Transformation(new kha.math.Vector2(x,y)));
		var angle = Math.round(Math.random()*360/45)*45;
		shooter.get(component.Transformation).angle = angle;

		shooter.set(new component.Sprite(cast states.Play.spriteData.entity.shooter));
		shooter.set(new component.Collisions([CollisionGroup.ShooterTrap],[CollisionGroup.Level,CollisionGroup.Enemy],new component.Collisions.Rect(5,5,6,6)));

		shooter.set(new component.TimedShoot(.5+Math.random()));
		//shooter.set(new component.Spin(-2+(Math.random()*4)));
		
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
		goblin.set(new component.ai.AI(component.ai.AI.AIMode.Goblin));
		goblin.set(new component.Collisions([CollisionGroup.Enemy,CollisionGroup.Chest],[], new component.Collisions.Rect(2,1,6,9)));
		return goblin;
	}
	public static function createBat (entities:eskimo.EntityManager,x:Int, y:Int){
		//TODO: Make a 'flying' component.
		var bat = entities.create();
		bat.set(new component.Name("Bat"));
		bat.set(new component.Transformation(new kha.math.Vector2(x,y)));
		bat.set(new component.AnimatedSprite(states.Play.spriteData.entity.bat));
		bat.get(component.AnimatedSprite).playAnimation("fly");
		bat.set(new component.Health(15));
		bat.get(component.AnimatedSprite).speed = 5;
		bat.set(new component.Physics());
		bat.set(new component.ai.BatAI());
		bat.set(new component.Collisions([CollisionGroup.Enemy],[],new component.Collisions.Rect(1,1,6,6)));
		return bat;
	}
	public static function createCorruptSoul (entities:eskimo.EntityManager,x:Int, y:Int){
		var corruptSoul = entities.create();
		corruptSoul.set(new component.Name("Corrupt Soul"));
		corruptSoul.set(new component.Transformation(new kha.math.Vector2(x,y)));
		corruptSoul.set(new component.Physics());
		corruptSoul.set(new component.ai.CorruptSoulAI());
		corruptSoul.set(new component.ActiveBoss("Corrupt Soul"));
		corruptSoul.set(new component.Collisions([CollisionGroup.Chest],[CollisionGroup.Enemy,CollisionGroup.Bullet,CollisionGroup.Item],new component.Collisions.Rect(-3,-3,6,6),false));
		corruptSoul.set(new component.CorruptSoul());
		corruptSoul.set(new component.Events());
		for (i in 0...15){
			var size = 3+Math.random()*3;
			var corruptSoulChild = entities.create();
			corruptSoulChild.set(new component.Transformation(new kha.math.Vector2(x,y)));
			corruptSoulChild.set(new component.Health(10));
			corruptSoulChild.set(new component.Physics());
			corruptSoulChild.set(new component.CorruptSoulChild());
			corruptSoulChild.get(component.Physics).friction = .5;
			corruptSoulChild.set(new component.Collisions([CollisionGroup.Enemy],[CollisionGroup.Enemy], new component.Collisions.Rect(Math.ceil(-size/2),Math.ceil(-size/2),Math.ceil(size),Math.ceil(size)),false));

			corruptSoul.get(component.CorruptSoul).children.push(corruptSoulChild);
		}
		return corruptSoul;
	}
	public static function createCactusBoss(entities:eskimo.EntityManager,x:Float,y:Float,room:worldgen.DungeonWorldGenerator.Room){
		var cactusBoss = entities.create();
		cactusBoss.set(new component.Name("Cactus Boss"));
		cactusBoss.set(new component.Transformation(new kha.math.Vector2(x,y)));
		cactusBoss.set(new component.Health(300));
		cactusBoss.set(new component.Physics());
		cactusBoss.set(new component.CactusBoss(room));
		cactusBoss.set(new component.ActiveBoss("Cactus Boss"));
		cactusBoss.get(component.ActiveBoss).current = 300;
		cactusBoss.get(component.ActiveBoss).max = 300;
		cactusBoss.set(new component.Collisions([CollisionGroup.Enemy],[],new component.Collisions.Rect(0,0,16,16)));
		cactusBoss.set(new component.Damager(.35));
		cactusBoss.set(new component.Events());
		cactusBoss.get(component.Events).listenToEvent(component.Events.Event.Death,function(e){
			trace("You killed the cactus boss!");
		});
	}
	public static function createPotion(entities:eskimo.EntityManager,x:Float, y:Float){
		var potion = entities.create();
		potion.set(new component.Name("Dropped Item"));
		potion.set(new component.Transformation(new kha.math.Vector2(x,y)));
		potion.set(new component.TimedLife(5+Math.random()*3));
		potion.set(new component.Magnet());
		potion.set(new component.Collisions([CollisionGroup.Item],[CollisionGroup.Bullet,CollisionGroup.Enemy,CollisionGroup.Friendly,CollisionGroup.Player,CollisionGroup.Particle,CollisionGroup.Item],new component.Collisions.Rect(2,2,4,4)));
		potion.set(new component.Sprite(states.Play.spriteData.entity.healthPotion));
		return potion;

	}
	public static function createLadder(entities:eskimo.EntityManager,x:Int,y:Int,onCollide:eskimo.Entity->Void){ 
		var ladder = entities.create(); 
		ladder.set(new component.Name("Ladder")); 
		ladder.set(new component.Transformation(new kha.math.Vector2(x,y))); 
		ladder.set(new component.Sprite(states.Play.spriteData.entity.ladder)); 
		ladder.set(new component.Collisions([CollisionGroup.Level],[],new component.Collisions.Rect(0,0,16,16)));
		ladder.set(new component.CustomCollisionHandler([CollisionGroup.Player],onCollide)); 
		return ladder; 
	}
	public static function createSign(entities:eskimo.EntityManager,x:Int,y:Int,message:String){ 
		var sign = entities.create(); 
		sign.set(new component.Name("Sign")); 
		sign.set(new component.Transformation(new kha.math.Vector2(x,y))); 
		sign.set(new component.Sprite(states.Play.spriteData.entity.sign));
		sign.set(new component.Message("sign",message));
		sign.set(new component.Collisions([],[],new component.Collisions.Rect(2,5,12,9),false));
		return sign;
	}
	public static function createSpike(entities:eskimo.EntityManager,x:Int,y:Int){ 
		var spikes = entities.create(); 
		spikes.set(new component.Name("Spike")); 
		spikes.set(new component.Transformation(new kha.math.Vector2(x,y)));
		spikes.set(new component.Damager(.4));
		spikes.set(new component.Spike());
		spikes.set(new component.Zindex(-1));
		spikes.set(new component.AnimatedSprite(states.Play.spriteData.entity.spikes));
		spikes.get(component.AnimatedSprite).playAnimation("raise","up").setSpeed(2);
		spikes.set(new component.Collisions([],CollisionGroup.createAll(),new component.Collisions.Rect(0,0,16,16),false)); 
		return spikes; 
	} 
}