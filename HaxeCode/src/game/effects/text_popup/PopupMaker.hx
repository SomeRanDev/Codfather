package game.effects.text_popup;

import godot.*;
import GDScript as GD;

class PopupMaker extends Node3D {
	var popups: Array<PopupLabel> = [];

	var popup_scene: Null<PackedScene> = null;

	public function popup(text: String) {
		if(popup_scene == null) {
			popup_scene = cast GD.load("res://Objects/Popup.tscn");
		}
		final l: PopupLabel = cast popup_scene.instantiate();
		get_tree().get_current_scene().add_child(l);

		l.text = text;
		l.setup(global_position, global_position + new Vector3(0, 2, 0));
		popups.push(l);
	}

	public function update(delta: Float) {
		var i = 0;
		while(i < popups.length) {
			if(popups[i].update(delta)) {
				get_tree().get_current_scene().remove_child(popups[i]);
				popups.remove_at(i);
				continue;
			}
			i++;
		}
	}
}
