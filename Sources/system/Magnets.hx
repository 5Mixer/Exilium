package system;

class Magnets extends System{
	var entities:eskimo.EntityManager;
	var view:eskimo.views.View;
	public var p:eskimo.Entity;
	public function new (entities:eskimo.EntityManager,p:eskimo.Entity){
		this.entities = entities;
		this.p = p;
		this.view = new eskimo.views.View(new eskimo.filters.Filter([component.Magnet,component.Transformation,component.Physics]),entities);
		super();
	}
	override public function onUpdate(delta:Float){
		super.onUpdate(delta);
		if (p == null || p.get(component.Transformation) == null){
			return;
		}
		var ptransform = p.get(component.Transformation).pos;
		for (entity in view.entities){
			var entityTransform = entity.get(component.Transformation);
			if ( entityTransform.pos.sub(ptransform).length < entity.get(component.Magnet).range ){
				var difference = ptransform.sub(entityTransform.pos);
				var distance = difference.length;
				difference.normalize();
				difference = difference.mult(Math.max(entity.get(component.Magnet).range/distance*.75,1));
				entity.get(component.Physics).velocity = entity.get(component.Physics).velocity.add(difference);
			}
		}
	}
}