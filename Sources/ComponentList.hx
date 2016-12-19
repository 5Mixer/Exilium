package ;

class ComponentList {
	public var components = new Map <String,Component>();
	public var eventListeners = new Map<String,Array<Dynamic -> Void>>();
	
	public function new () {

	}
	public function callEvent (event:String,data:Dynamic){
		if (!eventListeners.exists(event))
			return;
			
		for (listener in eventListeners.get(event))
			listener(data);
	}
	public function listenToEvent(event:String,listener:Dynamic->Void){
		
		if (eventListeners.get(event) == null){
			eventListeners.set(event,[listener]);
		}else{
			eventListeners.get(event).push(listener);
		}
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