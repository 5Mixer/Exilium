package system;
using kha.graphics2.GraphicsExtension;

class ShieldRenderer extends System {
	var view:eskimo.views.View;
	var shieldTargets:eskimo.views.View;
	var input:Input;
	var camera:Camera;
	var pixelisedRender:kha.Image;
	public function new (input:Input,camera:Camera,entities:eskimo.EntityManager){
		this.input = input;
		this.camera = camera;
		//this.pixelisedRender = kha.Image.createRenderTarget(kha.System.windowWidth(),kha.System.windowHeight());
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Shield]),entities);
		shieldTargets = new eskimo.views.View(new eskimo.filters.Filter([component.Physics,component.Collisions]),entities);
	}
	public function prepass(){
		//this.pixelisedRender = kha.Image.createRenderTarget(kha.System.windowWidth(),kha.System.windowHeight());
		/*var g = pixelisedRender.g2;
		g.begin(true,kha.Color.fromBytes(0,0,0,0));

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var shield = entity.get(component.Shield);
			var aabb = entity.get(component.Collisions).AABB;

			var tx = transform.pos.x + aabb.width/2;
			var ty = transform.pos.y + aabb.height/2;
			
			var mx = camera.screenToWorld(input.mousePos).x;
			var my = camera.screenToWorld(input.mousePos).y;
			var dirx = mx-tx;
			var diry = my-ty;
			var angleRads = Math.atan2(diry,dirx);
			shield.angle = angleRads;
			
			var sx = camera.worldToScreen(new kha.math.Vector2(tx,ty)).x/4;
			var sy = camera.worldToScreen(new kha.math.Vector2(tx,ty)).y/4;

			//Draw arc...
			var outset = Math.sqrt(Math.pow(aabb.width,2)+Math.pow(aabb.height,2));
			//var angleRads = shield.angle*(Math.PI/180);
			var arcRads = shield.arcAngle*(Math.PI/180);
			var segments = 10;
			var thickness = 3;
			g.color = kha.Color.fromBytes(250,175,90);
			for (segment in 0...segments){
				var width = thickness*(Math.sin(((segment/segments)*Math.PI/2)+1));
				var x1 = Math.cos(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var y1 = Math.sin(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var x2 = Math.cos(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;
				var y2 = Math.sin(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;

				//To smooth.
				g.fillCircle(x1+sx,y1+sy,width/2);
				g.fillCircle(x2+sx,y2+sy,width/2);
				//Draw line
				g.drawLine(x1+sx,y1+sy,x2+sx,y2+sy,width);
			}

			g.color = kha.Color.fromBytes(200,130,50);
			thickness = 1;
			for (segment in 0...segments){
				var width = thickness*(Math.sin(((segment/segments)*Math.PI/2)+1));
				var x1 = Math.cos(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var y1 = Math.sin(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var x2 = Math.cos(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;
				var y2 = Math.sin(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;

				//To smooth.
				g.fillCircle(x1+sx,y1+sy,width/2);
				g.fillCircle(x2+sx,y2+sy,width/2);
				//Draw line
				g.drawLine(x1+sx,y1+sy,x2+sx,y2+sy,width);
			}
		
			g.color = kha.Color.White;
		}*/

		//g.end();
	}

	override public function onUpdate(delta:Float){
		for (entity in view.entities)
			for (target in shieldTargets.entities){
				var transform = entity.get(component.Transformation);
				var shield = entity.get(component.Shield);
				var targetTransform = target.get(component.Transformation);
				var targetPhysics = target.get(component.Physics);

				var a = Math.atan2(targetTransform.pos.y-transform.pos.y,targetTransform.pos.x-transform.pos.x);
				var arc = shield.arcAngle * (Math.PI/180);
				if (a+(arc/2) > shield.angle && a+(arc/2) < shield.angle+arc){
					if (transform.pos.sub(targetTransform.pos).length < shield.size*1.5){
						targetPhysics.velocity = targetPhysics.velocity.mult(-1);
					}
				}
			}
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		/*g.pushTransformation(g.transformation);
		g.transformation = kha.math.FastMatrix3.identity();
		
		g.transformation._00 = 4;
		g.transformation._11 = 4;

		g.drawImage(pixelisedRender,0,0);
		pixelisedRender.unload();
		g.popTransformation();*/

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var shield = entity.get(component.Shield);
			var aabb = entity.get(component.Collisions).AABB;

			var tx = transform.pos.x + aabb.width/2;
			var ty = transform.pos.y + aabb.height/2;
			
			var mx = camera.screenToWorld(input.mousePos).x;
			var my = camera.screenToWorld(input.mousePos).y;
			var dirx = mx-tx;
			var diry = my-ty;
			var angleRads = Math.atan2(diry,dirx);
			shield.angle = angleRads;
			
			var sx = camera.worldToScreen(new kha.math.Vector2(tx,ty)).x/4;
			var sy = camera.worldToScreen(new kha.math.Vector2(tx,ty)).y/4;

			//Draw arc...
			var outset = Math.sqrt(Math.pow(aabb.width,2)+Math.pow(aabb.height,2));
			shield.size = Math.ceil(outset);
			//var angleRads = shield.angle*(Math.PI/180);
			var arcRads = shield.arcAngle*(Math.PI/180);
			var segments = 10;
			var thickness = 3;
			g.color = kha.Color.fromBytes(250,175,90);
			for (segment in 0...segments){
				var width = thickness*(Math.sin(((segment/segments)*Math.PI/2)+1));
				var x1 = Math.cos(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var y1 = Math.sin(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var x2 = Math.cos(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;
				var y2 = Math.sin(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;

				//To smooth.
				g.fillCircle(x1+sx,y1+sy,width/2);
				g.fillCircle(x2+sx,y2+sy,width/2);
				//Draw line
				g.drawLine(x1+sx,y1+sy,x2+sx,y2+sy,width);
			}

			g.color = kha.Color.fromBytes(200,130,50);
			thickness = 1;
			for (segment in 0...segments){
				var width = thickness*(Math.sin(((segment/segments)*Math.PI/2)+1));
				var x1 = Math.cos(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var y1 = Math.sin(angleRads+(((segment/segments)-.5)*arcRads))*outset;
				var x2 = Math.cos(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;
				var y2 = Math.sin(angleRads+((((segment+1)/segments)-.5)*arcRads))*outset;

				//To smooth.
				g.fillCircle(x1+tx,y1+ty,width/2);
				g.fillCircle(x2+tx,y2+ty,width/2);
				//Draw line
				g.drawLine(x1+tx,y1+ty,x2+tx,y2+ty,width);
			}
		
			g.color = kha.Color.White;
		}
	}
}