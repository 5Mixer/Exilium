package component;

class ParticleTrail extends Component {
	public var particle:component.VisualParticle.Effect;
	public var interval:Float;
	public var time = 0;
	public function new (interval:Float,particle:component.VisualParticle.Effect){
		this.interval = interval;
		this.particle = particle;
		super();
	}
}