package component;

enum Item {
	Gold;
	SlimeGun;
	LaserGun;
	HealthPotion;
	SpeedPotion;
	DefensivePotion;
	MayhamPotion;
	GrapplingHook;
	CastSheild;
	Key;
	Blaster;
	Bow;
	Bomb;
}
enum ItemType {
	Gun;
	Potion;
	Sword;
	Explosive;
	Currency;
	Other;
}

typedef Stack = {
	var item: Item;
	var quantity:Int;
}

class Inventory extends Component {
	public var stacks:Array<Stack>;
	public var length(get,null) = 0;
	public var activeIndex:Int = 0;
	public var itemData:Map<Item,{name:String, stackable:Bool, type: ItemType, sprite: Dynamic}> = [
		Item.HealthPotion => { name: "health potion", stackable: true, type: ItemType.Potion, sprite:states.Play.spriteData.entity.healthPotion },
		Item.SpeedPotion => { name: "speed potion", stackable: true, type: ItemType.Potion, sprite:states.Play.spriteData.entity.speedPotion },
		Item.DefensivePotion => { name: "Defensive potion", stackable: true, type: ItemType.Potion, sprite:states.Play.spriteData.entity.defensivePotion },
		Item.MayhamPotion => { name: "Mayham potion", stackable: true, type: ItemType.Potion, sprite:states.Play.spriteData.entity.mayhamPotion },
		
		Item.SlimeGun => { name: "slime gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.slimeGun },
		Item.LaserGun => { name: "laser gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.laserGun },
		Item.Blaster => { name: "blaster gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.blaster },
		Item.GrapplingHook => { name: "grappling gun", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.grapplingHook },
		Item.Bow => { name: "bow", stackable: false, type: ItemType.Gun, sprite:states.Play.spriteData.entity.bow },
		Item.CastSheild => { name: "cast shield", stackable: true, type: ItemType.Other, sprite:states.Play.spriteData.entity.cast_shield },
		Item.Bomb => { name: "bomb", stackable: true, type: ItemType.Explosive, sprite:states.Play.spriteData.entity.bomb },
		
		Item.Gold => { name: "gold", stackable: true, type: ItemType.Currency, sprite:states.Play.spriteData.entity.gold },
		Item.Key => { name: "key", stackable: true, type: ItemType.Other, sprite:states.Play.spriteData.entity.key }
	];
	override public function new (){
		super();
		stacks = new Array<Stack>();
	}
	public function putIntoInventory(item:Item,quantity:Int = 1){
		if (exists(item)){
			getStack(item).quantity += quantity;
		}else{
			stacks.push({item:item, quantity:quantity});
		}
	}
	public function takeFromInventory(item:Item,quantity:Int = 1){
		if (exists(item)){
			if (getStack(item).quantity >= quantity){
				getStack(item).quantity -= quantity;
				if (getStack(item).quantity < 1){
					stacks.remove(getStack(item));
					if (activeIndex < 0) {
						activeIndex = 0;
					}
					if (activeIndex > stacks.length-1){
						activeIndex = stacks.length-1;
					}
				}
				return true;
			}
		}
		return false;
	}
	public function getStack(item:Item){
		for (stack in stacks)
			if (stack.item == item)
				return stack;
		return null;
	}
	public function exists(item:Item){
		for (stack in stacks)
			if (stack.item == item)
				return true;
		
		return false;
	}
	public function getByIndex(index:Int):Stack{
		return stacks[index];
	}
	function get_length(){
		return stacks.length;
	}
}