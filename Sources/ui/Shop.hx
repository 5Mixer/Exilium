package ui;

typedef ShopItem = {
	var name:String;
	var description:String;
	var image:kha.Image;
	var price:Int;
	var item:component.Inventory.Item;
}

class Shop {
	var items = new Array<ShopItem>();
	var width = 128;
	var height = 64;
	var name = "Shop";
	var input:Input;
	var inventory:component.Inventory;
	public function new (input:Input,inventory:component.Inventory){
		this.input = input;
		this.inventory = inventory;
	}
	public function update (){
		if (input.mouseReleased){
		var y = 10;
			for (item in items){
				if (input.mousePos.x > 201 && input.mousePos.x < 201+(width*4)-22&&
					input.mousePos.y > 210+(y*4) && input.mousePos.y < 210+(y*4)+(18*4)){
					if (inventory.getStack(component.Inventory.Item.Gold) != null){
						if (inventory.getStack(component.Inventory.Item.Gold).quantity >= item.price){
							inventory.putIntoInventory(item.item,1);
							inventory.takeFromInventory(component.Inventory.Item.Gold, item.price);
							kha.audio1.Audio.play(kha.Assets.sounds.buy);
						}
					}
				}
				y += 20;
			}
		}

	}
	public function render(g:kha.graphics2.Graphics){
		g.pushTranslation(200,200);

		g.color = kha.Color.fromBytes(220,190,160);
		g.fillRect(0,0,1+(width)*4,(9+items.length*20)*4);

		
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
		g.drawSubImage(kha.Assets.images.Sellers,0-20,0,0,0,16,16);

		g.popTransformation();
		g.color = kha.Color.White;
	}
}