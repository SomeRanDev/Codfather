package game.effects.text_popup;

import godot.*;
import GDScript as GD;

class PopupMaker extends Node3D {
	@:const var POPUP_SCENE: PackedScene = cast GD.preload("res://Objects/Popup.tscn");

	var popups: Array<PopupLabel> = [];

	public function popup(text: String) {
		final l: PopupLabel = cast POPUP_SCENE.instantiate();
		get_tree().get_current_scene().add_child(l);

		l.text = text;
		l.setup(global_position, global_position + new Vector3(0, 3, 0));
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
