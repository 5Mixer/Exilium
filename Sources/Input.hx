package;

import kha.Key;

class Input {
	public var left: Bool;
	public var right: Bool;
	public var up: Bool;
	public var down: Bool;
	public var mousePos:kha.math.Vector2 = new kha.math.Vector2(0,0);

	public function new() {
		kha.input.Keyboard.get().notify(keyDown,keyUp);
		kha.input.Mouse.get().notify(mouseDown,mouseUp,mouseMove,mouseWheel);

	}
	public function mouseDown(x,y,z){

	}
	public function mouseUp(x,y,z){

	}
	public function mouseMove(x,y,z,w){
		mousePos.x = x;
		mousePos.y = y;
	}
	public function mouseWheel(direction){

	}


	public function keyDown(char:Key,letter) {

		if (char == LEFT || letter == "D")
			left = true;

		if (char == RIGHT || letter == "D")
			right = true;

		if (char == UP || letter == "W")
			up = true;

		if (char == DOWN || letter == "S")
			down = true;
	}

	public function keyUp(char: Key,letter) {
		switch (char) {
			case LEFT:
				left = false;
			case RIGHT:
				right = false;
			case UP:
				up = false;
			case DOWN:
				down = false;
			default:
		}
	}
}
