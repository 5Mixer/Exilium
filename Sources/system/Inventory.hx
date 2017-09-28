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
	public function onChangeItem(){
		for (entity in inventoryHolders.entities){
			var inventory = entity.get(component.Inventory);
			var activeItem = inventory.getByIndex(inventory.activeIndex);

			if (activeItem.item == component.Inventory.Item.CastSheild){
				entity.set(new component.Shield());
			}else{
				entity.remove(component.Shield);
			}
		}

	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in inventoryHolders.entities){
			var inventory = entity.get(component.Inventory);
			var activeItem = inventory.getByIndex(inventory.activeIndex);
			if (input.mouseReleased){
				if (activeItem.item == component.Inventory.Item.HealthPotion){
					if (entity.has(component.Health)){
						kha.audio1.Audio.play(kha.Assets.sounds.DrinkPotion);
						entity.get(component.Health).addToHealth(40);

						// +health particle effect.
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
				}

				

				if (activeItem.item == component.Inventory.Item.DefensivePotion){
					if (entity.has(component.PotionAffected)){
						kha.audio1.Audio.play(kha.Assets.sounds.DrinkPotion);
						entity.get(component.PotionAffected).effects.set(component.PotionAffected.EntityModifier.Defence,15);
					}
				}
				if (activeItem.item == component.Inventory.Item.SpeedPotion){
					if (entity.has(component.PotionAffected)){
						kha.audio1.Audio.play(kha.Assets.sounds.DrinkPotion);
						entity.get(component.PotionAffected).effects.set(component.PotionAffected.EntityModifier.Speed,15);
					}
				}
				if (activeItem.item == component.Inventory.Item.MayhamPotion){
					if (entity.has(component.PotionAffected)){
						kha.audio1.Audio.play(kha.Assets.sounds.DrinkPotion);
						entity.get(component.PotionAffected).effects.set(component.PotionAffected.EntityModifier.Speed,8);
						entity.get(component.PotionAffected).effects.set(component.PotionAffected.EntityModifier.Defence,8);
						entity.get(component.PotionAffected).effects.set(component.PotionAffected.EntityModifier.FireRate,8);
					}
				}
			}
		}
	}
}