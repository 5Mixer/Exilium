package system;

class Light extends System {
	var lights:Array<Light>;
	var view:eskimo.views.View;
	var lightmap = new Map<eskimo.Entity,Level.Light>();
	public function new (lights:Array<Light>,entities:eskimo.EntityManager){
		this.lights = lights;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Light]),entities);
		super();

		view.onAdd(newLight);
	}

	function newLight(entity){
		//lightmap.set(entity,new Level.Light())
	}


	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
	
		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var light = entity.get(component.Light);

		}
	}
}