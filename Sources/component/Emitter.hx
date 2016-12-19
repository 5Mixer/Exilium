package component ;



class Emitter extends Component{
	var children:Array<Entity>;
	public function new (parent:Entity){
		children = new Array<Entity>();
		super(parent);
	}
	public function emit (child:Entity){
		children.push(child);
	}
	public function kill(child:Entity){
		children.remove(child);
	}
	override public function draw (g){
		for (component in children) component.draw(g);
	}
	override public function update (delta:Float) {
		for (component in children) component.update(delta);
	}
}