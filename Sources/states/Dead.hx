package states;

class Dead extends states.State {
	var deadMessages = ["Dead huh. That's not good.", "Oh no, you are now little particles of meat.", "You were a nice desert for the dungeon", "Dead. Utterly dead.", "Yep... dead.", "Pretty sure you cease to be", "I'm afraid you're stone dead."];
	var header = "Dead. Thoroughly dead.";
	override public function new (){
		super();
		header = deadMessages[Math.floor(Math.random()*deadMessages.length)];
	}
	override public function render (framebuffer:kha.Framebuffer){
		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromFloats(.1,.1,.1,.6));
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38;
		g.drawString(header,20,20);
		g.end();
		
	}
}