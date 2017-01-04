package;

import kha.System;

class Main {
    #if sys static var hxt = new hxtelemetry.HxTelemetry(); #end
	public static function main() {
		System.init({title: "Dungeon Game", width: 1024, height: 768, samplesPerPixel: 4}, function () {
			#if sys 
				kha.Scheduler.addFrameTask(hxt.advance_frame.bind(null), 0);
			#end
			kha.Assets.loadEverything(function(){
				new Project();
			});
		});
	}
}
