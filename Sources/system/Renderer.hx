package system;

import kha.math.FastMatrix3;

class Renderer extends System {
	var view:eskimo.views.View;
	var animatedView:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Sprite,component.Transformation]), entities);
		animatedView = new eskimo.views.View(new eskimo.filters.Filter([component.AnimatedSprite,component.Transformation]), entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			
			var sprite:component.Sprite = entity.get(component.Sprite);
			var transformation:component.Transformation = entity.get(component.Transformation);

			
			var tilesize = sprite.tilesize;
			var originX = Math.floor(tilesize/2);
			var originY = Math.floor(tilesize/2);
			var x = transformation.pos.x;
			var y = transformation.pos.y;
			var angle = transformation.angle;

			g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(x + originX, y + originY)).multmat(kha.math.FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(kha.math.FastMatrix3.translation(-x - originX, -y - originY)));
					
			g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%tilesize)*tilesize),Math.floor(Math.floor(sprite.textureId/tilesize)*tilesize),tilesize,tilesize,x,y,tilesize,tilesize);
			
			g.popTransformation();
		}

		for (entity in animatedView.entities){
			var transformation = entity.get(component.Transformation);
			var animation = entity.get(component.AnimatedSprite);
			animation.currentFrameTime += 1;
			if (animation.currentFrameTime > animation.speed){
				animation.frame++;
				animation.currentFrameTime = 0;

				
			}

			var baseFrame = 0;
			if (animation.spriteData.animations != null && Reflect.field(animation.spriteData.animations,animation.currentAnimation) != null){
				if (animation.frame >= Std.int(Reflect.field(animation.spriteData.animations,animation.currentAnimation).length)){
					animation.frame = 0;
					animation.currentAnimation = animation.whenFinishedStart;	
				}
				baseFrame = Reflect.field(animation.spriteData.animations,animation.currentAnimation)[0];
			}else{
				animation.frame = 0;
			}
			
			var tilesize = animation.tilesize;
			var originX = Math.floor(tilesize/2);
			var originY = Math.floor(tilesize/2);
			var x = transformation.pos.x;
			var y = transformation.pos.y;
			var angle = transformation.angle;

			g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(x + originX, y + originY)).multmat(kha.math.FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(kha.math.FastMatrix3.translation(-x - originX, -y - originY)));
					
			g.drawScaledSubImage(animation.spriteMap,Math.floor(((baseFrame+animation.frame)%Math.floor(animation.spriteMap.width/tilesize))*tilesize),Math.floor(Math.floor((baseFrame+animation.frame)/Math.floor(animation.spriteMap.width/tilesize))*tilesize),tilesize,tilesize,x,y,tilesize,tilesize);
			
			g.popTransformation();
		}
	}
}