package component;

class AnimatedSprite extends Component {
	public var frame = 0;
	public var currentFrameTime:Int = 0; //This progresses from 0 - timeFrameIsShown for, then frame is incremented and this resets
	public var currentAnimation:String;
	public var animationData:Dynamic;
	public var spriteMap:kha.Image;
	public var tilesize = 16;
	public var speed:Int = 10;
	public var spriteData:Dynamic;
	public function new (?spriteData:Dynamic){
		this.spriteData = spriteData;
		spriteMap = kha.Assets.images.Entities;
		super();
	}
	public function playAnimation(name:String){
		if(currentAnimation != name)
			frame = 0;
		
		currentAnimation = name;
	}
}