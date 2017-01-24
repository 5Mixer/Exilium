package;

import kha.System;

class Main {
    //#if sys static var hxt = new hxtelemetry.HxTelemetry(); #end
	public static function main() {
		System.init(cast {title: "Dungeon Game", width: 800, height: 600, samplesPerPixel: 4, windowedModeOptions: cast { maximizable: true, resizable:true}}, function () {
		
			#if sys 
			//	kha.Scheduler.addFrameTask(hxt.advance_frame.bind(null), 0);
			#end

			kha.Assets.loadEverything(function(){
				new Project();
			});
		});
	}
}
