package component;

enum Item {
	Gold;
	Gem;
	
}

class Inventory extends Component {
	public var items:Array<Int> = [];
	override public function new (){
		items = [];
		super();
	}
	public function putIntoInventory(item:Item,quantity:Int = 1){

	}
	public function takeFromInventory(item:Item,quantity:Int = 1){

	}
}