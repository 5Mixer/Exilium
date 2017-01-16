package system;

typedef Message = {
	var string:String;
	var time:Float;
}

class DebugView extends System {
	var view:eskimo.views.View;
	var log = new Array<Message>();
	var messagesShown = 15;
	var messageFadeOutTime = 10;
	public function new (entities:eskimo.EntityManager){
		super();
		//view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation,component.Collisions]),entities);
	}

	public function traceLog ( v : Dynamic, ?inf : haxe.PosInfos ){
		log.unshift({string:v, time: kha.System.time});
		if (log.length > messagesShown){
			log.pop();
		}
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		g.color = kha.Color.White;
		g.pushTransformation(g.transformation);
		g.transformation = kha.math.FastMatrix3.identity();
		var y = 10;
		g.font = kha.Assets.fonts.OpenSans;
		g.fontSize = 20;
		var i = messagesShown;
		for (message in log){
			i--;
			g.color = kha.Color.fromFloats(1,1,1,Math.min(i/messageFadeOutTime,(messagesShown-(kha.System.time-message.time))/messagesShown));
			if (message != null && message.string != ""){
				g.drawString(message.string,10,y);
			}else{
				g.drawString("Null",10,y);
			}
			y += 25;

			if (kha.System.time-message.time > messageFadeOutTime){
				log.remove(message);
			}
		}
		g.popTransformation();
		

		/*for (entity in view.entities){
			var transform = entity.get(component.Transformation);
			var collisions = entity.get(component.Collisions);
			for (region in collisions.collisionRegions){
				draw.drawShape(region);
			}
		}*/

		g.color = kha.Color.White;
	}
}