package ;

class ComponentList {
	public var components = new Map <String,Component>();
	
	public function new () {

	}
	
	public function has(identifier:String){
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
}