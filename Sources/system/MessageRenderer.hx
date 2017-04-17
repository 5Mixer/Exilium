package system;
using kha.graphics2.GraphicsExtension;
import component.VisualParticle.Effect;

class MessageRenderer extends System {
	var view:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Message]),entities);
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var message = entity.get(component.Message);
			if (message.shown){
				g.pushTransformation(g.transformation.mult(1));
				g.transformation._00 = 1;
				g.transformation._11 = 1;
				g.font = kha.Assets.fonts.trenco;
				g.fontSize = 38;
				var lines = message.message.split("/n");
				var n = 0;
				for (line in lines){
					var width = g.font.width(g.fontSize,line);
					g.color = kha.Color.fromFloats(.05,.05,.05,.8);
					g.fillRect((transform.pos.x-2)*4 - (width/2),(transform.pos.y-4)*4 - (lines.length * g.font.height(g.fontSize)) + (n*g.font.height(g.fontSize)),width+12,g.font.height(g.fontSize)-4);
					
					g.color = kha.Color.fromFloats(1,1,1,.8);
					g.drawString(line,(transform.pos.x)*4 - (width/2),(transform.pos.y-6)*4 - (lines.length * g.font.height(g.fontSize)) + (n*g.font.height(g.fontSize)));
					n++;
				}
				g.popTransformation();
				g.color = kha.Color.White;
				message.shown = false; // shown must be set every frame, bad hacky behaviour
			}
		}
	}
}