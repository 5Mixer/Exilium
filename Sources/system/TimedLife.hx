package system;

class TimedLife extends System {
	var view:eskimo.views.View;
	var dview:eskimo.views.View;
	var pview:eskimo.views.View;
	var entities:eskimo.EntityManager;
	var camera:Camera;
	public function new (entities:eskimo.EntityManager,camera:Camera){
		super();
		this.camera = camera;
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.TimedLife]),entities);
		dview = new eskimo.views.View(new eskimo.filters.Filter([component.Health,component.Transformation]),entities);
		pview = new eskimo.views.View(new eskimo.filters.Filter([component.Physics,component.Transformation]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var timedLife = entity.get(component.TimedLife);
			timedLife.fuse += delta;

			if (timedLife.fuse >= timedLife.length){
				if (timedLife.explode){
					var pos = entity.get(component.Transformation).pos;
					EntityFactory.createExplosion(entities,pos);
					for (entityb in dview.entities){
						if (entityb.get(component.Transformation).pos.sub(pos).length < 40){
							if (!entityb.has(component.ai.AITarget))
								entityb.get(component.Health).addToHealth(-20);
						}
					}
					for (entityb in pview.entities){
						if (entity == entityb) continue;
						var transform = entityb.get(component.Transformation);
						if (transform.pos.sub(pos).length < 100){
							var phys = entityb.get(component.Physics);
							var difference = transform.pos.sub(entity.get(component.Transformation).pos);
							var normalised = difference.mult(1);
							normalised.normalize();
							var explosionForce = 20;
							difference = normalised.mult((100/difference.length)*explosionForce);
							phys.velocity = phys.velocity.add(difference);

							camera.shake(7,.4);

							// var length = phys.velocity.length;
							// if (length > 100){
							// 	phys.velocity.normalize();
							// 	phys.velocity = phys.velocity.mult(100);
							// }
						}
					}
				}
				entity.destroy();
			}
		}
	}
}