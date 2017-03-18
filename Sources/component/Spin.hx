package component;

class Spin extends Component {
	public var speed = 1.0;
	public var active = true;
	public function new (speed = 1.0){
		this.speed = speed;
		super();
	}
}