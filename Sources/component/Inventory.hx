package component;

enum Item {
	Gold;
	Gem;
	
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
	public var items:Map<Item,Int>;
	public var itemData =  [
		Item.Gold => { name: "gold", stackable: true, type: ItemType.Currency, sprite:Project.spriteData.entity.gold }
	];
	override public function new (){
		super();
		items = new Map<Item,Int>();
	}
	public function putIntoInventory(item:Item,quantity:Int = 1){
		
		if (items.exists(item)){
			items.set(item, items.get(item)+quantity);
		}else{
			items.set(item,1);
		}
	}
	public function takeFromInventory(item:Item,quantity:Int = 1){
		if (items.exists(item)){
			items.set(item, items.get(item)-quantity);
		}
	}
}