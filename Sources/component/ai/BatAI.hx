package component.ai;
class BatAI extends Component{
	public var isMoving = true;
	public var target:{x:Int,y:Int};
	public var life = 0;
	public var moveRate = 0;
	public var speed = 0;
	public function new (){
		super();
		speed = 40 + Math.floor(Math.random()*10);
		life = Math.floor(Math.random()*60);
		moveRate = 30 + Math.floor ( Math.random() * 10);
	}
}