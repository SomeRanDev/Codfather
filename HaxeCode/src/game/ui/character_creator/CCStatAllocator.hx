package game.ui.character_creator;

import game.AudioPlayer.MyAudioPlayer;
import godot.*;

class CCStatAllocator extends CCEntry {
	@:export var manager: CCStatManager;
	@:export var label: String = "";

	@:exportMultiline var description: String = "";
	@:export var description_label: Label;
	@:export var description_contents: Label;

	var entry_label: Label;
	var base_value_label: Label;
	var value_label: Label;

	var left_arrow: TextureRect;
	var right_arrow: TextureRect;

	var base_value: Int = 5;
	var value_offset: Int = 0;

	override function manual_ready() {
		super.manual_ready();

		entry_label = untyped __gdscript__("$Container/Label");
		base_value_label = untyped __gdscript__("$Container/BaseValue");
		value_label = untyped __gdscript__("$Container/Value");

		left_arrow = untyped __gdscript__("$Container/LeftArrow");
		right_arrow = untyped __gdscript__("$Container/RightArrow");

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
			if(can_subtract()) {
				value_offset--;
				if(value_offset >= 0) {
					manager.add_points(1);
				} else {
					manager.add_half_points(1);
				}
				refresh_label();
				manager.refresh_arrows();
				MyAudioPlayer.subtract_stat.play();
			}
		} else if(offset == 1) {
			if(can_add()) {
				if(value_offset < 0) {
					manager.add_half_points(-1);
				} else {
					manager.add_points(-1);
				}

				value_offset++;
				refresh_label();
				manager.refresh_arrows();
				MyAudioPlayer.add_stat.play();
			}
		}

		return false;
	}

	public function set_base_value(base_value: Int) {
		this.base_value = base_value;
		base_value_label.text = Std.string(base_value);
		value_offset = 0;
		refresh_label();
		refresh_arrows();
	}

	public function refresh_arrows() {
		left_arrow.self_modulate.a = can_subtract() ? 1.0 : 0.2;
		right_arrow.self_modulate.a = can_add() ? 1.0 : 0.2;
	}

	function can_add() {
		return (value_offset >= 0 && manager.has_points()) || (value_offset < 0 && manager.has_points_or_half_points());
	}

	function can_subtract() {
		return base_value + value_offset > 1;
	}

	function refresh_label() {
		if(value_offset == 0) {
			value_label.text = "";
		} else {
			value_label.text = "(" + (value_offset > 0 ? "+" : "") + Std.string(value_offset) + ")";
		}
	}

	public function get_final_value() {
		return base_value + value_offset;
	}
}
