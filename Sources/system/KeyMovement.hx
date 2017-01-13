package system;

class KeyMovement extends System {
	var input:Input;
	var view:eskimo.views.View;
	public function new (input:Input,entities:eskimo.EntityManager){
		this.input = input;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.KeyMovement,component.Physics]),entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var keymovement:component.KeyMovement = entity.get(component.KeyMovement);
			var physics:component.Physics = entity.get(component.Physics);

			var speed = keymovement.speed;

			if (input.left) physics.velocity.x = -speed;
			if (input.right) physics.velocity.x = speed;
			if (input.up) physics.velocity.y = -speed;
			if (input.down) physics.velocity.y = speed;

		}
	}
}