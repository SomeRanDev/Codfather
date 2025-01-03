package game.effects.text_popup;

import godot.*;
import GDScript as GD;

class PopupMaker extends Node3D {
	@:const var POPUP_SCENE: PackedScene = cast GD.preload("res://Objects/Popup.tscn");

	var popups: Array<PopupLabel> = [];

	public function popup(text: String) {
		final l: PopupLabel = cast POPUP_SCENE.instantiate();
		get_tree().get_current_scene().add_child(l);

		for(p in popups) {
			p.shift_up();
		}

		l.text = text;
		l.setup(global_position, global_position + new Vector3(0, 2, 0));
		popups.push(l);
		return l;
	}

	public function popup_green(text: String) {
		final l = popup(text);
		l.make_green();
	}

	public function update(delta: Float) {
		var i = 0;
		while(i < popups.length) {
			if(popups[i].update(delta)) {
				final p = popups[i];
				get_tree().get_current_scene().remove_child(p);
				popups.remove_at(i);
				p.queue_free();
				continue;
			}
			i++;
		}
	}

	public function detatch_and_delete_when_possible() {
		if(popups.length == 0) {
			return;
		}

		final parent = get_parent();
		final current_scene = get_tree().get_current_scene();
		final old_global_position = global_position;
		parent.remove_child(this);
		current_scene.add_child(this);
		global_position = old_global_position;

		set_process_mode(PROCESS_MODE_INHERIT);
	}

	override function _ready() {
		set_process_mode(PROCESS_MODE_DISABLED);
	}

	override function _process(delta: Float) {
		update(delta);

		if(popups.length == 0) {
			queue_free();
		}
	}
}
