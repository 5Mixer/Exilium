package;

import kha.Key;

typedef Listener = {
	var key : String;
	var callback:Void->Void;
}

class Input {
	public var left: Bool;
	public var right: Bool;
	public var up: Bool;
	public var down: Bool;
	
	public var keys = new Map<kha.Key,Bool >();
	public var chars = new Map<String,Bool >();

	public var mouseEvents = true;
	public var mousePos:kha.math.Vector2 = new kha.math.Vector2(0,0);
	public var mouseButtons:{left:Bool, right:Bool} = {
		left: false,
		right: false
	};
	public var mouseReleased = false;
	public var wheelListeners:Array<Int->Void> = [];
	

	public var listeners:Array<Listener> = [];
	public function listenToKeyRelease(char:String,listener:Void->Void){
		listeners.push({key:char,callback:listener});
	}

	public function new() {
		kha.input.Keyboard.get().notify(keyDown,keyUp);
		kha.input.Mouse.get().notify(mouseDown,mouseUp,mouseMove,mouseWheel);

	}
	public function mouseDown(button,y,z){
		if (!mouseEvents) return;
		if (button==0) mouseButtons.left=true;
		if (button==1) mouseButtons.right=true;
	}
	public function mouseUp(button,y,z){
		if (!mouseEvents) return;
		if (button==0) { mouseButtons.left=false; mouseReleased = true; }
		if (button==1) mouseButtons.right=false;

	}
	public function mouseMove(x,y,z,w){
		mousePos.x = x;
		mousePos.y = y;
	}
	public function mouseWheel(direction){
		for (listener in wheelListeners)
			listener(direction);
	}

	public function startUpdate (){
	}
	public function endUpdate() {
		mouseReleased = false;

	}


	public function keyDown(key:Key,char:String) {
		keys.set(key,true);
		chars.set(char,true);

		if (key == LEFT || char == "a")
			left = true;

		if (key == RIGHT || char == "d")
			right = true;

		if (key == UP || char == "w")
			up = true;

		if (key == DOWN || char == "s")
			down = true;
	}

	public function keyUp(key: Key,char) {
		
		keys.set(key,false);
		chars.set(char,false);

		for (listener in listeners){
			if (char == listener.key){
				listener.callback();
			}
		}
		if (key == ESC){
			for (listener in listeners){
				if (listener.key == "esc"){
					listener.callback();
				}
			}
		}
		
		if(key == LEFT || char == 'a')
			left = false;
		if(key == RIGHT || char == 'd')
			right = false;
		if(key == UP || char == 'w')
			up = false;
		if(key == DOWN || char == 's')
			down = false;
	}
}
