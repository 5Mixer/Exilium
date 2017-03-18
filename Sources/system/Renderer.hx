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
					
			g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%Math.floor(sprite.spriteMap.width/tilesize))*tilesize),Math.floor(Math.floor(sprite.textureId/Math.floor(sprite.spriteMap.width/tilesize))*tilesize),tilesize,tilesize,x,y,tilesize,tilesize);
			
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
				baseFrame = Reflect.field(animation.spriteData.animations,animation.currentAnimation)[animation.frame];
			}else{
				animation.frame = 0;
			}
			
			var tilesize = animation.tilesize;
			var originX = Math.floor(tilesize/2);
			var originY = Math.floor(tilesize/2);
			var x = transformation.pos.x;
			var y = transformation.pos.y;
			var angle = transformation.angle;

			var actualFrameIndex = baseFrame;

			g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(x + originX, y + originY)).multmat(kha.math.FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(kha.math.FastMatrix3.translation(-x - originX, -y - originY)));
					
			g.drawScaledSubImage(animation.spriteMap,Math.floor(((actualFrameIndex)%Math.floor(animation.spriteMap.width/tilesize))*tilesize),Math.floor(Math.floor((actualFrameIndex)/Math.floor(animation.spriteMap.width/tilesize))*tilesize),tilesize,tilesize,x,y,tilesize,tilesize);
			
			g.popTransformation();
		}
	}
	public static function renderSpriteData (g:kha.graphics2.Graphics,spriteData:Dynamic,x:Float,y:Float){
		var spriteMap:kha.Image = null;
		var tilesize:Int = 16;
		if (spriteData.tileset != null){
			switch spriteData.tileset {
				case "ghost": spriteMap = kha.Assets.images.Ghost;
				case "slime": spriteMap = kha.Assets.images.Slime; tilesize = 8;
				case "projectiles": spriteMap = kha.Assets.images.Projectiles;
				case "objects": spriteMap = kha.Assets.images.Objects; tilesize = 8;
				case "chest": spriteMap = kha.Assets.images.Chest; tilesize = 11;
				case "goblin": spriteMap = kha.Assets.images.Goblin; tilesize = 10;
				case "coin": spriteMap = kha.Assets.images.Coin; tilesize = 8;
			}
			
			var id = spriteData.id;
			g.drawScaledSubImage(spriteMap,Math.floor((id%tilesize)*tilesize),Math.floor(Math.floor(id/tilesize)*tilesize),tilesize,tilesize,x,y,tilesize,tilesize);
		}
			
	}
}