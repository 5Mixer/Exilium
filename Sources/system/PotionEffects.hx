package system;

class PotionEffects extends System {
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	var frame = 0;
	public function new (entities:eskimo.EntityManager){
		super();
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.PotionAffected]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame++;

		for (entity in view.entities){
			var effects = entity.get(component.PotionAffected).effects;
			var hadDefenseEffect = false;
			// Odd way of doing things, symptom of keys of map being floats, I think.
			for (effect in effects.keys()){
				effects.set(effect,effects.get(effect) - delta);

				if (effects.get(effect) <= 0)
					continue;
					
				if (effect == component.PotionAffected.EntityModifier.Speed){
					var phys = entity.get(component.Physics);
					if (phys != null && phys.velocity.length > .4){
						var particle = entities.create();
						particle.set(new component.Transformation(entity.get(component.Transformation).pos.mult(1).add(new kha.math.Vector2(4+Math.random()*8,4+Math.random()*8))));
						particle.set(new component.VisualParticle());
						var normalised = phys.velocity.mult(1);
						normalised.normalize();
						normalised = normalised.mult(1+Math.random());
						particle.get(component.VisualParticle).effect = component.VisualParticle.Effect.Speed(-normalised.x,-normalised.y);
						particle.set(new component.TimedLife(.2 + Math.random() * .2));
					}
				}
				if (effect == component.PotionAffected.EntityModifier.Defence){
					hadDefenseEffect = true;
					var health = entity.get(component.Health);
					if (health != null){
						health.defence = .1;
					}
				}				
			}
			if (hadDefenseEffect == false){
				var health = entity.get(component.Health);
				if (health != null){
					health.defence = 1;
				}
			}

		}

	}
	override public function render (g:kha.graphics2.Graphics){
		for (entity in view.entities){
			var effects = entity.get(component.PotionAffected).effects;
			// Odd way of doing things, symptom of keys of map being floats, I think.
			for (effect in effects.keys()){

				if (effects.get(effect) <= 0)
					continue;
					
				if (effect == component.PotionAffected.EntityModifier.Defence){
					var pos = entity.get(component.Transformation).pos;
					var multiplier = Math.PI * 2 / 8;
					var dist = 12+Math.sin(frame/30);
					for (i in 0...8){
						g.drawSubImage(kha.Assets.images.Objects,pos.x+Math.cos(i*multiplier+frame/30)*dist,pos.y+Math.sin(i*multiplier+frame/30)*dist,32,8,8,8);
					}
				}
			}
		}
	}
}