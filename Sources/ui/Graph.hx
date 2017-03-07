package ui;

class Graph {
	var pos:kha.math.Vector2;
	public var size:kha.math.Vector2;
	var bgColor:kha.Color;
	var fgColor:kha.Color;
	var values = new Array<Float>();
	public var visible = true;
	public function new (pos:kha.math.Vector2,size:kha.math.Vector2){
		this.pos = pos;
		this.size = size;
		bgColor = kha.Color.fromBytes(145,198,167,128);
		fgColor = kha.Color.fromBytes(108,252,168,240);
	}
	public function pushValue(value:Float){
		values.push(value);
	}
	public function render(g:kha.graphics2.Graphics){
		if (!visible) return;
		
		g.color = bgColor;
		g.fillRect(this.pos.x,this.pos.y,this.size.x,this.size.y);
		var startValueIndex = Math.ceil(Math.max(values.length - size.x,0));

		g.color = fgColor;
		for (i in startValueIndex...values.length){
			g.drawLine(this.pos.x-startValueIndex+i,this.pos.y+this.size.y,this.pos.x-startValueIndex+i,this.pos.y+this.size.y - (this.size.y*values[i]));
		}

	}
	//Remember to call this outside any other .begin/.end graphics!
	public function renderToImage (){
		var tempImg = kha.Image.createRenderTarget(Math.ceil(this.size.x),Math.ceil(this.size.y));
		tempImg.g2.begin(true,kha.Color.fromBytes(0,0,0,0));
		render(tempImg.g2);
		tempImg.g2.end();
		return tempImg;
	}
}