package component;

class TimedShoot extends Component {
	public var fireRate:Float = 1;
	public var active = true;
	public var timeLeft:Float = 0.0;
	override public function new (fireRate:Float=1){
		this.fireRate = fireRate;
		super();
	}
}