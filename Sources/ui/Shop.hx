package ui;

typedef ShopItem = {
	var name:String;
	var description:String;
	var image:kha.Image;
	var price:Int;
}

class Shop {
	var items = new Array<ShopItem>();
	var width = 128;
	var height = 64;
	var name = "Shop";
	var input:Input;
	public function new (input:Input){
		this.input = input;
	}
	public function render(g:kha.graphics2.Graphics){
		g.pushTranslation(200,200);

		g.color = kha.Color.fromBytes(220,190,160);
		g.fillRect(0,0,width,10+items.length*20);

		
		g.transformation._00 = 1;
		g.transformation._11 = 1;
		g.color = kha.Color.White;
		g.font = kha.Assets.fonts.trenco;
		g.fontSize = 38;

		g.drawString(name,2*4,0);
		
		g.transformation._00 = 4;
		g.transformation._11 = 4;

		var y = 10;
		for (item in items){
			g.color = kha.Color.fromBytes(105,105,105);
			if (input.mousePos.x > 201 && input.mousePos.x < 201+(width*4)-22&&
				input.mousePos.y > 210+(y*4) && input.mousePos.y < 210+(y*4)+(18*4)){
				g.color = kha.Color.fromBytes(120,120,120);
			}
			g.fillRect(1,y,width-2-18-2,18);
			g.fillRect(width-18-1,y,18,18);


			g.transformation._00 = 1;
			g.transformation._11 = 1;
			g.color = kha.Color.White;
			g.font = kha.Assets.fonts.trenco;
			g.fontSize = 38;

			g.drawString(item.name,2*4,((y-2)*4));

			g.color = kha.Color.fromBytes(230,230,230);
			g.fontSize = 25;
			g.drawString(item.description,2*4,(y*4) + (6 * 4));
			g.drawString(item.price+" g",2*4,((y+4)*4) + (6 * 4));
			
			g.transformation._00 = 4;
			g.transformation._11 = 4;

			y += 20;
		}

		g.popTransformation();
		g.color = kha.Color.White;
	}
}