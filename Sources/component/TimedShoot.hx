package component;

class TimedShoot extends Component {
	public var fireRate:Int = 60;
	public var active = true;
	public var timeLeft:Float = 0.0;
	override public function new (fireRate:Int=60){
		this.fireRate = fireRate;
		super();
	}
}