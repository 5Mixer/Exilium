package component;

enum EntityModifier {
	Speed;
	Defence;
	FireRate;
}

typedef TimeLeft = Float;

class PotionAffected extends Component {
	public var effects = new Map<EntityModifier,TimeLeft>();
}