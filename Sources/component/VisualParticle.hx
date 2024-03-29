package component;

enum Effect {
	Smoke;
	Spark;
	Flame;
	Blood;
	Text(t:String);
	Speed(xoff:Float,yoff:Float);
}

class VisualParticle extends Component{
	public var effect:Effect;
	public var rand = 0.0;
	public var life = 0;
	public function new (?e:Effect){
		effect = e;
		if (e == null) e = Effect.Spark;
		rand = Math.random();
		super();
	}
}