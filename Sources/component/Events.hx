package component;

enum Event {
	Death;
}

class Events extends Component {
	public var events:Map<Event,Array<Dynamic->Void>>;
	public function new (){
		events = new Map<Event,Array<Dynamic->Void>>();		
		super();
	}
	public function callEvent (event:Event,args:Dynamic){
		if (events.exists(event)){
			for (func in events.get(event))
				func(args);
		}
	}
	public function listenToEvent (event:Event,func:Dynamic->Void){
		if (events.exists(event)){
			events.get(event).push(func);
		}else{
			events.set(event,[func]);
		}
	}
}