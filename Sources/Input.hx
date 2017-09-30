package;

import kha.input.KeyCode;

typedef Listener = {
	var key : kha.input.KeyCode;
	var callback:Void->Void;
}

class Input {
	public var left: Bool;
	public var right: Bool;
	public var up: Bool;
	public var down: Bool;
	
	public var keys = new Map<KeyCode,Bool >();
	public var keysReleased = new Map<KeyCode,Bool >();

	public var mouseEvents = true;
	public var mousePos:kha.math.Vector2 = new kha.math.Vector2(0,0);
	public var mouseButtons:{left:Bool, right:Bool} = {
		left: false,
		right: false
	};
	public var mouseReleased = false;
	public var wheelListeners:Array<Int->Void> = [];
	

	public var listeners:Array<Listener> = [];
	public function listenToKeyRelease(char:kha.input.KeyCode,listener:Void->Void){
		listeners.push({key:char,callback:listener});
	}

	public function new() {
		kha.input.Keyboard.get().notify(keyDown,keyUp);
		kha.input.Mouse.get().notify(mouseDown,mouseUp,mouseMove,mouseWheel);

	}
	public function mouseDown(button,y,z){
		// if (!mouseEvents) return;
		if (button==0) mouseButtons.left=true;
		if (button==1) mouseButtons.right=true;
	}
	public function mouseUp(button,y,z){
		// if (!mouseEvents) return;
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
		keysReleased = new Map<KeyCode,Bool >();
	}

	public function keyDown(key:KeyCode) {
		keys.set(key,true);

		if (key == KeyCode.Left || key == KeyCode.A)
			left = true;

		if (key == KeyCode.Right || key == KeyCode.D)
			right = true;

		if (key == KeyCode.Up || key == KeyCode.W)
			up = true;

		if (key == KeyCode.Down || key == KeyCode.S)
			down = true;
	}

	public function keyUp(key:KeyCode) {
		
		keys.set(key,false);
		keysReleased.set(key,true);
		// if (key == KeyCode.R)
		// 	if (onRUp != null)
		// 		onRUp();
		for (listener in listeners)
			if (listener.key == key)
				listener.callback();
		
		if(key == KeyCode.Left || key == KeyCode.A)
			left = false;
		if(key == KeyCode.Right || key == KeyCode.D)
			right = false;
		if(key == KeyCode.Up || key == KeyCode.W)
			up = false;
		if(key == KeyCode.Down || key == KeyCode.S)
			down = false;
	}
}
