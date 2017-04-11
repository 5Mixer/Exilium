package component;

class CactusBoss extends Component {
	public var size:{width:Int,height:Int} = {width: 4, height: 4};
	public var room:worldgen.DungeonWorldGenerator.Room;
	public var tick = 0;
	public function new (room:worldgen.DungeonWorldGenerator.Room){
		this.room = room;
		super();
	}
}