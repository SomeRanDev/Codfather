package game.ui.dialogue;

import godot.*;

class DialogueBox extends GridContainer {
	@:onready var text: Label = untyped __gdscript__("$DialogueBox/Margin/VBoxContainer/Text");
	@:onready var arrow: TextureRect = untyped __gdscript__("$DialogueBox/Margin/VBoxContainer/ContinueArrow");

	var character_time: Float = 0.0;

	public function set_text(t: String) {
		text.text = t;
		text.visible_characters = 0;
		arrow.visible = false;
	}

	public function update(delta: Float) {
		if(text.visible_characters >= text.text.length) {
			arrow.visible = true;
			return true;
		}

		arrow.visible = false;

		character_time += delta * 20.0;
		if(character_time >= 1.0) {
			character_time = 0.0;

			if(text.visible_characters < text.text.length) {
				text.visible_characters += 1;

				return text.visible_characters >= text.text.length;
			}
		}
		return false;
	}

	public function snap_to_end(): Bool {
		if(text.visible_characters >= text.text.length) {
			return false;
		}

		text.visible_characters = text.text.length;
		return true;
	}
}
