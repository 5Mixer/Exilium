package system;

class DieOnCollision extends System{
	var entities:eskimo.EntityManager;
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		this.entities = entities;
		this.view = new eskimo.views.View(new eskimo.filters.Filter([component.DieOnCollision]),entities);
		super();
	}
	override public function onUpdate(delta:Float){
		super.onUpdate(delta);
		for (entity in view.entities){
			
		}
	}
}