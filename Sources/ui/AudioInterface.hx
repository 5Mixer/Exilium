package ui;

import zui.Zui;
import zui.Id;

class AudioInterface {
	var ui:Zui;
	public var visible = true;

	var audioBrowseWindow = {
		shown : false,
		currentOption : '',
		forSoundEvent : ''
	};

	public function new (zuiInstance:Zui) {
		ui = zuiInstance;
	}
	public function render(g:kha.graphics2.Graphics) {
		
		if (!visible) return;

		if (audioBrowseWindow.shown){
			if (ui.window(Id.handle(), 300, 10, 200, 600,true)) {
				ui.text("Browse for sound.");
				for (avaliableSound in AudioManager.soundFiles.keys()){
					ui.indent();
					if (ui.button(avaliableSound)){
						AudioManager.sounds.get(audioBrowseWindow.forSoundEvent).file = avaliableSound;
					}
					ui.unindent();
				}
				if (ui.button("Done")){
					audioBrowseWindow.shown = false;
				}
			}
		}
		
		if (ui.window(Id.handle(), 80, 10, 200, 600,true)) {
			ui.text("Sounds");
			ui.indent();
			var i = 0;
			for (soundEvent in AudioManager.sounds.keys()){
				i++;
				var value = AudioManager.sounds.get(soundEvent);
				if (ui.panel(Id.handle().nest(i), soundEvent)) {
					ui.indent();
					ui.text("File: "+value.file);
					if (ui.button("Browse")){
						audioBrowseWindow.shown = true;
						audioBrowseWindow.currentOption = value.file;
						audioBrowseWindow.forSoundEvent = soundEvent;
						
					}
					value.volume = ui.slider(Id.handle().nest(i), "Volume", 0, 100, true, 1, true);
					// value.pan = ui.slider(Id.handle().nest(i), "Pan", -100, 100, true, 1, true);
					ui.unindent();
				}
			}
			ui.unindent();
		}

	}
}