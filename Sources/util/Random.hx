package util;

class Random {
	var seed:Float;
	public function new (?seed:Float){
		this.seed = seed;
		if (seed == null){
			seed = Math.floor(Math.random()*999999);
		}
	}
	public function generate(){
		seed = (seed*9301+49297) % 233280;
		seed = Math.abs(seed);
		return (seed / 233280.0);
	}
}