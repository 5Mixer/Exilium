package ;

class ComponentList {
	public var components = new Map <String,Component>();
	
	public function new () {

	}
	
	public function hasComponent(identifier:String){
		return components.exists(identifier);
	}
	public function get(identifier){
		return components.get(identifier);
	}
	public function set(identifier:String,component:Component){
		components.set(identifier,component);
	}
	public function removeComponent(identifier){
		components.remove(identifier);
	}
	public function draw (g){
		for (component in components) component.draw(g);
	}
	public function update (delta:Float) {
		for (component in components) component.update(delta);
	}
}