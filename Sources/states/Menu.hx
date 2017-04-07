package states;

class Menu extends states.State {
	var input:Input;
	var frame = 0.;
	override public function new (){
		super();
		input = new Input();
	}
	override public function update (delta:Float){
		
	}
	override public function render (framebuffer:kha.Framebuffer){
		frame+=.25;
		input.startUpdate();
		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromFloats(.1,.1,.1,.6));

		g.pushTransformation(g.transformation);
		g.transformation = kha.math.FastMatrix3.identity();
		g.transformation._00 = 4;
		g.transformation._11 = 4;
		//pattern
		var patternSize = 64; //todo: use image size
		var offset = frame%64;
		for (x in 0...Math.ceil(kha.System.windowWidth()/patternSize)+1){
			for (y in 0...Math.ceil(kha.System.windowHeight()/patternSize)+1){
				g.drawImage(kha.Assets.images.pattern,((x-1)*64)+offset,((y-1)*64)+offset);
			}
		}
		g.popTransformation();
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38*4;

		g.color = kha.Color.fromBytes(30,30,30);
		g.fillRect(0,0,g.font.width(g.fontSize,"Exilium")+32,kha.System.windowHeight());

		g.color = kha.Color.White;
		
		g.drawString("Exilium",20,20);
		g.fontSize = 38*2;
		var y = Math.round(20+(g.font.height(38*4)+5));
		if (button(g,"New game.",20,y)){
			trace("Starting up game.");
			//var promise = thx.promise.Promise.create(function(resolve : states.Play -> Void, reject : thx.Error -> Void) {
				
				var p = new states.Play();
				Project.states.push(p);
				//resolve(p);
				
				//reject(new thx.Error("failure"));
			
			//});
			
			//promise.success(function(result:states.Play){
				// trace(result);
			//	Project.states.push(result);
			//});

		}

		y=kha.System.windowHeight();
		g.fontSize = 38*1;
		g.drawString("game by @5mixer...",20,y-100);
		g.drawString("art by patch...",20,y-70);
		g.drawString("music by gas.",20,y-40);

		g.end();
		input.endUpdate();
		
	}
	function button (g:kha.graphics2.Graphics,text:String,x:Int,y:Int){
		var padding = 2;
		var boxx = x-padding;
		var boxy = y-padding;
		var boxw = g.font.width(g.fontSize,text)+(2*padding);
		var boxh = g.font.height(g.fontSize)+(2*padding)-(3.5*8);
		
		g.color = kha.Color.fromFloats(.2,.2,.2,.6);
		g.fillRect(boxx,boxy,boxw+8,boxh);
		g.color = kha.Color.White;
		g.drawString(text,x+padding*4,y-(3*8));
		return (input.mouseReleased && input.mousePos.x > x && input.mousePos.y > y && input.mousePos.x < boxx+boxw && input.mousePos.y < boxy+boxh);
		
	}
}