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
			if (entity.has(component.PotionAffected)){
				var effects = entity.get(component.PotionAffected).effects;
				if (effects.exists(component.PotionAffected.EntityModifier.Speed)){
					if (effects.get(component.PotionAffected.EntityModifier.Speed) > 0){
						speed *= 2; //TODO: Make this not a magic constant - what should speed by multiplied by?
					}
				}
			}
			var animation = "walk";
			if (input.up) {
				physics.velocity.y = -speed;
				animation += "_up";
			}else if (input.down) {
				physics.velocity.y = speed;
				animation += "_down";
			}
			if (input.left) {
				physics.velocity.x = -speed;
				animation += "_left";
			}else if (input.right) {
				physics.velocity.x = speed;
				animation += "_right";
			}
			if (entity.has(component.AnimatedSprite))
			entity.get(component.AnimatedSprite).playAnimation(animation);
			

		}
	}
}