package game.ui.dialogue;

import game.ui.dialogue.DialogueBox;

import godot.*;
import GDScript as GD;

class DialogueBoxManager extends Node {
	@:const var DIALOGUE_BOX_SCENE: PackedScene = GD.preload("res://Objects/UI/DialogueBox/DialogueBox.tscn");

	@:export var screen_container: FullScreenPanelContainer;

	var dialogue_box: DialogueBox;

	var texts: Array<String> = [];

	public function add_text(text: String) {
		if(dialogue_box == null) {
			make_dialogue_box(text);
		} else {
			texts.push(text);
		}
	}

	function make_dialogue_box(text: String) {
		dialogue_box = cast DIALOGUE_BOX_SCENE.instantiate();
		screen_container.add_child(dialogue_box);
		dialogue_box.set_text(text);
	}

	function destroy_dialogue_box() {
		screen_container.remove_child(dialogue_box);
		dialogue_box.queue_free();
		dialogue_box = null;
	}

	public function update(delta: Float) {
		if(dialogue_box != null) {
			dialogue_box.update(delta);
			if(Input.is_action_just_pressed("ok")) {
				if(!dialogue_box.snap_to_end()) {
					if(texts.length > 0) {
						dialogue_box.set_text(texts.splice(0, 1)[0]);
					} else {
						destroy_dialogue_box();
					}
				}
			}
			return true;
		}

		return false;
	}
}
