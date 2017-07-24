package ui;

class PotionShop extends Shop {
	override public function new (input:Input){
		super(input);
		name = "Potion shop";
		items = [
			{
				name: "Health Potion",
				description: "Heals 30 hp instantly.",
				image: kha.Assets.images.Bat,
				price: 20
			},
			{
				name: "Speed Potion",
				description: "Doubles movement speed for 30 seconds.",
				image: kha.Assets.images.Bat,
				price: 60
			},
			{
				name: "Defensive Potion",
				description: "All damage halved for 30 seconds.",
				image: kha.Assets.images.Bat,
				price: 100
			},
			{
				name: "Mayham Potion",
				description: "For 30 seconds, double speed, armour and fire rate.",
				image: kha.Assets.images.Bat,
				price: 300
			}
		];
	}
}