package system;

import kha.math.FastMatrix3;

class Renderer extends System {
	var view:eskimo.views.View;
	var animatedView:eskimo.views.View;
	var entities:Array<eskimo.Entity> = [];
	var needRefresh = true;
	public var tilemap:world.Tilemap = null;
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
			az = a.get(component.Transformation).pos.y;
			bz = b.get(component.Transformation).pos.y;


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

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in entities){
			if (entity.has(component.AnimatedSprite)){
				var animation = entity.get(component.AnimatedSprite);
				if (animation.currentAnimation != ""){
				
					animation.currentFrameTime += 1;
					if (animation.currentFrameTime > animation.speed){
						animation.frame+=delta > 0 ? 1 : 0;
						animation.currentFrameTime = 0;	
					}

					
				}
			}
		}
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		var inset = .1; //Little inset as to not get next sprite;

		if (needRefresh)
			refreshz();
		
		for (entity in entities){
			var zoff = 0.;
			if (entity.has(component.Physics))
				zoff = entity.get(component.Physics).z;

			var colour = kha.Color.White;
			if (entity.has(component.Colour))
				colour = entity.get(component.Colour).colour;

			var transformation:component.Transformation = entity.get(component.Transformation);
			if (entity.has(component.ObeyLighting)){
				if (tilemap != null){
					var tile = tilemap.get(Math.floor(transformation.pos.x/16),Math.floor(transformation.pos.y/16));
					if (tile != null)
						colour = tile.colour;
					
					if (colour == null) colour = kha.Color.White;
				}
			}
			
			if (entity.has(component.Sprite)){
				var sprite:component.Sprite = entity.get(component.Sprite);

				
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
				if (zoff != 0){
					g.color = kha.Color.Black;
					g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%Math.floor(sprite.spriteMap.width/tilesize))*tilesize)+inset,Math.floor(Math.floor(sprite.textureId/Math.floor(sprite.spriteMap.width/tilesize))*tilesize)+inset,tilesize-(inset*2),tilesize-(inset*2),x,y,tilesize,tilesize);
				}
				g.color = colour;
				g.drawScaledSubImage(sprite.spriteMap,Math.floor((sprite.textureId%Math.floor(sprite.spriteMap.width/tilesize))*tilesize)+inset,Math.floor(Math.floor(sprite.textureId/Math.floor(sprite.spriteMap.width/tilesize))*tilesize)+inset,tilesize-(inset*2),tilesize-(inset*2),x,y-zoff,tilesize,tilesize);
				
				if (angle != 0) g.popTransformation();
			}else{
				var transformation = entity.get(component.Transformation);
				var animation = entity.get(component.AnimatedSprite);
				if (animation.currentAnimation != ""){
					var baseFrame = 0;
					if (animation.spriteData.animations != null && Reflect.field(animation.spriteData.animations,animation.currentAnimation) != null){
						if (animation.frame >= Std.int(Reflect.field(animation.spriteData.animations,animation.currentAnimation).length)){
							animation.frame = 0;
							animation.currentAnimation = animation.whenFinishedStart;	
						}
						if (animation.currentAnimation != "")
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

					if (animation.currentAnimation != ""){
						g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(x + originX, y + originY)).multmat(kha.math.FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(kha.math.FastMatrix3.translation(-x - originX, -y - originY)));
						if (zoff != 0){
							g.color = kha.Color.Black;
							g.drawScaledSubImage(animation.spriteMap,Math.floor(((actualFrameIndex)%Math.floor(animation.spriteMap.width/tilesize))*tilesize)+inset,Math.floor(Math.floor((actualFrameIndex)/Math.floor(animation.spriteMap.width/tilesize))*tilesize)+inset,tilesize-(inset*2),tilesize-(inset*2),x,y,tilesize,tilesize);
						}
						g.color = colour;
						g.drawScaledSubImage(animation.spriteMap,Math.floor(((actualFrameIndex)%Math.floor(animation.spriteMap.width/tilesize))*tilesize)+inset,Math.floor(Math.floor((actualFrameIndex)/Math.floor(animation.spriteMap.width/tilesize))*tilesize)+inset,tilesize-(inset*2),tilesize-(inset*2),x,y-zoff,tilesize,tilesize);
						
						g.popTransformation();
					}

					// Draw glow around things that have a light.
					// if (entity.has(component.Light)){
						// var c = entity.get(component.Light).colour;
						// g.color = kha.Color.fromFloats(c.R,c.G,c.B,.2);
						// g.fillRect(x,y,tilesize,tilesize);
						// g.color = kha.Color.White;
					// }
					
				}
			}
		}
		g.color = kha.Color.White;
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