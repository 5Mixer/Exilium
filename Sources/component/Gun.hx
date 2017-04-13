package component;

enum GunType {
	SlimeGun;
	LaserGun;
	BlasterGun;
}
class Gun extends Component {
	public var gun:GunType;
	public var fireRate = 12;
}