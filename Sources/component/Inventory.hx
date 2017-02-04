package component;

enum Item {
	Gold;
	SlimeGun;
	Gem;
	HealthPotion;
	
}
enum ItemType {
	Gun;
	Potion;
	Sword;
	Currency;
}
/*
{ name: "freaking destroyer", type: gun{bullet: giantBloodyGlowingBullet { angle : angle, speed: fucking fast} }}
{ name: "steroids", type: potion{ health: +5, speed: +5, poison: +3}}
{ name: "cluster bombs", type: bomb{ fuse: 5s, radius: 4, subbombs: {fuse: 1s, radius 1}}}
{ name: "long sword", type: sword{reach: 5, sweep: 45-90} }
{ name: "coin", type: currency, value: 1 }
{  }

name
type
*/

typedef Stack = {
	var item: Item;
	var quantity:Int;
}

class Inventory extends Component {
	public var stacks:Array<Stack>;
	public var length(get,null) = 0;
	public var activeIndex:Int = 0;
	public var itemData:Map<Item,{name:String, stackable:Bool, type: ItemType, sprite: Dynamic}> = [
		Item.Gold => { name: "gold", stackable: true, type: ItemType.Currency, sprite:Project.spriteData.entity.gold },
		Item.HealthPotion => { name: "gold", stackable: true, type: ItemType.Potion, sprite:Project.spriteData.entity.healthPotion },
		Item.SlimeGun => { name: "slime gun", stackable: false, type: ItemType.Gun, sprite:Project.spriteData.entity.slimeGun }
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