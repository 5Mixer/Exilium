package ;

class EventManager {
	public var eventListeners = new Map<String,Array<Dynamic -> Void>>();
	
	public function new (){

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
	

}