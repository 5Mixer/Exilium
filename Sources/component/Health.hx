package component;

class Health extends Component {
	public var max:Float;
	public var current:Float;
	public var defence:Float = 1.;
	public function new (maxHealth:Float){
		super();
		max = maxHealth;
		current = max;
	}
	public function addToHealth (amount:Float){
		if (amount < 0)
			amount *= defence;
		current = Math.min(current+(amount),max);
	}
}