package component;

class GhostModeCustomMultiplier extends Component{
	public var multiplier:Float = .1;
	override public function new (multiplier:Float = .1){
		this.multiplier = multiplier;
		super();
	}
}