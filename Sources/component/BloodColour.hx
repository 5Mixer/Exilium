package component;
class BloodColour extends Component{
	public var colour:kha.Color;
	override public function new (colour:kha.Color){
		this.colour = colour;
		super();
	}
}