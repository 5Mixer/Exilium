package component;

class Damager extends Component {
	public var damage:Float = 0.0;
	public var damageRate:Int = 10;
	public var onCollision = true;
	public var active = true;
	public var causesBlood = true;
	override public function new (damage:Float){
		this.damage = damage;
		super();
	}
}