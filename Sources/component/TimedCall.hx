package component;
class TimedCall extends Component {
	public var call:Void->Void = null;
	public var timeleft:Float = 0;
	public function new (timeleft:Float = 5, call:Void->Void){
		this.timeleft = timeleft;
		this.call = call;
		super();
	}
}