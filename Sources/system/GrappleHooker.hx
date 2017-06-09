package system;

class GrappleHooker extends System {
	var frame = 0;
	var input:Input;
	var camera:Camera;
	var view:eskimo.views.View;
	var entities:eskimo.EntityManager;
	var spriteData = CompileTime.parseJsonFile('../assets/spriteData.json').entity.bullet_basic;
	var collisionSystem:system.Collisions;

	override public function new (input:Input,camera:Camera,entities:eskimo.EntityManager,collisionSystem:system.Collisions){
		this.input = input;
		this.camera = camera;
		this.entities = entities;
		this.collisionSystem = collisionSystem;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.GrappleHook,component.Inventory,component.Transformation,component.Physics]),entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		for (entity in view.entities){
			var pinv = entity.get(component.Inventory);
			var collisions = entity.get(component.Collisions);
			var transformation = entity.get(component.Transformation);
			var hook = entity.get(component.GrappleHook);
			
			if (transformation != null){
				if (pinv.getByIndex(pinv.activeIndex).item == component.Inventory.Item.GrapplingHook && hook.fired){
					var endx = hook.destination.x;
					var endy = hook.destination.y;
					var px = transformation.pos.x + collisions.midpoint.x;
					var py = transformation.pos.y + collisions.midpoint.y;
					var a = Math.atan2(endy-py,endx-px)*(180/Math.PI);
					var l = collisionSystem.fireRay(new differ.shapes.Ray(new differ.math.Vector(px,py),new differ.math.Vector(endx,endy)),[component.Collisions.CollisionGroup.Player]);
					//g.drawLine(px,py,endx*l,endy*l);
					var rayDist = l * Math.sqrt(Math.pow(px-endx,2)+Math.pow(py-endy,2));
					
					var hookLength = 8;
					var hooks = Math.floor(rayDist/hookLength);
					
					//Refer to kha2d for rotating sprite help
					g.pushTransformation(g.transformation.multmat(kha.math.FastMatrix3.translation(px, py)).multmat(kha.math.FastMatrix3.rotation(a*(Math.PI/180))).multmat(kha.math.FastMatrix3.translation(-px - collisions.midpoint.x, -py - collisions.midpoint.y+1)));
					for (i in 0...hooks){
						g.drawSubImage(kha.Assets.images.Objects,px+(i*hookLength),py,6*8,0,8,8);
					}
					var clawx:Float = px+(hooks*hookLength);
					//Extra half a chain
					if (rayDist%hookLength > .5*hookLength){
						clawx += hookLength/2;
						g.drawSubImage(kha.Assets.images.Objects,px+((hooks)*hookLength),py,6*8,0,4,8);

					}
					//Final claw
					g.drawSubImage(kha.Assets.images.Objects,clawx,py,7*8,0,8,8);
					g.popTransformation();

				}
			}
		}
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		frame++;
		
		for (entity in view.entities){
			var transformation:component.Transformation = entity.get(component.Transformation);
			var inventory:component.Inventory = entity.get(component.Inventory);
			var physics:component.Physics = entity.get(component.Physics);
			var hook:component.GrappleHook = entity.get(component.GrappleHook);
			if (input.mouseButtons.left == false){
				hook.fired = false;
				hook.active = true;
			}
			if (inventory.getByIndex(inventory.activeIndex).item == component.Inventory.Item.GrapplingHook){
				if (input.mouseButtons.left){
					if (hook.fired){
						var distToHook = Math.sqrt(Math.pow(transformation.pos.x-hook.destination.x,2)+Math.pow(transformation.pos.y-hook.destination.y,2));
						if (distToHook > 15){
							var angle = Math.atan2(hook.destination.y - transformation.pos.y,hook.destination.x - transformation.pos.x);
							physics.velocity.x += Math.cos(angle)*7000*delta;
							physics.velocity.y += Math.sin(angle)*7000*delta;
						}
						if (distToHook<15){
							hook.active = false;
						}
					}else{						
						hook.fired = true;
						
						kha.audio1.Audio.play(kha.Assets.sounds.grapplehook);

						var dir = transformation.pos.sub(camera.screenToWorld(input.mousePos.sub(new kha.math.Vector2(24,24))));
						var a = Math.round(Math.atan2(-dir.y,-dir.x)*(180/Math.PI));
						var endx = Math.cos(a*(Math.PI/180))*1900;
						var endy = Math.sin(a*(Math.PI/180))*1900;
						var px = transformation.pos.x + 4;
						var py = transformation.pos.y + 4;
						var l = collisionSystem.fireRay(new differ.shapes.Ray(new differ.math.Vector(px,py),new differ.math.Vector(px+endx,py+endy)),[component.Collisions.CollisionGroup.Player]);
						
						hook.destination = {
							x: px+(endx*l),
							y: py+(endy*l),
						};
					}
				}else{
					//no mouse no hook
					hook.active = false;
					hook.fired = false;
				}
			}else{
				//Grapple hook isn't active in inventory
				hook.active = false;
				hook.fired = false;
			}
		}
	}
}