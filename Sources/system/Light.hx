package system;

class Light extends System {
	var lights:Array<Light>;
	public function new (lights:Array<Light>){
		this.lights = lights;
		super();
	}


	override public function update (delta:Float,entities:Array<Entity>){
		super.update(delta,entities);

		for (entity in entities){
			if (entity.components.has("transformation") && entity.components.has("physics")){
				var transformation:component.Transformation = cast entity.components.get("transformation");
				var physics:component.Physics = cast entity.components.get("physics");

				
				physics.velocity = physics.velocity.mult(.7);

				transformation.pos.x += physics.velocity.x;
				transformation.pos.y += physics.velocity.y;

			}
		}
	}
}