package component;

enum AIMode {
	Slime;
	Goblin;
}
class AI extends Component{
	public var mode:AIMode;
	public var visionLength = 50;
	public function new (mode:AIMode){
		this.mode = mode;
		super();
	}
}