package component;

enum Effect {
	Smoke;
	Spark;
	Flame;
	Text(t:String);
}

class VisualParticle extends Component{
	public var effect:Effect;
	public function new (?e:Effect){
		effect = e;
		if (e == null) e = Effect.Spark;
		super();
	}
}