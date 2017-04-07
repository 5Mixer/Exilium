package component;

class Health extends Component {
	public var max:Float;
	public var current:Float;
	public function new (maxHealth:Float){
		super();
		max = maxHealth;
		current = max;
	}
	public function addToHealth (amount:Float){
		current = Math.min(current+amount,max);
	}
}