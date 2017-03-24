package component;

typedef SmokeParticle = {x:Float,y:Float,size:Int,vx:Float,vy:Float};

class CorruptSoul extends Component{
	public var smokeParticles:Array<SmokeParticle> = [];
	public var children:Array<eskimo.Entity> = [];
	override public function new (particles=50){
		super();
		for (i in 0...particles){
			var a = Math.PI*2*(Math.random());
			smokeParticles.push({x:0,y:0,size:1+Math.floor(Math.random()*7),vx:4*Math.cos(a),vy:4*Math.sin(a)});
		}
	}
}