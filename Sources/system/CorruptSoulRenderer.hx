package system;
using kha.graphics2.GraphicsExtension;
import component.VisualParticle.Effect;

class CorruptSoulRenderer extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.CorruptSoul]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var soul = entity.get(component.CorruptSoul);
			/*for (smokeParticle in soul.smokeParticles){
				g.color = kha.Color.fromBytes(96,93,93,176);
				g.fillCircle(transform.pos.x+smokeParticle.x,transform.pos.y+smokeParticle.y,smokeParticle.size,5);
				smokeParticle.x += smokeParticle.vx; 
				smokeParticle.y += smokeParticle.vy;
				smokeParticle.vx *= .7;
				smokeParticle.vy *= .7;
				smokeParticle.vx += -.3+Math.random()*.6;
				smokeParticle.vy += -.3+Math.random()*.6;
				if (Math.pow(smokeParticle.x,2)+Math.pow(smokeParticle.y,2) > 25*25){
					smokeParticle.vx*=-1;
					smokeParticle.vy*=-1;
					var a = Math.atan2(smokeParticle.y,smokeParticle.x);
					smokeParticle.x = Math.cos(a)*25;
					smokeParticle.y = Math.sin(a)*25;
				}
			}*/
			for (child in soul.children){
				var p = child.get(component.Physics);
				var t = child.get(component.Transformation);
				if (t == null) continue;
				var childParticle = child.get(component.CorruptSoulChild);
				var targetRandomisation = 20;
				var target = t.pos.add(new kha.math.Vector2(-targetRandomisation+Math.random()*(2*targetRandomisation),-targetRandomisation+Math.random()*(2*targetRandomisation)));
				g.color = childParticle.colour;
				//t.pos = transform.pos.add(new kha.math.Vector2(-1+Math.random()*2,-1+Math.random()*2));
				if (Math.random()>.9){
					var randomThrowMagnitude = 4+(8*Math.random());
					p.velocity = p.velocity.add(new kha.math.Vector2(-randomThrowMagnitude+Math.random()*(2*randomThrowMagnitude),-randomThrowMagnitude+Math.random()*(2*randomThrowMagnitude)));
				}
				g.fillCircle(t.pos.x,t.pos.y,childParticle.size,childParticle.sides);
				var dire = transform.pos.sub(target);
				p.velocity = p.velocity.add(dire.mult(.05));
				if (Math.pow(t.pos.x-transform.pos.x,2)+Math.pow(t.pos.y-transform.pos.y,2) > 25*25){
					
					//var a = Math.atan2(t.pos.y-transform.pos.y,t.pos.x-transform.pos.x);
					//p.velocity.x = transform.pos.x+Math.cos(a)*.3;
					//p.velocity.y = transform.pos.y+Math.sin(a)*.3;
				}

			}
					
			g.color = kha.Color.White;
		}
	}
}