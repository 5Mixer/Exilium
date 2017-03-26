package states;

class Menu extends states.State {
	var input:Input;
	var transition = 0;
	var transitioning = false;
	override public function new (){
		super();
		input = new Input();
	}
	override public function update (delta:Float){
		
	}
	override public function render (framebuffer:kha.Framebuffer){
		input.startUpdate();
		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromFloats(.1,.1,.1,.6));
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38*4;
		var x = 20;//(framebuffer.width/2) - (g.font.width(g.fontSize,"Exilium")/2);
		g.drawString("Exilium",x,20);
		g.fontSize = 38*2;
		if (!transitioning && button(g,"New game.",x,Math.round(20+(g.font.height(38*4)+5)))){
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

		g.end();
		input.endUpdate();
		
	}
	function button (g:kha.graphics2.Graphics,text:String,x:Int,y:Int){
		var padding = 2;
		var boxx = x-padding;
		var boxy = y-padding;
		var boxw = g.font.width(g.fontSize,text)+(2*padding);
		var boxh = g.font.height(g.fontSize)+(2*padding);
		
		g.color = kha.Color.fromFloats(.2,.2,.2,.6);
		g.fillRect(boxx,boxy,boxw,boxh);
		g.color = kha.Color.White;
		g.drawString(text,x+padding*4,y-1*4);
		return (input.mouseReleased && input.mousePos.x > x && input.mousePos.y > y && input.mousePos.x < boxx+boxw && input.mousePos.y < boxy+boxh);
		
	}
}