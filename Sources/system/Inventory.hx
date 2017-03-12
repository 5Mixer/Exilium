package system;

class Inventory extends System {
	var inventoryHolders:eskimo.views.View;
	var entities:eskimo.EntityManager;
	var input:Input;
	override public function new (input:Input,entities:eskimo.EntityManager){
		this.input = input;
		inventoryHolders = new eskimo.views.View(new eskimo.filters.Filter([component.Inventory]),entities);
		this.entities = entities;
		super();
	}
	public function mouseUp (){

	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in inventoryHolders.entities){
			var inventory = entity.get(component.Inventory);
			var activeItem = inventory.getByIndex(inventory.activeIndex);
			if (activeItem.item == component.Inventory.Item.HealthPotion){
				if (input.mouseReleased){
					if (entity.has(component.Health)){
						kha.audio1.Audio.play(kha.Assets.sounds.DrinkPotion);
						entity.get(component.Health).addToHealth(40);
						var particle = entities.create();
						particle.set(new component.VisualParticle(component.VisualParticle.Effect.Text("+"+40)));
						
						particle.set(new component.Transformation(entity.get(component.Transformation).pos.add(new kha.math.Vector2(4,0))));
						var phys = new component.Physics();
						var speed = 9+Math.random()*4;
						phys.friction = 0.8;
						var particleAngle = - 6 + Math.random()*12 - 90;
						phys.velocity = new kha.math.Vector2(Math.cos(particleAngle * (Math.PI / 180)) * speed,Math.sin(particleAngle * (Math.PI / 180)) * speed);		
						particle.set(phys);
						particle.set(new component.TimedLife(.75));
					}
					var pos = entity.get(component.Transformation).pos.mult(1);
					//var p = EntityFactory.createPotion(entities,pos.x+0,pos.y+0);
					//p.set(new component.Physics().setVelocity(new kha.math.Vector2(-5+Math.random()*10,-5+Math.random()*10)));
					inventory.takeFromInventory(component.Inventory.Item.HealthPotion);
				}
			}
		}
	}
}