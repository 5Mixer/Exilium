package ui;
import zui.Zui;
import zui.Id;

enum Module {
	Label(Text:String);
}

typedef Window = {
	var title:String;
	var contents:Array<Module>;
}

class DebugInterface {
	var debugui: Zui;
	public var fpsGraph:ui.Graph;
	public var updateGraph:ui.Graph;
	public var visible = true;

	public var activeCollisionRegionsShown = false;
	public var staticCollisionRegionsShown = false;

	public var windows:Array<Window>=[];

	var player:eskimo.Entity;

	public function new (player:eskimo.Entity){
		debugui = new Zui({font: kha.Assets.fonts.OpenSans});
		fpsGraph = new ui.Graph(new kha.math.Vector2(0,0),new kha.math.Vector2(180,60));
		updateGraph = new ui.Graph(new kha.math.Vector2(0,0),new kha.math.Vector2(180,60));
		this.player = player;
	}
	public function render(g:kha.graphics2.Graphics){
		
		g.transformation = (kha.math.FastMatrix3.identity());
		
		
		var fpsImage = fpsGraph.renderToImage();
		var upsImage = updateGraph.renderToImage();

		debugui.begin(g);
			
		if (visible){
			//Ensure ZUI refreshes for animations.
			var hwin = Id.handle();
			hwin.redraws = 1;
			
			if (debugui.window(hwin,10,10,200,600,true)){
				debugui.text("Debug Interface");
				var k = Id.handle({selected: true});
				if (debugui.panel(k, "Stats")) {
					k.redraws = 1;
					debugui.indent();
					debugui.text("FPS "+fpsGraph.values[fpsGraph.values.length]);
					debugui.image(fpsImage);
					debugui.text("UPS");
					debugui.image(upsImage);
					debugui.separator();
					staticCollisionRegionsShown = (debugui.check(Id.handle(),"Static Collision Regions."));
					activeCollisionRegionsShown = (debugui.check(Id.handle(),"Active Collision Regions."));

				}
			}
			
			var x = 240;
			for (window in windows){
				if (debugui.window(Id.handle(),x,10,200,600,true)){
					for (module in window.contents){
						switch(module){
							case Module.Label(string): debugui.text(string);
						}
					}
				}
				x += 220;
			}
		}
		debugui.end();
	}
}