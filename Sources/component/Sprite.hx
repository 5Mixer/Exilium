package component;

class Sprite extends Component {
	public var textureId:Int;
	public var spriteMap:kha.Image;
	public var tilesize = 16;
	public function new (id){
		textureId = id;
		spriteMap = kha.Assets.images.Entities;
		super();
	}
}