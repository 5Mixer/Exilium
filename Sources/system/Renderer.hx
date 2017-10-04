package system;

import kha.math.FastMatrix3;
using kha.graphics2.GraphicsExtension;
import component.VisualParticle.Effect;

class Renderer extends System {
	var view:eskimo.views.View;
	var animatedView:eskimo.views.View;
	var particleView:eskimo.views.View;
	var entities:Array<eskimo.Entity> = [];
	var needRefresh = true;
	public var tilemap:world.Tilemap = null;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Sprite,component.Transformation]), entities);
		animatedView = new eskimo.views.View(new eskimo.filters.Filter([component.AnimatedSprite,component.Transformation]), entities);
		particleView = new eskimo.views.View(new eskimo.filters.Filter([component.VisualParticle,component.Transformation]), entities);
		view.onAdd = resort;
		view.onRemove = resort;
		animatedView.onAdd = resort;
		animatedView.onRemove = resort;
		particleView.onAdd = resort;
		particleView.onRemove = resort;
		super();
	}
	function resort(e){
		needRefresh = true;
	}
	function refreshz (){
		needRefresh = false;
		entities = view.entities.entities;
		entities = entities.concat(animatedView.entities.entities);
		entities = entities.concat(particleView.entities.entities);

		//Use haxe.ds sort as entities.sort is not stable (blood has equel z, causes reshuffling glitchyness)
		haxe.ds.ArraySort.sort(entities,function(a:eskimo.Entity,b:eskimo.Entity){
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
					var tileColour = null;
					if (tile != null)
						tileColour = tile.colour;

					if (colour != kha.Color.White && tileColour != null){
						var a = hxColorToolkit.ColorToolkit.toRGB(colour.value);
						var b = hxColorToolkit.ColorToolkit.toRGB(tileColour.value);
						var merge = new hxColorToolkit.spaces.RGB((a.red * b.red)/255, (a.green * b.green)/255, (a.blue * b.blue)/255);
						colour = kha.Color.fromBytes(Math.round(merge.red), Math.round(merge.green), Math.round(merge.blue));
					}else{
						colour = tileColour;
					}
					
				}
			}
			if (colour == null) colour = kha.Color.White;
			
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
			}else if (entity.has(component.VisualParticle)){
				var transform = entity.get(component.Transformation);
				var particle = entity.get(component.VisualParticle);

				particle.life++;
				switch(particle.effect){
					case Effect.Blood: {
						g.color = colour;
						var variant = Math.floor(particle.rand*5);
						g.drawSubImage(kha.Assets.images.Blood,transform.pos.x,transform.pos.y,8*variant,0,8,8);
					}
					case Effect.Spark: {
						if (entity.has(component.TimedLife)){
							var life = entity.get(component.TimedLife);

							g.fillCircle(transform.pos.x,transform.pos.y,((life.length-life.fuse)/life.length)*2,4);
						}else{
							g.fillCircle(transform.pos.x,transform.pos.y,3,4);
						}
					}
					case Effect.Speed(xoff,yoff): {
						g.drawLine(transform.pos.x,transform.pos.y,transform.pos.x+xoff,transform.pos.y+yoff);
						
					}
					case Effect.Smoke: {
						g.color = kha.Color.fromBytes(200-particle.life*4,90,90,100-particle.life*3);
						transform.pos.x += Math.floor(-1+Math.random()*2);
						//g.fillCircle(transform.pos.x-3+(particle.life/2),transform.pos.y-particle.life,2,8);
						var s = Math.max(0,2-(particle.life/10));
						g.fillRect(transform.pos.x-3+(particle.life/2),transform.pos.y-particle.life,s,s);
					}
					case Effect.Text(t): {
						var offx = 0.0;
						if (entity.has(component.TimedLife)){
							var life = entity.get(component.TimedLife);
							offx = Math.sin((life.fuse/life.length)*5)*(((life.length-life.fuse)/life.length)*1.5);
						}
						g.pushTransformation(g.transformation.mult(1));
						g.transformation._00 = 1;
						g.transformation._11 = 1;
						g.font = kha.Assets.fonts.trenco;
						g.color = kha.Color.fromFloats(1,1,1,.8);
						g.fontSize = 38;
						g.drawString(t,(transform.pos.x+offx)*4,transform.pos.y*4);
						g.popTransformation();
					}
					default : {}
				}
				
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