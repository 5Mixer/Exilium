package ;

typedef ChannelData = {
	var volume:Float; 
}
typedef SoundData = {
	var file:String;
	var volume:Float;
	var pan:Float;
}

typedef AudioData = {
	var channels:Map<String,ChannelData>;
	var sounds:Map<String,SoundData>;
}

class AudioManager {
	var data:AudioData;
	public static var sounds = new Map<String,SoundData>();
	public static var soundFiles = new Map<String,kha.Sound>();
	public function new (){
		throw "Audio Manager isn't too be instanced; use it through it's static methods.";
	}
	public static function init(){
		soundFiles = [
			"ui/click.wav" => kha.Assets.sounds.button_click,
			"gun/blaster.wav" => kha.Assets.sounds.shoot2,
			"gun/laser.wav" => kha.Assets.sounds.shoot1,
			"entity/bat/squeak.wav" => kha.Assets.sounds.Bat
		];
		sounds = [
			"UI_CLICK" => {
				file:"ui/click.wav",
				volume:1,
				pan:50
			},
			"BLASTER_SHOOT" => {
				file:"gun/blaster.wav",
				volume:1,
				pan:50
			},
			"LASER_SHOOT" => {
				file:"gun/laser.wav",
				volume:1,
				pan:50
			},
			"BAT_SQUEAK" => {
				file:"entity/bat/squeak.wav",
				volume:1,
				pan:50
			}
		];
	}
	public static function play(sound:String){
		var soundData = sounds.get(sound);
		var channel = kha.audio1.Audio.play(soundFiles.get(soundData.file));
		if (channel == null){
			trace("Sound overflow related bug!");
			return false;
		}
		channel.volume = soundData.volume/50;
		// var channel2 = kha.audio2.Audio.stream(kha.Assets.sounds.shoot1).
		return true;
	}
}