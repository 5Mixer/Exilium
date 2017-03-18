package system;

class Spinner extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Spin,component.Transformation]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var spin = entity.get(component.Spin);
			if (spin.active){
				var transform = entity.get(component.Transformation);
				transform.angle += spin.speed;
			}
		}
	}
}