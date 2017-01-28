package ;

using util.ArrayExtender;

class EntityFactory {
	public function new () {};
	public static function makeItem (entities:eskimo.EntityManager, item:component.Inventory.Item, options:{pos:{x:Float,y:Float}}){
		var droppedItem = entities.create();
		droppedItem.set(new component.Name("Dropped Item"));
		droppedItem.set(new component.Transformation(new kha.math.Vector2(options.pos.x,options.pos.y)));
		droppedItem.set(new component.TimedLife(5+Math.random()*3));
		droppedItem.set(new component.Collisions([]).registerCollisionRegion(new component.Collisions.Rect(2,2,4,4)));
		droppedItem.set(new component.Collectable([component.Collisions.CollisionGroup.Friendly],[item]));

		if (item == component.Inventory.Item.Gold){
			droppedItem.set(new component.AnimatedSprite(Project.spriteData.entity.gold).playAnimation("spin").setSpeed(3));
		}
		if (item == component.Inventory.Item.HealthPotion){
			droppedItem.set(new component.Sprite(Project.spriteData.entity.healthPotion));
		}
		return droppedItem;
	}
	public static function createPlayer(entities:eskimo.EntityManager,spawnPoint:{x:Int,y:Int}) {
		var p = entities.create();
		p.set(new component.Name("Ghost"));
		p.set(new component.Transformation(new kha.math.Vector2(spawnPoint.x*16,spawnPoint.y*16)));
		p.set(new component.AnimatedSprite(Project.spriteData.entity.ghost));
		p.set(new component.AITarget());
		p.set(new component.Health(150));
		p.get(component.AnimatedSprite).spriteMap = kha.Assets.images.Ghost;
		p.get(component.AnimatedSprite).tilesize = 10;
		p.set(new component.KeyMovement());
		p.set(new component.Physics());
		p.set(new component.Gun());
		p.set(new component.Inventory());
		p.set(new component.Collisions([component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Player],[component.Collisions.CollisionGroup.Friendly,component.Collisions.CollisionGroup.Player,component.Collisions.CollisionGroup.Bullet]));
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
		slime.set(new component.AnimatedSprite(Project.spriteData.entity.slime));
		slime.set(new component.Health(5));
		slime.get(component.AnimatedSprite).speed = 4;
		slime.set(new component.Physics());
		slime.set(new component.AI(component.AI.AIMode.Slime));
		slime.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Bullet]));
		slime.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]));
		var b:component.Collisions.Rect = new component.Collisions.Rect(0,0,8,8);
		slime.get(component.Collisions).registerCollisionRegion(b);
		return slime;
	}
	public static function createTreasure(entities:eskimo.EntityManager,x:Int,y:Int){
		var treasure = entities.create();
		treasure.set(new component.Name("Treasure"));
		treasure.set(new component.Transformation(new kha.math.Vector2(x,y)));
		treasure.set(new component.AnimatedSprite(cast Project.spriteData.entity.chest));
		treasure.get(component.AnimatedSprite).speed = 2;
		treasure.set(new component.Collisions([component.Collisions.CollisionGroup.Level],[component.Collisions.CollisionGroup.Level]));
		treasure.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(2,3,8,8));
		
		var contents = [];
		contents.pushx(component.Inventory.Item.Gold,Math.floor(Math.random()*15));
		contents.pushx(component.Inventory.Item.HealthPotion,Math.floor(Math.random()*2));
		treasure.set(new component.ReleaseOnCollision(contents,[component.Collisions.CollisionGroup.Friendly]));
		
		treasure.set(new component.Light());
		treasure.get(component.Light).colour = kha.Color.fromBytes(0,0,140);//kha.Color.Green;
		//treasure.get(component.Light).strength = 1;

		return treasure;
	}
	public static function createGoblin (entities:eskimo.EntityManager,x:Int, y:Int){
		var goblin = entities.create();
		goblin.set(new component.Name("Goblin"));
		goblin.set(new component.Transformation(new kha.math.Vector2(x,y)));
		goblin.set(new component.AnimatedSprite(Project.spriteData.entity.goblin));
		goblin.set(new component.Health(15));
		goblin.get(component.AnimatedSprite).speed = 13;
		goblin.set(new component.Physics());
		goblin.set(new component.AI(component.AI.AIMode.Goblin));
		goblin.set(new component.DieOnCollision([component.Collisions.CollisionGroup.Bullet]));
		goblin.set(new component.Collisions([component.Collisions.CollisionGroup.Enemy]));
		var b:component.Collisions.Rect = new component.Collisions.Rect(2,1,6,9);
		goblin.get(component.Collisions).registerCollisionRegion(b);
		return goblin;
	}
	public static function createLadder(entities:eskimo.EntityManager,x:Int,y:Int,onCollide:Void->Void){ 
		var ladder = entities.create(); 
		ladder.set(new component.Name("Ladder")); 
		ladder.set(new component.Transformation(new kha.math.Vector2(x,y))); 
		ladder.set(new component.Sprite(Project.spriteData.entity.ladder)); 
		ladder.set(new component.Collisions([component.Collisions.CollisionGroup.Level])); 
		ladder.get(component.Collisions).registerCollisionRegion(new component.Collisions.Rect(0,0,8,8)); 
		ladder.set(new component.CustomCollisionHandler([component.Collisions.CollisionGroup.Player],onCollide)); 
		return ladder; 
	} 
}