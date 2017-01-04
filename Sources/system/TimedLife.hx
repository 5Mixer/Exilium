package system;

class TimedLife extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.TimedLife]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var timedLife = entity.get(component.TimedLife);
			timedLife.fuse += delta;

			if (timedLife.fuse >= timedLife.length){
				entity.destroy();
			}
		}
	}
}