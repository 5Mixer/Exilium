package system;

class KeyMovement extends System {
	var input:Input;
	public function new (input:Input){
		this.input = input;
		super();
	}

	override public function update (delta:Float,entities:Array<Entity>){
		super.update(delta,entities);

		for (entity in entities){
			if (entity.components.has("keymovement") && entity.components.has("physics")){
				var keymovement:component.KeyMovement = cast entity.components.get("keymovement");
				var physics:component.Physics = cast entity.components.get("physics");

				var speed = keymovement.speed;

				if (input.left && physics.velocity.x > -speed) physics.velocity.x -= speed;
				if (input.right && physics.velocity.x < speed) physics.velocity.x += speed;
				if (input.up && physics.velocity.y > -speed) physics.velocity.y -= speed;
				if (input.down && physics.velocity.y < speed) physics.velocity.y += speed;

			}
		}
	}
}