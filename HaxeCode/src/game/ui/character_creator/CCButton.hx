package game.ui.character_creator;

import godot.*;

class CCButton extends CCEntry {
	@:export var description_label: Label;
	@:export var description_contents: Label;

	public override function update(): Bool {
		if(Input.is_action_just_pressed("start")) {
			return true;
		}
		return false;
	}

	override function on_selected() {
		description_label.text = "Start game!";
		description_contents.text = "Press ENTER or A to begin!";
	}
}
