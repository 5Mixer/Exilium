package states;

class Dead extends states.State {
	var deadMessages = ["Dead huh. That's not good.", "Oh no, you are now little particles of meat.", "You were a nice desert for the dungeon", "Dead. Utterly dead.", "Yep... dead.", "Pretty sure you cease to be", "I'm afraid you're stone dead."];
	var header = "Dead. Thoroughly dead.";
	var input:Input;
	var transition = 0;
	var transitioning = false;
	override public function new (){
		super();
		header = deadMessages[Math.floor(Math.random()*deadMessages.length)];
		input = new Input();
	}
	override public function render (framebuffer:kha.Framebuffer){
		
		input.startUpdate();

		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromFloats(.1,.1,.1,.6));
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38;
		g.drawString(header,20,20);

		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38*4;
		var x = 20;//(framebuffer.width/2) - (g.font.width(g.fontSize,"Exilium")/2);
		g.fontSize = 38*2;
		if (!transitioning && button(g,"Retry.",x,Math.round(20+(g.font.height(38*4)+5)))){
			transitioning = true;
		}
		g.color = kha.Color.fromFloats(0,0,0,transition/30);
		g.fillRect(0,0,framebuffer.width,framebuffer.height);
		if (transitioning){
			transition++;
			if (transition >= 29){
				transitioning = false;
				Project.states.push(new states.Play());

			}
		}

		input.endUpdate();

		g.end();
		
	}
	function button (g:kha.graphics2.Graphics,text:String,x:Int,y:Int){
		var padding = 2;
		var boxx = x-padding;
		var boxy = y-padding;
		var boxw = g.font.width(g.fontSize,text)+(2*padding);
		var boxh = g.font.height(g.fontSize)+(2*padding);
		
		g.color = kha.Color.fromFloats(.2,.2,.2,.6);
		g.fillRect(boxx,boxy,boxw+8,boxh);
		g.color = kha.Color.White;
		g.drawString(text,x+padding*4,y-1*4);
		return (input.mouseReleased && input.mousePos.x > x && input.mousePos.y > y && input.mousePos.x < boxx+boxw && input.mousePos.y < boxy+boxh);
		
	}
}