package system;

import kha.math.FastMatrix3;

class Renderer extends System {
	var view:eskimo.views.View;
	var animatedView:eskimo.views.View;
	var entities:Array<eskimo.Entity> = [];
	var needRefresh = true;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Sprite,component.Transformation]), entities);
		animatedView = new eskimo.views.View(new eskimo.filters.Filter([component.AnimatedSprite,component.Transformation]), entities);
		view.onAdd = resort;
		view.onRemove = resort;
		animatedView.onAdd = resort;
		animatedView.onRemove = resort;
		super();
	}
	function resort(e){
		needRefresh = true;
	}
	function refreshz (){
		needRefresh = false;
		entities = view.entities.entities;
		entities = entities.concat(animatedView.entities.entities);
		entities.sort(function(a:eskimo.Entity,b:eskimo.Entity){
			var az = 0.0;
			var bz = 0.0;
			var azc = a.get(component.Zindex);
			var bzc = b.get(component.Zindex);
			if (azc != null)
				az = azc.z;
			
			if (bzc != null)
				bz = bzc.z;
			
			if (az>bz) return 1;
			if (az<bz) return -1;
			return 0;
		});
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		var inset = .1; //Little inset as to not get next sprite;

		if (needRefresh)
			refreshz();
		
		for (entity in entities){
			if (entity.has(component.Sprite)){
				var sprite:component.Sprite = entity.get(component.Sprite);
				var transformation:component.Transformation = entity.get(component.Transformation);

				
				var tilesize = sprite.tilesize;
				var originX = Math.floor(tilesize/2);
				var originY = Math.floor(tilesize/2);

				// if (entity.has(component.Collisions)){
				// 	var aabb = entity.get(component.Collisions).AABB;
				// 	originX = Math.floor(aabb.width/2);
				// 	originY = Math.floor(aabb.height/2);
				// }


				var x = transformation.pos.x;
				var y = transformation.pos.y;
				var angle = transformation.angle*(Math.PI/180);

				if (angle != 0) g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
				g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%Math.floor(sprite.spriteMap.width/tilesize))*tilesize)+inset,Math.floor(Math.floor(sprite.textureId/Math.floor(sprite.spriteMap.width/tilesize))*tilesize)+inset,tilesize-(inset*2),tilesize-(inset*2),x,y,tilesize,tilesize);
				if (angle != 0) g.popTransformation();
			}else{
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
						
				g.drawScaledSubImage(animation.spriteMap,Math.floor(((actualFrameIndex)%Math.floor(animation.spriteMap.width/tilesize))*tilesize)+inset,Math.floor(Math.floor((actualFrameIndex)/Math.floor(animation.spriteMap.width/tilesize))*tilesize)+inset,tilesize-(inset*2),tilesize-(inset*2),x,y,tilesize,tilesize);
				
				g.popTransformation();
			}
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