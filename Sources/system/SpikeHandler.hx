package system;

class SpikeHandler extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Spike]), entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			
			var spike:component.Spike = entity.get(component.Spike);
			if (entity.has(component.Sprite)){
				var sprite = entity.get(component.Sprite);
				sprite.textureId = spike.isUp ? 6 : 7;
			}
			
		}
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		for (entity in view.entities){
			
			var spike:component.Spike = entity.get(component.Spike);
			spike.timeLeft += 1;
			if ((spike.timeLeft > spike.timeDown*30 && spike.isUp == false) || (spike.timeLeft > spike.timeUp*30 && spike.isUp == true)){
				spike.isUp = !spike.isUp;
				spike.timeLeft = 0.0;
				
				if(entity.has(component.Damager)){
					var damager = entity.get(component.Damager);
					damager.active = !damager.active;
				}
			}
			
		}
	}
}