package system;

class Inventory extends System {
	var inventoryHolders:eskimo.views.View;
	var entities:eskimo.EntityManager;
	override public function new (entities:eskimo.EntityManager){
		inventoryHolders = new eskimo.views.View(new eskimo.filters.Filter([component.Inventory]),entities);
		this.entities = entities;
		super();
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in inventoryHolders.entities){
			var inventory = entity.get(component.Inventory);
			var activeItem = inventory.getByIndex(inventory.activeIndex);
			if (activeItem.item == component.Inventory.Item.HealthPotion){
				var pos = entity.get(component.Transformation).pos.mult(1);
				var p = EntityFactory.createPotion(entities,pos.x+0,pos.y+0);
				p.set(new component.Physics().setVelocity(new kha.math.Vector2(-2.5+Math.random()*5,-2.5+Math.random()*5)));
			}
		}
	}
}