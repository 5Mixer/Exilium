package component;

class ActiveBoss extends Component {
	public var max:Int=0;
	public var current:Int=0;
	public var name:String;
	public var rage:Bool = false;
	public var mode = "";
	public function new (name:String){
		super();
		this.name = name;
	}
}