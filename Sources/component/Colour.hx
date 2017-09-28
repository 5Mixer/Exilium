package component;

class Colour {
	public var colour:kha.Color;
	public function new (?colour:kha.Color){
		if (colour != null){
			this.colour = colour;
		}else{
			this.colour = kha.Color.Red;
		}
	}
}