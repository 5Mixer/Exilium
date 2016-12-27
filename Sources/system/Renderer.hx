package system;

import kha.math.FastMatrix3;

class Renderer extends System {

	override public function render (g:kha.graphics2.Graphics,entities:Array<Entity>){
		super.render(g,entities);

		for (entity in entities){
			if (entity.components.has("sprite") && entity.components.has("transformation")){
				var sprite:component.Sprite = cast entity.components.get("sprite");
				var transformation:component.Transformation = cast entity.components.get("transformation");

				var originX = 4;
				var originY = 4;
				var x = transformation.pos.x;
				var y = transformation.pos.y;
				var angle = 0;

				g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
				//g.rotate(angle / (Math.PI / 180),x+4,y+4);

				
				g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%8)*8),Math.floor(Math.floor(sprite.textureId/8)*8),8,8,x,y,8,8);
				
				g.popTransformation();
			}
		}
	}
}