package system;

class ParticleTrails extends System {
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	public function new (entities:eskimo.EntityManager){
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.ParticleTrail,component.Transformation]), entities);
		super();
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		for (entity in view.entities){
			
			var particleTrailer:component.ParticleTrail = entity.get(component.ParticleTrail);
			var transformation:component.Transformation = entity.get(component.Transformation);
			particleTrailer.time++;
			
			if (particleTrailer.time > particleTrailer.interval){
				particleTrailer.time = 0;

				var particle = entities.create();
				particle.set(new component.VisualParticle(particleTrailer.particle));
				var off = 3.;
				if (entity.has(component.Sprite))
					off = entity.get(component.Sprite).tilesize/2;
				
				if (entity.has(component.AnimatedSprite))
					off = entity.get(component.AnimatedSprite).tilesize/2;
				
				var t = new component.Transformation(transformation.pos.add(new kha.math.Vector2(off,off)));
				t.angle = transformation.angle;
				particle.set(t);
				particle.set(new component.TimedLife(.5));
			
			}			
		}
	}
}