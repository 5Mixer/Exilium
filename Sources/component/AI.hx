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
	public function new (){
		activeState = AIMode.Idle;
		super();
	}
}