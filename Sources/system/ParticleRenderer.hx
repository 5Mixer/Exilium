package system;
using kha.graphics2.GraphicsExtension;
import component.VisualParticle.Effect;

class ParticleRenderer extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.VisualParticle]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var particle = entity.get(component.VisualParticle);
			particle.life++;
			switch(particle.effect){
				case Effect.Blood: {
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
			g.color = kha.Color.White;
		}
	}
}