package component;

enum AIMode {
	Shoot;
	Idle;
	Investigate;
	Retreat;
	Alert;
	Chase;
	Attack;
	Patrol;
}
class AI extends Component{
	public var activeState:AIMode;
	public var visionLength = 50;
	public function new (){
		activeState = AIMode.Idle;
		super();
	}
}