package component;

typedef EntityData = {
	@:optional var width:Int;
	@:optional var height:Int;
	@:optional var id:Int;
	@:optional var tileset:String;
	@:optional var animations:Int;
}

class Sprite extends Component {
	public var textureId:Int;
	public var spriteMap:kha.Image;
	public var tilesize = 16;
	public function new (spriteData:EntityData){
		if (spriteData.id != null)
			textureId = spriteData.id;
		spriteMap = kha.Assets.images.Entities;

		if (spriteData.tileset != null){
			switch spriteData.tileset {
				case "ghost": spriteMap = kha.Assets.images.Ghost;
				case "slime": spriteMap = kha.Assets.images.Slime;
				case "projectiles": spriteMap = kha.Assets.images.Projectiles;
				case "objects": spriteMap = kha.Assets.images.Objects;
			}
		}
		super();
	}
}