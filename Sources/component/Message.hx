package component;

class Message extends Component {
	public var name:String;
	public var message:String;
	public var shown = false;
	public function new (name:String,message:String){
		this.name = name;
		this.message = message;
		super();
	}
}