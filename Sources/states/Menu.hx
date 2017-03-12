package states;

class Menu extends states.State {
	var header = "Exilium.";
	override public function new (){
		super();
	}
	override public function render (framebuffer:kha.Framebuffer){
		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromFloats(.1,.1,.1,.6));
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38*4;
		var x = (framebuffer.width/2) - (g.font.width(g.fontSize,header)/2);
		g.drawString(header,x,20);
		g.end();
		
	}
}