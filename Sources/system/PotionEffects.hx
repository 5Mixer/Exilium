package system;

class PotionEffects extends System {
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	public function new (entities:eskimo.EntityManager){
		super();
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.PotionAffected]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var effects = entity.get(component.PotionAffected).effects;
			// Odd way of doing things, symptom of keys of map being floats, I think.
			for (effect in effects.keys()){
				effects.set(effect,effects.get(effect) - delta);

				if (effects.get(effect) <= 0)
					continue;
					
				if (effect == component.PotionAffected.EntityModifier.Speed){
					var phys = entity.get(component.Physics);
					if (phys != null){
						var particle = entities.create();
						particle.set(new component.Transformation(entity.get(component.Transformation).pos.mult(1).add(new kha.math.Vector2(4+Math.random()*8,4+Math.random()*8))));
						particle.set(new component.VisualParticle());
						var normalised = phys.velocity.mult(1);
						normalised.normalize();
						normalised = normalised.mult(1+Math.random()*2);
						particle.get(component.VisualParticle).effect = component.VisualParticle.Effect.Speed(-normalised.x,-normalised.y);
						particle.set(new component.TimedLife(.3 + Math.random() * .2));
					}
				}
			}

		}

	}
	// override public function render (g:kha.graphics2.Graphics){
	// 	for (entity in view.entities){
	// 		var effects = entity.get(component.PotionAffected).effects;
	// 		// Odd way of doing things, symptom of keys of map being floats, I think.
			
	// 	}
	// }
}