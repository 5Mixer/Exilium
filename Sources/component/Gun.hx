package component;

enum GunType {
	SlimeGun;
	LaserGun;
}
class Gun extends Component {
	public var gun:GunType;
	public var fireRate = 12;
}