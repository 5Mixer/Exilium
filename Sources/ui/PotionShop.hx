package ui;

class PotionShop extends Shop {
	public function new (input:Input,inventory:component.Inventory){
		super(input,inventory);
		name = "Potion shop";
		items = [
			{
				name: "Health Potion",
				description: "Heals 30 hp instantly.",
				image: kha.Assets.images.Bat,
				price: 20,
				item: component.Inventory.Item.HealthPotion
			},
			{
				name: "Speed Potion",
				description: "Doubles movement speed for 15 seconds.",
				image: kha.Assets.images.Bat,
				price: 60,
				item: component.Inventory.Item.SpeedPotion
			},
			{
				name: "Defensive Potion",
				description: "All damage halved for 15 seconds.",
				image: kha.Assets.images.Bat,
				price: 100,
				item: component.Inventory.Item.DefensivePotion
			},
			{
				name: "Mayham Potion",
				description: "For 8 seconds, double speed, defence and fire rate.",
				image: kha.Assets.images.Bat,
				price: 300,
				item: component.Inventory.Item.MayhamPotion
			}
		];
	}
}