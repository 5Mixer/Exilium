package ui;
import zui.Zui;
import zui.Id;

class DebugInterface {
	var debugui: Zui;
	public var fpsGraph:ui.Graph;
	public var updateGraph:ui.Graph;
	public var visible = true;
	public function new (){
		debugui = new Zui({font: kha.Assets.fonts.OpenSans});
		fpsGraph = new ui.Graph(new kha.math.Vector2(0,0),new kha.math.Vector2(180,60));
		updateGraph = new ui.Graph(new kha.math.Vector2(0,0),new kha.math.Vector2(180,60));

	}
	public function render(g:kha.graphics2.Graphics){
		if (!visible) return;
		
		g.transformation = (kha.math.FastMatrix3.identity());

		var fpsImage = fpsGraph.renderToImage();
		var upsImage = updateGraph.renderToImage();

		debugui.begin(g);
		
		//Ensure ZUI refreshes for animations.
		var hwin = Id.handle();
		hwin.redraws = 1;

		var a = Id.handle();
		a.redraws = 1;
		if (debugui.window(a,10,10,200,600,true)){
			debugui.text("Debug Interface");
			var k = Id.handle({selected: true});
			if (debugui.panel(k, "Stats")) {
				k.redraws = 1;
				debugui.indent();
				debugui.text("FPS");
				debugui.image(fpsImage);
				debugui.text("UPS");
				debugui.image(upsImage);

			}
		}
		if (debugui.window(Id.handle(),220,10,200,600,true)){
			debugui.text("Player Interface");
			if (debugui.panel(Id.handle({selected: true}), "Stats")) {
				debugui.indent();
				debugui.text("Update Rate");
				
				debugui.text("Render Rate");
			}
		}
		debugui.end();
	}
}