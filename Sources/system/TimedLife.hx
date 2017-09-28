package system;

class TimedLife extends System {
	var view:eskimo.views.View;
	var dview:eskimo.views.View;
	var entities:eskimo.EntityManager;
	public function new (entities:eskimo.EntityManager){
		super();
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.TimedLife]),entities);
		dview = new eskimo.views.View(new eskimo.filters.Filter([component.Health,component.Transformation]),entities);
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
				}
				entity.destroy();
			}
		}
	}
}