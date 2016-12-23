package ;

class SubEntity extends Entity{
	var onDeath:SubEntity->Void;
	override public function new (onDeath){
		super();
		this.onDeath = onDeath;
	}
}