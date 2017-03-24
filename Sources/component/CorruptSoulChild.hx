package component;

class CorruptSoulChild extends Component{
	public var colour:kha.Color;
	public var size:Int;
	public var sides:Int;
	override public function new (){
		super();
		size = 4+Math.floor(Math.random()*3);
		colour = kha.Color.fromValue(new hxColorToolkit.spaces.HSL(0, 2, Math.round(30+Math.random()*20)).getColor());
		colour.A = .4+(Math.random()*.2);
		sides = (Math.random() > .2) ? 3 : 5;
		
	}
}