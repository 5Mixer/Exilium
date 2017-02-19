package component;

class Health extends Component {
	public var max:Int;
	public var current:Int;
	public function new (maxHealth:Int){
		super();
		max = maxHealth;
		current = max;
	}
	public function addToHealth (amount:Int){
		current = Math.floor(Math.min(current+amount,max));
	}
}