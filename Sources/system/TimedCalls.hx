package system;

class TimedCalls extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.TimedCall]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var c = entity.get(component.TimedCall);
			c.timeleft -= delta;
			if (c.timeleft < 0){
				c.call();
				entity.remove(component.TimedCall);
			}
		}
	}
}