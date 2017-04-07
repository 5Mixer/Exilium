package component.ai;

enum AIMode {
	Slime;
	Goblin;
	CorruptSoul;
}
class AI extends Component{
	public var mode:AIMode;
	public var visionLength = 50;
	public var rage = false;
	public function new (mode:AIMode){
		this.mode = mode;
		super();
	}
}