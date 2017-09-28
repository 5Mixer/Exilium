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
	public var whenFinishedStart:String;
	public function new (?spriteData:Dynamic){
		this.spriteData = spriteData;

		if (this.spriteData.speed != null){
			this.speed = this.spriteData.speed;
		}

		if (spriteData.tileset != null){
			switch spriteData.tileset {
				case "ghost": {spriteMap = kha.Assets.images.Ghost; tilesize = 10;}
				case "slime": {spriteMap = kha.Assets.images.Slime; tilesize = 8;}
				case "projectiles": {spriteMap = kha.Assets.images.Projectiles;}
				case "objects": {spriteMap = kha.Assets.images.Objects; tilesize = 8;}
				case "chest": {spriteMap = kha.Assets.images.Chest; tilesize = 11;}
				case "goblin": {spriteMap = kha.Assets.images.Goblin; tilesize = 10;}
				case "coin": {spriteMap = kha.Assets.images.Coin; tilesize = 8;}
				case "tileset": {spriteMap = kha.Assets.images.Tileset; tilesize = 16;}
				case "mummy": {spriteMap = kha.Assets.images.Mummy; tilesize = 10; }
				case "bat": {spriteMap = kha.Assets.images.Bat; tilesize = 8; }
				case "explosions": {spriteMap = kha.Assets.images.Explosion; tilesize = 32; }
			}
		}

		super();
	}
	public function playAnimation(name:String,?whenFinishedStart:String){
		if(currentAnimation != name)
			frame = 0;
		if (whenFinishedStart != null){
			this.whenFinishedStart = whenFinishedStart;
		}else{
			this.whenFinishedStart = name;
		}
		
		currentAnimation = name;
		return this;
	}
	public function setSpeed(x:Int){ this.speed = x; return this; }
}