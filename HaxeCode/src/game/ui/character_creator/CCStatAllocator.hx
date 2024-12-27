package game.ui.character_creator;

import godot.*;

class CCStatAllocator extends CCEntry {
	@:export var manager: CCStatManager;
	@:export var label: String = "";

	@:exportMultiline var description: String = "";
	@:export var description_label: Label;
	@:export var description_contents: Label;

	var entry_label: Label;
	var value_label: Label;

	var base_value: Int = 5;
	var value_offset: Int = 0;

	override function manual_ready() {
		super.manual_ready();

		entry_label = untyped __gdscript__("$Container/Label");
		value_label = untyped __gdscript__("$Container/Value");

		entry_label.text = label;
	}

	override function on_selected() {
		description_label.text = label;
		description_contents.text = description;
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
			if(base_value + value_offset > 0) {
				value_offset--;
				if(value_offset >= 0) {
					manager.add_points(1);
				} else {
					manager.add_half_points(1);
				}
				refresh_label();
			}
		} else if(offset == 1) {
			if((value_offset >= 0 && manager.has_points()) || (value_offset < 0 && manager.has_points_or_half_points())) {
				if(value_offset < 0) {
					manager.add_half_points(-1);
				} else {
					manager.add_points(-1);
				}

				value_offset++;
				refresh_label();
			}
		}

		return false;
	}

	function refresh_label() {
		if(value_offset == 0) {
			value_label.text = "";
		} else {
			value_label.text = "(" + (value_offset > 0 ? "+" : "") + Std.string(value_offset) + ")";
		}
	}
}
