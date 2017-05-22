package component.ai;
class BatAI extends Component{
	public var isMoving = true;
	public var target:{x:Int,y:Int};
	public var life = 0;
	public var visionLength = 40;
	public function new (){
		super();
	}
}