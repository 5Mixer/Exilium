package;

import kha.Key;

class Input {
	public var left: Bool;
	public var right: Bool;
	public var up: Bool;
	public var down: Bool;

	public function new() {
		kha.input.Keyboard.get().notify(keyDown,keyUp);
		//kha.input.Mouse.get().notify()

	}

	public function keyDown(char:Key,letter) {
		trace(char+"down");

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
		trace(char+"up");
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
