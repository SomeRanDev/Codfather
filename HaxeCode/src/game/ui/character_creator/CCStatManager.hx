package game.ui.character_creator;

import godot.Label;
import godot.Node;

class CCStatManager extends Node {
	@:export public var stat_points(default, null): Int = 10;
	@:export var stat_point_label: Label;

	var current_stat_points: Int;
	var half_point: Bool = false;

	override function _ready() {
		current_stat_points = stat_points;
	}

	public function has_points() {
		return current_stat_points > 0;
	}

	public function has_points_or_half_points() {
		return has_points() || half_point;
	}

	public function at_max_points(): Bool {
		return current_stat_points >= stat_points;
	}

	public function add_points(amount: Int) {
		current_stat_points += amount;
		refresh_label();
	}

	public function add_half_points(amount: Int) {
		if(half_point && amount == 1) {
			half_point = false;
			add_points(1);
		} else if(!half_point && amount == 1) {
			half_point = true;
			refresh_label();
		} else if(half_point && amount == -1) {
			half_point = false;
			refresh_label();
		} else if(!half_point && amount == -1) {
			half_point = true;
			add_points(-1);
		}
	}

	function refresh_label() {
		final half_char = "½";
		stat_point_label.text = Std.string(current_stat_points) + (half_point ? half_char : "");
	}
}