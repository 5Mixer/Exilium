package;

import kha.System;

class Main {
	static var hxt = new hxtelemetry.HxTelemetry();
	
	public static function main() {
		System.init({title: "Dungeon Game", width: 1024, height: 768, samplesPerPixel: 4}, function () {
			
			kha.Scheduler.addFrameTask(hxt.advance_frame.bind(null), 0);

			kha.Assets.loadEverything(function(){
				new Project();
			});
		});
	}
}
