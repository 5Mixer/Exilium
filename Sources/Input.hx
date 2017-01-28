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
	public var mousePos:kha.math.Vector2 = new kha.math.Vector2(0,0);
	public var mouseButtons:{left:Bool, right:Bool} = {
		left: false,
		right: false
	};
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
		if (button==0) mouseButtons.left=true;
		if (button==1) mouseButtons.right=true;
	}
	public function mouseUp(button,y,z){
		if (button==0) mouseButtons.left=false;
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


	public function keyDown(char:Key,letter:String) {
		

		if (char == LEFT || letter == "a")
			left = true;

		if (char == RIGHT || letter == "d")
			right = true;

		if (char == UP || letter == "w")
			up = true;

		if (char == DOWN || letter == "s")
			down = true;
	}

	public function keyUp(char: Key,letter) {

		for (listener in listeners){
			if (letter == listener.key){
				listener.callback();
			}
		}
		
		if(char == LEFT || letter == 'a')
			left = false;
		if(char == RIGHT || letter == 'd')
			right = false;
		if(char == UP || letter == 'w')
			up = false;
		if(char == DOWN || letter == 's')
			down = false;
	}
}
