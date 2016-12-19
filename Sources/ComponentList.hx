package ;

class ComponentList {
	public var components = new Map <String,Component>();
	public var eventListeners = new Map<String,Array<Dynamic -> Void>>();
	
	public function new () {

	}
	public function callEvent (event:String,data:Dynamic){
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
	public function registerComponent(identifier:String,component:Component){
		components.set(identifier,component);
	}
	public function removeComponent(identifier){
		components.remove(identifier);
	}
}