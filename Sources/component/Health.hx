package component;

class Health extends Component {
	public var max:Float;
	public var current:Float;
	public var defence:Float = 1.;
	public var healthDelta = 0.;
	public function new (maxHealth:Float){
		super();
		max = maxHealth;
		current = max;
	}
	public function addToHealth (amount:Float){
		if (amount < 0)
			amount *= defence;
		
		healthDelta += amount;

		current = Math.min(current+(amount),max);
	}
}