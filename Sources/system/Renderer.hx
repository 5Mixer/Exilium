package system;

import kha.math.FastMatrix3;

class Renderer extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Sprite,component.Transformation]), entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			
			var sprite:component.Sprite = entity.get(component.Sprite);
			var transformation:component.Transformation = entity.get(component.Transformation);

			var originX = 4;
			var originY = 4;
			var x = transformation.pos.x;
			var y = transformation.pos.y;
			var angle = transformation.angle;

			g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(x + originX, y + originY)).multmat(kha.math.FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(kha.math.FastMatrix3.translation(-x - originX, -y - originY)));
					
			g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%8)*8),Math.floor(Math.floor(sprite.textureId/8)*8),8,8,x,y,8,8);
			
			g.popTransformation();
		}
	}
}