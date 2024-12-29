package game.ui.character_creator;

import game.AudioPlayer.MyAudioPlayer;
import godot.*;

class CCOption extends CCEntry {
	@:export var label: String = "";
	@:export var choices: Array<String> = [];
	@:export var descriptions: Array<String> = [];
	@:export var description_label: Label;
	@:export var description_contents: Label;

	@:signal function on_choice_changed(index: Int) {}
	@:native("on_choice_changed") extern var on_choice_changed_signal: Signal;

	var entry_label: Label;
	var value_label: Label;

	var selected_index: Int = 0;

	override function manual_ready() {
		super.manual_ready();

		entry_label = untyped __gdscript__("$Container/Container/Label");
		value_label = untyped __gdscript__("$Container/Container/ValueLabel");

		entry_label.text = label;
		refresh_choice();
	}

	override function on_selected() {
		refresh_description();
	}

	public override function update(): Bool {
		var offset = 0;
		if(Input.is_action_just_pressed("left")) {
			offset--;
		}
		if(Input.is_action_just_pressed("right")) {
			offset++;
		}

		if(offset == -1) {
			set_index(selected_index == 0 ? choices.length - 1 : selected_index - 1);
			MyAudioPlayer.selection_change.play();
		} else if(offset == 1) {
			set_index(selected_index == choices.length - 1 ? 0 : selected_index + 1);
			MyAudioPlayer.selection_change.play();
		}

		return false;
	}

	public function get_selected_index(): Int {
		return selected_index;
	}

	function set_index(index: Int) {
		if(selected_index != index) {
			selected_index = index;
			untyped __gdscript__("emit_signal(\"on_choice_changed\", {0})", index);
			refresh_choice();
		}
	}

	function refresh_choice() {
		value_label.text = choices[selected_index];
		refresh_description();
	}

	function refresh_description() {
		description_label.text = label + ": " + choices[selected_index];
		description_contents.text = descriptions[selected_index];
	}
}
