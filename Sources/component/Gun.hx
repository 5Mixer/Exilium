package component;

enum GunType {
	SlimeGun;
	LaserGun;
	BlasterGun;
	Bow;
}
class Gun extends Component {
	public var gun:GunType;
	public var fireRate = 12.;
	public var charge = 0.0;
	public var timeFromLastFire = 0.0;
}