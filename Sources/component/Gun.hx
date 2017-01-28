package component;

enum GunType {
	SlimeGun;
}
class Gun extends Component {
	public var gun:GunType;
	public var fireRate = 7;
}